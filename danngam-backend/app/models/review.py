"""
리뷰(Review) 모델

필드:
- id: UUID (기본 키)
- booking_id: 예약 ID (Foreign Key)
- equipment_id: 장비 ID (Foreign Key)
- reviewer_id: 리뷰 작성자 ID (Foreign Key)
- rating: 평점 (1~5)
- comment: 리뷰 댓글
- created_at: 생성 시간
- updated_at: 수정 시간
"""

from sqlalchemy import Column, String, Integer, Float, ForeignKey, Index, Text
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID
from app.models.base import BaseModel


class Review(BaseModel):
    """
    리뷰 테이블
    """
    __tablename__ = "reviews"

    # 외래 키
    booking_id = Column(UUID(as_uuid=True), ForeignKey('bookings.id'), nullable=False, index=True, unique=True)
    equipment_id = Column(UUID(as_uuid=True), ForeignKey('equipment.id'), nullable=False, index=True)
    reviewer_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False, index=True)

    # 리뷰 내용
    rating = Column(Integer, nullable=False)  # 1 ~ 5
    comment = Column(Text, nullable=True)  # 리뷰 텍스트

    # 관계 정의
    booking = relationship("Booking", foreign_keys=[booking_id])
    equipment = relationship("Equipment", foreign_keys=[equipment_id])
    reviewer = relationship("User", foreign_keys=[reviewer_id])

    # 인덱스 정의
    __table_args__ = (
        Index('idx_review_booking_id', 'booking_id'),
        Index('idx_review_equipment_id', 'equipment_id'),
        Index('idx_review_reviewer_id', 'reviewer_id'),
    )

    def __repr__(self) -> str:
        return f"<Review(id={self.id}, booking_id={self.booking_id}, rating={self.rating})>"
