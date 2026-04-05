from datetime import datetime, timezone


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def run_once() -> None:
    print(f"[pulseocore-worker] heartbeat {now_iso()}")
    print("[pulseocore-worker] no queue backend wired yet - placeholder worker is alive")


if __name__ == "__main__":
    run_once()
