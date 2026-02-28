# FastAPI Phase A-3 데이터베이스 스키마 검증

**파일 위치**: /Users/hanjinjang/Desktop/회사/danngam/docs/FastAPI_테스트_계획_Phase_A3.md

## Phase A-3 테스트 계획: 데이터베이스 스키마 검증

### 테스트 환경

**필수 도구**:
- Docker (PostgreSQL 실행)
- PgAdmin (DB 관리)
- psql 또는 DBeaver (쿼리 실행)

---

## 테스트 케이스 (총 13개)

### TC-A3-001: 모든 테이블 생성 확인
**목표**: 8개 테이블이 모두 생성되었는가?

**테스트 단계**:
```bash
# 방법 1: PgAdmin 웹 UI에서 확인
# localhost:5050 → danngam → Schemas → public → Tables
# users, equipment, equipment_images, bookings, payments, reviews, chats, messages 확인

# 방법 2: psql 명령어
psql -h localhost -U danngam_user -d danngam -c "\dt"
```

**기대 결과**:
```
Schema | Name | Type  | Owner
-------+------+-------+-------
public | users | table | danngam_user
public | equipment | table | danngam_user
public | equipment_images | table | danngam_user
public | bookings | table | danngam_user
public | payments | table | danngam_user
public | reviews | table | danngam_user
public | chats | table | danngam_user
public | messages | table | danngam_user
(8 rows)
```

**통과 기준**: ✅ 정확히 8개 테이블 존재

---

### TC-A3-002: users 테이블 컬럼 확인
**목표**: users 테이블의 컬럼이 모두 정의되었는가?

**기대 컬럼**:
- id (UUID, PK)
- phone (VARCHAR, Unique)
- name (VARCHAR)
- email (VARCHAR)
- profile_image_url (VARCHAR)
- location (geometry)
- rating (NUMERIC)
- review_count (INTEGER)
- role (ENUM: SUPPLIER, RENTER)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

**테스트**:
```bash
psql -h localhost -U danngam_user -d danngam -c "\d users"
```

**통과 기준**: ✅ 11개 컬럼 모두 존재

---

### TC-A3-003: equipment 테이블 - type 컬럼 (⭐ 중요)
**목표**: equipment 테이블에 MOBILE/FIXED 구분이 있는가?

**테스트**:
```bash
psql -h localhost -U danngam_user -d danngam \
  -c "SELECT column_name, data_type FROM information_schema.columns WHERE table_name='equipment' AND column_name='type';"
```

**기대 결과**:
```
column_name | data_type
-------------+-----------
type | USER-DEFINED (enum)
```

**통과 기준**: ✅ type 컬럼이 ENUM으로 정의됨

---

### TC-A3-004: Foreign Key 관계 확인
**목표**: 모든 Foreign Key 관계가 설정되었는가?

**기대 관계**:
- equipment.supplier_id → users.id
- equipment_images.equipment_id → equipment.id
- bookings.equipment_id → equipment.id
- bookings.renter_id → users.id
- bookings.supplier_id → users.id
- payments.booking_id → bookings.id (Unique)
- reviews.booking_id → bookings.id (Unique)
- reviews.equipment_id → equipment.id
- reviews.reviewer_id → users.id
- chats.sender_id → users.id
- chats.receiver_id → users.id
- messages.chat_id → chats.id
- messages.sender_id → users.id

**테스트**:
```bash
psql -h localhost -U danngam_user -d danngam \
  -c "SELECT constraint_name, table_name, column_name FROM information_schema.key_column_usage WHERE table_schema='public' AND referenced_table_name IS NOT NULL LIMIT 20;"
```

**통과 기준**: ✅ 13개 이상의 FK 관계 존재

---

### TC-A3-005: 인덱스 생성 확인
**목표**: 성능 최적화를 위한 인덱스가 생성되었는가?

**기대 인덱스**:
- equipment.location (GIS 인덱스)
- equipment.type (ENUM 필터링)
- equipment.supplier_id
- bookings.equipment_id
- bookings.renter_id
- messages.chat_id

**테스트**:
```bash
psql -h localhost -U danngam_user -d danngam -c "\di"
```

**통과 기준**: ✅ 6개 이상의 인덱스 존재

---

### TC-A3-006: 샘플 데이터 - 사용자 5명
**목표**: 5명의 샘플 사용자가 입력되었는가?

**테스트**:
```bash
psql -h localhost -U danngam_user -d danngam -c "SELECT COUNT(*) FROM users;"
```

**기대 결과**: 5

**데이터 조회**:
```bash
psql -h localhost -U danngam_user -d danngam \
  -c "SELECT id, name, role, rating FROM users LIMIT 5;"
```

**통과 기준**: ✅ 정확히 5명

---

### TC-A3-007: 샘플 데이터 - 장비 10개
**목표**: 10개의 샘플 장비가 입력되었는가?

**테스트**:
```bash
psql -h localhost -U danngam_user -d danngam -c "SELECT COUNT(*) FROM equipment;"
```

**기대 결과**: 10

**이동형/고정형 확인**:
```bash
psql -h localhost -U danngam_user -d danngam \
  -c "SELECT type, COUNT(*) FROM equipment GROUP BY type;"
```

**기대 결과**:
```
type  | count
-------+-------
MOBILE | 7
FIXED  | 3
```

**통과 기준**: ✅ 이동형 7개 + 고정형 3개 = 10개

---

### TC-A3-008: equipment_images 확인
**목표**: 각 장비별로 이미지가 연결되었는가?

**테스트**:
```bash
psql -h localhost -U danngam_user -d danngam \
  -c "SELECT equipment_id, COUNT(*) FROM equipment_images GROUP BY equipment_id;"
```

**기대**: 각 장비당 최소 1개 이상의 이미지

**통과 기준**: ✅ 모든 equipment_id 매칭됨

---

### TC-A3-009: 기본 쿼리 - equipment 이동형 필터
**목표**: 이동형 장비만 조회 가능한가?

**쿼리**:
```sql
SELECT id, name, type, price_per_hour FROM equipment WHERE type = 'MOBILE' ORDER BY price_per_hour DESC;
```

**기대**: 7개 행 반환

**통과 기준**: ✅ 7개 행

---

### TC-A3-010: 기본 쿼리 - equipment 고정형 필터
**목표**: 고정형 장비만 조회 가능한가?

**쿼리**:
```sql
SELECT id, name, type, location FROM equipment WHERE type = 'FIXED';
```

**기대**: 3개 행 반환

**통과 기준**: ✅ 3개 행

---

### TC-A3-011: 기본 쿼리 - 위치 기반 검색
**목표**: 특정 위치 기반으로 장비를 조회할 수 있는가?

**쿼리** (PostGIS 사용):
```sql
SELECT id, name, ST_Distance(location, ST_Point(127.0, 37.5)::geography) as distance
FROM equipment
WHERE ST_DWithin(location, ST_Point(127.0, 37.5)::geography, 30000)
ORDER BY distance;
```

**기대**: 거리순 정렬된 결과

**통과 기준**: ✅ 정상 정렬됨

---

### TC-A3-012: 테이블 간 JOIN 확인
**목표**: 외래키로 테이블을 JOIN할 수 있는가?

**쿼리**:
```sql
SELECT e.name, e.type, u.name as supplier_name, e.price_per_hour
FROM equipment e
JOIN users u ON e.supplier_id = u.id
WHERE e.type = 'MOBILE';
```

**기대**: 7개 행 반환 (이동형 장비 + 공급자명)

**통과 기준**: ✅ 정상 JOIN됨

---

### TC-A3-013: 데이터 무결성 확인
**목표**: 모든 제약조건이 정상 작동하는가?

**테스트 1**: Unique 제약
```bash
# phone 중복 입력 시도 (실패해야 함)
psql -h localhost -U danngam_user -d danngam \
  -c "INSERT INTO users (phone, name, role) VALUES ('010-1234-5678', 'duplicate', 'RENTER');"
# Error: duplicate key value violates unique constraint
```

**테스트 2**: Foreign Key 제약
```bash
# 존재하지 않는 user_id로 booking 입력 (실패해야 함)
psql -h localhost -U danngam_user -d danngam \
  -c "INSERT INTO bookings (equipment_id, renter_id, supplier_id, start_time, end_time) VALUES (..., 'fake-uuid', ...);"
# Error: foreign key constraint
```

**통과 기준**: ✅ 제약조건 정상 작동

---

## 최종 검증 체크리스트

- [ ] 8개 테이블 생성 완료
- [ ] 모든 컬럼 및 타입 정확
- [ ] equipment.type (MOBILE/FIXED) 정의
- [ ] 13개 Foreign Key 설정
- [ ] 6개 이상 인덱스 생성
- [ ] 사용자 5명 입력
- [ ] 장비 10개 입력 (이동형 7개 + 고정형 3개)
- [ ] 이미지 연결 완료
- [ ] 기본 쿼리 작동 확인
- [ ] JOIN 쿼리 작동 확인
- [ ] 제약조건 정상 작동

---

## 테스트 리포트 템플릿

```markdown
# Phase A-3 테스트 리포트

**테스트 일시**: [날짜]
**테스터**: QA 팀
**버전**: A-3

## 결과 요약
| 항목 | 결과 |
|------|------|
| 테이블 생성 | PASS |
| Foreign Key | PASS |
| 인덱스 | PASS |
| 샘플 데이터 | PASS |
| 쿼리 | PASS |

## 상세 결과
- TC-A3-001~013: 모두 PASS ✅

## 발견된 이슈
- 없음

## 다음 단계
- [ ] Task A-4: 인증 API 구현 진행 가능
```
