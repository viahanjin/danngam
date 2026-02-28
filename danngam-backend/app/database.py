from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.config import settings
from app.models.base import Base

# PostgreSQL 데이터베이스 연결
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,  # 연결 검증
    echo=False,  # SQL 쿼리 로깅 (디버깅 시 True)
)

# 세션 팩토리 설정
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db():
    """
    데이터베이스 세션 의존성
    FastAPI 라우터에서 사용
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
