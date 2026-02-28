"""
사용자(User) 모델

필드:
- id: UUID (기본 키)
- phone: 전화번호 (유니크)
- name: 사용자 이름
- email: 이메일 (선택사항)
- profile_image_url: 프로필 이미지 URL
- location: GIS 위치 정보 (위도/경도)
- rating: 평균 평점 (1-5)
- review_count: 리뷰 개수
- role: 사용자 역할 (SUPPLIER/RENTER)
- created_at: 생성 시간
- updated_at: 수정 시간
"""

from sqlalchemy import Column, String, Float, Integer, Enum, Index
from sqlalchemy.dialects.postgresql import UUID
from geoalchemy2 import Geometry
from enum import Enum as PyEnum
from app.models.base import BaseModel


class UserRole(str, PyEnum):
    """사용자 역할 정의"""
    SUPPLIER = "SUPPLIER"  # 공급자 (장비 소유자)
    RENTER = "RENTER"      # 차용자 (장비 대여자)


class User(BaseModel):
    """
    사용자 테이블
    """
    __tablename__ = "users"

    # 기본 정보
    phone = Column(String(20), unique=True, nullable=False, index=True)
    name = Column(String(100), nullable=False)
    email = Column(String(255), nullable=True, index=True)
    profile_image_url = Column(String(500), nullable=True)

    # 위치 정보 (GIS - PostGIS 필요)
    # Point 형식: 'POINT(경도 위도)'
    location = Column(
        Geometry(geometry_type='POINT', srid=4326),
        nullable=True,
        index=True  # GiST 인덱스 자동 생성
    )

    # 평가 정보
    rating = Column(Float, default=0.0, nullable=False)  # 0.0 ~ 5.0
    review_count = Column(Integer, default=0, nullable=False)

    # 사용자 역할
    role = Column(Enum(UserRole), nullable=False, default=UserRole.RENTER)

    # 인덱스 정의
    __table_args__ = (
        Index('idx_user_phone', 'phone'),
        Index('idx_user_email', 'email'),
        Index('idx_user_role', 'role'),
        Index('idx_user_location', 'location', postgresql_using='gist'),
    )

    def __repr__(self) -> str:
        return f"<User(id={self.id}, phone={self.phone}, name={self.name}, role={self.role})>"
