# FastAPI Phase A-4: 인증 API 상세 기획서

**작성일**: 2026-02-14
**담당**: 기획자 (Planner)
**상태**: 개발 준비 완료
**Phase**: A-4 (인증 API 구현)

---

## 📋 Executive Summary

**Phase A-4**는 당나무 서비스의 사용자 인증 시스템을 구현하는 단계입니다. OTP(One-Time Password)를 기반으로 휴대폰 번호 인증을 수행하고, JWT(JSON Web Token)를 발급하여 API 보안을 확보합니다. 또한 로그아웃 시 토큰 블랙리스트 관리로 세션 보안을 강화합니다.

**목표**: 3개 인증 API + JWT 토큰 관리 + OTP 인증 로직 완성

**주요 기능**:
- OTP 발송 (휴대폰 SMS)
- OTP 검증 및 JWT 토큰 발급
- 로그아웃 (토큰 블랙리스트)

---

## 🎯 Phase A-4 목표

### 주요 목표
1. **OTP 인증 시스템 구현**: 휴대폰 번호 기반 OTP 생성 및 검증
2. **JWT 토큰 관리**: 토큰 발급, 검증, 갱신 로직
3. **보안 강화**: 레이트 리미팅, HTTPS, 토큰 블랙리스트
4. **API 엔드포인트 완성**: 3개의 인증 API 구현

### 성공 기준
- [ ] 모든 3개 엔드포인트 정상 작동
- [ ] OTP 생성, 검증, 만료 로직 완전 구현
- [ ] JWT 토큰 발급 및 검증 정상
- [ ] 레이트 리미팅 적용
- [ ] Postman 테스트 통과
- [ ] 보안 점검 완료 (HTTPS, 암호화)

---

## 📊 인증 시스템 설계

### 시스템 아키텍처

```
┌─────────────────┐
│  클라이언트 앱  │
└────────┬────────┘
         │
         │ 1. POST /auth/send-otp (phone)
         ▼
    ┌────────────────────────────────┐
    │   FastAPI 인증 서버            │
    │                                │
    │  ┌──────────────────────────┐  │
    │  │ OTP 생성 및 저장         │  │
    │  │ - 6자리 난수 생성        │  │
    │  │ - Redis/메모리 저장      │  │
    │  │ - TTL: 3분               │  │
    │  └──────────────────────────┘  │
    │                                │
    │  ┌──────────────────────────┐  │
    │  │ SMS 발송 (외부 서비스)   │  │
    │  │ - 보류 (향후 SMS API)    │  │
    │  └──────────────────────────┘  │
    │                                │
    │  ┌──────────────────────────┐  │
    │  │ JWT 토큰 발급            │  │
    │  │ - Access Token (24시간)  │  │
    │  │ - Refresh Token (7일)    │  │
    │  └──────────────────────────┘  │
    │                                │
    │  ┌──────────────────────────┐  │
    │  │ 토큰 블랙리스트 관리    │  │
    │  │ - 로그아웃 토큰 저장     │  │
    │  │ - Redis TTL 사용         │  │
    │  └──────────────────────────┘  │
    └────────────────────────────────┘
         │
         │ 2. POST /auth/verify-otp (phone, otp)
         │    → JWT 토큰 반환
         ▼
    ┌────────────────────────────────┐
    │   PostgreSQL 데이터베이스      │
    │                                │
    │   users 테이블                 │
    │   - id (UUID)                  │
    │   - phone (유니크)             │
    │   - name, email                │
    │   - created_at, updated_at     │
    └────────────────────────────────┘
         │
         │ 3. Authorization: Bearer {token}
         │    (이후 모든 API 요청)
         ▼
    ┌────────────────────────────────┐
    │  인증된 API 엔드포인트         │
    │  - /api/v1/equipments          │
    │  - /api/v1/bookings            │
    │  - /api/v1/users/profile       │
    └────────────────────────────────┘
```

### 인증 플로우

```
┌──────────────────────────────────────────────────────────────────┐
│ 1단계: OTP 발송 (새 사용자 또는 재인증)                         │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  클라이언트          FastAPI 서버              Redis/메모리      │
│      │                   │                         │            │
│      │ 휴대폰 번호 입력  │                         │            │
│      ├──────────────────>│                         │            │
│      │                   │ OTP 생성 (6자리)       │            │
│      │                   ├────────────────────────>│            │
│      │                   │ 6자리 난수             │            │
│      │                   │ {phone: otp} 저장      │            │
│      │                   │ TTL: 3분 설정          │            │
│      │                   │<────────────────────────┤            │
│      │                   │                        │            │
│      │  OTP 발송됨 응답  │                        │            │
│      │<──────────────────┤                        │            │
│      │ (메시지/확인)     │                        │            │
│      │                   │                        │            │
│      │ [사용자 OTP 입력] │                        │            │
│      │                   │                        │            │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│ 2단계: OTP 검증 및 JWT 토큰 발급                                 │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  클라이언트          FastAPI 서버         Redis/메모리/PostgreSQL│
│      │                   │                        │              │
│      │ 휴대폰 + OTP 입력 │                        │              │
│      ├──────────────────>│                        │              │
│      │                   │ Redis에서 OTP 확인     │              │
│      │                   ├───────────────────────>│              │
│      │                   │ 저장된 OTP 반환        │              │
│      │                   │<───────────────────────┤              │
│      │                   │                       │              │
│      │                   │ OTP 비교 (일치 확인)   │              │
│      │                   │ OTP 삭제               │              │
│      │                   │ (사용 완료)           │              │
│      │                   │                       │              │
│      │                   │ User 조회/생성        │              │
│      │                   ├────────────────────────────────────>│
│      │                   │ 기존 사용자 또는      │              │
│      │                   │ 신규 사용자 생성      │              │
│      │                   │<────────────────────────────────────┤
│      │                   │                       │              │
│      │                   │ JWT 토큰 생성         │              │
│      │                   │ - Access Token (24h)  │              │
│      │                   │ - Refresh Token (7d)  │              │
│      │                   │                       │              │
│      │   JWT 토큰 반환   │                       │              │
│      │<──────────────────┤                       │              │
│      │ {access_token,    │                       │              │
│      │  refresh_token,   │                       │              │
│      │  token_type}      │                       │              │
│      │                   │                       │              │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│ 3단계: 로그아웃 (토큰 블랙리스트)                                 │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  클라이언트       FastAPI 서버        Redis (블랙리스트)         │
│      │                 │                      │                 │
│      │ POST /logout    │                      │                 │
│      │ Header:         │                      │                 │
│      │ Bearer token    │                      │                 │
│      ├────────────────>│                      │                 │
│      │                 │ 토큰 검증            │                 │
│      │                 │ 토큰 만료까지의      │                 │
│      │                 │ 시간 계산            │                 │
│      │                 │                      │                 │
│      │                 │ 블랙리스트에 추가    │                 │
│      │                 ├─────────────────────>│                 │
│      │                 │ {token_id: exp_time}│                 │
│      │                 │<─────────────────────┤                 │
│      │                 │                      │                 │
│      │   로그아웃 완료 │                      │                 │
│      │<────────────────┤                      │                 │
│      │ {message:       │                      │                 │
│      │  "로그아웃됨"}  │                      │                 │
│      │                 │                      │                 │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🔐 API 엔드포인트 상세 설계

### 1. POST /api/v1/auth/send-otp

**설명**: 휴대폰 번호로 OTP 발송 요청

#### Request

```json
{
  "phone": "010-1234-5678"
}
```

**요청 스키마 (Pydantic)**:

```python
class SendOTPRequest(BaseModel):
    """OTP 발송 요청 스키마"""
    phone: str = Field(
        ...,
        pattern=r'^01[0-9]-\d{3,4}-\d{4}$',
        description="휴대폰 번호 (형식: 010-1234-5678)"
    )

    class Config:
        schema_extra = {
            "example": {
                "phone": "010-1234-5678"
            }
        }
```

#### Response (200 OK)

```json
{
  "message": "OTP가 발송되었습니다.",
  "phone": "010-1234-5678",
  "expires_in": 300,
  "status": "pending"
}
```

**응답 스키마 (Pydantic)**:

```python
class SendOTPResponse(BaseModel):
    """OTP 발송 응답 스키마"""
    message: str = Field(
        ...,
        description="응답 메시지"
    )
    phone: str = Field(
        ...,
        description="요청한 휴대폰 번호"
    )
    expires_in: int = Field(
        default=300,
        description="OTP 만료 시간 (초)"
    )
    status: str = Field(
        default="pending",
        description="OTP 상태"
    )

    class Config:
        schema_extra = {
            "example": {
                "message": "OTP가 발송되었습니다.",
                "phone": "010-1234-5678",
                "expires_in": 300,
                "status": "pending"
            }
        }
```

#### 에러 응답

```json
{
  "detail": "Invalid phone format"
}
```

| 상태 코드 | 설명 | 예시 |
|----------|------|------|
| 200 | 정상 발송 | `{"message": "OTP가 발송되었습니다."}` |
| 400 | 잘못된 휴대폰 형식 | `{"detail": "Invalid phone format"}` |
| 429 | 레이트 리미팅 (5회/시간) | `{"detail": "Too many OTP requests"}` |
| 500 | 서버 오류 | `{"detail": "Internal server error"}` |

#### 비즈니스 로직

```python
async def send_otp(phone: str) -> SendOTPResponse:
    """
    OTP 발송 비즈니스 로직

    1. 휴대폰 번호 형식 검증
    2. 레이트 리미팅 확인 (Redis)
    3. OTP 생성 (6자리 난수)
    4. OTP 저장 (Redis, TTL 3분)
    5. SMS 발송 (향후 SMS API 통합)
    6. 응답 반환

    Args:
        phone: 휴대폰 번호 (010-1234-5678)

    Returns:
        SendOTPResponse: OTP 발송 응답

    Raises:
        HTTPException(400): 잘못된 형식
        HTTPException(429): 레이트 리미팅
        HTTPException(500): 서버 오류
    """
    # 1. 형식 검증
    if not is_valid_phone(phone):
        raise HTTPException(
            status_code=400,
            detail="Invalid phone format"
        )

    # 2. 레이트 리미팅 (5회/시간)
    rate_limit_key = f"otp_rate_limit:{phone}"
    attempt_count = await redis.incr(rate_limit_key)

    if attempt_count == 1:
        await redis.expire(rate_limit_key, 3600)  # 1시간

    if attempt_count > 5:
        raise HTTPException(
            status_code=429,
            detail="Too many OTP requests"
        )

    # 3. OTP 생성 (6자리 난수)
    otp = generate_otp()  # "123456"

    # 4. Redis에 저장 (TTL 3분)
    otp_key = f"otp:{phone}"
    await redis.setex(
        otp_key,
        300,  # 300초 = 5분
        otp
    )

    # 5. SMS 발송 (현재는 로그만)
    logger.info(f"OTP for {phone}: {otp}")
    # await send_sms(phone, f"인증 코드: {otp}")

    # 6. 응답 반환
    return SendOTPResponse(
        message="OTP가 발송되었습니다.",
        phone=phone,
        expires_in=300,
        status="pending"
    )
```

---

### 2. POST /api/v1/auth/verify-otp

**설명**: OTP 검증 및 JWT 토큰 발급

#### Request

```json
{
  "phone": "010-1234-5678",
  "otp": "123456"
}
```

**요청 스키마 (Pydantic)**:

```python
class VerifyOTPRequest(BaseModel):
    """OTP 검증 요청 스키마"""
    phone: str = Field(
        ...,
        pattern=r'^01[0-9]-\d{3,4}-\d{4}$',
        description="휴대폰 번호"
    )
    otp: str = Field(
        ...,
        min_length=6,
        max_length=6,
        pattern=r'^\d{6}$',
        description="6자리 OTP"
    )

    class Config:
        schema_extra = {
            "example": {
                "phone": "010-1234-5678",
                "otp": "123456"
            }
        }
```

#### Response (200 OK)

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 86400,
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "phone": "010-1234-5678",
    "name": "홍길동",
    "email": "hong@example.com",
    "role": "RENTER"
  }
}
```

**응답 스키마 (Pydantic)**:

```python
class UserResponse(BaseModel):
    """사용자 정보 응답 스키마"""
    id: UUID
    phone: str
    name: str
    email: Optional[str] = None
    role: str = Field(default="RENTER", description="SUPPLIER 또는 RENTER")

class VerifyOTPResponse(BaseModel):
    """OTP 검증 응답 스키마"""
    access_token: str = Field(
        ...,
        description="JWT 액세스 토큰 (24시간)"
    )
    refresh_token: str = Field(
        ...,
        description="JWT 갱신 토큰 (7일)"
    )
    token_type: str = Field(
        default="bearer",
        description="토큰 타입"
    )
    expires_in: int = Field(
        default=86400,
        description="토큰 만료 시간 (초, 24시간)"
    )
    user: UserResponse = Field(
        ...,
        description="사용자 정보"
    )

    class Config:
        schema_extra = {
            "example": {
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "token_type": "bearer",
                "expires_in": 86400,
                "user": {
                    "id": "550e8400-e29b-41d4-a716-446655440000",
                    "phone": "010-1234-5678",
                    "name": "홍길동",
                    "email": "hong@example.com",
                    "role": "RENTER"
                }
            }
        }
```

#### 에러 응답

| 상태 코드 | 설명 | 예시 |
|----------|------|------|
| 200 | 정상 검증 | `{"access_token": "...", "user": {...}}` |
| 400 | OTP 형식 오류 | `{"detail": "Invalid OTP format"}` |
| 401 | OTP 불일치 | `{"detail": "Invalid OTP"}` |
| 410 | OTP 만료 | `{"detail": "OTP expired"}` |
| 429 | 검증 시도 횟수 초과 | `{"detail": "Too many verification attempts"}` |
| 500 | 서버 오류 | `{"detail": "Internal server error"}` |

#### 비즈니스 로직

```python
async def verify_otp(
    phone: str,
    otp: str,
    db: Session = Depends(get_db)
) -> VerifyOTPResponse:
    """
    OTP 검증 및 JWT 토큰 발급 비즈니스 로직

    1. OTP 형식 검증
    2. Redis에서 OTP 확인
    3. OTP 비교
    4. OTP 삭제 (사용 완료)
    5. User 조회 또는 생성
    6. JWT 토큰 생성
    7. 응답 반환

    Args:
        phone: 휴대폰 번호
        otp: 입력한 OTP
        db: 데이터베이스 세션

    Returns:
        VerifyOTPResponse: JWT 토큰 및 사용자 정보

    Raises:
        HTTPException(400): OTP 형식 오류
        HTTPException(401): OTP 불일치
        HTTPException(410): OTP 만료
        HTTPException(429): 시도 횟수 초과
        HTTPException(500): 서버 오류
    """
    # 1. 형식 검증
    if not otp.isdigit() or len(otp) != 6:
        raise HTTPException(
            status_code=400,
            detail="Invalid OTP format"
        )

    # 2. Redis에서 저장된 OTP 확인
    otp_key = f"otp:{phone}"
    stored_otp = await redis.get(otp_key)

    # 3. OTP 비교
    if stored_otp is None:
        raise HTTPException(
            status_code=410,
            detail="OTP expired"
        )

    if stored_otp != otp:
        # 시도 횟수 추적
        attempt_key = f"otp_attempts:{phone}"
        attempts = await redis.incr(attempt_key)

        if attempts == 1:
            await redis.expire(attempt_key, 600)  # 10분

        if attempts > 3:
            await redis.delete(otp_key)  # OTP 삭제
            raise HTTPException(
                status_code=429,
                detail="Too many verification attempts"
            )

        raise HTTPException(
            status_code=401,
            detail="Invalid OTP"
        )

    # 4. OTP 삭제 (사용 완료)
    await redis.delete(otp_key)

    # 5. User 조회 또는 생성
    user = db.query(User).filter(User.phone == phone).first()

    if user is None:
        # 신규 사용자 생성
        user = User(
            id=uuid4(),
            phone=phone,
            name=phone,  # 기본값: 휴대폰 번호
            role="RENTER",  # 기본값
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    # 6. JWT 토큰 생성
    access_token = create_access_token(
        data={"sub": str(user.id), "phone": phone},
        expires_delta=timedelta(hours=24)
    )

    refresh_token = create_refresh_token(
        data={"sub": str(user.id)},
        expires_delta=timedelta(days=7)
    )

    # 7. 응답 반환
    return VerifyOTPResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=86400,  # 24시간
        user=UserResponse(
            id=user.id,
            phone=user.phone,
            name=user.name,
            email=user.email,
            role=user.role
        )
    )
```

---

### 3. POST /api/v1/auth/logout

**설명**: 사용자 로그아웃 (토큰 블랙리스트)

#### Request

```
Header: Authorization: Bearer {access_token}
```

**요청**:
- 헤더에 JWT 토큰 필요
- 요청 본문 없음

#### Response (200 OK)

```json
{
  "message": "로그아웃되었습니다.",
  "status": "success"
}
```

**응답 스키마 (Pydantic)**:

```python
class LogoutResponse(BaseModel):
    """로그아웃 응답 스키마"""
    message: str = Field(
        ...,
        description="응답 메시지"
    )
    status: str = Field(
        default="success",
        description="로그아웃 상태"
    )

    class Config:
        schema_extra = {
            "example": {
                "message": "로그아웃되었습니다.",
                "status": "success"
            }
        }
```

#### 에러 응답

| 상태 코드 | 설명 | 예시 |
|----------|------|------|
| 200 | 정상 로그아웃 | `{"message": "로그아웃되었습니다."}` |
| 401 | 인증되지 않음 | `{"detail": "Not authenticated"}` |
| 403 | 토큰 블랙리스트됨 | `{"detail": "Token already revoked"}` |
| 500 | 서버 오류 | `{"detail": "Internal server error"}` |

#### 비즈니스 로직

```python
async def logout(
    current_user: User = Depends(get_current_user),
    token: str = Depends(oauth2_scheme)
) -> LogoutResponse:
    """
    로그아웃 비즈니스 로직

    1. 토큰 검증
    2. 토큰 만료 시간 계산
    3. 토큰을 블랙리스트에 추가
    4. 응답 반환

    Args:
        current_user: 현재 로그인한 사용자
        token: JWT 토큰

    Returns:
        LogoutResponse: 로그아웃 응답

    Raises:
        HTTPException(401): 인증되지 않음
        HTTPException(500): 서버 오류
    """
    # 1. 토큰 검증
    if not token:
        raise HTTPException(
            status_code=401,
            detail="Not authenticated"
        )

    # 2. 토큰 디코딩하여 만료 시간 확인
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        exp = payload.get("exp")

        if exp is None:
            raise HTTPException(
                status_code=401,
                detail="Invalid token"
            )

        # 3. 토큰을 블랙리스트에 추가
        # TTL: 토큰 만료까지의 남은 시간
        now = datetime.utcnow()
        exp_datetime = datetime.utcfromtimestamp(exp)
        ttl = int((exp_datetime - now).total_seconds())

        if ttl > 0:
            blacklist_key = f"blacklist:{token}"
            await redis.setex(
                blacklist_key,
                ttl,
                "revoked"
            )

    except JWTError:
        raise HTTPException(
            status_code=401,
            detail="Invalid token"
        )

    # 4. 응답 반환
    return LogoutResponse(
        message="로그아웃되었습니다.",
        status="success"
    )
```

---

## 🔑 JWT 토큰 로직

### JWT 토큰 구조

```
Header.Payload.Signature

Header:
{
  "alg": "HS256",
  "typ": "JWT"
}

Payload (Access Token):
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",  // 사용자 ID
  "phone": "010-1234-5678",
  "exp": 1708000000,  // 만료 시간 (24시간 후)
  "iat": 1707913600,  // 발급 시간
  "type": "access"
}

Payload (Refresh Token):
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",  // 사용자 ID
  "exp": 1708604400,  // 만료 시간 (7일 후)
  "iat": 1707913600,  // 발급 시간
  "type": "refresh"
}

Signature:
HMACSHA256(
  base64UrlEncode(header) + "." +
  base64UrlEncode(payload),
  secret
)
```

### JWT 발급 (create_access_token)

```python
from datetime import datetime, timedelta
import jwt
from app.config import settings

def create_access_token(
    data: dict,
    expires_delta: Optional[timedelta] = None
) -> str:
    """
    JWT 액세스 토큰 생성

    Args:
        data: 토큰에 포함할 데이터
        expires_delta: 만료 시간

    Returns:
        str: 암호화된 JWT 토큰
    """
    to_encode = data.copy()

    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(hours=24)

    to_encode.update({
        "exp": expire,
        "iat": datetime.utcnow(),
        "type": "access"
    })

    encoded_jwt = jwt.encode(
        to_encode,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM
    )

    return encoded_jwt
```

### JWT 검증 (verify_token)

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def verify_token(token: str = Depends(oauth2_scheme)) -> dict:
    """
    JWT 토큰 검증

    Args:
        token: JWT 토큰

    Returns:
        dict: 디코딩된 토큰 페이로드

    Raises:
        HTTPException: 유효하지 않은 토큰
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        # 토큰이 블랙리스트에 있는지 확인
        blacklist_key = f"blacklist:{token}"
        if await redis.get(blacklist_key):
            raise credentials_exception

        # 토큰 디코딩
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )

        user_id: str = payload.get("sub")
        token_type: str = payload.get("type")

        if user_id is None or token_type != "access":
            raise credentials_exception

        return payload

    except JWTError:
        raise credentials_exception
```

### 현재 사용자 조회 (get_current_user)

```python
def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> User:
    """
    현재 로그인한 사용자 조회

    Args:
        token: JWT 토큰
        db: 데이터베이스 세션

    Returns:
        User: 현재 사용자

    Raises:
        HTTPException: 인증 오류
    """
    payload = verify_token(token)
    user_id: str = payload.get("sub")

    user = db.query(User).filter(User.id == UUID(user_id)).first()

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return user
```

---

## 🛡️ 보안 고려사항

### 1. HTTPS 강제

```python
# app/main.py

from fastapi.middleware.httpsredirect import HTTPSRedirectMiddleware

# 프로덕션 환경에서만 HTTPS 리다이렉트
if settings.ENVIRONMENT == "production":
    app.add_middleware(HTTPSRedirectMiddleware)
```

**설정**:
- 개발 환경: HTTP 허용
- 프로덕션 환경: HTTPS 필수
- HTTP 요청 자동 리다이렉트

### 2. 레이트 리미팅

```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

app = FastAPI()
app.state.limiter = limiter

@app.post("/api/v1/auth/send-otp")
@limiter.limit("5/hour")
async def send_otp(request: Request, req: SendOTPRequest):
    """OTP 발송 (5회/시간)"""
    pass
```

**정책**:
- OTP 발송: 5회/시간 (동일 휴대폰)
- OTP 검증: 3회/10분 (동일 휴대폰)
- API 전체: 100회/분 (동일 IP)

### 3. OTP 암호화

```python
import hashlib
import secrets

def generate_otp() -> str:
    """
    6자리 OTP 생성

    Returns:
        str: "123456" 형식의 OTP
    """
    return str(secrets.randbelow(1000000)).zfill(6)

def hash_otp(otp: str) -> str:
    """
    OTP 해시 (저장 시)

    Args:
        otp: 원본 OTP

    Returns:
        str: 해시된 OTP
    """
    return hashlib.sha256(otp.encode()).hexdigest()
```

**정책**:
- OTP는 Redis에만 저장 (데이터베이스에 저장 금지)
- 토큰은 HTTPS 암호화 전송
- 민감 정보는 로그에 기록 금지

### 4. 토큰 블랙리스트

```python
# 로그아웃 시 토큰을 블랙리스트에 추가
# Redis의 TTL을 사용하여 자동 삭제

blacklist_key = f"blacklist:{token}"
ttl = token_expiration_time  # 남은 시간
redis.setex(blacklist_key, ttl, "revoked")

# 모든 API 요청 시 블랙리스트 확인
if redis.get(f"blacklist:{token}"):
    raise HTTPException(status_code=401, detail="Token revoked")
```

### 5. CORS (Cross-Origin Resource Sharing)

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",      # 개발 환경
        "https://danngam.com"         # 프로덕션
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 6. 환경 변수 보안

```python
# app/config.py

from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    """애플리케이션 설정"""

    # 핵심 설정 (환경 변수에서 로드)
    SECRET_KEY: str  # JWT 시크릿 키
    ALGORITHM: str = "HS256"

    # 데이터베이스
    DATABASE_URL: str
    REDIS_URL: str

    # 환경
    ENVIRONMENT: str = "development"
    DEBUG: bool = False

    class Config:
        env_file = ".env"

settings = Settings()
```

**정책**:
- `.env` 파일 사용 (Git에 커밋 금지)
- 민감한 정보는 환경 변수에서만 로드
- 프로덕션 환경에서만 DEBUG=False

---

## 💾 데이터 모델

### OTP 저장소 (Redis)

```
Key: otp:{phone}
Value: {otp}
TTL: 300초 (5분)

예:
Key: otp:010-1234-5678
Value: 123456
TTL: 300
```

### 토큰 블랙리스트 (Redis)

```
Key: blacklist:{token}
Value: "revoked"
TTL: 토큰 만료까지의 남은 시간

예:
Key: blacklist:eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Value: revoked
TTL: 86400 (24시간)
```

### User 모델 (PostgreSQL)

```python
from sqlalchemy import Column, String, Float, Integer, DateTime, Enum
from sqlalchemy.dialects.postgresql import UUID
from uuid import uuid4
from datetime import datetime

class User(Base):
    """사용자 모델"""

    __tablename__ = "users"

    # Primary Key
    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid4
    )

    # 인증 정보
    phone = Column(
        String(20),
        unique=True,
        nullable=False,
        index=True
    )

    # 기본 정보
    name = Column(String(100), nullable=False)
    email = Column(String(100), nullable=True, unique=True)
    profile_image_url = Column(String(500), nullable=True)

    # 평점
    rating = Column(Float, default=0.0, nullable=False)
    review_count = Column(Integer, default=0, nullable=False)

    # 역할
    role = Column(
        Enum('SUPPLIER', 'RENTER', name='user_role_enum'),
        default='RENTER',
        nullable=False
    )

    # 시간 추적
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False
    )
```

---

## 📝 구현 예제 (FastAPI 코드)

### 1. 의존성 설정 (app/utils/auth.py)

```python
from fastapi import HTTPException, status, Depends
from fastapi.security import OAuth2PasswordBearer
from jwt import PyJWT, JWTError
from datetime import datetime, timedelta
import jwt
from typing import Optional
from app.config import settings
from app.database import redis_client, get_db
from sqlalchemy.orm import Session
from app.models.user import User
from uuid import UUID

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def create_access_token(
    data: dict,
    expires_delta: Optional[timedelta] = None
) -> str:
    """JWT 액세스 토큰 생성"""
    to_encode = data.copy()

    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(hours=24)

    to_encode.update({
        "exp": expire,
        "iat": datetime.utcnow(),
        "type": "access"
    })

    encoded_jwt = jwt.encode(
        to_encode,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM
    )

    return encoded_jwt


def create_refresh_token(
    data: dict,
    expires_delta: Optional[timedelta] = None
) -> str:
    """JWT 갱신 토큰 생성"""
    to_encode = data.copy()

    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(days=7)

    to_encode.update({
        "exp": expire,
        "iat": datetime.utcnow(),
        "type": "refresh"
    })

    encoded_jwt = jwt.encode(
        to_encode,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM
    )

    return encoded_jwt


async def verify_token(token: str) -> dict:
    """JWT 토큰 검증"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        # 토큰 블랙리스트 확인
        blacklist_key = f"blacklist:{token}"
        is_blacklisted = await redis_client.get(blacklist_key)

        if is_blacklisted:
            raise credentials_exception

        # 토큰 디코딩
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )

        user_id: str = payload.get("sub")
        token_type: str = payload.get("type")

        if user_id is None or token_type != "access":
            raise credentials_exception

        return payload

    except JWTError:
        raise credentials_exception


def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> User:
    """현재 로그인한 사용자 조회"""
    payload = verify_token(token)
    user_id: str = payload.get("sub")

    user = db.query(User).filter(User.id == UUID(user_id)).first()

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return user
```

### 2. 라우터 구현 (app/routers/auth.py)

```python
from fastapi import APIRouter, HTTPException, status, Depends, Request
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from uuid import uuid4
import re
import secrets

from app.database import get_db, redis_client
from app.models.user import User
from app.schemas.auth import (
    SendOTPRequest,
    SendOTPResponse,
    VerifyOTPRequest,
    VerifyOTPResponse,
    UserResponse,
    LogoutResponse
)
from app.utils.auth import (
    create_access_token,
    create_refresh_token,
    get_current_user,
    oauth2_scheme
)
from app.config import settings

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])


def is_valid_phone(phone: str) -> bool:
    """휴대폰 번호 형식 검증"""
    pattern = r'^01[0-9]-\d{3,4}-\d{4}$'
    return re.match(pattern, phone) is not None


def generate_otp() -> str:
    """6자리 OTP 생성"""
    return str(secrets.randbelow(1000000)).zfill(6)


@router.post(
    "/send-otp",
    response_model=SendOTPResponse,
    status_code=status.HTTP_200_OK,
    summary="OTP 발송",
    description="휴대폰 번호로 OTP 발송 요청"
)
async def send_otp(req: SendOTPRequest):
    """
    OTP 발송 엔드포인트

    - **phone**: 휴대폰 번호 (010-1234-5678 형식)

    **레이트 리미팅**: 동일 번호 5회/시간
    """

    # 1. 형식 검증
    if not is_valid_phone(req.phone):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid phone format"
        )

    # 2. 레이트 리미팅 (5회/시간)
    rate_limit_key = f"otp_rate_limit:{req.phone}"
    attempt_count = await redis_client.incr(rate_limit_key)

    if attempt_count == 1:
        await redis_client.expire(rate_limit_key, 3600)

    if attempt_count > 5:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many OTP requests"
        )

    # 3. OTP 생성
    otp = generate_otp()

    # 4. Redis에 저장 (TTL 5분)
    otp_key = f"otp:{req.phone}"
    await redis_client.setex(otp_key, 300, otp)

    # 5. SMS 발송 (현재는 로그만)
    import logging
    logger = logging.getLogger(__name__)
    logger.info(f"OTP for {req.phone}: {otp}")
    # 실제 SMS API 통합 시 여기서 호출

    return SendOTPResponse(
        message="OTP가 발송되었습니다.",
        phone=req.phone,
        expires_in=300,
        status="pending"
    )


@router.post(
    "/verify-otp",
    response_model=VerifyOTPResponse,
    status_code=status.HTTP_200_OK,
    summary="OTP 검증 및 토큰 발급",
    description="OTP 검증 후 JWT 토큰 발급"
)
async def verify_otp(
    req: VerifyOTPRequest,
    db: Session = Depends(get_db)
):
    """
    OTP 검증 및 JWT 토큰 발급 엔드포인트

    - **phone**: 휴대폰 번호
    - **otp**: 6자리 OTP

    **응답**:
    - access_token: JWT 액세스 토큰 (24시간)
    - refresh_token: JWT 갱신 토큰 (7일)
    - user: 사용자 정보

    **레이트 리미팅**: 3회/10분 (검증 시도)
    """

    # 1. 형식 검증
    if not req.otp.isdigit() or len(req.otp) != 6:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid OTP format"
        )

    # 2. Redis에서 저장된 OTP 확인
    otp_key = f"otp:{req.phone}"
    stored_otp = await redis_client.get(otp_key)

    # 3. OTP 비교
    if stored_otp is None:
        raise HTTPException(
            status_code=status.HTTP_410_GONE,
            detail="OTP expired"
        )

    if stored_otp != req.otp:
        # 시도 횟수 추적
        attempt_key = f"otp_attempts:{req.phone}"
        attempts = await redis_client.incr(attempt_key)

        if attempts == 1:
            await redis_client.expire(attempt_key, 600)

        if attempts > 3:
            await redis_client.delete(otp_key)
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Too many verification attempts"
            )

        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid OTP"
        )

    # 4. OTP 삭제 (사용 완료)
    await redis_client.delete(otp_key)

    # 5. User 조회 또는 생성
    user = db.query(User).filter(User.phone == req.phone).first()

    if user is None:
        # 신규 사용자 생성
        user = User(
            id=uuid4(),
            phone=req.phone,
            name=req.phone,  # 기본값
            role="RENTER",  # 기본값
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    # 6. JWT 토큰 생성
    access_token = create_access_token(
        data={"sub": str(user.id), "phone": req.phone},
        expires_delta=timedelta(hours=24)
    )

    refresh_token = create_refresh_token(
        data={"sub": str(user.id)},
        expires_delta=timedelta(days=7)
    )

    # 7. 응답 반환
    return VerifyOTPResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=86400,
        user=UserResponse(
            id=user.id,
            phone=user.phone,
            name=user.name,
            email=user.email,
            role=user.role
        )
    )


@router.post(
    "/logout",
    response_model=LogoutResponse,
    status_code=status.HTTP_200_OK,
    summary="로그아웃",
    description="사용자 로그아웃 (토큰 블랙리스트)"
)
async def logout(
    current_user: User = Depends(get_current_user),
    token: str = Depends(oauth2_scheme)
):
    """
    로그아웃 엔드포인트

    **Header**: Authorization: Bearer {access_token}

    **동작**:
    - 토큰을 블랙리스트에 추가
    - 토큰 만료까지의 시간만큼 Redis에 저장
    - 자동으로 삭제 (TTL 만료)
    """

    # 1. 토큰 검증
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated"
        )

    # 2. 토큰 디코딩하여 만료 시간 확인
    try:
        import jwt

        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        exp = payload.get("exp")

        if exp is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )

        # 3. 토큰을 블랙리스트에 추가
        now = datetime.utcnow()
        exp_datetime = datetime.utcfromtimestamp(exp)
        ttl = int((exp_datetime - now).total_seconds())

        if ttl > 0:
            blacklist_key = f"blacklist:{token}"
            await redis_client.setex(
                blacklist_key,
                ttl,
                "revoked"
            )

    except jwt.JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )

    return LogoutResponse(
        message="로그아웃되었습니다.",
        status="success"
    )
```

### 3. Pydantic 스키마 (app/schemas/auth.py)

```python
from pydantic import BaseModel, Field
from typing import Optional
from uuid import UUID

class SendOTPRequest(BaseModel):
    """OTP 발송 요청"""
    phone: str = Field(
        ...,
        pattern=r'^01[0-9]-\d{3,4}-\d{4}$',
        description="휴대폰 번호 (010-1234-5678)"
    )

    class Config:
        schema_extra = {
            "example": {
                "phone": "010-1234-5678"
            }
        }


class SendOTPResponse(BaseModel):
    """OTP 발송 응답"""
    message: str
    phone: str
    expires_in: int = 300
    status: str = "pending"

    class Config:
        schema_extra = {
            "example": {
                "message": "OTP가 발송되었습니다.",
                "phone": "010-1234-5678",
                "expires_in": 300,
                "status": "pending"
            }
        }


class VerifyOTPRequest(BaseModel):
    """OTP 검증 요청"""
    phone: str = Field(
        ...,
        pattern=r'^01[0-9]-\d{3,4}-\d{4}$',
        description="휴대폰 번호"
    )
    otp: str = Field(
        ...,
        min_length=6,
        max_length=6,
        pattern=r'^\d{6}$',
        description="6자리 OTP"
    )

    class Config:
        schema_extra = {
            "example": {
                "phone": "010-1234-5678",
                "otp": "123456"
            }
        }


class UserResponse(BaseModel):
    """사용자 정보 응답"""
    id: UUID
    phone: str
    name: str
    email: Optional[str] = None
    role: str = "RENTER"

    class Config:
        from_attributes = True
        schema_extra = {
            "example": {
                "id": "550e8400-e29b-41d4-a716-446655440000",
                "phone": "010-1234-5678",
                "name": "홍길동",
                "email": "hong@example.com",
                "role": "RENTER"
            }
        }


class VerifyOTPResponse(BaseModel):
    """OTP 검증 및 토큰 발급 응답"""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = 86400
    user: UserResponse

    class Config:
        schema_extra = {
            "example": {
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "token_type": "bearer",
                "expires_in": 86400,
                "user": {
                    "id": "550e8400-e29b-41d4-a716-446655440000",
                    "phone": "010-1234-5678",
                    "name": "홍길동",
                    "email": "hong@example.com",
                    "role": "RENTER"
                }
            }
        }


class LogoutResponse(BaseModel):
    """로그아웃 응답"""
    message: str
    status: str = "success"

    class Config:
        schema_extra = {
            "example": {
                "message": "로그아웃되었습니다.",
                "status": "success"
            }
        }
```

---

## 🧪 테스트 케이스

### 테스트 환경 설정

```python
# tests/conftest.py

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.main import app
from app.database import Base, get_db

# 테스트 데이터베이스
SQLALCHEMY_TEST_DATABASE_URL = "sqlite:///./test.db"

engine = create_engine(
    SQLALCHEMY_TEST_DATABASE_URL,
    connect_args={"check_same_thread": False}
)

TestingSessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

Base.metadata.create_all(bind=engine)


def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db

@pytest.fixture
def client():
    return TestClient(app)
```

### OTP 발송 테스트

```python
# tests/test_auth.py

def test_send_otp_success(client):
    """OTP 정상 발송"""
    response = client.post(
        "/api/v1/auth/send-otp",
        json={"phone": "010-1234-5678"}
    )
    assert response.status_code == 200
    assert response.json()["message"] == "OTP가 발송되었습니다."
    assert response.json()["expires_in"] == 300


def test_send_otp_invalid_format(client):
    """OTP 발송 - 잘못된 휴대폰 형식"""
    response = client.post(
        "/api/v1/auth/send-otp",
        json={"phone": "01012345678"}  # 하이픈 없음
    )
    assert response.status_code == 400
    assert "Invalid phone format" in response.json()["detail"]


def test_send_otp_rate_limiting(client):
    """OTP 발송 - 레이트 리미팅"""
    phone = "010-1234-5678"

    # 5회 정상 발송
    for i in range(5):
        response = client.post(
            "/api/v1/auth/send-otp",
            json={"phone": phone}
        )
        assert response.status_code == 200

    # 6회차는 에러
    response = client.post(
        "/api/v1/auth/send-otp",
        json={"phone": phone}
    )
    assert response.status_code == 429
    assert "Too many OTP requests" in response.json()["detail"]
```

### OTP 검증 테스트

```python
def test_verify_otp_success(client):
    """OTP 검증 - 정상"""
    phone = "010-1234-5678"

    # 1. OTP 발송
    response = client.post(
        "/api/v1/auth/send-otp",
        json={"phone": phone}
    )
    assert response.status_code == 200

    # 2. Redis에서 OTP 가져오기 (테스트용)
    # 실제 구현에서는 mock이나 테스트 DB 사용

    # 3. OTP 검증
    response = client.post(
        "/api/v1/auth/verify-otp",
        json={"phone": phone, "otp": "123456"}
    )
    # 테스트 OTP 저장 후 검증
    # assert response.status_code == 200
    # assert "access_token" in response.json()


def test_verify_otp_invalid_format(client):
    """OTP 검증 - 잘못된 형식"""
    response = client.post(
        "/api/v1/auth/verify-otp",
        json={"phone": "010-1234-5678", "otp": "12345"}  # 5자리
    )
    assert response.status_code == 400


def test_verify_otp_expired(client):
    """OTP 검증 - 만료된 OTP"""
    response = client.post(
        "/api/v1/auth/verify-otp",
        json={"phone": "010-1234-5678", "otp": "123456"}
    )
    assert response.status_code == 410
    assert "OTP expired" in response.json()["detail"]


def test_verify_otp_invalid_otp(client):
    """OTP 검증 - 잘못된 OTP"""
    phone = "010-1234-5678"

    # OTP 발송
    client.post(
        "/api/v1/auth/send-otp",
        json={"phone": phone}
    )

    # 잘못된 OTP로 검증
    response = client.post(
        "/api/v1/auth/verify-otp",
        json={"phone": phone, "otp": "000000"}
    )
    assert response.status_code == 401
    assert "Invalid OTP" in response.json()["detail"]
```

### 로그아웃 테스트

```python
def test_logout_success(client):
    """로그아웃 - 정상"""
    # 인증 후 토큰 획득
    # token = "..."

    # response = client.post(
    #     "/api/v1/auth/logout",
    #     headers={"Authorization": f"Bearer {token}"}
    # )
    # assert response.status_code == 200
    # assert response.json()["message"] == "로그아웃되었습니다."


def test_logout_no_token(client):
    """로그아웃 - 토큰 없음"""
    response = client.post("/api/v1/auth/logout")
    assert response.status_code == 403  # 또는 401


def test_logout_invalid_token(client):
    """로그아웃 - 잘못된 토큰"""
    response = client.post(
        "/api/v1/auth/logout",
        headers={"Authorization": "Bearer invalid_token"}
    )
    assert response.status_code == 401
```

---

## 📋 인수 기준 (Acceptance Criteria)

### AC-1: OTP 발송 기능

- [ ] POST /api/v1/auth/send-otp 엔드포인트 정상 작동
- [ ] 휴대폰 번호 형식 검증 (010-xxxx-xxxx)
- [ ] OTP 6자리 난수 생성
- [ ] OTP Redis에 저장 (TTL 5분)
- [ ] 레이트 리미팅 적용 (5회/시간)
- [ ] 정상 응답 시 200 OK + JSON 응답
- [ ] 에러 응답 시 400/429 상태 코드
- [ ] Postman 테스트 통과

### AC-2: OTP 검증 및 토큰 발급

- [ ] POST /api/v1/auth/verify-otp 엔드포인트 정상 작동
- [ ] OTP 형식 검증 (6자리 숫자)
- [ ] Redis에서 저장된 OTP 확인
- [ ] OTP 일치 여부 확인
- [ ] OTP 검증 횟수 제한 (3회/10분)
- [ ] OTP 만료 시 410 Gone 응답
- [ ] 신규 사용자 자동 생성
- [ ] JWT 액세스 토큰 발급 (24시간)
- [ ] JWT 갱신 토큰 발급 (7일)
- [ ] 사용자 정보 함께 반환
- [ ] Postman 테스트 통과

### AC-3: 로그아웃 기능

- [ ] POST /api/v1/auth/logout 엔드포인트 정상 작동
- [ ] 토큰 검증 (Authorization 헤더)
- [ ] 토큰을 블랙리스트에 추가
- [ ] Redis에 TTL과 함께 저장
- [ ] 로그아웃 후 동일 토큰으로 API 접근 불가
- [ ] 정상 응답 시 200 OK + JSON 응답
- [ ] Postman 테스트 통과

### AC-4: 보안 요구사항

- [ ] HTTPS 리다이렉트 설정
- [ ] 레이트 리미팅 구현
- [ ] JWT 시크릿 키 환경 변수 관리
- [ ] OTP는 Redis에만 저장 (DB 저장 금지)
- [ ] 토큰 블랙리스트 관리
- [ ] CORS 설정 완료
- [ ] 민감 정보 로그에 기록 금지

### AC-5: 데이터베이스 요구사항

- [ ] User 모델 구현 (phone 유니크)
- [ ] 신규 사용자 자동 생성
- [ ] created_at, updated_at 타임스탬프
- [ ] role 기본값 'RENTER'

---

## 📅 다음 단계 (Phase A-5)

### Phase A-5: 장비 API 구현 (1주)

**목표**: 6개의 장비 검색 API 구현

**API 엔드포인트**:
1. GET /api/v1/equipments/nearby (위치 기반)
2. GET /api/v1/equipments/fixed (고정형)
3. GET /api/v1/equipments/{id} (상세)
4. GET /api/v1/equipments/categories (카테고리)
5. GET /api/v1/equipments/search (검색)
6. GET /api/v1/equipments/{id}/availability (가용성)

**예상 기간**: 1주 (개발) + 1주 (테스트)

**선행 작업**:
- [ ] Phase A-4 완료 및 테스트
- [ ] Equipment, EquipmentImage 모델 재확인
- [ ] 데이터베이스 샘플 데이터 10개 이상

---

## 🔍 개발 가이드라인

### 코드 구조

```
app/
├── routers/
│   └── auth.py                 # 인증 엔드포인트
├── schemas/
│   └── auth.py                 # Pydantic 스키마
├── utils/
│   ├── auth.py                 # JWT, OTP 유틸
│   └── validators.py           # 검증 함수
├── models/
│   └── user.py                 # User 모델 (Phase A-3)
├── database.py                 # DB, Redis 연결
├── config.py                   # 환경 변수
└── main.py                     # FastAPI 앱
```

### 커밋 메시지

```
[A][A-4] 인증 API 구현 완료

- OTP 발송 API (send-otp)
- OTP 검증 및 토큰 발급 API (verify-otp)
- 로그아웃 API (logout)
- JWT 토큰 관리 로직
- 레이트 리미팅
- 토큰 블랙리스트
```

### 개발 체크리스트

- [ ] Pydantic 스키마 구현
- [ ] 라우터 구현 (3개 엔드포인트)
- [ ] JWT 유틸 함수 구현
- [ ] OTP 생성/검증 로직 구현
- [ ] 에러 처리 (HTTP 상태 코드)
- [ ] 보안 고려사항 (HTTPS, 레이트 리미팅)
- [ ] Postman 테스트 (모든 케이스)
- [ ] 테스트 코드 작성
- [ ] 기획 문서와 코드 일치 확인
- [ ] 코드 리뷰 및 병합

---

## 📞 FAQ

### Q1: OTP를 실제 SMS로 발송하려면?

**A**: SMS API 제공자 (예: Twilio, NCP, KakaoTalk) 계정 필요. 환경 변수에 API 키 설정 후 `send_sms()` 함수 구현.

```python
async def send_sms(phone: str, message: str):
    """실제 SMS 발송 (예: Twilio)"""
    from twilio.rest import Client

    client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
    client.messages.create(
        body=message,
        from_=settings.TWILIO_PHONE_NUMBER,
        to=phone
    )
```

### Q2: Redis가 없으면 어떻게 하나?

**A**: 개발 환경에서는 메모리 저장소 사용 가능. 프로덕션에서는 Redis 필수.

```python
# 메모리 저장소 (개발 환경)
otp_storage = {}  # {phone: (otp, expires_at)}

# Redis (프로덕션)
await redis_client.setex(key, ttl, value)
```

### Q3: Refresh Token은 어떻게 사용하나?

**A**: Access Token이 만료되면 Refresh Token으로 새 Access Token 발급. Phase A-5 이후에 구현 예정.

```python
@router.post("/refresh-token")
async def refresh_token(refresh_token: str):
    # Refresh Token 검증
    # 새 Access Token 발급
    # 새 Refresh Token 발급 (optional)
    pass
```

### Q4: 휴대폰 번호 형식이 다르면?

**A**: Pydantic의 regex 패턴을 수정하거나, 정규화 함수 추가.

```python
def normalize_phone(phone: str) -> str:
    """휴대폰 번호 정규화"""
    # "01012345678" → "010-1234-5678"
    phone = phone.replace("-", "")
    if len(phone) == 11:
        return f"{phone[:3]}-{phone[3:7]}-{phone[7:]}"
    return phone
```

---

**작성자**: 기획팀
**작성일**: 2026-02-14
**버전**: 1.0.0
**상태**: 개발 준비 완료
