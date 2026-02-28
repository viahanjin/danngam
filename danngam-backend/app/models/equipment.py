"""
장비(Equipment) 및 장비 이미지(EquipmentImage) 모델

Equipment 필드:
- id: UUID (기본 키)
- name: 장비 이름
- category: 장비 카테고리
- type: 장비 유형 (MOBILE/FIXED) - 이동형/고정형
- description: 장비 설명
- price_per_hour: 시간당 가격
- location: GIS 위치 정보 (위도/경도)
- status: 장비 상태 (AVAILABLE/RENTED/MAINTENANCE)
- average_rating: 평균 평점
- review_count: 리뷰 개수
- supplier_id: 공급자 ID (Foreign Key)
- created_at: 생성 시간
- updated_at: 수정 시간

EquipmentImage 필드:
- id: UUID (기본 키)
- equipment_id: 장비 ID (Foreign Key)
- image_url: 이미지 URL
- display_order: 표시 순서
- created_at: 생성 시간
"""

from sqlalchemy import Column, String, Float, Integer, Enum, ForeignKey, Index
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID
from geoalchemy2 import Geometry
from enum import Enum as PyEnum
from uuid import UUID as PyUUID
from app.models.base import BaseModel


class EquipmentType(str, PyEnum):
    """장비 유형"""
    MOBILE = "MOBILE"      # 이동형 장비
    FIXED = "FIXED"        # 고정형 장비


class EquipmentStatus(str, PyEnum):
    """장비 상태"""
    AVAILABLE = "AVAILABLE"      # 사용 가능
    RENTED = "RENTED"            # 렌팅 중
    MAINTENANCE = "MAINTENANCE"  # 정비 중


class Equipment(BaseModel):
    """
    장비 테이블
    """
    __tablename__ = "equipment"

    # 기본 정보
    name = Column(String(200), nullable=False, index=True)
    category = Column(String(100), nullable=False, index=True)  # e.g., "지게차", "포크리프트"
    type = Column(Enum(EquipmentType), nullable=False, index=True)  # MOBILE or FIXED
    description = Column(String(2000), nullable=True)

    # 가격 정보
    price_per_hour = Column(Float, nullable=False)  # 시간당 가격

    # 위치 정보 (GIS)
    location = Column(
        Geometry(geometry_type='POINT', srid=4326),
        nullable=True,
        index=True
    )

    # 상태
    status = Column(Enum(EquipmentStatus), nullable=False, default=EquipmentStatus.AVAILABLE)

    # 평가 정보
    average_rating = Column(Float, default=0.0, nullable=False)  # 0.0 ~ 5.0
    review_count = Column(Integer, default=0, nullable=False)

    # 공급자 정보 (Foreign Key)
    supplier_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False, index=True)

    # 관계 정의
    supplier = relationship("User", foreign_keys=[supplier_id])
    images = relationship("EquipmentImage", back_populates="equipment", cascade="all, delete-orphan")

    # 인덱스 정의
    __table_args__ = (
        Index('idx_equipment_name', 'name'),
        Index('idx_equipment_category', 'category'),
        Index('idx_equipment_type', 'type'),
        Index('idx_equipment_status', 'status'),
        Index('idx_equipment_supplier_id', 'supplier_id'),
        Index('idx_equipment_location', 'location', postgresql_using='gist'),
    )

    def __repr__(self) -> str:
        return f"<Equipment(id={self.id}, name={self.name}, type={self.type}, status={self.status})>"


class EquipmentImage(BaseModel):
    """
    장비 이미지 테이블
    """
    __tablename__ = "equipment_images"

    # 외래 키
    equipment_id = Column(UUID(as_uuid=True), ForeignKey('equipment.id'), nullable=False, index=True)

    # 이미지 정보
    image_url = Column(String(500), nullable=False)
    display_order = Column(Integer, default=0, nullable=False)  # 표시 순서

    # 관계 정의
    equipment = relationship("Equipment", back_populates="images")

    # 인덱스 정의
    __table_args__ = (
        Index('idx_equipment_image_equipment_id', 'equipment_id'),
    )

    def __repr__(self) -> str:
        return f"<EquipmentImage(id={self.id}, equipment_id={self.equipment_id}, order={self.display_order})>"
