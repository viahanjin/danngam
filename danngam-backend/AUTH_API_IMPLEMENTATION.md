# Phase A-4: 인증 API 구현 완료 문서

## 개요
FastAPI 기반 Danngam 농기계 공유 플랫폼의 인증 API 구현이 완료되었습니다.

**구현 일시**: 2026-02-14
**구현 상태**: 완료
**파일 구조**: 모듈화된 설계로 향후 확장 용이

---

## 구현된 파일 목록

### 1. 설정 수정
- **파일**: `/Users/hanjinjang/Desktop/회사/danngam/danngam-backend/app/config.py`
- **변경사항**:
  - `ACCESS_TOKEN_EXPIRE_MINUTES`: 30 → 24시간 (1440분)
  - `ACCESS_TOKEN_EXPIRE_HOURS`: 24 시간 추가
  - `OTP_EXPIRE_SECONDS`: 180초 (3분)
  - `OTP_EXPIRE_MINUTES`: 3분
  - `OTP_LENGTH`: 6자리
  - `MAX_OTP_ATTEMPTS_PER_HOUR`: 5회 (레이트 리미팅)

### 2. OTP 유틸리티
- **파일**: `/Users/hanjinjang/Desktop/회사/danngam/danngam-backend/app/utils/otp.py` (177줄)
- **기능**:
  - `generate_otp()`: 6자리 OTP 코드 생성
  - `save_otp()`: OTP 저장 및 만료 시간 설정
  - `verify_otp()`: OTP 검증
  - `get_otp_expires_in()`: 남은 유효 시간 조회
  - `is_rate_limited()`: 레이트 리미팅 확인 (1시간당 5회)
  - `increment_rate_limit()`: 레이트 리미팅 카운터 증가
  - `get_otp_id()`: OTP 코드 조회 (테스트용)
  - `cleanup_expired_otps()`: 만료된 OTP 정리

### 3. JWT 인증 유틸리티
- **파일**: `/Users/hanjinjang/Desktop/회사/danngam/danngam-backend/app/utils/auth.py` (109줄)
- **기능**:
  - `create_access_token()`: JWT 토큰 생성 (24시간 유효)
  - `verify_token()`: JWT 토큰 검증
  - `extract_token_from_header()`: Authorization 헤더에서 Bearer 토큰 추출
  - `get_token_expire_time()`: 토큰 만료 시간 반환 (초 단위)
- **알고리즘**: HS256
- **만료 시간**: 24시간 (86400초)

### 4. Pydantic 스키마
- **파일**: `/Users/hanjinjang/Desktop/회사/danngam/danngam-backend/app/schemas/auth.py` (185줄)
- **스키마**:
  - `SendOTPRequest`: OTP 발송 요청 (phone)
  - `SendOTPResponse`: OTP 발송 응답 (message, otp_id, expires_in)
  - `VerifyOTPRequest`: OTP 검증 요청 (phone, otp_code)
  - `VerifyOTPResponse`: OTP 검증 응답 (access_token, token_type, expires_in)
  - `LogoutRequest`: 로그아웃 요청
  - `LogoutResponse`: 로그아웃 응답 (message)
  - `ErrorResponse`: 에러 응답 (detail, status_code)

### 5. 인증 라우터
- **파일**: `/Users/hanjinjang/Desktop/회사/danngam/danngam-backend/app/routers/auth.py` (256줄)
- **엔드포인트** (3개):
  1. `POST /api/v1/auth/send-otp` - OTP 발송
  2. `POST /api/v1/auth/verify-otp` - OTP 검증 및 로그인
  3. `POST /api/v1/auth/logout` - 로그아웃

### 6. 메인 애플리케이션 수정
- **파일**: `/Users/hanjinjang/Desktop/회사/danngam/danngam-backend/app/main.py`
- **변경사항**: 인증 라우터 임포트 및 등록

### 7. 의존성 업데이트
- **파일**: `/Users/hanjinjang/Desktop/회사/danngam/danngam-backend/requirements.txt`
- **추가**: `PyJWT==2.8.1`

---

## API 명세서

### 1. OTP 발송 API

#### 엔드포인트
```
POST /api/v1/auth/send-otp
```

#### 요청 본문
```json
{
    "phone": "010-1234-5678"
}
```

#### 성공 응답 (200 OK)
```json
{
    "message": "OTP가 발송되었습니다. 3분 내에 입력해주세요.",
    "otp_id": "123456",
    "expires_in": 180
}
```

#### 에러 응답

**400 Bad Request** - 잘못된 전화번호
```json
{
    "detail": "유효한 전화번호 형식이 아닙니다 (최소 10자리)"
}
```

**429 Too Many Requests** - 레이트 리미팅 초과
```json
{
    "detail": "1시간에 5회 이상 요청할 수 없습니다. 잠시 후 다시 시도해주세요."
}
```

---

### 2. OTP 검증 및 로그인 API

#### 엔드포인트
```
POST /api/v1/auth/verify-otp
```

#### 요청 본문
```json
{
    "phone": "010-1234-5678",
    "otp_code": "123456"
}
```

#### 성공 응답 (200 OK)
```json
{
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyX2lkIiwicGhvbmUiOiIwMTAtMTIzNC01Njc4IiwiZXhwIjoxNzEzMjE4NzMxfQ.xY...",
    "token_type": "bearer",
    "expires_in": 86400
}
```

#### 에러 응답

**400 Bad Request** - OTP 코드 불일치 또는 만료
```json
{
    "detail": "OTP 코드 불일치"
}
```

또는

```json
{
    "detail": "OTP 만료됨"
}
```

---

### 3. 로그아웃 API

#### 엔드포인트
```
POST /api/v1/auth/logout
```

#### 요청 헤더
```
Authorization: Bearer {access_token}
```

#### 성공 응답 (200 OK)
```json
{
    "message": "로그아웃되었습니다."
}
```

#### 에러 응답

**401 Unauthorized** - 유효한 토큰이 없음
```json
{
    "detail": "Authorization 헤더가 없습니다"
}
```

또는

```json
{
    "detail": "토큰이 만료되었습니다"
}
```

---

## 기술 상세 정보

### OTP 로직
- **저장소**: 메모리 기반 딕셔너리 (프로덕션은 Redis 권장)
- **생성**: random 모듈로 6자리 숫자 생성
- **검증**: 코드 일치 여부 및 만료 시간 확인
- **만료**: 3분 (180초)
- **레이트 리미팅**: 1시간당 동일 번호 최대 5회 요청

### JWT 토큰
- **알고리즘**: HS256
- **시크릿 키**: `config.SECRET_KEY` (환경 변수)
- **페이로드**: `sub` (사용자 ID), `phone` (전화번호), `exp` (만료 시간)
- **만료**: 24시간 (86400초)

### 사용자 관리
- **자동 생성**: OTP 검증 시 기존 사용자가 없으면 자동 생성
- **기본 이름**: 전화번호 (나중에 수정 가능)
- **역할**: 기본값 `RENTER` (User 모델 참조)

---

## 테스트 방법

### 사전 준비
```bash
# 프로젝트 디렉토리로 이동
cd /Users/hanjinjang/Desktop/회사/danngam/danngam-backend

# 의존성 설치 (필요시)
pip install -r requirements.txt

# 데이터베이스 실행 (Docker)
docker-compose up -d

# FastAPI 서버 시작
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Postman 테스트 시나리오

#### 1. OTP 발송 테스트
```
POST http://localhost:8000/api/v1/auth/send-otp

Request Body:
{
    "phone": "010-1234-5678"
}

Expected Response (200):
{
    "message": "OTP가 발송되었습니다. 3분 내에 입력해주세요.",
    "otp_id": "123456",
    "expires_in": 180
}
```

#### 2. OTP 검증 테스트
```
POST http://localhost:8000/api/v1/auth/verify-otp

Request Body:
{
    "phone": "010-1234-5678",
    "otp_code": "123456"
}

Expected Response (200):
{
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer",
    "expires_in": 86400
}

Note: 응답의 access_token을 복사하여 다음 테스트에 사용
```

#### 3. 로그아웃 테스트
```
POST http://localhost:8000/api/v1/auth/logout

Headers:
Authorization: Bearer {위에서 받은 access_token}

Expected Response (200):
{
    "message": "로그아웃되었습니다."
}
```

#### 4. 토큰 만료 테스트
```
POST http://localhost:8000/api/v1/auth/logout

Headers:
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.invalid...

Expected Response (401):
{
    "detail": "토큰이 유효하지 않습니다"
}
```

#### 5. 레이트 리미팅 테스트
```
# 동일 번호로 6번 이상 OTP 발송 요청
POST http://localhost:8000/api/v1/auth/send-otp

Request Body:
{
    "phone": "010-1234-5678"
}

Expected Response (6번째 요청, 429):
{
    "detail": "1시간에 5회 이상 요청할 수 없습니다. 잠시 후 다시 시도해주세요."
}
```

---

## 코드 구조 및 모듈화

### 장점
1. **독립적 모듈**: 각 기능이 독립적으로 개발/테스트 가능
2. **재사용성**: OTP/JWT 유틸리티를 다른 기능에서 재사용 가능
3. **유지보수성**: 변경이 필요할 때 해당 모듈만 수정
4. **테스트 용이성**: 단위 테스트 작성이 간편

### 의존성 관계
```
auth.py (라우터)
├── auth.py (JWT 유틸리티)
├── otp.py (OTP 유틸리티)
├── auth.py (스키마)
├── user.py (모델)
└── database.py (세션)
```

---

## 보안 고려사항

### 현재 구현
- ✅ JWT 토큰 검증
- ✅ OTP 만료 시간 관리
- ✅ 레이트 리미팅 (1시간 5회)
- ✅ Bearer 토큰 추출 검증
- ✅ 전화번호 형식 검증

### 프로덕션 권장사항
- [ ] HTTPS 필수
- [ ] JWT 시크릿 키를 강력한 무작위 문자열로 변경
- [ ] OTP 저장소를 Redis로 마이그레이션
- [ ] 토큰 블랙리스트 구현 (로그아웃 기능 강화)
- [ ] 레이트 리미팅을 Redis로 마이그레이션
- [ ] SMS 서비스 통합 (실제 OTP 발송)
- [ ] CORS 정책 제한
- [ ] 로깅 및 모니터링 추가

---

## 인수 기준 검증

### ✅ 구현 완료
- [x] OTP 코드: 6자리 숫자 (000000-999999)
- [x] OTP 만료: 3분 (180초)
- [x] JWT 토큰 만료: 24시간
- [x] JWT 시크릿: config에서 읽기
- [x] 사용자 없으면 자동 생성
- [x] 레이트 리미팅: 동일 번호 5회/시간 제한
- [x] 에러 처리: 400, 401, 429, 500
- [x] POST /api/v1/auth/send-otp 구현
- [x] POST /api/v1/auth/verify-otp 구현
- [x] POST /api/v1/auth/logout 구현
- [x] Pydantic 스키마 정의
- [x] 개발 환경에서 otp_id 반환 (테스트용)

---

## 다음 단계 (Phase B)

### Phase B-1: 장비 API (6개 엔드포인트)
- GET /api/v1/equipments/nearby
- GET /api/v1/equipments/fixed
- GET /api/v1/equipments/{id}
- GET /api/v1/equipments/categories
- GET /api/v1/equipments/search
- GET /api/v1/equipments/{id}/availability

### Phase B-2: 예약 API (4개 엔드포인트)
- POST /api/v1/bookings
- GET /api/v1/bookings/{id}
- PATCH /api/v1/bookings/{id}/cancel
- GET /api/v1/bookings/my

### Phase B-3: 결제 API (3개 엔드포인트)
- POST /api/v1/payments/initiate
- POST /api/v1/payments/confirm
- GET /api/v1/payments/{id}

---

## 파일 목록 및 라인 수

| 파일 | 라인 수 | 설명 |
|------|--------|------|
| app/utils/otp.py | 177 | OTP 생성/검증 로직 |
| app/utils/auth.py | 109 | JWT 토큰 생성/검증 |
| app/schemas/auth.py | 185 | Pydantic 스키마 |
| app/routers/auth.py | 256 | 인증 API 라우터 |
| app/config.py | 27 | 설정 (수정) |
| app/main.py | 21 | 메인 애플리케이션 (수정) |
| requirements.txt | 14 | 의존성 (수정) |
| **Total** | **789** | **구현 완료** |

---

## 문의 및 개선사항

### 개발 중 발견된 개선사항
1. **Redis 마이그레이션**: OTP 저장소를 Redis로 변경하면 서버 재시작 시에도 OTP 유지 가능
2. **이메일 인증**: 전화번호 대신 이메일 OTP도 구현 고려
3. **토큰 블랙리스트**: 로그아웃 시 토큰을 무효화하려면 토큰 블랙리스트 구현 필요
4. **모바일 번호 검증**: 정규표현식으로 더 정확한 한국 휴대폰 번호 검증
5. **CORS 정책**: 프로덕션에서는 구체적인 도메인으로 제한

---

**작성자**: 개발팀
**작성일**: 2026-02-14
**Status**: Phase A-4 완료
**Version**: 1.0.0
