from __future__ import annotations

from contextlib import asynccontextmanager
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional
from uuid import uuid4

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, EmailStr

from persistence import initialize_database, insert_checkin, insert_craving, list_checkins as db_list_checkins, list_cravings as db_list_cravings
from runtime_certification import emit_opc, now_iso, validate_manifest
from settings import settings


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    displayName: str


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class RefreshRequest(BaseModel):
    refreshToken: str


class UserProfile(BaseModel):
    id: str
    email: EmailStr
    displayName: str
    timezone: str = "Europe/Paris"


class AuthSession(BaseModel):
    accessToken: str
    refreshToken: str
    user: UserProfile


class CheckinCreate(BaseModel):
    mood: int
    energy: int
    cravings: int
    sleepHours: Optional[float] = None
    notes: Optional[str] = None


class Checkin(CheckinCreate):
    id: str
    createdAt: str


class CravingCreate(BaseModel):
    intensity: int
    trigger: Optional[str] = None
    notes: Optional[str] = None


class CravingEntry(CravingCreate):
    id: str
    createdAt: str


class Ritual(BaseModel):
    id: str
    title: str
    description: Optional[str] = None
    durationMinutes: int


class RitualCompletion(BaseModel):
    ritualId: str
    completedAt: str


class SosTrigger(BaseModel):
    context: Optional[str] = None
    note: Optional[str] = None


class SosResponse(BaseModel):
    status: str
    protocol: List[str]


class PhoenixSummary(BaseModel):
    score: int
    streakDays: int
    updatedAt: str


class ManifestValidationRequest(BaseModel):
    manifest: Dict[str, Any]


class OpcEmitRequest(BaseModel):
    manifest: Dict[str, Any]
    resultCode: int = 0
    outputPayload: Dict[str, Any] = {}


@asynccontextmanager
async def lifespan(_: FastAPI):
    initialize_database()
    yield


app = FastAPI(title="PulseoCore Runtime Minimum", version="0.2.0", lifespan=lifespan)


def _session(email: str, display_name: str) -> AuthSession:
    return AuthSession(
        accessToken=f"access-{uuid4().hex}",
        refreshToken=f"refresh-{uuid4().hex}",
        user=UserProfile(id="usr_demo", email=email, displayName=display_name),
    )


@app.get("/v1/health")
def health() -> dict:
    return {
        "status": "ok",
        "environment": settings.app_env,
        "version": "0.2.0",
        "runtime": "certifiable-minimum",
    }


@app.post("/v1/auth/register", response_model=AuthSession)
def register(payload: RegisterRequest) -> AuthSession:
    return _session(payload.email, payload.displayName)


@app.post("/v1/auth/login", response_model=AuthSession)
def login(payload: LoginRequest) -> AuthSession:
    return _session(payload.email, "Pulseo User")


@app.post("/v1/auth/refresh", response_model=AuthSession)
def refresh(payload: RefreshRequest) -> AuthSession:
    return AuthSession(
        accessToken=f"access-{uuid4().hex}",
        refreshToken=payload.refreshToken,
        user=UserProfile(id="usr_demo", email="demo@pulseo.local", displayName="Pulseo User"),
    )


@app.get("/v1/me", response_model=UserProfile)
def me() -> UserProfile:
    return UserProfile(id="usr_demo", email="demo@pulseo.local", displayName="Pulseo User")


@app.get("/v1/checkins")
def list_checkins(limit: int = 20) -> dict:
    return {"items": db_list_checkins(limit)}


@app.post("/v1/checkins", response_model=Checkin)
def create_checkin(payload: CheckinCreate) -> Checkin:
    item = Checkin(id=f"chk_{uuid4().hex[:10]}", createdAt=now_iso(), **payload.model_dump())
    insert_checkin(item.model_dump())
    return item


@app.get("/v1/cravings")
def list_cravings(limit: int = 20) -> dict:
    return {"items": db_list_cravings(limit)}


@app.post("/v1/cravings", response_model=CravingEntry)
def create_craving(payload: CravingCreate) -> CravingEntry:
    item = CravingEntry(id=f"crv_{uuid4().hex[:10]}", createdAt=now_iso(), **payload.model_dump())
    insert_craving(item.model_dump())
    return item


@app.get("/v1/rituals")
def list_rituals() -> dict:
    return {
        "items": [
            Ritual(id="ritual_breathing", title="Breathing Reset", description="Short grounding ritual", durationMinutes=5).model_dump(),
            Ritual(id="ritual_walk", title="Micro Walk", description="Short movement ritual", durationMinutes=10).model_dump(),
        ]
    }


@app.post("/v1/rituals/{ritual_id}/complete", response_model=RitualCompletion)
def complete_ritual(ritual_id: str) -> RitualCompletion:
    return RitualCompletion(ritualId=ritual_id, completedAt=now_iso())


@app.post("/v1/sos", response_model=SosResponse)
def trigger_sos(payload: SosTrigger) -> SosResponse:
    return SosResponse(status="acknowledged", protocol=["Pause", "Breathe", "Hydrate", "Move to a safe context"])


@app.get("/v1/phoenix", response_model=PhoenixSummary)
def phoenix() -> PhoenixSummary:
    return PhoenixSummary(score=42, streakDays=3, updatedAt=now_iso())


@app.post("/v1/runtime/manifest/validate")
def runtime_validate_manifest(payload: ManifestValidationRequest) -> dict:
    result = validate_manifest(payload.manifest)
    if not result["is_valid"]:
        raise HTTPException(status_code=400, detail=result)
    return result


@app.post("/v1/runtime/opc/emit")
def runtime_emit_opc(payload: OpcEmitRequest) -> dict:
    validation = validate_manifest(payload.manifest)
    if not validation["is_valid"]:
        raise HTTPException(status_code=400, detail=validation)
    manifest = dict(payload.manifest)
    manifest.setdefault("started_at", datetime.now(timezone.utc).isoformat())
    opc = emit_opc(manifest, payload.resultCode, payload.outputPayload)
    return opc
