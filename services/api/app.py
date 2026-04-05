from datetime import datetime, timezone
from typing import List, Optional

from fastapi import FastAPI
from pydantic import BaseModel, EmailStr

app = FastAPI(title="PulseoCore API", version="0.1.0")


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


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


@app.get("/v1/health")
def health() -> dict:
    return {"status": "ok", "environment": "local", "version": "0.1.0"}


@app.post("/v1/auth/register", response_model=AuthSession)
def register(payload: RegisterRequest) -> AuthSession:
    user = UserProfile(id="usr_demo", email=payload.email, displayName=payload.displayName)
    return AuthSession(accessToken="demo-access", refreshToken="demo-refresh", user=user)


@app.post("/v1/auth/login", response_model=AuthSession)
def login(payload: LoginRequest) -> AuthSession:
    user = UserProfile(id="usr_demo", email=payload.email, displayName="Pulseo User")
    return AuthSession(accessToken="demo-access", refreshToken="demo-refresh", user=user)


@app.post("/v1/auth/refresh", response_model=AuthSession)
def refresh(payload: RefreshRequest) -> AuthSession:
    user = UserProfile(id="usr_demo", email="demo@pulseo.local", displayName="Pulseo User")
    return AuthSession(accessToken="demo-access", refreshToken=payload.refreshToken, user=user)


@app.get("/v1/me", response_model=UserProfile)
def me() -> UserProfile:
    return UserProfile(id="usr_demo", email="demo@pulseo.local", displayName="Pulseo User")


@app.get("/v1/checkins")
def list_checkins(limit: int = 20) -> dict:
    item = Checkin(id="chk_demo", mood=6, energy=5, cravings=3, sleepHours=7.5, notes="Morning check-in", createdAt=_now())
    return {"items": [item.model_dump()]}


@app.post("/v1/checkins", response_model=Checkin)
def create_checkin(payload: CheckinCreate) -> Checkin:
    return Checkin(id="chk_demo", createdAt=_now(), **payload.model_dump())


@app.get("/v1/cravings")
def list_cravings() -> dict:
    item = CravingEntry(id="crv_demo", intensity=4, trigger="stress", notes="Afternoon", createdAt=_now())
    return {"items": [item.model_dump()]}


@app.post("/v1/cravings", response_model=CravingEntry)
def create_craving(payload: CravingCreate) -> CravingEntry:
    return CravingEntry(id="crv_demo", createdAt=_now(), **payload.model_dump())


@app.get("/v1/rituals")
def list_rituals() -> dict:
    items = [
        Ritual(id="ritual_breathing", title="Breathing Reset", description="Short grounding ritual", durationMinutes=5).model_dump(),
        Ritual(id="ritual_walk", title="Micro Walk", description="Short movement ritual", durationMinutes=10).model_dump(),
    ]
    return {"items": items}


@app.post("/v1/rituals/{ritual_id}/complete", response_model=RitualCompletion)
def complete_ritual(ritual_id: str) -> RitualCompletion:
    return RitualCompletion(ritualId=ritual_id, completedAt=_now())


@app.post("/v1/sos", response_model=SosResponse)
def trigger_sos(payload: SosTrigger) -> SosResponse:
    return SosResponse(status="acknowledged", protocol=["Pause", "Breathe", "Hydrate", "Move to a safe context"])


@app.get("/v1/phoenix", response_model=PhoenixSummary)
def phoenix() -> PhoenixSummary:
    return PhoenixSummary(score=42, streakDays=3, updatedAt=_now())
