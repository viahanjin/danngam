"""
예약(Booking) 및 결제(Payment) 모델

Booking 필드:
- id: UUID (기본 키)
- equipment_id: 장비 ID (Foreign Key)
- renter_id: 차용자 ID (Foreign Key)
- supplier_id: 공급자 ID (Foreign Key)
- start_time: 예약 시작 시간
- end_time: 예약 종료 시간
- status: 예약 상태
- total_amount: 총 금액
- platform_fee: 플랫폼 수수료 (8%)
- created_at: 생성 시간
- updated_at: 수정 시간

Payment 필드:
- id: UUID (기본 키)
- booking_id: 예약 ID (Foreign Key)
- amount: 결제 금액
- method: 결제 방법
- status: 결제 상태
- transaction_id: 거래 ID
- created_at: 생성 시간
- updated_at: 수정 시간
"""

from sqlalchemy import Column, String, Float, DateTime, Enum, ForeignKey, Index, Text
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID
from enum import Enum as PyEnum
from datetime import datetime
from app.models.base import BaseModel


class BookingStatus(str, PyEnum):
    """예약 상태"""
    PENDING = "PENDING"           # 대기 중
    APPROVED = "APPROVED"         # 승인됨
    REJECTED = "REJECTED"         # 거절됨
    ONGOING = "ONGOING"           # 진행 중
    COMPLETED = "COMPLETED"       # 완료됨
    CANCELLED = "CANCELLED"       # 취소됨


class Booking(BaseModel):
    """
    예약 테이블
    """
    __tablename__ = "bookings"

    # 외래 키
    equipment_id = Column(UUID(as_uuid=True), ForeignKey('equipment.id'), nullable=False, index=True)
    renter_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False, index=True)
    supplier_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False, index=True)

    # 시간 정보
    start_time = Column(DateTime, nullable=False, index=True)
    end_time = Column(DateTime, nullable=False)

    # 상태
    status = Column(Enum(BookingStatus), nullable=False, default=BookingStatus.PENDING, index=True)

    # 가격 정보
    total_amount = Column(Float, nullable=False)  # 렌탈 가격 + 수수료
    platform_fee = Column(Float, nullable=False)  # 플랫폼 수수료 (8%)

    # 관계 정의
    equipment = relationship("Equipment", foreign_keys=[equipment_id])
    renter = relationship("User", foreign_keys=[renter_id])
    supplier = relationship("User", foreign_keys=[supplier_id])
    payments = relationship("Payment", back_populates="booking", cascade="all, delete-orphan")

    # 인덱스 정의
    __table_args__ = (
        Index('idx_booking_equipment_id', 'equipment_id'),
        Index('idx_booking_renter_id', 'renter_id'),
        Index('idx_booking_supplier_id', 'supplier_id'),
        Index('idx_booking_status', 'status'),
        Index('idx_booking_start_time', 'start_time'),
    )

    def __repr__(self) -> str:
        return f"<Booking(id={self.id}, equipment_id={self.equipment_id}, renter_id={self.renter_id}, status={self.status})>"


class PaymentMethod(str, PyEnum):
    """결제 방법"""
    CREDIT_CARD = "CREDIT_CARD"       # 신용카드
    BANK_TRANSFER = "BANK_TRANSFER"   # 계좌이체
    MOBILE_PAYMENT = "MOBILE_PAYMENT" # 모바일 결제


class PaymentStatus(str, PyEnum):
    """결제 상태"""
    PENDING = "PENDING"       # 대기 중
    SUCCESS = "SUCCESS"       # 성공
    FAILED = "FAILED"         # 실패
    REFUNDED = "REFUNDED"     # 환불됨


class Payment(BaseModel):
    """
    결제 테이블
    """
    __tablename__ = "payments"

    # 외래 키
    booking_id = Column(UUID(as_uuid=True), ForeignKey('bookings.id'), nullable=False, index=True, unique=True)

    # 결제 정보
    amount = Column(Float, nullable=False)
    method = Column(Enum(PaymentMethod), nullable=False)
    status = Column(Enum(PaymentStatus), nullable=False, default=PaymentStatus.PENDING, index=True)
    transaction_id = Column(String(255), nullable=True, unique=True, index=True)  # 외부 결제 게이트웨이의 거래 ID

    # 관계 정의
    booking = relationship("Booking", back_populates="payments")

    # 인덱스 정의
    __table_args__ = (
        Index('idx_payment_booking_id', 'booking_id'),
        Index('idx_payment_status', 'status'),
        Index('idx_payment_transaction_id', 'transaction_id'),
    )

    def __repr__(self) -> str:
        return f"<Payment(id={self.id}, booking_id={self.booking_id}, status={self.status}, amount={self.amount})>"
