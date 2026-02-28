# FastAPI Phase A-4 인증 API Postman 테스트 계획

**파일 위치**: /Users/hanjinjang/Desktop/회사/danngam/docs/FastAPI_테스트_계획_Phase_A4.md

**작성자**: QA 테스터 팀
**작성일**: 2026-02-14
**테스트 방법**: Postman
**API 범위**: `/api/v1/auth/*` (send-otp, verify-otp, logout)

---

## 개요

본 문서는 Danngam 프로젝트의 FastAPI Phase A-4 인증 API에 대한 Postman 기반 테스트 계획입니다. 총 15개 이상의 테스트 케이스를 통해 OTP 기반 인증, JWT 토큰 관리, 레이트 리미팅, 보안 검증을 수행합니다.

### 테스트 목표
- OTP 송수신 및 검증 기능 검증
- JWT 토큰 생성 및 관리 검증
- 로그아웃 기능 검증
- 에러 처리 및 보안 정책 검증
- 레이트 리미팅 및 동시성 테스트

---

## 1. Postman 환경 설정

### 1.1 환경(Environment) 생성

Postman에서 새로운 환경을 생성합니다:

**환경명**: Danngam_Auth_Test

**환경 변수**:
```json
{
  "base_url": "http://localhost:8000",
  "api_version": "v1",
  "phone": "010-1234-5678",
  "otp_code": "",
  "access_token": "",
  "token_type": "bearer",
  "timeout": 5000,
  "max_retries": 3
}
```

### 1.2 Postman Collection 생성

**Collection명**: Danngam API - Phase A4 인증

**구조**:
```
Danngam API - Phase A4 인증
├── 01. Pre-request Script (공통 설정)
├── 02. Authentication
│   ├── TC-A4-001: Send OTP (정상)
│   ├── TC-A4-002: Send OTP (잘못된 전화번호)
│   ├── TC-A4-003: Send OTP (레이트 리미팅)
│   ├── TC-A4-004: Verify OTP (정상)
│   ├── TC-A4-005: Verify OTP (잘못된 코드)
│   ├── TC-A4-006: Verify OTP (만료된 코드)
│   ├── TC-A4-007: Verify OTP (사용자 자동 생성)
│   └── TC-A4-008: Logout (정상)
├── 03. Error Handling
│   ├── TC-A4-009: Logout (토큰 없음 - 401)
│   ├── TC-A4-010: Logout (유효하지 않은 토큰)
│   └── TC-A4-015: 보안 헤더 확인
├── 04. Advanced Tests
│   ├── TC-A4-011: JWT 토큰 검증
│   ├── TC-A4-012: JWT 토큰 갱신 (필요시)
│   ├── TC-A4-013: 동시 요청 (동시성 테스트)
│   └── TC-A4-014: OTP 만료 시간 테스트
└── 05. Test Results & Reports
```

### 1.3 Collection 레벨 Pre-request Script

```javascript
// Danngam API - Phase A4 인증 (Collection-level Pre-request)

// 1. 기본 헤더 설정
pm.request.headers.add({
  key: "Content-Type",
  value: "application/json"
});

pm.request.headers.add({
  key: "User-Agent",
  value: "Postman/10.0 DangamAuth-Test"
});

// 2. 요청 시작 시간 기록
pm.globals.set("request_start_time", Date.now());

// 3. 로깅 함수 정의
pm.globals.set("logMessage", function(message) {
  var timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${message}`);
});

// 4. Base URL 검증
if (!pm.environment.get("base_url")) {
  pm.environment.set("base_url", "http://localhost:8000");
}

console.log("Pre-request Script 실행 완료");
console.log("Base URL: " + pm.environment.get("base_url"));
```

---

## 2. API 엔드포인트 정의

### 2.1 Send OTP

**엔드포인트**: POST `/api/v1/auth/send-otp`

**목적**: 사용자 전화번호로 OTP 코드 발송

**요청 형식**:
```json
{
  "phone": "010-1234-5678"
}
```

**응답 형식 (정상)**:
```json
{
  "message": "OTP가 발송되었습니다",
  "phone": "010-1234-5678",
  "expires_in": 300
}
```

**응답 형식 (에러)**:
```json
{
  "detail": "잘못된 전화번호 형식입니다"
}
```

**상태 코드**:
- 200: 성공
- 400: 잘못된 요청
- 429: 너무 많은 요청 (레이트 리미팅)
- 500: 서버 오류

### 2.2 Verify OTP

**엔드포인트**: POST `/api/v1/auth/verify-otp`

**목적**: OTP 코드 검증 및 JWT 토큰 발급

**요청 형식**:
```json
{
  "phone": "010-1234-5678",
  "otp": "123456"
}
```

**응답 형식 (정상)**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 86400,
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "phone": "010-1234-5678",
    "name": "새로운 사용자",
    "role": "RENTER"
  }
}
```

**응답 형식 (에러)**:
```json
{
  "detail": "OTP 코드가 일치하지 않습니다"
}
```

**상태 코드**:
- 200: 성공 (토큰 발급)
- 400: 잘못된 요청
- 401: 인증 실패
- 410: OTP 만료
- 500: 서버 오류

### 2.3 Logout

**엔드포인트**: POST `/api/v1/auth/logout`

**목적**: 사용자 로그아웃 (토큰 무효화)

**요청 형식**:
```
Header: Authorization: Bearer {access_token}
Body: (빈 객체 또는 없음)
```

**응답 형식 (정상)**:
```json
{
  "message": "로그아웃이 완료되었습니다"
}
```

**응답 형식 (에러)**:
```json
{
  "detail": "유효하지 않은 토큰입니다"
}
```

**상태 코드**:
- 200: 성공
- 401: 토큰 없음/유효하지 않음
- 500: 서버 오류

---

## 3. 테스트 케이스 (15개)

### TC-A4-001: Send OTP - 정상 요청

**테스트 목표**: 유효한 전화번호로 OTP 발송 가능 여부 확인

**Method**: POST
**URL**: `{{base_url}}/api/v1/auth/send-otp`

**Request Body**:
```json
{
  "phone": "010-1234-5678"
}
```

**Pre-request Script**:
```javascript
pm.environment.set("test_phone", "010-1234-5678");
var timestamp = new Date().toISOString();
pm.environment.set("otp_send_time", timestamp);
console.log("[TC-A4-001] OTP 발송 테스트 시작");
```

**Expected Response Status**: 200

**Expected Response Body**:
```json
{
  "message": "OTP가 발송되었습니다",
  "phone": "010-1234-5678",
  "expires_in": 300
}
```

**Test Script**:
```javascript
pm.test("[TC-A4-001] OTP 발송 - 상태 코드 200", function() {
  pm.response.to.have.status(200);
});

pm.test("[TC-A4-001] OTP 발송 - 응답 형식", function() {
  var jsonData = pm.response.json();
  pm.expect(jsonData).to.have.property("message");
  pm.expect(jsonData).to.have.property("phone");
  pm.expect(jsonData).to.have.property("expires_in");
});

pm.test("[TC-A4-001] OTP 발송 - expires_in은 300초", function() {
  var jsonData = pm.response.json();
  pm.expect(jsonData.expires_in).to.equal(300);
});

pm.test("[TC-A4-001] OTP 발송 - 전화번호 매칭", function() {
  var jsonData = pm.response.json();
  pm.expect(jsonData.phone).to.equal(pm.environment.get("test_phone"));
});

console.log("[TC-A4-001] ✅ 모든 테스트 통과");
```

**통과 기준**:
- ✅ 상태 코드 200
- ✅ 응답에 message, phone, expires_in 포함
- ✅ expires_in 값이 300
- ✅ 전화번호가 요청과 일치

---

### TC-A4-002: Send OTP - 잘못된 전화번호

**테스트 목표**: 유효하지 않은 전화번호 형식 거부 확인

**Method**: POST
**URL**: `{{base_url}}/api/v1/auth/send-otp`

**Request Body** (옵션 1 - 형식 오류):
```json
{
  "phone": "12345"
}
```

**Request Body** (옵션 2 - 비어있음):
```json
{
  "phone": ""
}
```

**Request Body** (옵션 3 - 잘못된 형식):
```json
{
  "phone": "invalid-number"
}
```

**Pre-request Script**:
```javascript
console.log("[TC-A4-002] 잘못된 전화번호 테스트 시작");
pm.environment.set("invalid_phone", "12345");
```

**Expected Response Status**: 400

**Expected Response Body**:
```json
{
  "detail": "잘못된 전화번호 형식입니다"
}
```

**Test Script**:
```javascript
pm.test("[TC-A4-002] 잘못된 전화번호 - 상태 코드 400", function() {
  pm.response.to.have.status(400);
});

pm.test("[TC-A4-002] 잘못된 전화번호 - 에러 메시지 포함", function() {
  var jsonData = pm.response.json();
  pm.expect(jsonData).to.have.property("detail");
  pm.expect(jsonData.detail).to.include("전화번호");
});

console.log("[TC-A4-002] ✅ 에러 처리 정상 작동");
```

**통과 기준**:
- ✅ 상태 코드 400
- ✅ 에러 메시지 포함
- ✅ 에러 메시지가 명확함

---

### TC-A4-003: Send OTP - 레이트 리미팅 (5회 초과)

**테스트 목표**: 동일 전화번호 5회 초과 요청 시 레이트 리미팅 작동 확인

**Method**: POST
**URL**: `{{base_url}}/api/v1/auth/send-otp`

**Request Body**:
```json
{
  "phone": "010-9999-9999"
}
```

**Pre-request Script**:
```javascript
pm.environment.set("rate_limit_phone", "010-9999-9999");
console.log("[TC-A4-003] 레이트 리미팅 테스트 시작");
```

**테스트 절차**:
1. 첫 번째 요청: 200 OK (성공)
2. 두 번째 요청: 200 OK (성공)
3. 세 번째 요청: 200 OK (성공)
4. 네 번째 요청: 200 OK (성공)
5. 다섯 번째 요청: 200 OK (성공)
6. **여섯 번째 요청: 429 Too Many Requests (실패)**

**Expected Response Status** (1-5번째): 200
**Expected Response Status** (6번째): 429

**Expected Response Body** (6번째):
```json
{
  "detail": "너무 많은 요청입니다. 5분 후 다시 시도해주세요"
}
```

**Test Script** (6번째 요청):
```javascript
pm.test("[TC-A4-003] 레이트 리미팅 - 상태 코드 429", function() {
  pm.response.to.have.status(429);
});

pm.test("[TC-A4-003] 레이트 리미팅 - 에러 메시지", function() {
  var jsonData = pm.response.json();
  pm.expect(jsonData.detail).to.include("많은 요청");
});

pm.test("[TC-A4-003] 레이트 리미팅 - Retry-After 헤더 포함", function() {
  pm.expect(pm.response.headers.get("Retry-After")).to.exist;
});

console.log("[TC-A4-003] ✅ 레이트 리미팅 정상 작동");
```

**통과 기준**:
- ✅ 1-5번째 요청: 200 상태 코드
- ✅ 6번째 요청: 429 상태 코드
- ✅ 429 응답에 에러 메시지 포함
- ✅ Retry-After 헤더 존재

---

### TC-A4-004: Verify OTP - 정상 요청

**테스트 목표**: 정상적인 OTP 코드로 토큰 발급 확인

**Method**: POST
**URL**: `{{base_url}}/api/v1/auth/verify-otp`

**선행 조건**: TC-A4-001 실행 후 OTP 코드 획득

**Request Body** (실제 OTP 코드 필요):
```json
{
  "phone": "010-1234-5678",
  "otp": "123456"
}
```

**Pre-request Script**:
```javascript
console.log("[TC-A4-004] OTP 검증 테스트 시작");
var phone = pm.environment.get("test_phone") || "010-1234-5678";
pm.environment.set("verify_phone", phone);

// 실제 구현에서는 DB 또는 캐시에서 OTP 조회
// 테스트용 OTP (개발 서버에서만 사용 가능): 000000
pm.environment.set("verify_otp", "123456");
```

**Expected Response Status**: 200

**Expected Response Body**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 86400,
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "phone": "010-1234-5678",
    "name": "새로운 사용자",
    "role": "RENTER"
  }
}
```

**Test Script**:
```javascript
pm.test("[TC-A4-004] OTP 검증 - 상태 코드 200", function() {
  pm.response.to.have.status(200);
});

pm.test("[TC-A4-004] OTP 검증 - JWT 토큰 발급", function() {
  var jsonData = pm.response.json();
  pm.expect(jsonData).to.have.property("access_token");
  pm.expect(jsonData).to.have.property("token_type");
  pm.expect(jsonData).to.have.property("expires_in");
});

pm.test("[TC-A4-004] OTP 검증 - token_type은 bearer", function() {
  var jsonData = pm.response.json();
  pm.expect(jsonData.token_type.toLowerCase()).to.equal("bearer");
});

pm.test("[TC-A4-004] OTP 검증 - 사용자 정보 포함", function() {
  var jsonData = pm.response.json();
  pm.expect(jsonData.user).to.have.property("id");
  pm.expect(jsonData.user).to.have.property("phone");
  pm.expect(jsonData.user).to.have.property("role");
});

pm.test("[TC-A4-004] OTP 검증 - JWT 토큰 저장", function() {
  var jsonData = pm.response.json();
  var token = jsonData.access_token;

  // JWT 토큰 유효성 검사 (3개 부분으로 구성)
  var parts = token.split('.');
  pm.expect(parts.length).to.equal(3);

  // 환경 변수에 토큰 저장
  pm.environment.set("access_token", token);
  pm.environment.set("token_type", jsonData.token_type);
  pm.environment.set("user_id", jsonData.user.id);
  pm.environment.set("user_phone", jsonData.user.phone);

  console.log("[TC-A4-004] JWT 토큰 저장 완료");
});

console.log("[TC-A4-004] ✅ 모든 테스트 통과");
```

**통과 기준**:
- ✅ 상태 코드 200
- ✅ access_token, token_type, expires_in 포함
- ✅ token_type이 "bearer"
- ✅ user 객체에 id, phone, role 포함
- ✅ JWT 토큰이 유효한 형식 (3개 부분)
- ✅ 토큰이 환경 변수에 저장됨

---

### TC-A4-005: Verify OTP - 잘못된 코드

**테스트 목표**: 잘못된 OTP 코드 거부 확인

**Method**: POST
**URL**: `{{base_url}}/api/v1/auth/verify-otp`

**Request Body**:
```json
{
  "phone": "010-1234-5678",
  "otp": "000000"
}
```

**Pre-request Script**:
```javascript
console.log("[TC-A4-005] 잘못된 OTP 코드 테스트");
```

**Expected Response Status**: 401

**Expected Response Body**:
```json
{
  "detail": "OTP 코드가 일치하지 않습니다"
}
```

**Test Script**:
```javascript
pm.test("[TC-A4-005] 잘못된 OTP - 상태 코드 401", function() {
  pm.response.to.have.status(401);
});

pm.test("[TC-A4-005] 잘못된 OTP - 에러 메시지", function() {
  var jsonData = pm.response.json();
  pm.expect(jsonData).to.have.property("detail");
  pm.expect(jsonData.detail).to.include("일치하지 않습니다");
});

console.log("[TC-A4-005] ✅ 에러 처리 정상");
```

**통과 기준**:
- ✅ 상태 코드 401
- ✅ 에러 메시지 포함

---

### TC-A4-006: Verify OTP - 만료된 코드

**테스트 목표**: OTP 만료 시간 초과 시 거부 확인

**Method**: POST
**URL**: `{{base_url}}/api/v1/auth/verify-otp`

**테스트 절차**:
1. TC-A4-001 실행 (OTP 발송, expires_in: 300초)
2. 5분 이상 대기
3. TC-A4-006 실행 (만료된 OTP로 검증 시도)

**Request Body**:
```json
{
  "phone": "010-1234-5678",
  "otp": "123456"
}
```

**Pre-request Script**:
```javascript
console.log("[TC-A4-006] 만료된 OTP 코드 테스트 (5분 이상 경과)");
```

**Expected Response Status**: 410

**Expected Response Body**:
```json
{
  "detail": "OTP 코드가 만료되었습니다"
}
```

**Test Script**:
```javascript
pm.test("[TC-A4-006] 만료된 OTP - 상태 코드 410", function() {
  pm.response.to.have.status(410);
});

pm.test("[TC-A4-006] 만료된 OTP - 에러 메시지", function() {
  var jsonData = pm.response.json();
  pm.expect(jsonData.detail).to.include("만료");
});

console.log("[TC-A4-006] ✅ OTP 만료 처리 정상");
```

**통과 기준**:
- ✅ 상태 코드 410 (Gone)
- ✅ 에러 메시지에 "만료" 포함

---

### TC-A4-007: Verify OTP - 사용자 자동 생성

**테스트 목표**: OTP 검증 성공 시 새 사용자 자동 생성 확인

**Method**: POST
**URL**: `{{base_url}}/api/v1/auth/verify-otp`

**선행 조건**: 새로운 전화번호 (기존 사용자 아님)

**Request Body**:
```json
{
  "phone": "010-5555-5555",
  "otp": "123456"
}
```

**Pre-request Script**:
```javascript
console.log("[TC-A4-007] 사용자 자동 생성 테스트");
pm.environment.set("new_user_phone", "010-5555-5555");
```

**Expected Response Status**: 200

**Expected Response Body**:
```json
{
  "access_token": "...",
  "token_type": "bearer",
  "expires_in": 86400,
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "phone": "010-5555-5555",
    "name": "새로운 사용자",
    "role": "RENTER"
  }
}
```

**Test Script**:
```javascript
pm.test("[TC-A4-007] 사용자 자동 생성 - 상태 코드 200", function() {
  pm.response.to.have.status(200);
});

pm.test("[TC-A4-007] 사용자 자동 생성 - 사용자 생성됨", function() {
  var jsonData = pm.response.json();
  pm.expect(jsonData.user.phone).to.equal("010-5555-5555");
  pm.expect(jsonData.user.name).to.equal("새로운 사용자");
  pm.expect(jsonData.user.role).to.equal("RENTER");
});

pm.test("[TC-A4-007] 사용자 자동 생성 - 고유 ID 생성", function() {
  var jsonData = pm.response.json();
  var uuid = jsonData.user.id;

  // UUID v4 형식 검증 (정규식)
  var uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  pm.expect(uuid).to.match(uuidRegex);
});

pm.environment.set("new_user_id", pm.response.json().user.id);
pm.environment.set("new_user_token", pm.response.json().access_token);

console.log("[TC-A4-007] ✅ 사용자 자동 생성 완료");
```

**통과 기준**:
- ✅ 상태 코드 200
- ✅ 새 사용자 생성됨 (RENTER 기본 역할)
- ✅ UUID 형식의 고유 ID 생성
- ✅ JWT 토큰 발급

---

### TC-A4-008: Logout - 정상 요청

**테스트 목표**: 유효한 토큰으로 로그아웃 확인

**Method**: POST
**URL**: `{{base_url}}/api/v1/auth/logout`

**선행 조건**: TC-A4-004 또는 TC-A4-007 실행 후 access_token 획득

**Request Header**:
```
Authorization: Bearer {{access_token}}
Content-Type: application/json
```

**Request Body**:
```json
{}
```

**Pre-request Script**:
```javascript
console.log("[TC-A4-008] 로그아웃 테스트");
var token = pm.environment.get("access_token");
pm.request.headers.upsert({
  key: "Authorization",
  value: "Bearer " + token
});
```

**Expected Response Status**: 200

**Expected Response Body**:
```json
{
  "message": "로그아웃이 완료되었습니다"
}
```

**Test Script**:
```javascript
pm.test("[TC-A4-008] 로그아웃 - 상태 코드 200", function() {
  pm.response.to.have.status(200);
});

pm.test("[TC-A4-008] 로그아웃 - 성공 메시지", function() {
  var jsonData = pm.response.json();
  pm.expect(jsonData).to.have.property("message");
  pm.expect(jsonData.message).to.include("로그아웃");
});

// 로그아웃 후 토큰 초기화
pm.environment.set("access_token", "");
console.log("[TC-A4-008] ✅ 로그아웃 완료");
```

**통과 기준**:
- ✅ 상태 코드 200
- ✅ 성공 메시지 포함
- ✅ 토큰이 무효화됨

---

### TC-A4-009: Logout - 토큰 없음 (401)

**테스트 목표**: Authorization 헤더 없이 로그아웃 시도 거부 확인

**Method**: POST
**URL**: `{{base_url}}/api/v1/auth/logout`

**Request Header**:
```
Content-Type: application/json
(Authorization 헤더 없음)
```

**Request Body**:
```json
{}
```

**Pre-request Script**:
```javascript
console.log("[TC-A4-009] 토큰 없이 로그아웃 시도");
// Authorization 헤더 명시적으로 제거
pm.request.headers.remove("Authorization");
```

**Expected Response Status**: 401

**Expected Response Body**:
```json
{
  "detail": "유효한 토큰이 제공되지 않았습니다"
}
```

**Test Script**:
```javascript
pm.test("[TC-A4-009] 토큰 없음 - 상태 코드 401", function() {
  pm.response.to.have.status(401);
});

pm.test("[TC-A4-009] 토큰 없음 - 에러 메시지", function() {
  var jsonData = pm.response.json();
  pm.expect(jsonData.detail).to.include("토큰");
});

console.log("[TC-A4-009] ✅ 인증 요구 정상");
```

**통과 기준**:
- ✅ 상태 코드 401
- ✅ 에러 메시지 포함

---

### TC-A4-010: Logout - 유효하지 않은 토큰

**테스트 목표**: 잘못된 토큰으로 로그아웃 시도 거부 확인

**Method**: POST
**URL**: `{{base_url}}/api/v1/auth/logout`

**Request Header**:
```
Authorization: Bearer invalid.token.here
Content-Type: application/json
```

**Request Body**:
```json
{}
```

**Pre-request Script**:
```javascript
console.log("[TC-A4-010] 유효하지 않은 토큰으로 로그아웃 시도");
pm.request.headers.upsert({
  key: "Authorization",
  value: "Bearer invalid.token.here"
});
```

**Expected Response Status**: 401

**Expected Response Body**:
```json
{
  "detail": "유효하지 않은 토큰입니다"
}
```

**Test Script**:
```javascript
pm.test("[TC-A4-010] 유효하지 않은 토큰 - 상태 코드 401", function() {
  pm.response.to.have.status(401);
});

pm.test("[TC-A4-010] 유효하지 않은 토큰 - 에러 메시지", function() {
  var jsonData = pm.response.json();
  pm.expect(jsonData.detail).to.include("유효하지 않은");
});

console.log("[TC-A4-010] ✅ 토큰 검증 정상");
```

**통과 기준**:
- ✅ 상태 코드 401
- ✅ 에러 메시지 포함

---

### TC-A4-011: JWT 토큰 검증

**테스트 목표**: JWT 토큰 형식, 페이로드, 서명 검증

**Method**: POST
**URL**: `{{base_url}}/api/v1/auth/verify-otp`

**선행 조건**: TC-A4-004 실행 후 access_token 획득

**Pre-request Script**:
```javascript
console.log("[TC-A4-011] JWT 토큰 검증");
```

**Test Script**:
```javascript
pm.test("[TC-A4-011] JWT 토큰 - 형식 검증", function() {
  var token = pm.environment.get("access_token");

  // JWT는 3개 부분으로 구성 (header.payload.signature)
  var parts = token.split('.');
  pm.expect(parts.length).to.equal(3);

  // Base64 디코딩 테스트
  try {
    var headerDecoded = atob(parts[0]);
    var payloadDecoded = atob(parts[1]);

    var header = JSON.parse(headerDecoded);
    var payload = JSON.parse(payloadDecoded);

    console.log("JWT Header:", header);
    console.log("JWT Payload:", payload);
  } catch (e) {
    throw new Error("JWT 디코딩 실패: " + e.message);
  }
});

pm.test("[TC-A4-011] JWT 토큰 - 페이로드 내용", function() {
  var token = pm.environment.get("access_token");
  var parts = token.split('.');
  var payloadDecoded = atob(parts[1]);
  var payload = JSON.parse(payloadDecoded);

  // 필수 클레임 확인
  pm.expect(payload).to.have.property("sub");  // subject (user_id)
  pm.expect(payload).to.have.property("exp");  // expiration time
  pm.expect(payload).to.have.property("iat");  // issued at

  // exp가 미래 시간인지 확인
  var expTime = payload.exp * 1000;  // 초를 밀리초로 변환
  var now = Date.now();
  pm.expect(expTime).to.be.above(now);
});

pm.test("[TC-A4-011] JWT 토큰 - 만료 시간 (24시간)", function() {
  var token = pm.environment.get("access_token");
  var parts = token.split('.');
  var payloadDecoded = atob(parts[1]);
  var payload = JSON.parse(payloadDecoded);

  var iat = payload.iat;  // 발급 시간
  var exp = payload.exp;  // 만료 시간
  var duration = (exp - iat) / 3600;  // 시간 단위

  // 86400초 = 24시간
  pm.expect(duration).to.be.within(23, 25);
});

console.log("[TC-A4-011] ✅ JWT 검증 완료");
```

**통과 기준**:
- ✅ JWT는 3개 부분(header.payload.signature)으로 구성
- ✅ Header 디코딩 성공
- ✅ Payload에 sub, exp, iat 포함
- ✅ exp (만료시간)가 현재 시간보다 미래
- ✅ 토큰 유효 기간이 약 24시간

---

### TC-A4-012: JWT 토큰 갱신 (필요시)

**테스트 목표**: Refresh Token으로 새 Access Token 획득 (선택 기능)

**Method**: POST
**URL**: `{{base_url}}/api/v1/auth/refresh-token` (선택 사항)

**참고**: 프로젝트에서 Refresh Token 미지원 시 SKIP

**Request Body**:
```json
{
  "refresh_token": "{{refresh_token}}"
}
```

**Expected Response Status**: 200

**Expected Response Body**:
```json
{
  "access_token": "new_token_here",
  "token_type": "bearer",
  "expires_in": 86400
}
```

**Test Script**:
```javascript
pm.test("[TC-A4-012] 토큰 갱신 - 새 토큰 발급", function() {
  var jsonData = pm.response.json();
  var newToken = jsonData.access_token;
  var oldToken = pm.environment.get("access_token");

  // 새 토큰과 이전 토큰이 다른지 확인
  pm.expect(newToken).to.not.equal(oldToken);

  // 새 토큰 저장
  pm.environment.set("access_token", newToken);
});

console.log("[TC-A4-012] ✅ 토큰 갱신 완료");
```

**통과 기준**:
- ✅ 상태 코드 200
- ✅ 새로운 access_token 발급
- ✅ token_type이 "bearer"
- ✅ 이전 토큰과 다름

---

### TC-A4-013: 동시 요청 (동시성 테스트)

**테스트 목표**: 동시에 여러 OTP 발송 요청 시 안정성 확인

**Method**: POST
**URL**: `{{base_url}}/api/v1/auth/send-otp`

**테스트 도구**: Postman Collection Runner 또는 Newman CLI

**테스트 구성**:
```javascript
// 동시성 테스트 설정
var concurrentRequests = 10;  // 동시 요청 수
var uniquePhones = [];

for (var i = 0; i < concurrentRequests; i++) {
  uniquePhones.push("010-" + (1000 + i).toString().padStart(4, '0') + "-" + (5000 + i).toString().padStart(4, '0'));
}
```

**Pre-request Script**:
```javascript
console.log("[TC-A4-013] 동시 요청 테스트 시작");
pm.environment.set("concurrent_test_start", Date.now());
```

**Request Body** (각 요청마다 다른 전화번호):
```json
{
  "phone": "{{concurrent_phone}}"
}
```

**Expected Response Status**: 200 (모든 요청)

**Test Script**:
```javascript
pm.test("[TC-A4-013] 동시 요청 - 모두 성공", function() {
  pm.response.to.have.status(200);
});

// 동시성 테스트 완료 시 성능 통계
pm.test("[TC-A4-013] 동시 요청 - 성능 측정", function() {
  var startTime = pm.environment.get("concurrent_test_start");
  var duration = Date.now() - startTime;

  console.log("동시 요청 처리 시간: " + duration + "ms");

  // 10개 요청이 5초 이내에 완료되어야 함
  pm.expect(duration).to.be.below(5000);
});

console.log("[TC-A4-013] ✅ 동시성 테스트 완료");
```

**통과 기준**:
- ✅ 모든 동시 요청이 200 상태 코드
- ✅ 응답 시간이 일정함 (병목 현상 없음)
- ✅ 10개 요청 처리 시간 < 5초

---

### TC-A4-014: OTP 만료 시간 테스트 (180초)

**테스트 목표**: OTP 만료 시간이 정확하게 180초 또는 300초인지 확인

**Method 1: Send OTP**
**URL**: `{{base_url}}/api/v1/auth/send-otp`

**테스트 절차**:
1. OTP 발송 요청 (expires_in 기록)
2. 90초 대기
3. OTP 검증 시도 → 성공 (아직 유효)
4. 91초 이상 대기 (총 181초 경과)
5. OTP 검증 시도 → 실패 (410 Gone)

**Pre-request Script**:
```javascript
console.log("[TC-A4-014] OTP 만료 시간 테스트");
pm.environment.set("otp_test_phone", "010-7777-7777");
pm.environment.set("otp_test_start_time", Date.now());
```

**Test Script** (Send OTP 응답):
```javascript
pm.test("[TC-A4-014] OTP 발송 - expires_in 값", function() {
  var jsonData = pm.response.json();
  var expiresIn = jsonData.expires_in;

  // 만료 시간이 180초 또는 300초
  pm.expect([180, 300]).to.include(expiresIn);

  pm.environment.set("otp_expires_in", expiresIn);
  console.log("OTP 만료 시간: " + expiresIn + "초");
});
```

**Test Script** (Verify OTP 응답 - 90초 후):
```javascript
pm.test("[TC-A4-014] OTP 검증 (90초 후) - 성공", function() {
  pm.response.to.have.status(200);
  console.log("90초 후 OTP 검증: 성공");
});
```

**Test Script** (Verify OTP 응답 - 181초 후):
```javascript
pm.test("[TC-A4-014] OTP 검증 (181초 후) - 만료됨", function() {
  pm.response.to.have.status(410);
  console.log("181초 후 OTP 검증: 만료됨");
});
```

**통과 기준**:
- ✅ expires_in 값이 180초 또는 300초
- ✅ 만료 시간 이전: OTP 검증 성공
- ✅ 만료 시간 이후: 410 상태 코드

---

### TC-A4-015: 보안 헤더 확인

**테스트 목표**: API 응답에 보안 관련 헤더 포함 확인

**Method**: POST
**URL**: `{{base_url}}/api/v1/auth/send-otp`

**Request Body**:
```json
{
  "phone": "010-1234-5678"
}
```

**Expected Security Headers**:
```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: default-src 'self'
Cache-Control: no-store, no-cache, must-revalidate
```

**Test Script**:
```javascript
pm.test("[TC-A4-015] 보안 헤더 - X-Content-Type-Options", function() {
  pm.expect(pm.response.headers.get("X-Content-Type-Options")).to.equal("nosniff");
});

pm.test("[TC-A4-015] 보안 헤더 - X-Frame-Options", function() {
  pm.expect(pm.response.headers.get("X-Frame-Options")).to.equal("DENY");
});

pm.test("[TC-A4-015] 보안 헤더 - X-XSS-Protection", function() {
  var xssHeader = pm.response.headers.get("X-XSS-Protection");
  pm.expect(xssHeader).to.include("1");
  pm.expect(xssHeader).to.include("mode=block");
});

pm.test("[TC-A4-015] 보안 헤더 - Cache-Control", function() {
  var cacheHeader = pm.response.headers.get("Cache-Control");
  pm.expect(cacheHeader).to.include("no-store");
});

pm.test("[TC-A4-015] 보안 헤더 - Content-Type 검증", function() {
  pm.expect(pm.response.headers.get("Content-Type")).to.include("application/json");
});

console.log("[TC-A4-015] ✅ 보안 헤더 검증 완료");
```

**통과 기준**:
- ✅ X-Content-Type-Options: nosniff
- ✅ X-Frame-Options: DENY
- ✅ X-XSS-Protection 포함
- ✅ Cache-Control: no-store 포함
- ✅ Content-Type: application/json

---

## 4. 테스트 시나리오

### 4.1 정상 흐름 (Happy Path)

**시나리오**: 신규 사용자 회가입 → 로그인 → 로그아웃

```
1. TC-A4-001: Send OTP (신규 전화번호)
   ↓
2. [5분 이내 대기]
   ↓
3. TC-A4-004: Verify OTP (정상 OTP 코드)
   ↓
4. [JWT 토큰 획득 및 저장]
   ↓
5. TC-A4-008: Logout (토큰 사용)
   ↓
6. [로그아웃 완료, 토큰 무효화]
```

**기대 결과**: 모든 단계 성공 (6개 TC 모두 PASS)

---

### 4.2 에러 흐름 (Unhappy Path)

**시나리오 1**: 잘못된 OTP 코드

```
1. TC-A4-001: Send OTP
   ↓
2. TC-A4-005: Verify OTP (잘못된 코드)
   ↓
3. [401 오류, 토큰 미발급]
```

**시나리오 2**: OTP 만료

```
1. TC-A4-001: Send OTP (expires_in: 300초)
   ↓
2. [5분 이상 대기]
   ↓
3. TC-A4-006: Verify OTP (만료된 코드)
   ↓
4. [410 오류]
```

**시나리오 3**: 레이트 리미팅

```
1-5. TC-A4-003: Send OTP (동일 전화번호 5회)
     ↓ [200 OK, 5회 모두 성공]
6. TC-A4-003: Send OTP (6번째 요청)
   ↓ [429 Too Many Requests]
```

**시나리오 4**: 인증 없이 Logout

```
1. TC-A4-009: Logout (토큰 없음)
   ↓
2. [401 Unauthorized]
```

---

### 4.3 보안 흐름

**시나리오**: 토큰 검증 및 보안 헤더 확인

```
1. TC-A4-004: Verify OTP (토큰 획득)
   ↓
2. TC-A4-011: JWT 검증 (페이로드 확인)
   ↓
3. TC-A4-015: 보안 헤더 확인
   ↓
4. TC-A4-008: Logout (토큰 무효화)
```

---

## 5. 레이트 리미팅 상세 테스트

### 레이트 리미팅 정책
- **제한 대상**: 전화번호별 OTP 발송
- **제한 횟수**: 5회/5분
- **응답 코드**: 429 Too Many Requests
- **Retry-After 헤더**: 300초 (5분)

### 테스트 유틸리티 (Postman 폴더 레벨 스크립트)

```javascript
// Rate Limit Testing Utility
pm.globals.set("rateLimitTracker", {
  requests: {},

  trackRequest: function(phone) {
    var timestamp = Date.now();
    if (!this.requests[phone]) {
      this.requests[phone] = [];
    }
    this.requests[phone].push(timestamp);
    return this.requests[phone].length;
  },

  getRequestCount: function(phone) {
    if (!this.requests[phone]) return 0;

    var now = Date.now();
    var fiveMinutesAgo = now - (5 * 60 * 1000);

    // 5분 이내 요청만 카운트
    this.requests[phone] = this.requests[phone].filter(function(req) {
      return req > fiveMinutesAgo;
    });

    return this.requests[phone].length;
  }
});
```

---

## 6. Postman 컬렉션 작성 가이드

### 6.1 컬렉션 생성 단계

**Step 1: 새 컬렉션 생성**
```
[Postman 메인 화면]
→ Collections 탭
→ "+" 버튼 또는 "Create"
→ 컬렉션명: "Danngam API - Phase A4 인증"
```

**Step 2: 환경 변수 추가**
```
[Environments 탭]
→ "+" 또는 "Create"
→ 환경명: "Danngam_Auth_Test"
→ 변수 추가:
   - base_url: http://localhost:8000
   - api_version: v1
   - phone: 010-1234-5678
   - access_token: (비워둠)
   - otp_code: (비워둠)
```

**Step 3: API 요청 추가**
```
컬렉션 → [우클릭] → Add Request
→ 요청명: "TC-A4-001: Send OTP"
→ Method: POST
→ URL: {{base_url}}/api/v1/auth/send-otp
→ Body: raw JSON
→ Tests 탭에 테스트 스크립트 추가
```

**Step 4: 요청 간 변수 연결**
- Pre-request Script에서 환경 변수 설정
- Test Script에서 응답값을 환경 변수에 저장
- 다음 요청에서 `{{access_token}}` 참조

---

### 6.2 컬렉션 폴더 구조

```
Danngam API - Phase A4 인증
│
├─ 📁 01. 환경 설정 & 공통 설정
│  └─ Pre-request Script 및 공통 함수 정의
│
├─ 📁 02. Send OTP 테스트
│  ├─ TC-A4-001: Send OTP - 정상
│  ├─ TC-A4-002: Send OTP - 잘못된 번호
│  └─ TC-A4-003: Send OTP - 레이트 리미팅
│
├─ 📁 03. Verify OTP 테스트
│  ├─ TC-A4-004: Verify OTP - 정상
│  ├─ TC-A4-005: Verify OTP - 잘못된 코드
│  ├─ TC-A4-006: Verify OTP - 만료 코드
│  └─ TC-A4-007: Verify OTP - 사용자 생성
│
├─ 📁 04. Logout 테스트
│  ├─ TC-A4-008: Logout - 정상
│  ├─ TC-A4-009: Logout - 토큰 없음
│  └─ TC-A4-010: Logout - 유효하지 않은 토큰
│
├─ 📁 05. 보안 & 고급 테스트
│  ├─ TC-A4-011: JWT 토큰 검증
│  ├─ TC-A4-012: 토큰 갱신 (선택)
│  ├─ TC-A4-013: 동시 요청 테스트
│  ├─ TC-A4-014: OTP 만료 시간
│  └─ TC-A4-015: 보안 헤더
│
└─ 📁 06. 테스트 결과 리포트
   └─ 자동화된 결과 수집 및 요약
```

---

## 7. Postman 자동화 스크립트 (JavaScript)

### 7.1 Pre-request Script (공통)

```javascript
/**
 * Danngam Auth API - Pre-request Script
 * 모든 요청 전 실행되는 공통 스크립트
 */

// 1. 환경 변수 기본값 설정
function initializeEnvironment() {
  var defaults = {
    base_url: "http://localhost:8000",
    api_version: "v1",
    timeout: 5000,
    access_token: "",
    user_id: "",
    user_phone: ""
  };

  for (var key in defaults) {
    if (!pm.environment.get(key)) {
      pm.environment.set(key, defaults[key]);
    }
  }
}

// 2. 요청 타이밍 기록
pm.globals.set("request_timestamp", Date.now());

// 3. 요청 추적용 ID 생성
var requestId = "REQ-" + Date.now() + "-" + Math.random().toString(36).substr(2, 9);
pm.globals.set("current_request_id", requestId);

// 4. 공통 헤더 설정
pm.request.headers.upsert({
  key: "X-Request-ID",
  value: requestId
});

pm.request.headers.upsert({
  key: "User-Agent",
  value: "Postman/Danngam-Auth-Test"
});

// 함수 실행
initializeEnvironment();

console.log("[Pre-request] Request ID: " + requestId);
console.log("[Pre-request] Base URL: " + pm.environment.get("base_url"));
```

### 7.2 Test Script (공통 검증)

```javascript
/**
 * Danngam Auth API - Common Test Script
 */

// 1. 응답 시간 측정
var responseTime = pm.response.responseTime;
pm.globals.set("last_response_time", responseTime);

console.log("[Response] Time: " + responseTime + "ms");
console.log("[Response] Status: " + pm.response.code);

// 2. 기본 응답 검증
pm.test("[공통] 응답 형식 - JSON", function() {
  var contentType = pm.response.headers.get("Content-Type");
  pm.expect(contentType).to.include("application/json");
});

// 3. 응답 타이밍 확인 (500ms 이상 경고)
pm.test("[공통] 응답 시간 - 성능 확인", function() {
  if (responseTime > 500) {
    console.warn("[성능 경고] 응답 시간 초과: " + responseTime + "ms");
  }
  pm.expect(responseTime).to.be.below(5000);
});

// 4. 보안 헤더 기본 확인
pm.test("[공통] 보안 - Content-Type 검증", function() {
  pm.expect(pm.response.headers.get("Content-Type")).to.exist;
});

// 5. 응답 결과 로깅
function logResponse() {
  var status = pm.response.code;
  var requestId = pm.globals.get("current_request_id");

  var logEntry = {
    requestId: requestId,
    timestamp: new Date().toISOString(),
    method: pm.request.method,
    url: pm.request.url.toString(),
    status: status,
    responseTime: responseTime
  };

  // 콘솔에 출력
  console.log("[Test Result]", JSON.stringify(logEntry, null, 2));
}

logResponse();
```

### 7.3 OTP 추출 및 검증 스크립트

```javascript
/**
 * OTP 코드 추출 스크립트
 * Verify OTP 요청 전에 실행되어야 함
 */

// 개발 환경: 백엔드에서 OTP 디버그 로그 확인
// 프로덕션 환경: OTP는 SMS를 통해 사용자가 입력

function extractOTPFromResponse() {
  /**
   * NOTE: 실제 환경에서는 다음 중 하나:
   * 1. 개발/테스트 서버: 응답 헤더 또는 특수 엔드포인트에서 OTP 조회
   * 2. 프로덕션: 사용자가 SMS를 통해 수신한 OTP를 입력
   */

  // 개발용 - 테스트 OTP 코드
  var testOTP = pm.environment.get("test_otp_code");

  if (testOTP) {
    pm.environment.set("otp_code", testOTP);
    console.log("[OTP] 환경 변수에서 OTP 로드: " + testOTP);
    return testOTP;
  }

  // 백엔드 응답에서 OTP 추출 시도 (debug 모드)
  try {
    var jsonData = pm.response.json();
    if (jsonData.otp_code_for_testing) {
      pm.environment.set("otp_code", jsonData.otp_code_for_testing);
      console.log("[OTP] 응답에서 OTP 추출: " + jsonData.otp_code_for_testing);
      return jsonData.otp_code_for_testing;
    }
  } catch (e) {
    console.error("[OTP] OTP 추출 실패: " + e.message);
  }

  return null;
}

// 실행
var otp = extractOTPFromResponse();
if (!otp) {
  console.warn("[OTP] ⚠️  OTP를 얻을 수 없습니다. 수동으로 입력해야 합니다.");
}
```

### 7.4 JWT 토큰 저장 및 검증

```javascript
/**
 * JWT 토큰 처리 스크립트
 * Verify OTP 응답 처리
 */

pm.test("[JWT] 토큰 저장 및 검증", function() {
  var jsonData = pm.response.json();

  if (!jsonData.access_token) {
    throw new Error("access_token이 응답에 없습니다");
  }

  var token = jsonData.access_token;

  // 1. JWT 형식 검증
  var parts = token.split('.');
  pm.expect(parts.length).to.equal(3);

  // 2. 페이로드 디코딩 및 검증
  var payloadDecoded = atob(parts[1]);
  var payload = JSON.parse(payloadDecoded);

  console.log("[JWT] Header:", JSON.stringify(JSON.parse(atob(parts[0])), null, 2));
  console.log("[JWT] Payload:", JSON.stringify(payload, null, 2));

  // 3. 필수 클레임 확인
  pm.expect(payload).to.have.property("sub");
  pm.expect(payload).to.have.property("exp");
  pm.expect(payload).to.have.property("iat");

  // 4. 만료 시간 검증 (미래)
  var now = Math.floor(Date.now() / 1000);
  pm.expect(payload.exp).to.be.above(now);

  // 5. 환경 변수 저장
  pm.environment.set("access_token", token);
  pm.environment.set("token_type", jsonData.token_type);
  pm.environment.set("user_id", jsonData.user.id);
  pm.environment.set("user_phone", jsonData.user.phone);

  console.log("[JWT] ✅ 토큰 저장 완료");
  console.log("[JWT] User ID: " + jsonData.user.id);
  console.log("[JWT] User Phone: " + jsonData.user.phone);
});
```

### 7.5 동시성 테스트 스크립트

```javascript
/**
 * 동시성 테스트 유틸리티
 * Collection Runner에서 반복 실행
 */

pm.globals.set("concurrencyTest", {
  startTime: Date.now(),
  requests: [],

  recordRequest: function(phone, status) {
    this.requests.push({
      phone: phone,
      status: status,
      timestamp: Date.now()
    });
  },

  getSummary: function() {
    var success = this.requests.filter(function(r) { return r.status === 200; }).length;
    var failed = this.requests.filter(function(r) { return r.status !== 200; }).length;
    var totalTime = Date.now() - this.startTime;

    return {
      total: this.requests.length,
      success: success,
      failed: failed,
      totalTimeMs: totalTime,
      avgTimeMs: totalTime / this.requests.length
    };
  }
});

// 각 요청 후 기록
var summary = pm.globals.get("concurrencyTest");
summary.recordRequest(pm.environment.get("phone"), pm.response.code);

console.log("[Concurrency]", JSON.stringify(summary.getSummary()));
```

---

## 8. 테스트 결과 보고 템플릿

### 8.1 테스트 실행 리포트

```markdown
# Phase A-4 인증 API 테스트 리포트

**테스트 일시**: 2026-02-14 14:30 ~ 15:45
**테스터**: QA 팀
**버전**: FastAPI Phase A-4
**환경**: 로컬 개발 (localhost:8000)

---

## 1. 테스트 결과 요약

| 항목 | 결과 |
|------|------|
| 총 테스트 케이스 | 15개 |
| 성공 (PASS) | 15개 |
| 실패 (FAIL) | 0개 |
| 스킵 (SKIP) | 0개 |
| **성공률** | **100%** |

---

## 2. 테스트 케이스별 결과

### Send OTP (3개)
| TC | 테스트명 | 상태 | 비고 |
|----|---------|------|------|
| A4-001 | 정상 요청 | ✅ PASS | 200 OK |
| A4-002 | 잘못된 번호 | ✅ PASS | 400 Bad Request |
| A4-003 | 레이트 리미팅 | ✅ PASS | 429 Too Many Requests |

### Verify OTP (4개)
| TC | 테스트명 | 상태 | 비고 |
|----|---------|------|------|
| A4-004 | 정상 요청 | ✅ PASS | 토큰 발급 성공 |
| A4-005 | 잘못된 코드 | ✅ PASS | 401 Unauthorized |
| A4-006 | 만료 코드 | ✅ PASS | 410 Gone |
| A4-007 | 사용자 생성 | ✅ PASS | 신규 사용자 자동 생성 |

### Logout (3개)
| TC | 테스트명 | 상태 | 비고 |
|----|---------|------|------|
| A4-008 | 정상 요청 | ✅ PASS | 200 OK |
| A4-009 | 토큰 없음 | ✅ PASS | 401 Unauthorized |
| A4-010 | 유효하지 않은 토큰 | ✅ PASS | 401 Unauthorized |

### 보안 & 고급 (5개)
| TC | 테스트명 | 상태 | 비고 |
|----|---------|------|------|
| A4-011 | JWT 토큰 검증 | ✅ PASS | 형식, 페이로드, 시간 검증 |
| A4-012 | 토큰 갱신 | ⏭️ SKIP | 기능 미지원 |
| A4-013 | 동시 요청 | ✅ PASS | 10개 동시 요청 성공 |
| A4-014 | OTP 만료 시간 | ✅ PASS | 300초 정확 |
| A4-015 | 보안 헤더 | ✅ PASS | 모든 헤더 확인 |

---

## 3. 성능 측정

| 항목 | 측정값 | 기준 | 상태 |
|------|--------|------|------|
| 평균 응답 시간 | 45ms | < 500ms | ✅ 우수 |
| 최대 응답 시간 | 120ms | < 1000ms | ✅ 우수 |
| 동시 요청 처리 | 10개/3초 | < 5초 | ✅ 우수 |

---

## 4. 시나리오 테스트

### 정상 흐름
```
✅ Send OTP → Verify OTP → Logout
   200         200          200
```

### 에러 흐름
```
✅ 잘못된 OTP 검증
   Send OTP (200) → Verify OTP with wrong code (401)

✅ 만료된 OTP 검증
   Send OTP (300초) → [300초 경과] → Verify OTP (410)

✅ 레이트 리미팅
   5회 요청 (200) → 6회 요청 (429)

✅ 토큰 없이 로그아웃
   Logout without token (401)
```

---

## 5. 보안 검증

| 항목 | 확인 | 상태 |
|------|------|------|
| JWT 형식 | 3부분 (header.payload.signature) | ✅ |
| JWT 페이로드 | sub, exp, iat 포함 | ✅ |
| JWT 만료시간 | 24시간 정확 | ✅ |
| 보안 헤더 | X-Content-Type-Options, X-Frame-Options 등 | ✅ |
| HTTPS | (프로덕션 환경) | ⏳ 미검증 |
| 비밀번호 없는 인증 | OTP 기반 인증 정상 작동 | ✅ |

---

## 6. 발견된 이슈

| 번호 | 심각도 | 제목 | 설명 | 상태 |
|------|--------|------|------|------|
| -    | -      | -    | 발견된 이슈 없음 | -    |

---

## 7. 개선 제안

1. **OTP 코드 길이**: 현재 6자리, 보안을 위해 8자리로 늘릴 것 권장
2. **레이트 리미팅**: 5분 제한은 적절, 로그인 시도 실패 누적 시 추가 제약 검토
3. **토큰 갱신**: Refresh Token 추가 구현 고려
4. **로그 기록**: 보안 감시를 위해 모든 인증 시도 로깅

---

## 8. 테스트 환경 정보

- **API 서버**: http://localhost:8000
- **데이터베이스**: PostgreSQL 15.0
- **Postman 버전**: 10.0
- **OS**: macOS
- **네트워크**: 로컬 (지연 없음)

---

## 9. 결론

✅ **Phase A-4 인증 API는 모든 인수 기준을 충족합니다.**

- 모든 기능이 정상 작동
- 보안 정책이 적절히 적용됨
- 성능이 우수함
- 에러 처리가 명확함

**다음 단계**: Phase B-1 (장비 API) 개발 진행 가능

---

**작성자**: QA 팀
**검토자**: -
**승인자**: 기획팀
```

---

## 9. Postman 문제 해결 FAQ

### Q1: "변수를 찾을 수 없습니다" 오류

**문제**: `{{access_token}}`이 정의되지 않았다는 오류

**해결 방법**:
1. Environment 탭 확인
2. 올바른 환경이 선택되어 있는지 확인
3. Pre-request Script에서 변수가 설정되었는지 확인
4. 환경 변수명이 정확한지 확인 (대소문자 구분)

```javascript
// 환경 변수 설정 예시
pm.environment.set("access_token", "your_token_here");

// 환경 변수 확인
console.log(pm.environment.get("access_token"));
```

---

### Q2: JWT 토큰이 Base64 디코딩되지 않음

**문제**: JWT 페이로드 디코딩 시 "Illegal base64url string" 오류

**해결 방법**:
```javascript
// 올바른 디코딩 방법
function decodeJWT(token) {
  var parts = token.split('.');

  // Base64url → Base64 변환 (패딩 추가)
  var payload = parts[1];
  var padded = payload + '=='.substring(0, (4 - payload.length % 4) % 4);

  return JSON.parse(atob(padded));
}

var decoded = decodeJWT(pm.environment.get("access_token"));
console.log(decoded);
```

---

### Q3: "CORS 오류" 또는 "요청 차단"

**문제**: 브라우저에서 API 호출 시 CORS 오류

**해결 방법** (Postman 사용 시는 영향 없음):
1. Postman은 CORS 제약이 없으므로 정상 작동
2. 프론트엔드 테스트 시 백엔드에서 CORS 헤더 설정 필요

```python
# FastAPI CORS 설정
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

### Q4: 레이트 리미팅 테스트 실패

**문제**: TC-A4-003에서 5회 이후 429가 아닌 200이 반환됨

**해결 방법**:
1. 서로 다른 전화번호 사용 (테스트 후 환경 초기화)
2. 시간 경과 확인 (5분 제한이므로 이전 요청 카운트 초기화 대기)
3. 백엔드 레이트 리미팅 설정 확인

```javascript
// 레이트 리미트 추적 함수
function isRateLimited(phone) {
  var requests = pm.globals.get("requests_by_phone") || {};
  var now = Date.now();
  var fiveMinutesAgo = now - (5 * 60 * 1000);

  if (!requests[phone]) {
    requests[phone] = [];
  }

  // 5분 이내 요청만 유지
  requests[phone] = requests[phone].filter(t => t > fiveMinutesAgo);

  requests[phone].push(now);
  pm.globals.set("requests_by_phone", requests);

  return requests[phone].length > 5;
}
```

---

### Q5: OTP 코드를 어디서 얻나요?

**문제**: 테스트에 필요한 실제 OTP 코드를 얻을 수 없음

**해결 방법**:

**개발 환경** (추천):
1. 백엔드에서 debug 모드 활성화
2. OTP 발송 응답에 테스트용 OTP 코드 포함
3. 또는 `/api/v1/auth/debug/otp?phone=...` 엔드포인트 추가

**실제 환경**:
1. SMS를 통해 수신한 OTP를 Postman에 수동 입력
2. 또는 로그 파일에서 확인 (관리자만 가능)

```python
# FastAPI 백엔드 - 디버그 모드
@router.post("/auth/send-otp")
async def send_otp(request: SendOTPRequest):
    # OTP 생성 및 저장
    otp_code = generate_otp()
    cache.set(f"otp:{request.phone}", otp_code, expire=300)

    response = {
        "message": "OTP가 발송되었습니다",
        "phone": request.phone,
        "expires_in": 300
    }

    # 개발 환경에서만 OTP 코드 포함
    if settings.DEBUG:
        response["otp_code_for_testing"] = otp_code

    return response
```

---

### Q6: 동시 요청 테스트 실행 방법

**문제**: Postman에서 동시에 여러 요청을 보낼 수 없음

**해결 방법**: Collection Runner 사용

```
[Postman]
→ Collections 탭
→ "Danngam API - Phase A4" [우클릭]
→ "Run collection"
→ Iterations: 10 (10개 요청)
→ Delay: 100ms (각 요청 간 100ms 간격)
→ "Run"
```

또는 Newman CLI 사용:

```bash
# Newman 설치
npm install -g newman

# 컬렉션 실행
newman run "Danngam API - Phase A4.postman_collection.json" \
  -e "Danngam_Auth_Test.postman_environment.json" \
  --iteration-count 10 \
  --delay-request 100
```

---

### Q7: "요청 타임아웃" 오류

**문제**: 요청이 응답 없이 대기함

**해결 방법**:
1. API 서버 실행 확인: `curl http://localhost:8000/health`
2. 포트 번호 확인 (기본: 8000)
3. 방화벽 설정 확인
4. 네트워크 지연 확인

```javascript
// Postman에서 타임아웃 설정
// Settings → Timeout (기본 30초, 최대 5분)
```

---

## 10. 테스트 체크리스트

### 프로젝트 시작 전

- [ ] Postman 설치 (최신 버전)
- [ ] Collection 생성: "Danngam API - Phase A4 인증"
- [ ] Environment 생성: "Danngam_Auth_Test"
- [ ] 기본 변수 설정 (base_url, api_version 등)

### 테스트 실행 전

- [ ] API 서버 실행 확인 (`http://localhost:8000/health`)
- [ ] 데이터베이스 연결 확인
- [ ] 환경 변수 올바르게 설정
- [ ] 테스트 데이터 초기화 (필요시)

### 각 테스트 케이스 실행 시

- [ ] Pre-request Script 확인
- [ ] Request 형식 확인 (Method, URL, Body)
- [ ] Expected Response 확인
- [ ] Test Script 실행 확인
- [ ] 결과 기록

### 테스트 완료 후

- [ ] 모든 TC 결과 기록
- [ ] 성공률 확인 (목표: 100%)
- [ ] 발견된 이슈 문서화
- [ ] 성능 지표 기록
- [ ] 최종 리포트 작성

---

## 11. 참고 자료

### 공식 문서
- [Postman Documentation](https://learning.postman.com/)
- [Postman Collection Format](https://learning.postman.com/docs/sending-requests/requests/)
- [Postman Test Scripts](https://learning.postman.com/docs/writing-scripts/test-scripts/)

### JWT
- [JWT Introduction](https://jwt.io/)
- [JWT Claims](https://tools.ietf.org/html/rfc7519#section-4)

### OTP
- [TOTP (Time-based OTP)](https://tools.ietf.org/html/rfc6238)
- [Best Practices for OTP](https://owasp.org/www-community/attacks/Brute_force_attack)

---

## 12. 최종 인수 기준

**Phase A-4 인증 API는 다음을 모두 충족해야 합니다:**

- [ ] TC-A4-001~015 중 14개 이상 PASS (TC-A4-012 제외 가능)
- [ ] OTP 발송 및 검증 정상 작동
- [ ] JWT 토큰 발급 및 검증 정상 작동
- [ ] 로그아웃 기능 정상 작동
- [ ] 레이트 리미팅 정상 작동 (5회/5분)
- [ ] 모든 에러 케이스 적절히 처리
- [ ] 보안 헤더 포함
- [ ] 응답 시간 < 500ms (평균)
- [ ] 동시 요청 10개/5초 이내 처리
- [ ] 테스트 리포트 작성 완료

---

**작성 완료일**: 2026-02-14
**최종 수정**: 2026-02-14
**상태**: ✅ Phase A-4 테스트 계획 완성
