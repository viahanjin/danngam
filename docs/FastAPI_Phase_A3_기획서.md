# FastAPI Phase A-3: 데이터베이스 스키마 생성 상세 기획서

**작성일**: 2026-02-14
**담당**: 기획자 (Planner)
**상태**: 개발 준비 완료
**Phase**: A-3 (데이터베이스 구축)

---

## 📋 Executive Summary

**Phase A-3**는 당나무 서비스의 핵심 데이터 구조를 설계하고 구현하는 단계입니다. SQLAlchemy ORM을 사용하여 8개의 데이터베이스 테이블을 생성하고, 관계(Foreign Key)를 설정한 후 초기 샘플 데이터를 입력합니다.

**목표**: 8개 테이블 생성 + 관계 설정 + 초기 샘플 데이터(5명 사용자 + 10개 장비)

---

## 🎯 Phase A-3 목표

### 주요 목표
1. **SQLAlchemy 모델 구현**: 8개 테이블을 Python 클래스로 정의
2. **데이터베이스 관계 설정**: 테이블 간 Foreign Key 및 관계 정의
3. **샘플 데이터 입력**: 초기 데이터로 테스트 가능한 환경 구축
4. **인덱싱**: 성능 최적화를 위한 주요 컬럼 인덱싱

### 성공 기준
- 모든 8개 테이블이 PostgreSQL에서 실제로 생성됨
- 모든 Foreign Key 관계가 정상 작동
- 샘플 데이터가 완전히 입력됨
- PgAdmin에서 데이터 조회 가능

---

## 📊 데이터베이스 설계

### 개요

당나무 플랫폼은 다음과 같은 핵심 엔티티들로 구성됩니다:

| 엔티티 | 설명 | 레코드 수 (예상) |
|--------|------|-----------------|
| User | 사용자 (공급자/차용인) | 5+ |
| Equipment | 장비 정보 | 10+ |
| EquipmentImage | 장비 이미지 | 20+ |
| Booking | 예약 요청 | 10+ |
| Payment | 결제 정보 | 10+ |
| Review | 리뷰/평가 | 5+ |
| Chat | 채팅방 | 5+ |
| Message | 메시지 | 20+ |

---

## 🗄️ SQLAlchemy 모델 상세 설계

### 1. User (사용자)

**용도**: 서비스의 모든 사용자 (공급자, 차용인)

```python
class User(Base):
    __tablename__ = "users"

    # Primary Key
    id: UUID = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)

    # 기본 정보
    phone: str = Column(String(20), unique=True, nullable=False, index=True)
    name: str = Column(String(100), nullable=False)
    email: str = Column(String(100), nullable=True)

    # 프로필
    profile_image_url: str = Column(String(500), nullable=True)
    location: Point = Column(Geometry('POINT', srid=4326), nullable=True)

    # 평점 시스템
    rating: float = Column(Float, default=0.0, nullable=False)
    review_count: int = Column(Integer, default=0, nullable=False)

    # 역할
    role: str = Column(
        Enum('SUPPLIER', 'RENTER', name='user_role_enum'),
        nullable=False
    )

    # 시간 추적
    created_at: datetime = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at: datetime = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # 관계
    equipment = relationship('Equipment', back_populates='supplier')
    bookings_as_renter = relationship('Booking', foreign_keys='Booking.renter_id', back_populates='renter')
    bookings_as_supplier = relationship('Booking', foreign_keys='Booking.supplier_id', back_populates='supplier')
    reviews = relationship('Review', back_populates='reviewer')
    chats_as_sender = relationship('Chat', foreign_keys='Chat.sender_id', back_populates='sender')
    chats_as_receiver = relationship('Chat', foreign_keys='Chat.receiver_id', back_populates='receiver')
    messages = relationship('Message', back_populates='sender')
```

**주요 특징**:
- `phone`: 고유 식별자로 사용되는 전화번호 (인덱싱)
- `role`: ENUM 타입으로 공급자/차용인 구분
- `location`: PostGIS Geometry 포인트로 GPS 좌표 저장
- `rating`: 평점 (1.0 ~ 5.0)

**샘플 데이터**:
```
1. 김기계 (010-1111-1111) - SUPPLIER
2. 이농부 (010-2222-2222) - SUPPLIER
3. 박시설 (010-3333-3333) - SUPPLIER
4. 최농가 (010-4444-4444) - RENTER
5. 정경작 (010-5555-5555) - RENTER
```

---

### 2. Equipment (장비)

**용도**: 공급자가 등록한 농기계/장비 정보

```python
class Equipment(Base):
    __tablename__ = "equipment"

    # Primary Key
    id: UUID = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)

    # 기본 정보
    name: str = Column(String(100), nullable=False, index=True)
    category: str = Column(String(50), nullable=False, index=True)  # 콤바인, 트랙터 등
    description: str = Column(Text, nullable=True)

    # 타입 (중요)
    type: str = Column(
        Enum('MOBILE', 'FIXED', name='equipment_type_enum'),
        nullable=False,
        index=True
    )

    # 가격
    price_per_hour: Decimal = Column(Numeric(10, 2), nullable=False)

    # 위치
    location: Point = Column(Geometry('POINT', srid=4326), nullable=False, index=True)

    # 상태
    status: str = Column(
        Enum('AVAILABLE', 'RENTED', 'MAINTENANCE', name='equipment_status_enum'),
        default='AVAILABLE',
        nullable=False,
        index=True
    )

    # 평점 시스템
    average_rating: float = Column(Float, default=0.0, nullable=False)
    review_count: int = Column(Integer, default=0, nullable=False)

    # Foreign Key
    supplier_id: UUID = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False, index=True)

    # 시간 추적
    created_at: datetime = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at: datetime = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # 관계
    supplier = relationship('User', back_populates='equipment')
    images = relationship('EquipmentImage', back_populates='equipment', cascade='all, delete-orphan')
    bookings = relationship('Booking', back_populates='equipment')
    reviews = relationship('Review', back_populates='equipment')
```

**주요 특징**:
- `type`: MOBILE(이동 가능) / FIXED(고정형) - 검색 필터링에 중요
- `location`: PostGIS Geometry로 거리 기반 검색 지원
- `status`: 장비의 현재 상태 (가용, 대여 중, 정비)
- 다중 인덱싱: name, category, type, status, location, supplier_id

**샘플 데이터** (10개):

| ID | 이름 | 카테고리 | 타입 | 시간당 가격 | 공급자 | 위치 |
|----|------|---------|------|-----------|-------|------|
| 1 | 콤바인 | 수확기계 | MOBILE | 50,000원 | 김기계 | 서울 |
| 2 | 트랙터 | 경작기계 | MOBILE | 40,000원 | 이농부 | 경기 |
| 3 | 이앙기 | 파종기계 | MOBILE | 35,000원 | 박시설 | 인천 |
| 4 | 드론 | 방제기계 | MOBILE | 25,000원 | 김기계 | 서울 |
| 5 | 경운기 | 경작기계 | MOBILE | 20,000원 | 이농부 | 경기 |
| 6 | 분무기 | 방제기계 | MOBILE | 15,000원 | 박시설 | 인천 |
| 7 | 수확기 | 수확기계 | MOBILE | 45,000원 | 김기계 | 서울 |
| 8 | 건조기 | 후처리 | FIXED | 100,000원 | 박시설 | 인천 |
| 9 | 저온저장고 | 저장 | FIXED | 200,000원 | 이농부 | 경기 |
| 10 | 저장창고 | 저장 | FIXED | 150,000원 | 김기계 | 서울 |

---

### 3. EquipmentImage (장비 이미지)

**용도**: 각 장비의 여러 이미지 저장

```python
class EquipmentImage(Base):
    __tablename__ = "equipment_images"

    # Primary Key
    id: UUID = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)

    # Foreign Key
    equipment_id: UUID = Column(
        UUID(as_uuid=True),
        ForeignKey('equipment.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )

    # 이미지
    image_url: str = Column(String(500), nullable=False)
    display_order: int = Column(Integer, default=0, nullable=False)

    # 시간 추적
    created_at: datetime = Column(DateTime, default=datetime.utcnow, nullable=False)

    # 관계
    equipment = relationship('Equipment', back_populates='images')
```

**주요 특징**:
- `equipment_id`: CASCADE 삭제로 장비 삭제 시 자동 삭제
- `display_order`: 이미지 표시 순서
- Foreign Key 인덱싱으로 빠른 조회

**샘플 데이터**: 각 장비당 2-3개의 이미지 (총 20+)

---

### 4. Booking (예약)

**용도**: 사용자의 장비 예약 요청 및 상태 관리

```python
class Booking(Base):
    __tablename__ = "bookings"

    # Primary Key
    id: UUID = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)

    # Foreign Keys
    equipment_id: UUID = Column(
        UUID(as_uuid=True),
        ForeignKey('equipment.id'),
        nullable=False,
        index=True
    )
    renter_id: UUID = Column(
        UUID(as_uuid=True),
        ForeignKey('users.id'),
        nullable=False,
        index=True
    )
    supplier_id: UUID = Column(
        UUID(as_uuid=True),
        ForeignKey('users.id'),
        nullable=False,
        index=True
    )

    # 예약 기간
    start_time: datetime = Column(DateTime, nullable=False, index=True)
    end_time: datetime = Column(DateTime, nullable=False)

    # 상태
    status: str = Column(
        Enum('PENDING', 'APPROVED', 'REJECTED', 'ONGOING', 'COMPLETED', 'CANCELLED',
             name='booking_status_enum'),
        default='PENDING',
        nullable=False,
        index=True
    )

    # 가격 계산
    total_amount: Decimal = Column(Numeric(10, 2), nullable=False)
    platform_fee: Decimal = Column(Numeric(10, 2), nullable=False)  # 8%

    # 시간 추적
    created_at: datetime = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at: datetime = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # 관계
    equipment = relationship('Equipment', back_populates='bookings')
    renter = relationship('User', foreign_keys=[renter_id], back_populates='bookings_as_renter')
    supplier = relationship('User', foreign_keys=[supplier_id], back_populates='bookings_as_supplier')
    payment = relationship('Payment', uselist=False, back_populates='booking')
    review = relationship('Review', uselist=False, back_populates='booking')
```

**주요 특징**:
- `status`: 6가지 상태로 예약 생명주기 관리
- `renter_id`, `supplier_id`: 다대다 관계 표현
- `platform_fee`: 8% 수수료 자동 계산 필드
- `start_time`, `end_time`: 시간 기반 인덱싱으로 가용성 검색 최적화

**가격 계산 로직**:
```
총 가격 = (end_time - start_time) * equipment.price_per_hour
수수료 = 총 가격 * 0.08
최종 청구액 = 총 가격 + 수수료
```

**샘플 데이터**: 10개의 예약 (다양한 상태)

---

### 5. Payment (결제)

**용도**: 예약에 대한 결제 정보 및 거래 추적

```python
class Payment(Base):
    __tablename__ = "payments"

    # Primary Key
    id: UUID = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)

    # Foreign Key (1:1 관계)
    booking_id: UUID = Column(
        UUID(as_uuid=True),
        ForeignKey('bookings.id', ondelete='CASCADE'),
        nullable=False,
        unique=True,
        index=True
    )

    # 결제 정보
    amount: Decimal = Column(Numeric(10, 2), nullable=False)
    method: str = Column(
        Enum('CREDIT_CARD', 'BANK_TRANSFER', 'MOBILE_PAYMENT', name='payment_method_enum'),
        nullable=False
    )
    status: str = Column(
        Enum('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED', name='payment_status_enum'),
        default='PENDING',
        nullable=False,
        index=True
    )

    # 외부 결제 게이트웨이 ID
    transaction_id: str = Column(String(100), nullable=True, unique=True)

    # 시간 추적
    created_at: datetime = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at: datetime = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # 관계
    booking = relationship('Booking', back_populates='payment')
```

**주요 특징**:
- `booking_id`: UNIQUE 제약으로 1:1 관계 보장
- `transaction_id`: PG사 거래ID로 결제 추적
- `method`: 결제 수단 (신용카드, 계좌이체, 모바일페이)
- `status`: 결제 상태 추적

**샘플 데이터**: 예약과 같은 수량 (10개)

---

### 6. Review (리뷰)

**용도**: 예약 완료 후 평가 및 리뷰

```python
class Review(Base):
    __tablename__ = "reviews"

    # Primary Key
    id: UUID = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)

    # Foreign Keys (1:1 관계)
    booking_id: UUID = Column(
        UUID(as_uuid=True),
        ForeignKey('bookings.id', ondelete='CASCADE'),
        nullable=False,
        unique=True,
        index=True
    )
    equipment_id: UUID = Column(
        UUID(as_uuid=True),
        ForeignKey('equipment.id'),
        nullable=False,
        index=True
    )
    reviewer_id: UUID = Column(
        UUID(as_uuid=True),
        ForeignKey('users.id'),
        nullable=False,
        index=True
    )

    # 리뷰 내용
    rating: int = Column(Integer, nullable=False)  # 1~5
    comment: str = Column(Text, nullable=True)

    # 시간 추적
    created_at: datetime = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at: datetime = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # 관계
    booking = relationship('Booking', back_populates='review')
    equipment = relationship('Equipment', back_populates='reviews')
    reviewer = relationship('User', back_populates='reviews')
```

**주요 특징**:
- `rating`: 1~5 범위의 정수형 평점
- `booking_id`: UNIQUE 제약으로 예약당 1개 리뷰만 작성 가능
- 리뷰가 생성되면 Equipment의 average_rating 자동 업데이트

**샘플 데이터**: 5개의 리뷰

---

### 7. Chat (채팅방)

**용도**: 사용자 간 1:1 채팅방

```python
class Chat(Base):
    __tablename__ = "chats"

    # Primary Key
    id: UUID = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)

    # Foreign Keys
    sender_id: UUID = Column(
        UUID(as_uuid=True),
        ForeignKey('users.id'),
        nullable=False,
        index=True
    )
    receiver_id: UUID = Column(
        UUID(as_uuid=True),
        ForeignKey('users.id'),
        nullable=False,
        index=True
    )

    # 시간 추적
    created_at: datetime = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at: datetime = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # 관계
    sender = relationship('User', foreign_keys=[sender_id], back_populates='chats_as_sender')
    receiver = relationship('User', foreign_keys=[receiver_id], back_populates='chats_as_receiver')
    messages = relationship('Message', back_populates='chat', cascade='all, delete-orphan')
```

**주요 특징**:
- `sender_id`, `receiver_id`: 양방향 채팅 관계
- CASCADE 삭제로 채팅방 삭제 시 메시지 자동 삭제
- 인덱싱으로 빠른 채팅방 검색

**샘플 데이터**: 5개의 채팅방

---

### 8. Message (메시지)

**용도**: 채팅방 내 개별 메시지

```python
class Message(Base):
    __tablename__ = "messages"

    # Primary Key
    id: UUID = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)

    # Foreign Keys
    chat_id: UUID = Column(
        UUID(as_uuid=True),
        ForeignKey('chats.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )
    sender_id: UUID = Column(
        UUID(as_uuid=True),
        ForeignKey('users.id'),
        nullable=False,
        index=True
    )

    # 메시지 내용
    content: str = Column(Text, nullable=False)
    image_url: str = Column(String(500), nullable=True)

    # 읽음 상태
    is_read: bool = Column(Boolean, default=False, nullable=False)

    # 시간 추적
    created_at: datetime = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    updated_at: datetime = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    # 관계
    chat = relationship('Chat', back_populates='messages')
    sender = relationship('User', back_populates='messages')
```

**주요 특징**:
- `created_at`: 메시지 시간 순서 정렬을 위한 인덱싱
- `is_read`: 읽음 상태 관리
- `image_url`: 선택적 이미지 지원

**샘플 데이터**: 채팅방당 4개의 메시지 (총 20+)

---

## 🔗 데이터베이스 관계도

### ER Diagram (텍스트 표현)

```
┌─────────────────────┐
│      User           │
│─────────────────────│
│ id (PK)            │
│ phone (UNIQUE)     │◄────────────────────┐
│ name               │                    │
│ email              │                    │
│ profile_image_url  │                    │
│ location           │                    │
│ rating             │                    │
│ role               │                    │
│ created_at         │                    │
│ updated_at         │                    │
└─────────────────────┘                    │
       ▲     ▲     ▲                       │
       │     │     │                       │
       │ 1   │1    │ 1                    │
       │     │     │                      (1)
       │     │     └──────────┐            │
       │     │                │            │
       │  (N) Booking      (1N) Chat       │
       │     │         / (N)  │            │
      (N)   │        /         │            │
       │   Booking  Message    │            │
       │     │        (1)      │            │
       │     │         │       │            │
       │     │    Sender    Receiver        │
       │     │                │            │
    (1N)    │ PENDING         │            │
Equipment   │ APPROVED        │            │
    │       │ REJECTED        │            │
    │       │ ONGOING         │            │
    │       │ COMPLETED       │            │
    │       │ CANCELLED       │            │
    │       │                 │            │
    │    (1)               (N) │            │
    │    │                   │             │
    │    Equipment        Receiver        │
    │      │                 ▲            │
    │      │                 │            │
    │      │ Supplier────────┘            │
    │      │                              │
    │      │ 1                            │
┌───┴──────────────────┐              (1N) │
│   Equipment          │               │   │
│──────────────────────│               │   │
│ id (PK)             │               │   │
│ name (INDEX)        │               │   │
│ category (INDEX)    │               │   │
│ type (INDEX)        │ ◄─────────────┘   │
│ description         │                   │
│ price_per_hour      │                   │
│ location (INDEX)    │                   │
│ status (INDEX)      │                   │
│ average_rating      │                   │
│ review_count        │                   │
│ supplier_id (FK)    │───────────────────┘
│ created_at          │
│ updated_at          │
└──────────────────────┘
    │ 1
    │ ├──────────────────────────────────────┐
    │ │                                      │
    (N) EquipmentImage                    (N) Review
    │   (IMAGES)                          (REVIEWS)
    │                                      │
    │                                      │
┌───┴──────────────────────┐      ┌────────┴──────────────┐
│ EquipmentImage           │      │ Review               │
│──────────────────────────│      │──────────────────────│
│ id (PK)                 │      │ id (PK)              │
│ equipment_id (FK)       │      │ booking_id (FK,UNQ)  │
│ image_url               │      │ equipment_id (FK)    │
│ display_order           │      │ reviewer_id (FK)     │
│ created_at              │      │ rating (1-5)         │
└────────────────────────┘      │ comment              │
                                │ created_at           │
                                │ updated_at           │
                                └──────────────────────┘
                                    │ 1
                                    │ ├─────────────────────┐
                                    │ │                     │
                                    (1) Booking         Booking (Renter)
                                       │                  │
                                       │ 1              (1)
                                       │                  │
                                 ┌─────┴──────────────────┘
                                 │
                                 (1) Payment
                                    │
┌────────────────────────────────────┴─────────────┐
│ Payment                                          │
│────────────────────────────────────────────────│
│ id (PK)                                        │
│ booking_id (FK, UNIQUE)                        │
│ amount                                         │
│ method                                         │
│ status                                         │
│ transaction_id (UNIQUE)                        │
│ created_at                                     │
│ updated_at                                     │
└──────────────────────────────────────────────┘
```

### 관계 매트릭스

| From | To | Type | 설명 |
|------|----|----|------|
| User | Equipment | 1:N | 공급자가 여러 장비 등록 |
| User | Booking (Renter) | 1:N | 차용인이 여러 예약 |
| User | Booking (Supplier) | 1:N | 공급자가 여러 예약 수신 |
| User | Review | 1:N | 사용자가 여러 리뷰 작성 |
| User | Chat (Sender) | 1:N | 사용자가 여러 채팅방 시작 |
| User | Chat (Receiver) | 1:N | 사용자가 여러 채팅방 수신 |
| User | Message | 1:N | 사용자가 여러 메시지 송신 |
| Equipment | EquipmentImage | 1:N | 장비가 여러 이미지 보유 |
| Equipment | Booking | 1:N | 장비가 여러 예약 가능 |
| Equipment | Review | 1:N | 장비가 여러 리뷰 받음 |
| Booking | Payment | 1:1 | 예약 1개당 결제 1건 |
| Booking | Review | 1:1 | 예약 1개당 리뷰 1개 |
| Chat | Message | 1:N | 채팅방에 여러 메시지 |

---

## 🗃️ 파일 구조

### 프로젝트 디렉토리 구조

```
danngam-backend/
├── app/
│   ├── models/
│   │   ├── __init__.py              # 모든 모델 import
│   │   ├── base.py                  # Base 클래스, UUID 타입 정의
│   │   ├── user.py                  # User 모델
│   │   ├── equipment.py             # Equipment, EquipmentImage 모델
│   │   ├── booking.py               # Booking, Payment 모델
│   │   ├── review.py                # Review 모델
│   │   └── chat.py                  # Chat, Message 모델
│   ├── init_db.py                   # DB 초기화 + 샘플 데이터
│   ├── database.py                  # PostgreSQL 연결 (기존)
│   └── main.py                      # FastAPI 앱 (기존)
└── ...
```

---

## 📝 구현 세부사항

### 1. Base 클래스 (app/models/base.py)

```python
from sqlalchemy.orm import declarative_base
from sqlalchemy import Column, DateTime
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
import uuid

Base = declarative_base()

def generate_uuid():
    return uuid.uuid4()

# 모든 모델은 Base를 상속받음
```

**역할**:
- SQLAlchemy ORM의 declarative base 정의
- UUID 타입 정의
- 공통 시간 필드 (created_at, updated_at) 자동 처리

### 2. 모델 구현 원칙

**Type Hints 필수**:
```python
class User(Base):
    id: UUID = Column(...)  # 타입 힌트 + Column 정의
```

**관계 정의 (Relationship)**:
```python
# User 모델
equipment = relationship('Equipment', back_populates='supplier')

# Equipment 모델
supplier = relationship('User', back_populates='equipment')
```

**인덱싱 전략**:
```python
# 자주 조회되는 컬럼
phone: str = Column(String(20), unique=True, nullable=False, index=True)
location: Point = Column(Geometry(...), index=True)
status: str = Column(Enum(...), index=True)
```

### 3. 초기화 스크립트 (app/init_db.py)

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models import Base, User, Equipment, Booking, Payment, Review, Chat, Message
from app.config import DATABASE_URL

def init_database():
    """데이터베이스 초기화 및 샘플 데이터 입력"""

    # 1. 테이블 생성
    engine = create_engine(DATABASE_URL)
    Base.metadata.create_all(engine)

    # 2. 세션 생성
    Session = sessionmaker(bind=engine)
    session = Session()

    # 3. 샘플 데이터 입력
    try:
        # 사용자 5명 생성
        users = create_sample_users()
        session.add_all(users)
        session.commit()

        # 장비 10개 생성
        equipments = create_sample_equipment(session)
        session.add_all(equipments)
        session.commit()

        # 장비 이미지 추가
        images = create_sample_images(session)
        session.add_all(images)
        session.commit()

        # 예약, 결제, 리뷰, 채팅 등 추가
        ...

        print("✅ 데이터베이스 초기화 완료")
    except Exception as e:
        session.rollback()
        print(f"❌ 오류: {e}")
    finally:
        session.close()

if __name__ == "__main__":
    init_database()
```

**실행 방법**:
```bash
python app/init_db.py
```

---

## 📊 샘플 데이터 상세

### 1. 사용자 (5명)

```sql
-- 공급자 (SUPPLIER)
INSERT INTO users VALUES (
    'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',  -- uuid
    '010-1111-1111',                          -- phone
    '김기계',                                  -- name
    'kim@example.com',                        -- email
    'https://cdn.example.com/profile/kim.jpg',-- profile_image_url
    '0101:0101:0101:0101:0101:0101:0101:0101', -- location (PostGIS)
    4.5,                                      -- rating
    10,                                       -- review_count
    'SUPPLIER',                               -- role
    NOW(),                                    -- created_at
    NOW()                                     -- updated_at
);

-- ... 이농부, 박시설 (SUPPLIER)
-- ... 최농가, 정경작 (RENTER)
```

### 2. 장비 (10개)

```sql
INSERT INTO equipment VALUES (
    'equipment-uuid-001',
    '콤바인',
    '수확기계',
    'MOBILE',
    '최신형 콤바인',
    50000.00,
    '0101:0101:0101:0101:0101:0101:0101:0101',  -- 서울
    'AVAILABLE',
    4.8,
    5,
    'supplier-uuid-1',
    NOW(),
    NOW()
);
-- ... 나머지 9개
```

### 3. 예약 (10개)

```sql
INSERT INTO bookings VALUES (
    'booking-uuid-001',
    'equipment-uuid-001',
    'renter-uuid-4',
    'supplier-uuid-1',
    '2026-02-15 10:00:00',
    '2026-02-15 18:00:00',  -- 8시간 예약
    'COMPLETED',
    400000.00,  -- 50000 * 8
    32000.00,   -- 400000 * 0.08
    NOW(),
    NOW()
);
-- ... 나머지 9개 (다양한 상태)
```

---

## ✅ 인수 기준 (Acceptance Criteria)

### Phase A-3 완료 기준

- [ ] **모델 구현 완료**
  - [ ] app/models/base.py 작성 완료
  - [ ] app/models/user.py 작성 완료
  - [ ] app/models/equipment.py 작성 완료
  - [ ] app/models/booking.py 작성 완료
  - [ ] app/models/review.py 작성 완료
  - [ ] app/models/chat.py 작성 완료

- [ ] **테이블 생성 확인**
  - [ ] `docker-compose up` 실행 가능
  - [ ] PostgreSQL 연결 정상
  - [ ] 모든 8개 테이블이 PgAdmin에서 visible
  - [ ] 테이블 구조가 설계서와 일치

- [ ] **관계 설정 확인**
  - [ ] 모든 Foreign Key 정상 작동
  - [ ] Cascade 삭제 정상 작동
  - [ ] 1:1 관계 (Booking-Payment, Booking-Review) 정상

- [ ] **인덱싱 확인**
  - [ ] phone (UNIQUE)
  - [ ] location (SPATIAL)
  - [ ] status (REGULAR)
  - [ ] type (REGULAR)
  - [ ] created_at (REGULAR)

- [ ] **샘플 데이터 입력**
  - [ ] 5명 사용자 입력 (3명 SUPPLIER, 2명 RENTER)
  - [ ] 10개 장비 입력 (7개 MOBILE, 3개 FIXED)
  - [ ] 20+ 이미지 입력
  - [ ] 10+ 예약 입력 (다양한 상태)
  - [ ] 10+ 결제 입력
  - [ ] 5+ 리뷰 입력
  - [ ] 5+ 채팅방 입력
  - [ ] 20+ 메시지 입력

- [ ] **데이터 무결성 검증**
  - [ ] Foreign Key 제약 확인
  - [ ] NOT NULL 제약 확인
  - [ ] UNIQUE 제약 확인 (phone, booking_id)
  - [ ] ENUM 타입 정상 작동

- [ ] **성능 검증**
  - [ ] 샘플 데이터 조회 시간 < 100ms
  - [ ] 위치 기반 검색 쿼리 < 200ms
  - [ ] 인덱스 정상 사용 (EXPLAIN 분석)

- [ ] **문서화 완료**
  - [ ] 마이그레이션 스크립트 작성 완료
  - [ ] README.md (초기화 방법) 작성 완료
  - [ ] 샘플 쿼리 문서 작성

---

## 🔍 검증 체크리스트

### 개발자 검증

```bash
# 1. 모델 구현 확인
python -c "from app.models import User, Equipment; print('✅ 모델 import 성공')"

# 2. 데이터베이스 연결 확인
python -c "from app.database import engine; engine.connect(); print('✅ DB 연결 성공')"

# 3. 테이블 생성 실행
python app/init_db.py

# 4. 데이터 확인
python -c "
from app.database import SessionLocal
from app.models import User
session = SessionLocal()
print(f'사용자 수: {session.query(User).count()}')
"
```

### PgAdmin 검증

1. PgAdmin 접속 (http://localhost:5050)
2. 서버 연결: `localhost:5432`
3. 데이터베이스 선택: `danngam`
4. Tables 확인:
   - [ ] users
   - [ ] equipment
   - [ ] equipment_images
   - [ ] bookings
   - [ ] payments
   - [ ] reviews
   - [ ] chats
   - [ ] messages

5. 각 테이블 우클릭 > Query Tool > 데이터 조회:
   ```sql
   SELECT COUNT(*) FROM users;           -- 5
   SELECT COUNT(*) FROM equipment;       -- 10
   SELECT COUNT(*) FROM bookings;        -- 10
   ```

---

## 📐 마이그레이션 전략

### Option A: 직접 생성 (현재 선택)

**장점**:
- 빠른 개발
- 복잡한 설정 불필요
- 초기 프로토타입에 적합

**단점**:
- 스키마 변경 추적 어려움
- 다중 환경 관리 복잡

**구현**:
```python
# app/init_db.py
from app.models import Base
from app.database import engine

Base.metadata.create_all(engine)
```

### Option B: Alembic 사용 (향후 전환)

**장점**:
- 스키마 버전 관리
- 변경 이력 추적
- 다중 환경 관리 용이

**단점**:
- 초기 설정 복잡
- 마이그레이션 파일 관리 필요

**전환 시기**: Phase B 이후 필요시

---

## 🛠️ PostGIS 설정 (지리공간 쿼리)

### Docker에서 PostGIS 설정

```yaml
# docker-compose.yml
services:
  postgres:
    image: postgis/postgis:latest
    environment:
      POSTGRES_DB: danngam
    ports:
      - "5432:5432"
```

### Python에서 PostGIS 사용

```python
from sqlalchemy import Column, Geometry
from geoalchemy2 import Geometry

class Equipment(Base):
    location = Column(Geometry('POINT', srid=4326), nullable=False)

# 거리 기반 검색
from sqlalchemy import func
from geoalchemy2 import functions as geofunc

# 50km 반경 검색
query = session.query(Equipment).filter(
    func.ST_DWithin(
        Equipment.location,
        func.ST_Point(user_lat, user_lon, 4326),
        50000  # 50km in meters
    )
)
```

---

## 📚 참고 자료

### SQLAlchemy 패턴

**1:1 관계**:
```python
# Booking ↔ Payment (1:1)
class Booking(Base):
    payment = relationship('Payment', uselist=False, back_populates='booking')

class Payment(Base):
    booking = relationship('Booking', back_populates='payment')
```

**1:N 관계**:
```python
# User ↔ Equipment (1:N)
class User(Base):
    equipment = relationship('Equipment', back_populates='supplier')

class Equipment(Base):
    supplier = relationship('User', back_populates='equipment')
```

**Foreign Key (다중 참조)**:
```python
# Booking에서 User를 2번 참조 (renter, supplier)
class Booking(Base):
    renter_id = Column(UUID, ForeignKey('users.id'))
    supplier_id = Column(UUID, ForeignKey('users.id'))

    renter = relationship('User', foreign_keys=[renter_id])
    supplier = relationship('User', foreign_keys=[supplier_id])
```

### 쿼리 예제

```python
from sqlalchemy import desc
from app.database import SessionLocal
from app.models import Equipment, Booking, User

session = SessionLocal()

# 1. 사용자의 모든 장비 조회
user = session.query(User).filter_by(id='xxx').first()
user.equipment  # User의 equipment 관계 접근

# 2. 장비의 모든 예약 조회
equipment = session.query(Equipment).first()
equipment.bookings

# 3. 예약의 결제 정보 조회
booking = session.query(Booking).first()
booking.payment  # 1:1 관계

# 4. 예약 목록 (최신순)
bookings = session.query(Booking).order_by(desc(Booking.created_at)).limit(10).all()

# 5. 특정 사용자의 예약 (차용인 기준)
user_bookings = session.query(Booking).filter_by(renter_id='xxx').all()
```

---

## 📋 개발 체크리스트

### Phase A-3 개발 체크리스트

```markdown
# Phase A-3: 데이터베이스 스키마 생성

## 모델 구현
- [ ] app/models/__init__.py (모든 모델 import)
- [ ] app/models/base.py (Base 클래스 정의)
- [ ] app/models/user.py (User 모델)
- [ ] app/models/equipment.py (Equipment, EquipmentImage)
- [ ] app/models/booking.py (Booking, Payment)
- [ ] app/models/review.py (Review)
- [ ] app/models/chat.py (Chat, Message)

## 초기화 및 샘플 데이터
- [ ] app/init_db.py (테이블 생성 함수)
- [ ] 샘플 사용자 5명 생성
- [ ] 샘플 장비 10개 생성
- [ ] 샘플 이미지 20+ 생성
- [ ] 샘플 예약 10개 생성
- [ ] 샘플 결제 10개 생성
- [ ] 샘플 리뷰 5개 생성
- [ ] 샘플 채팅방 5개 생성
- [ ] 샘플 메시지 20+ 생성

## 검증
- [ ] 테이블 생성 확인 (PgAdmin)
- [ ] Foreign Key 관계 확인
- [ ] 인덱스 생성 확인
- [ ] 샘플 데이터 데이터 입력 확인
- [ ] Cascade 삭제 테스트
- [ ] 제약 조건 테스트 (NOT NULL, UNIQUE)

## 문서화
- [ ] 마이그레이션 스크립트 README 작성
- [ ] 샘플 쿼리 문서 작성
- [ ] 초기화 방법 가이드 작성
```

---

## 🚀 다음 단계

### Phase A-4: 인증 API 구현

Phase A-3 완료 후, Phase A-4에서는:

1. **인증 API 엔드포인트** (3개)
   - POST /api/v1/auth/send-otp
   - POST /api/v1/auth/verify-otp
   - POST /api/v1/auth/logout

2. **사용자 API** (3개)
   - GET /api/v1/users/profile
   - PATCH /api/v1/users/profile
   - DELETE /api/v1/users/{id}

3. **JWT 토큰 관리**
   - 액세스 토큰 발급
   - 토큰 검증 미들웨어

---

## 📞 FAQ & Troubleshooting

### Q: PostGIS 설치 오류가 발생합니다

**A**: docker-compose.yml에서 이미지를 `postgis/postgis:latest`로 변경하세요.

### Q: UUID 타입 오류

**A**: 모델에서 UUID를 import 확인:
```python
from sqlalchemy.dialects.postgresql import UUID
from uuid import uuid4
```

### Q: Foreign Key 제약 오류

**A**: `ondelete='CASCADE'` 옵션 확인:
```python
booking_id = Column(UUID, ForeignKey('bookings.id', ondelete='CASCADE'))
```

### Q: 샘플 데이터 입력 실패

**A**: 세션 롤백 확인:
```python
try:
    session.add(user)
    session.commit()
except Exception as e:
    session.rollback()
    print(f"Error: {e}")
```

---

## 👥 담당자 및 일정

**기획**: 기획팀
**개발**: 백엔드 팀 (FastAPI)
**검증**: QA 팀

**예상 일정**: 1일 (Phase A-3)

---

**Document Version**: 1.0
**Last Updated**: 2026-02-14
**Status**: Draft → Ready for Development
