from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = (
        "postgresql+asyncpg://bunnybank:bunnybank@localhost:5432/bunnybank"
    )
    jwt_secret: str = "dev-secret-change-in-production"
    jwt_algorithm: str = "HS256"
    jwt_expire_minutes: int = 60 * 24  # 24 hours
    firebase_credentials_file: str = ""

    model_config = {"env_file": ".env", "extra": "ignore"}


settings = Settings()
