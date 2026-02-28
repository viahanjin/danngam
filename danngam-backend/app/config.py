from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # 데이터베이스
    DATABASE_URL: str = "postgresql://user:password@localhost:5432/danngam"

    # API
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "Danngam API"

    # JWT
    SECRET_KEY: str = "your-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 24 * 60  # 24시간
    ACCESS_TOKEN_EXPIRE_HOURS: int = 24

    # OTP
    OTP_EXPIRE_SECONDS: int = 180  # 3분
    OTP_EXPIRE_MINUTES: int = 3
    OTP_LENGTH: int = 6
    MAX_OTP_ATTEMPTS_PER_HOUR: int = 5  # 동일 번호 1시간당 최대 5회

    class Config:
        env_file = ".env"


settings = Settings()
