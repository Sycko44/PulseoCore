from dataclasses import dataclass
import os


@dataclass(frozen=True)
class Settings:
    app_env: str = os.getenv("APP_ENV", "development")
    app_name: str = os.getenv("APP_NAME", "PulseoCore")
    app_host: str = os.getenv("APP_HOST", "0.0.0.0")
    app_port: int = int(os.getenv("APP_PORT", "8000"))
    database_url: str = os.getenv("DATABASE_URL", "sqlite:////tmp/pulseo.sqlite3")
    sqlite_path: str = os.getenv("SQLITE_PATH", "/tmp/pulseo.sqlite3")
    secret_key: str = os.getenv("SECRET_KEY", "change-me")
    jwt_secret: str = os.getenv("JWT_SECRET", "change-me")
    opc_archive_path: str = os.getenv("OPC_ARCHIVE_PATH", "/opt/pulseo/archive/opc")
    manifest_archive_path: str = os.getenv("MANIFEST_ARCHIVE_PATH", "/opt/pulseo/archive/manifests")


settings = Settings()
