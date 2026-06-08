from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = (
        "postgresql+asyncpg://bunnybank:bunnybank@localhost:5432/bunnybank"
    )
    jwt_secret: str = "dev-secret-change-in-production"
    jwt_algorithm: str = "HS256"
    jwt_expire_minutes: int = 60 * 24  # 24 hours
    firebase_credentials_file: str = ""

    # Comma-separated list of allowed CORS origins. Overridable via CORS_ORIGINS env var.
    cors_origins: str = (
        "http://localhost:5000,http://localhost:5001,"
        "http://localhost:6000,http://localhost:6001"
    )

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    model_config = {"env_file": ".env", "extra": "ignore"}


settings = Settings()
