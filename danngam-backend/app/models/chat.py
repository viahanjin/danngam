"""
채팅(Chat) 및 메시지(Message) 모델

Chat 필드:
- id: UUID (기본 키)
- sender_id: 발신자 ID (Foreign Key)
- receiver_id: 수신자 ID (Foreign Key)
- created_at: 생성 시간
- updated_at: 수정 시간

Message 필드:
- id: UUID (기본 키)
- chat_id: 채팅 ID (Foreign Key)
- sender_id: 발신자 ID (Foreign Key)
- content: 메시지 내용
- image_url: 이미지 URL (선택사항)
- is_read: 읽음 여부
- created_at: 생성 시간
- updated_at: 수정 시간
"""

from sqlalchemy import Column, String, Boolean, ForeignKey, Index, Text
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID
from app.models.base import BaseModel


class Chat(BaseModel):
    """
    채팅 테이블
    두 사용자 간의 1:1 채팅방
    """
    __tablename__ = "chats"

    # 외래 키
    sender_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False, index=True)
    receiver_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False, index=True)

    # 관계 정의
    sender = relationship("User", foreign_keys=[sender_id])
    receiver = relationship("User", foreign_keys=[receiver_id])
    messages = relationship("Message", back_populates="chat", cascade="all, delete-orphan")

    # 인덱스 정의
    __table_args__ = (
        Index('idx_chat_sender_id', 'sender_id'),
        Index('idx_chat_receiver_id', 'receiver_id'),
        Index('idx_chat_participants', 'sender_id', 'receiver_id'),  # 복합 인덱스
    )

    def __repr__(self) -> str:
        return f"<Chat(id={self.id}, sender_id={self.sender_id}, receiver_id={self.receiver_id})>"


class Message(BaseModel):
    """
    메시지 테이블
    """
    __tablename__ = "messages"

    # 외래 키
    chat_id = Column(UUID(as_uuid=True), ForeignKey('chats.id'), nullable=False, index=True)
    sender_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False, index=True)

    # 메시지 내용
    content = Column(Text, nullable=True)  # 텍스트 메시지
    image_url = Column(String(500), nullable=True)  # 이미지 URL

    # 메시지 상태
    is_read = Column(Boolean, default=False, nullable=False, index=True)

    # 관계 정의
    chat = relationship("Chat", back_populates="messages")
    sender = relationship("User", foreign_keys=[sender_id])

    # 인덱스 정의
    __table_args__ = (
        Index('idx_message_chat_id', 'chat_id'),
        Index('idx_message_sender_id', 'sender_id'),
        Index('idx_message_is_read', 'is_read'),
    )

    def __repr__(self) -> str:
        return f"<Message(id={self.id}, chat_id={self.chat_id}, sender_id={self.sender_id})>"
