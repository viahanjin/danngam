"""
공통 Base 모델 설정
모든 모델이 상속할 기본 클래스 정의
"""

from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, DateTime, func
from sqlalchemy.dialects.postgresql import UUID
from uuid import uuid4

Base = declarative_base()


class BaseModel(Base):
    """
    모든 모델의 기본 클래스
    자동으로 id, created_at, updated_at 필드를 추가
    """
    __abstract__ = True

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4, nullable=False)
    created_at = Column(DateTime, default=func.now(), nullable=False)
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now(), nullable=False)
