from __future__ import annotations

import json
from contextlib import asynccontextmanager
from pathlib import Path

import httpx
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse, StreamingResponse
from pydantic import BaseModel

from persistence import initialize_database
from runtime_minimum import app as runtime_app
from settings import settings

LEGACY_INDEX = Path(__file__).resolve().parents[2] / "legacy" / "vps_existing" / "pulseo_chat" / "index.html"
OLLAMA_URL = "http://localhost:11434/api/generate"
OLLAMA_MODEL = "qwen3:14b"


class Message(BaseModel):
    message: str
    history: list = []


@asynccontextmanager
async def lifespan(_: FastAPI):
    initialize_database()
    yield


app = FastAPI(title="Pulseo Minimum", version="0.3.0", lifespan=lifespan)
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])
app.include_router(runtime_app.router)


@app.get("/", response_class=HTMLResponse)
async def index() -> str:
    if LEGACY_INDEX.exists():
        return LEGACY_INDEX.read_text(encoding="utf-8")
    return "<html><body><h1>Pulseo Minimum</h1><p>Legacy index not found.</p></body></html>"


@app.get("/health")
async def chat_health() -> dict:
    return {
        "status": "ok",
        "app": "pulseo-minimum",
        "environment": settings.app_env,
        "ollama_model": OLLAMA_MODEL,
    }


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
                "POST",
                OLLAMA_URL,
                json={"model": OLLAMA_MODEL, "prompt": prompt, "stream": True},
            ) as response:
                async for line in response.aiter_lines():
                    if not line:
                        continue
                    try:
                        data = json.loads(line)
                        token = data.get("response", "")
                        if token:
                            yield token
                    except Exception:
                        continue

    return StreamingResponse(stream(), media_type="text/plain; charset=utf-8")
