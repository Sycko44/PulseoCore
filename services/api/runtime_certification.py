from __future__ import annotations

from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
from typing import Any, Dict

from persistence import insert_opc
from settings import settings


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def sha256_text(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def validate_manifest(manifest: Dict[str, Any]) -> Dict[str, Any]:
    required = ["manifest_version", "execution_id", "environment", "artifact", "inputs", "runtime", "policy"]
    missing = [key for key in required if key not in manifest]
    return {
        "is_valid": len(missing) == 0,
        "missing": missing,
        "manifest_hash": sha256_text(json.dumps(manifest, sort_keys=True)),
    }


def emit_opc(manifest: Dict[str, Any], result_code: int, output_payload: Dict[str, Any]) -> Dict[str, Any]:
    started_at = manifest.get("started_at", now_iso())
    finished_at = now_iso()
    opc = {
        "opc_version": "0.1",
        "execution_id": manifest["execution_id"],
        "manifest_hash": sha256_text(json.dumps(manifest, sort_keys=True)),
        "input_hash": sha256_text(json.dumps(manifest.get("inputs", {}), sort_keys=True)),
        "output_hash": sha256_text(json.dumps(output_payload, sort_keys=True)),
        "result_code": result_code,
        "started_at": started_at,
        "finished_at": finished_at,
        "artifact_commit_sha": manifest.get("artifact", {}).get("commit_sha", "unknown"),
        "runner_id": manifest.get("runner_id", "local-runtime"),
        "trace_id": manifest.get("trace_id", manifest["execution_id"]),
        "archive_status": "pending",
        "signature": "unsigned"
    }
    persist_opc(opc)
    return opc


def persist_opc(opc: Dict[str, Any]) -> None:
    archive_dir = Path(settings.opc_archive_path)
    archive_dir.mkdir(parents=True, exist_ok=True)
    opc_path = archive_dir / f"{opc['execution_id']}.json"
    opc_json = json.dumps(opc, indent=2, sort_keys=True)
    opc_path.write_text(opc_json, encoding="utf-8")
    insert_opc(opc["execution_id"], opc_json, opc["finished_at"])
