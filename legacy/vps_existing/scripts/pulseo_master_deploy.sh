#!/bin/bash
# ============================================================
# PULSEO MASTER DEPLOY v3.0 — Auto-correcteur
# Ubuntu 24.04 | ubuntu@51.38.39.106
# Remplace tous les scripts précédents obsolètes
# ============================================================

LOG="$HOME/pulseo_deploy.log"
exec > >(tee -a "$LOG") 2>&1

G='\033[0;32m'; R='\033[0;31m'; Y='\033[1;33m'; B='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${G}[OK]${NC} $1"; }
fail() { echo -e "${R}[FAIL]${NC} $1"; }
info() { echo -e "${B}[->]${NC} $1"; }
warn() { echo -e "${Y}[!!]${NC} $1"; }

banner() {
    echo ""
    echo -e "${B}==================================================${NC}"
    echo -e "${B}  $1${NC}"
    echo -e "${B}==================================================${NC}"
}

# ─── Auto-correction : installe ce qui manque ───────────────
install_pkg() {
    local pkg="$1"
    if ! dpkg -l "$pkg" &>/dev/null; then
        info "Installation $pkg..."
        sudo apt-get install -y -qq "$pkg" && ok "$pkg installé" || fail "$pkg échec"
    else
        ok "$pkg déjà présent"
    fi
}

install_py() {
    local pkg="$1"
    if ! python3 -c "import ${2:-$1}" &>/dev/null; then
        info "Installation Python $pkg..."
        sudo apt-get install -y -qq "python3-$pkg" 2>/dev/null || \
        python3 -m pip install "$pkg" --break-system-packages -q 2>/dev/null
        python3 -c "import ${2:-$1}" && ok "Python $pkg OK" || fail "Python $pkg ECHEC"
    else
        ok "Python $pkg déjà présent"
    fi
}

# ─── AUDIT COMPLET ──────────────────────────────────────────
banner "AUDIT VPS"

info "OS : $(lsb_release -d | cut -f2)"
info "RAM : $(free -h | grep Mem | awk '{print $2}') total, $(free -h | grep Mem | awk '{print $7}') dispo"
info "CPU : $(nproc) cores"
info "Disk: $(df -h / | tail -1 | awk '{print $4}') libre"

# ─── DÉPENDANCES SYSTÈME ────────────────────────────────────
banner "DÉPENDANCES"

install_pkg python3
install_pkg python3-pip
install_pkg python3-uvicorn
install_pkg python3-fastapi

# httpx — critique pour les requêtes async
install_py httpx

# Pip comme fallback
if ! python3 -m pip --version &>/dev/null; then
    sudo apt-get install -y -qq python3-pip
fi

# Install via pip si apt n'a pas tout
python3 -m pip install httpx uvicorn fastapi --break-system-packages -q 2>/dev/null || true

# Vérification finale
python3 -c "import fastapi, uvicorn, httpx" && ok "Stack Python complète" || {
    fail "Stack Python incomplète — tentative pip forcée"
    python3 -m pip install fastapi uvicorn httpx --break-system-packages
}

# ─── OLLAMA ─────────────────────────────────────────────────
banner "OLLAMA"

if ! command -v ollama &>/dev/null; then
    info "Installation Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
fi

# Démarrer Ollama
if ! pgrep -x ollama &>/dev/null; then
    info "Démarrage Ollama en arrière-plan..."
    nohup ollama serve > /home/ubuntu/ollama.log 2>&1 &
    sleep 5
fi

# Vérifier modèle
if ollama list 2>/dev/null | grep -q "qwen3:14b"; then
    ok "qwen3:14b disponible"
else
    warn "qwen3:14b absent — pull en cours (~9GB)..."
    ollama pull qwen3:14b
fi

# Test Ollama
RESP=$(curl -s --max-time 30 http://localhost:11434/api/generate \
    -d '{"model":"qwen3:14b","prompt":"OK?","stream":false}' \
    | python3 -c "import sys,json; print(json.load(sys.stdin).get('response','?'))" 2>/dev/null)
[ -n "$RESP" ] && ok "Ollama répond : $RESP" || fail "Ollama ne répond pas"

# ─── SERVEUR PULSEO CHAT ────────────────────────────────────
banner "SERVEUR PULSEO CHAT"

mkdir -p /home/ubuntu/pulseo_chat

# Arrêter l'ancienne instance
pkill -f "uvicorn server" 2>/dev/null
pkill -f "pulseo_chat" 2>/dev/null
sleep 2

# Créer server.py
cat > /home/ubuntu/pulseo_chat/server.py << 'PYEOF'
from fastapi import FastAPI
from fastapi.responses import HTMLResponse, StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import httpx, json

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

class Message(BaseModel):
    message: str
    history: list = []

@app.get("/", response_class=HTMLResponse)
async def index():
    with open("/home/ubuntu/pulseo_chat/index.html", encoding="utf-8") as f:
        return f.read()

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.post("/chat")
async def chat(msg: Message):
    history = msg.history[-10:]
    prompt = "\n".join([f"{m['role']}: {m['content']}" for m in history])
    if prompt:
        prompt += f"\nuser: {msg.message}\nassistant:"
    else:
        prompt = msg.message

    async def stream():
        async with httpx.AsyncClient(timeout=120) as client:
            async with client.stream(
                "POST", "http://localhost:11434/api/generate",
                json={"model": "qwen3:14b", "prompt": prompt, "stream": True}
            ) as r:
                async for line in r.aiter_lines():
                    if line:
                        try:
                            data = json.loads(line)
                            if token := data.get("response", ""):
                                yield token
                        except Exception:
                            pass

    return StreamingResponse(stream(), media_type="text/plain; charset=utf-8")
PYEOF

ok "server.py créé"

# Créer index.html
cat > /home/ubuntu/pulseo_chat/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<meta name="theme-color" content="#080810">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-capable" content="yes">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;700;800&family=DM+Mono&display=swap" rel="stylesheet">
<title>PULSEO</title>
<style>
:root {
  --bg: #080810;
  --surf: #10101c;
  --brd: #1c1c30;
  --acc: #6c5fff;
  --acc2: #ff5f9e;
  --txt: #ddddf0;
  --mut: #44445a;
}
* { margin:0; padding:0; box-sizing:border-box; -webkit-tap-highlight-color:transparent; }
html,body { height:100%; overflow:hidden; }
body {
  background:var(--bg);
  color:var(--txt);
  font-family:'DM Mono',monospace;
  display:flex;
  flex-direction:column;
  height:100dvh;
}
header {
  display:flex;
  align-items:center;
  padding:14px 18px;
  border-bottom:1px solid var(--brd);
  gap:10px;
  flex-shrink:0;
}
.logo {
  font-family:'Syne',sans-serif;
  font-weight:800;
  font-size:17px;
  letter-spacing:.12em;
  background:linear-gradient(120deg,var(--acc),var(--acc2));
  -webkit-background-clip:text;
  -webkit-text-fill-color:transparent;
}
.pill {
  margin-left:auto;
  background:var(--surf);
  border:1px solid var(--brd);
  border-radius:20px;
  padding:4px 10px;
  font-size:10px;
  color:var(--mut);
  display:flex;
  align-items:center;
  gap:5px;
}
.dot {
  width:5px;height:5px;
  border-radius:50%;
  background:#4ade80;
  animation:blink 2s infinite;
}
@keyframes blink { 0%,100%{opacity:1} 50%{opacity:.2} }
#msgs {
  flex:1;
  overflow-y:auto;
  padding:16px;
  display:flex;
  flex-direction:column;
  gap:18px;
  scroll-behavior:smooth;
}
#msgs::-webkit-scrollbar { width:2px; }
#msgs::-webkit-scrollbar-thumb { background:var(--brd); }
.bubble {
  max-width:86%;
  padding:11px 15px;
  border-radius:16px;
  font-size:13px;
  line-height:1.65;
  animation:up .25s ease;
  white-space:pre-wrap;
  word-break:break-word;
}
@keyframes up { from{opacity:0;transform:translateY(6px)} to{opacity:1;transform:none} }
.bubble.u {
  background:var(--surf);
  border:1px solid var(--acc);
  border-bottom-right-radius:3px;
  align-self:flex-end;
}
.bubble.a {
  background:var(--surf);
  border:1px solid var(--brd);
  border-bottom-left-radius:3px;
  align-self:flex-start;
  position:relative;
}
.bubble.a::before {
  content:'PULSEO';
  position:absolute;
  top:-16px; left:0;
  font-size:8px;
  letter-spacing:.2em;
  color:var(--acc);
  font-family:'Syne',sans-serif;
  font-weight:700;
}
.welcome {
  text-align:center;
  padding:30px 10px;
  color:var(--mut);
  font-size:12px;
  line-height:1.9;
}
.welcome h2 {
  font-family:'Syne',sans-serif;
  font-weight:800;
  font-size:20px;
  margin-bottom:6px;
  background:linear-gradient(120deg,var(--acc),var(--acc2));
  -webkit-background-clip:text;
  -webkit-text-fill-color:transparent;
}
.chips {
  display:flex;
  flex-wrap:wrap;
  gap:7px;
  justify-content:center;
  margin-top:16px;
}
.chip {
  background:var(--surf);
  border:1px solid var(--brd);
  border-radius:18px;
  padding:7px 13px;
  font-size:11px;
  color:var(--mut);
  cursor:pointer;
}
.chip:active { border-color:var(--acc); color:var(--acc); }
.typing {
  display:flex;
  gap:4px;
  padding:12px 15px;
  align-self:flex-start;
}
.typing span {
  width:5px;height:5px;
  border-radius:50%;
  background:var(--acc);
  animation:bounce 1.1s infinite;
}
.typing span:nth-child(2){animation-delay:.18s}
.typing span:nth-child(3){animation-delay:.36s}
@keyframes bounce{0%,100%{transform:translateY(0);opacity:.3}50%{transform:translateY(-5px);opacity:1}}
footer {
  display:flex;
  gap:8px;
  padding:10px 14px 18px;
  border-top:1px solid var(--brd);
  align-items:flex-end;
  flex-shrink:0;
}
#inp {
  flex:1;
  background:var(--surf);
  border:1px solid var(--brd);
  border-radius:13px;
  padding:11px 14px;
  color:var(--txt);
  font-family:'DM Mono',monospace;
  font-size:13px;
  resize:none;
  outline:none;
  min-height:42px;
  max-height:110px;
  line-height:1.5;
  transition:border-color .2s;
}
#inp:focus{border-color:var(--acc)}
#inp::placeholder{color:var(--mut)}
#btn {
  width:42px;height:42px;
  border-radius:11px;
  background:linear-gradient(135deg,var(--acc),var(--acc2));
  border:none;
  cursor:pointer;
  display:flex;
  align-items:center;
  justify-content:center;
  flex-shrink:0;
  transition:transform .15s;
}
#btn:active{transform:scale(.9)}
#btn:disabled{opacity:.4}
#btn svg{width:17px;height:17px;fill:white}
</style>
</head>
<body>
<header>
  <div class="logo">PULSEO</div>
  <div class="pill"><div class="dot"></div>qwen3:14b</div>
</header>
<div id="msgs">
  <div class="welcome" id="w">
    <h2>Bonjour Rémi</h2>
    <p>Ollama actif sur VPS.<br>Ton cerveau distant est prêt.</p>
    <div class="chips">
      <div class="chip" onclick="use(this)">Analyse mon VPS</div>
      <div class="chip" onclick="use(this)">Idée PULSEO</div>
      <div class="chip" onclick="use(this)">Code Python</div>
      <div class="chip" onclick="use(this)">Optimise mon téléphone</div>
    </div>
  </div>
</div>
<footer>
  <textarea id="inp" placeholder="Message…" rows="1"
    onkeydown="if(event.key==='Enter'&&!event.shiftKey){event.preventDefault();go()}"
    oninput="this.style.height='auto';this.style.height=Math.min(this.scrollHeight,110)+'px'"></textarea>
  <button id="btn" onclick="go()">
    <svg viewBox="0 0 24 24"><path d="M2 21l21-9L2 3v7l15 2-15 2z"/></svg>
  </button>
</footer>
<script>
const M=document.getElementById('msgs');
const I=document.getElementById('inp');
const B=document.getElementById('btn');
let H=[];

function use(el){I.value=el.textContent;go()}

function add(role,txt){
  const d=document.createElement('div');
  d.className='bubble '+role;
  d.textContent=txt;
  M.appendChild(d);
  M.scrollTop=M.scrollHeight;
  return d;
}

function loader(){
  const d=document.createElement('div');
  d.className='typing';
  d.innerHTML='<span></span><span></span><span></span>';
  M.appendChild(d);
  M.scrollTop=M.scrollHeight;
  return d;
}

async function go(){
  const t=I.value.trim();
  if(!t||B.disabled)return;
  document.getElementById('w')?.remove();
  add('u',t);
  H.push({role:'user',content:t});
  I.value='';I.style.height='auto';
  B.disabled=true;
  const l=loader();
  try{
    const r=await fetch('/chat',{
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body:JSON.stringify({message:t,history:H.slice(-10)})
    });
    l.remove();
    const d=add('a','');
    const rd=r.body.getReader();
    const dc=new TextDecoder();
    let full='';
    while(true){
      const{done,value}=await rd.read();
      if(done)break;
      full+=dc.decode(value);
      d.textContent=full;
      M.scrollTop=M.scrollHeight;
    }
    H.push({role:'assistant',content:full});
  }catch(e){
    l.remove();
    add('a','⚠️ VPS inaccessible. Vérifie ta connexion.');
  }
  B.disabled=false;
  I.focus();
}
</script>
</body>
</html>
HTMLEOF

ok "index.html créé"

# ─── LANCEMENT ──────────────────────────────────────────────
banner "LANCEMENT SERVEUR"

cd /home/ubuntu/pulseo_chat

# Test syntaxe Python
python3 -c "
import ast, sys
with open('server.py') as f:
    src = f.read()
try:
    ast.parse(src)
    print('Syntaxe Python OK')
except SyntaxError as e:
    print(f'ERREUR SYNTAXE: {e}')
    sys.exit(1)
"

# Lancement
nohup python3 -m uvicorn server:app --host 0.0.0.0 --port 7860 \
    > /home/ubuntu/pulseo_chat/server.log 2>&1 &
echo $! > /home/ubuntu/pulseo_chat/server.pid
sleep 4

# Vérification auto-corrective
TRIES=0
while [ $TRIES -lt 3 ]; do
    STATUS=$(curl -s --max-time 5 http://localhost:7860/health 2>/dev/null)
    if echo "$STATUS" | grep -q "ok"; then
        ok "Serveur PULSEO Chat actif sur port 7860"
        break
    fi
    TRIES=$((TRIES+1))
    warn "Tentative $TRIES/3 — log : $(tail -3 /home/ubuntu/pulseo_chat/server.log)"
    sleep 3
done

if [ $TRIES -eq 3 ]; then
    fail "Serveur ne démarre pas. Log complet :"
    cat /home/ubuntu/pulseo_chat/server.log
    exit 1
fi

# ─── NGINX CONFIG ───────────────────────────────────────────
banner "NGINX"

if command -v nginx &>/dev/null; then
    sudo tee /etc/nginx/sites-available/pulseo > /dev/null << 'NGX'
server {
    listen 80;
    server_name pulseo.me www.pulseo.me _;

    location /chat {
        proxy_pass http://127.0.0.1:7860;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_buffering off;
        proxy_cache off;
        proxy_read_timeout 120s;
    }

    location /veopulse {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
    }

    location / {
        proxy_pass http://127.0.0.1:7860;
        proxy_buffering off;
        proxy_cache off;
    }
}
NGX
    sudo ln -sf /etc/nginx/sites-available/pulseo /etc/nginx/sites-enabled/pulseo
    sudo rm -f /etc/nginx/sites-enabled/default
    sudo nginx -t && sudo systemctl reload nginx && ok "Nginx configuré"
else
    warn "Nginx absent — accès direct via port 7860"
fi

# ─── BILAN FINAL ────────────────────────────────────────────
banner "BILAN"

echo ""
echo "Chat accessible sur :"
echo "  http://51.38.39.106:7860"
echo "  http://51.38.39.106/chat (si Nginx OK)"
echo ""
echo "Stack active :"
python3 --version
ollama list
echo ""
echo "PID serveur : $(cat /home/ubuntu/pulseo_chat/server.pid 2>/dev/null)"
echo "Log : /home/ubuntu/pulseo_chat/server.log"
echo ""
ok "PULSEO CHAT DEPLOYE"
