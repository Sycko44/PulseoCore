from __future__ import annotations

import sqlite3
from pathlib import Path
from typing import Any, Dict, List

from settings import settings


SCHEMA = """
CREATE TABLE IF NOT EXISTS checkins (
  id TEXT PRIMARY KEY,
  mood INTEGER NOT NULL,
  energy INTEGER NOT NULL,
  cravings INTEGER NOT NULL,
  sleep_hours REAL,
  notes TEXT,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS cravings (
  id TEXT PRIMARY KEY,
  intensity INTEGER NOT NULL,
  trigger TEXT,
  notes TEXT,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS opc_records (
  execution_id TEXT PRIMARY KEY,
  opc_json TEXT NOT NULL,
  created_at TEXT NOT NULL
);
"""


def _db_path() -> Path:
    path = Path(settings.sqlite_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    return path


def get_connection() -> sqlite3.Connection:
    conn = sqlite3.connect(_db_path())
    conn.row_factory = sqlite3.Row
    return conn


def initialize_database() -> None:
    with get_connection() as conn:
        conn.executescript(SCHEMA)
        conn.commit()


def insert_checkin(payload: Dict[str, Any]) -> None:
    with get_connection() as conn:
        conn.execute(
            "INSERT INTO checkins (id, mood, energy, cravings, sleep_hours, notes, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
            (
                payload["id"],
                payload["mood"],
                payload["energy"],
                payload["cravings"],
                payload.get("sleepHours"),
                payload.get("notes"),
                payload["createdAt"],
            ),
        )
        conn.commit()


def list_checkins(limit: int) -> List[Dict[str, Any]]:
    with get_connection() as conn:
        rows = conn.execute(
            "SELECT id, mood, energy, cravings, sleep_hours, notes, created_at FROM checkins ORDER BY created_at DESC LIMIT ?",
            (limit,),
        ).fetchall()
        return [
            {
                "id": row["id"],
                "mood": row["mood"],
                "energy": row["energy"],
                "cravings": row["cravings"],
                "sleepHours": row["sleep_hours"],
                "notes": row["notes"],
                "createdAt": row["created_at"],
            }
            for row in rows
        ]


def insert_craving(payload: Dict[str, Any]) -> None:
    with get_connection() as conn:
        conn.execute(
            "INSERT INTO cravings (id, intensity, trigger, notes, created_at) VALUES (?, ?, ?, ?, ?)",
            (
                payload["id"],
                payload["intensity"],
                payload.get("trigger"),
                payload.get("notes"),
                payload["createdAt"],
            ),
        )
        conn.commit()


def list_cravings(limit: int = 20) -> List[Dict[str, Any]]:
    with get_connection() as conn:
        rows = conn.execute(
            "SELECT id, intensity, trigger, notes, created_at FROM cravings ORDER BY created_at DESC LIMIT ?",
            (limit,),
        ).fetchall()
        return [
            {
                "id": row["id"],
                "intensity": row["intensity"],
                "trigger": row["trigger"],
                "notes": row["notes"],
                "createdAt": row["created_at"],
            }
            for row in rows
        ]


def insert_opc(execution_id: str, opc_json: str, created_at: str) -> None:
    with get_connection() as conn:
        conn.execute(
            "INSERT OR REPLACE INTO opc_records (execution_id, opc_json, created_at) VALUES (?, ?, ?)",
            (execution_id, opc_json, created_at),
        )
        conn.commit()
