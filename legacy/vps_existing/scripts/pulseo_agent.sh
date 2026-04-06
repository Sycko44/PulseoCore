#!/bin/bash
# ============================================================
# PULSEO AGENT — Agent Autonome Termux v1.0
# Connexion : Termux → Téléphone (ADB WiFi) + VPS (Ollama)
# ============================================================
# Usage : bash pulseo_agent.sh
# Le script demande ce qui manque, fait tout seul le reste.
# ============================================================

PHONE_IP="192.168.86.125"
PHONE_PORT="43317"
PHONE_TARGET="${PHONE_IP}:${PHONE_PORT}"
VPS_USER="ubuntu"
VPS_IP="51.38.39.106"
OLLAMA_MODEL_AUDIT="deepseek-r1:32b"
OLLAMA_MODEL_CODE="qwen3-coder:30b"
OLLAMA_MODEL_FR="qwen3:14b"
LOG_DIR="$HOME/pulseo_logs"
LOG="$LOG_DIR/agent_$(date +%Y%m%d_%H%M%S).log"
STATE_FILE="$HOME/.pulseo_state"
MAX_RETRIES=3
LOOP_INTERVAL=300  # 5 min entre chaque cycle

mkdir -p "$LOG_DIR"

# ─── Couleurs ───────────────────────────────────────────────
G='\033[0;32m'; R='\033[0;31m'; Y='\033[1;33m'
B='\033[0;34m'; P='\033[0;35m'; NC='\033[0m'

ok()     { echo -e "${G}[OK]${NC} $1" | tee -a "$LOG"; }
fail()   { echo -e "${R}[FAIL]${NC} $1" | tee -a "$LOG"; }
info()   { echo -e "${B}[->]${NC} $1" | tee -a "$LOG"; }
warn()   { echo -e "${Y}[!!]${NC} $1" | tee -a "$LOG"; }
ai()     { echo -e "${P}[AI]${NC} $1" | tee -a "$LOG"; }
banner() {
    echo "" | tee -a "$LOG"
    echo -e "${B}==================================================${NC}" | tee -a "$LOG"
    echo -e "${B}  $1${NC}" | tee -a "$LOG"
    echo -e "${B}==================================================${NC}" | tee -a "$LOG"
}

# ─── Setup SSH sans mot de passe (première fois) ────────────
setup_ssh() {
    if ! ssh -o BatchMode=yes -o ConnectTimeout=3 \
        "${VPS_USER}@${VPS_IP}" "echo ok" &>/dev/null; then
        warn "Pas de clé SSH vers le VPS. Configuration..."
        if [ ! -f ~/.ssh/id_rsa ]; then
            ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -q
            ok "Clé SSH générée"
        fi
        echo ""
        echo "Entre le mot de passe du VPS pour copier la clé SSH (une seule fois) :"
        ssh-copy-id -o StrictHostKeyChecking=no "${VPS_USER}@${VPS_IP}"
        ok "Clé SSH copiée — plus de mot de passe requis"
    else
        ok "SSH vers VPS déjà configuré"
    fi
}

# ─── Ollama via VPS ─────────────────────────────────────────
ollama_ask() {
    local model="$1"
    local prompt="$2"
    ssh -o ConnectTimeout=10 "${VPS_USER}@${VPS_IP}" \
        "curl -s http://localhost:11434/api/generate \
        -d '{\"model\":\"$model\",\"prompt\":\"$(echo "$prompt" | sed "s/'/\\\'/g")\",\"stream\":false}' \
        | python3 -c \"import sys,json; print(json.load(sys.stdin).get('response','?'))\"" 2>/dev/null
}

# ─── Connexion ADB avec auto-retry ──────────────────────────
connect_adb() {
    local attempt=0
    while [ $attempt -lt $MAX_RETRIES ]; do
        attempt=$((attempt + 1))
        info "Tentative ADB $attempt/$MAX_RETRIES → $PHONE_TARGET"

        # Tente connexion directe
        RESULT=$(adb connect "$PHONE_TARGET" 2>&1)
        if echo "$RESULT" | grep -q "connected"; then
            ok "ADB connecté : $PHONE_TARGET"
            return 0
        fi

        # Auto-correction : kill daemon et retry
        warn "Échec : $RESULT — Reset daemon ADB..."
        adb kill-server 2>/dev/null
        sleep 2
        adb start-server 2>/dev/null
        sleep 2
    done

    fail "Impossible de connecter ADB après $MAX_RETRIES tentatives"
    fail "Vérifie que le débogage sans fil est actif sur le téléphone"
    return 1
}

# ─── Audit du téléphone ─────────────────────────────────────
audit_phone() {
    info "Collecte état téléphone..."
    PHONE_DATA=$(adb -s "$PHONE_TARGET" shell "
        echo '=DEVICE=' && getprop ro.product.model && getprop ro.build.version.release
        echo '=RAM=' && free -h
        echo '=STOCKAGE=' && df /data | tail -1
        echo '=BATTERIE=' && dumpsys battery | grep -E 'level|status|health'
        echo '=NFC=' && settings get global nfc_on
        echo '=ANIMATIONS=' && settings get global window_animation_scale
        echo '=MIUI_ACTIF=' && pm list packages -e 2>/dev/null | grep -E 'miui|xiaomi' | head -20
        echo '=MIUI_DESACTIVE=' && pm list packages -d 2>/dev/null | grep -E 'miui|xiaomi' | head -20
        echo '=CPU=' && top -n 1 -b | head -5
        echo '=PROCESSES_TOP=' && ps -A --sort=-rss | head -15
        echo '=UPTIME=' && uptime
    " 2>&1)
    echo "$PHONE_DATA" >> "$LOG"
    echo "$PHONE_DATA"
}

# ─── Simulation (dry-run) ───────────────────────────────────
simulate() {
    local audit_data="$1"
    ai "deepseek-r1:32b analyse et planifie les actions..."
    PLAN=$(ollama_ask "$OLLAMA_MODEL_AUDIT" \
        "Tu es expert Android MIUI. Analyse ces données et génère un plan d'action en JSON STRICT: {\"score_avant\":0-100,\"problemes\":[{\"id\":\"P1\",\"desc\":\"...\",\"gravite\":\"haute/moyenne/faible\"}],\"actions\":[{\"id\":\"A1\",\"cmd\":\"adb shell ...\",\"description\":\"...\",\"risque\":\"nul/faible/moyen\",\"gain_estime\":\"...\"}],\"ordre_execution\":[\"A1\",\"A2\"]}. NFC est desactive (com.android.nfc desactive). Données: $audit_data")

    echo "$PLAN" > "$STATE_FILE.plan"
    echo ""
    ai "PLAN GENERE PAR deepseek-r1:32b :"
    echo "$PLAN" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(f'  Score santé avant : {d.get(\"score_avant\",\"?\")}')
    print(f'  Problèmes détectés : {len(d.get(\"problemes\",[]))}')
    for p in d.get('problemes',[]): print(f'    [{p[\"gravite\"]}] {p[\"desc\"]}')
    print(f'  Actions planifiées : {len(d.get(\"actions\",[]))}')
    for a in d.get('actions',[]): print(f'    {a[\"id\"]} [{a[\"risque\"]}] {a[\"description\"]}')
except: print(sys.stdin.read())
" 2>/dev/null || echo "$PLAN"

    echo ""
    warn "SIMULATION TERMINEE — Appuie sur ENTREE pour exécuter, ou Ctrl+C pour annuler"
    read -r
    echo "$PLAN"
}

# ─── Execution avec auto-correction ─────────────────────────
execute_plan() {
    local plan="$1"

    # qwen3-coder génère le script bash final
    ai "qwen3-coder:30b génère le script d'exécution..."
    SCRIPT_CONTENT=$(ollama_ask "$OLLAMA_MODEL_CODE" \
        "Génère UNIQUEMENT un script bash exécutable. Chaque commande adb doit utiliser 'adb -s $PHONE_TARGET shell'. Inclus des echo de statut avant chaque commande. Pas d'explication, juste le code bash. Plan: $plan")

    EXEC_SCRIPT="$LOG_DIR/exec_$(date +%H%M%S).sh"
    echo "#!/bin/bash" > "$EXEC_SCRIPT"
    echo "set +e  # Continue même si une commande échoue" >> "$EXEC_SCRIPT"
    echo "$SCRIPT_CONTENT" >> "$EXEC_SCRIPT"
    chmod +x "$EXEC_SCRIPT"

    # Actions fixes toujours appliquées
    banner "EXECUTION — Corrections garanties"

    # NFC
    info "Reactivation NFC..."
    adb -s "$PHONE_TARGET" shell pm enable com.android.nfc 2>/dev/null && ok "NFC package activé" || warn "NFC package déjà actif ou absent"
    sleep 1
    adb -s "$PHONE_TARGET" shell svc nfc enable 2>/dev/null && ok "NFC activé" || warn "NFC enable échoué"

    # Debloat MIUI niveau 1
    info "Debloat MIUI..."
    BLOAT=(
        com.miui.analytics com.miui.msa.global com.miui.weather2
        com.miui.screenrecorder com.miui.compass com.miui.android.fashiongallery
        com.miui.mediaeditor com.miui.player com.miui.backup
        com.android.thememanager com.miui.miwallpaper com.miui.notes
        com.miui.cleanmaster com.miui.gallery com.miui.video
        com.miui.systemAdSolution com.miui.rom.publisher
        com.miui.global.providers.transparentagent
    )
    DISABLED=0; SKIPPED=0
    for pkg in "${BLOAT[@]}"; do
        if adb -s "$PHONE_TARGET" shell pm disable-user --user 0 "$pkg" 2>/dev/null | grep -q "disabled"; then
            ok "Désactivé: $pkg"; DISABLED=$((DISABLED+1))
        else
            warn "Déjà absent/désactivé: $pkg"; SKIPPED=$((SKIPPED+1))
        fi
    done
    ok "Debloat: $DISABLED désactivés, $SKIPPED déjà absents"

    # Optimisations
    info "Optimisations animations + cache..."
    adb -s "$PHONE_TARGET" shell settings put global window_animation_scale 0.5
    adb -s "$PHONE_TARGET" shell settings put global transition_animation_scale 0.5
    adb -s "$PHONE_TARGET" shell settings put global animator_duration_scale 0.5
    adb -s "$PHONE_TARGET" shell pm trim-caches 999999999
    adb -s "$PHONE_TARGET" shell am send-trim-memory all COMPLETE
    ok "Optimisations appliquées"

    # Exécution du script IA généré
    banner "EXECUTION — Script généré par qwen3-coder:30b"
    bash "$EXEC_SCRIPT" 2>&1 | tee -a "$LOG" || warn "Quelques commandes ont échoué (normal)"
}

# ─── Rapport final ───────────────────────────────────────────
rapport_final() {
    banner "RAPPORT FINAL"
    AFTER_DATA=$(adb -s "$PHONE_TARGET" shell "
        echo '=RAM_APRES=' && free -h
        echo '=NFC_APRES=' && settings get global nfc_on
        echo '=ANIMATIONS_APRES=' && settings get global window_animation_scale
    " 2>&1)

    RAPPORT=$(ollama_ask "$OLLAMA_MODEL_FR" \
        "Fais un rapport final court en français (5 lignes max) de ce qui a été fait sur ce téléphone Android Xiaomi MIUI. Résultat: $AFTER_DATA. Actions: debloat MIUI, NFC réactivé, animations optimisées.")

    ai "Rapport qwen3:14b :"
    echo "$RAPPORT"
    echo ""
    ok "Rapport sauvegardé : $LOG"

    # Sauvegarde état sur VPS
    ssh "${VPS_USER}@${VPS_IP}" "mkdir -p ~/pulseo_phone_reports" 2>/dev/null
    scp "$LOG" "${VPS_USER}@${VPS_IP}:~/pulseo_phone_reports/" 2>/dev/null
    ok "Rapport synchronisé sur VPS"
}

# ─── BOUCLE PRINCIPALE ──────────────────────────────────────
main() {
    clear
    echo -e "${P}"
    echo "  ██████╗ ██╗   ██╗██╗     ███████╗███████╗ ██████╗ "
    echo "  ██╔══██╗██║   ██║██║     ██╔════╝██╔════╝██╔═══██╗"
    echo "  ██████╔╝██║   ██║██║     ███████╗█████╗  ██║   ██║"
    echo "  ██╔═══╝ ██║   ██║██║     ╚════██║██╔══╝  ██║   ██║"
    echo "  ██║     ╚██████╔╝███████╗███████║███████╗╚██████╔╝"
    echo "  ╚═╝      ╚═════╝ ╚══════╝╚══════╝╚══════╝ ╚═════╝ "
    echo -e "${B}  Agent Autonome v1.0 — Termux × VPS × AI${NC}"
    echo ""

    CYCLE=0

    while true; do
        CYCLE=$((CYCLE + 1))
        banner "CYCLE $CYCLE — $(date '+%H:%M:%S')"

        # 1. SSH VPS
        info "Connexion SSH VPS..."
        setup_ssh || { fail "SSH VPS impossible"; sleep 60; continue; }

        # 2. ADB Phone
        connect_adb || { fail "ADB impossible — cycle ignoré"; sleep 60; continue; }

        # 3. Audit
        banner "AUDIT — État du téléphone"
        AUDIT=$(audit_phone)

        # 4. Simulation + confirmation
        banner "SIMULATION — Plan d'action"
        PLAN=$(simulate "$AUDIT")

        # 5. Exécution
        execute_plan "$PLAN"

        # 6. Rapport
        rapport_final

        # 7. Attente prochain cycle
        banner "CYCLE $CYCLE TERMINE"
        ok "Prochain cycle dans ${LOOP_INTERVAL}s — Ctrl+C pour arrêter"
        echo "  (ou modifie LOOP_INTERVAL dans le script pour changer l'intervalle)"
        sleep "$LOOP_INTERVAL"
    done
}

# ─── POINT D'ENTREE ─────────────────────────────────────────
main
