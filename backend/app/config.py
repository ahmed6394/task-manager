import os
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", "postgresql://todouser:todopass@localhost:5432/tododb"
    )
    DATABASE_ECHO: bool = os.getenv("DATABASE_ECHO", "True").lower() == "true"

    class Config:
        env_file = ".env"


settings = Settings()
