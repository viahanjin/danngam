"""
모든 모델을 한곳에서 임포트할 수 있도록 하는 init 파일
"""

from app.models.base import Base, BaseModel
from app.models.user import User, UserRole
from app.models.equipment import Equipment, EquipmentImage, EquipmentType, EquipmentStatus
from app.models.booking import Booking, Payment, BookingStatus, PaymentMethod, PaymentStatus
from app.models.review import Review
from app.models.chat import Chat, Message

__all__ = [
    # Base
    "Base",
    "BaseModel",
    # User
    "User",
    "UserRole",
    # Equipment
    "Equipment",
    "EquipmentImage",
    "EquipmentType",
    "EquipmentStatus",
    # Booking & Payment
    "Booking",
    "Payment",
    "BookingStatus",
    "PaymentMethod",
    "PaymentStatus",
    # Review
    "Review",
    # Chat & Message
    "Chat",
    "Message",
]
