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
