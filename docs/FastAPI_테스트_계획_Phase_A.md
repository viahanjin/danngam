# FastAPI Phase A 테스트 계획 및 검증 가이드

## 문서 정보
- 작성일: 2026-02-14
- 작성자: QA 팀
- 버전: 1.0
- 목적: Phase A (기초 구축) 테스트 및 검증

---

## 1. 환경 준비

### 1.1 Postman 설정
```
1. Postman 설치 (https://www.postman.com/downloads/)
2. Collection 생성: "Danngam API"
3. Environment 생성:
   - base_url: http://localhost:8000
   - api_v1: /api/v1
```

### 1.2 Docker 확인
```bash
# Docker 실행 확인
docker-compose up

# 컨테이너 상태 확인
docker ps

# PostgreSQL 접속 (선택)
psql -h localhost -U danngam_user -d danngam
```

---

## 2. Task A-1 테스트: FastAPI 프로젝트 초기화

### TC-A1-001: FastAPI 앱 실행
**목표**: FastAPI 앱이 정상 실행되는가?
**테스트 단계**:
1. `docker-compose up` 실행
2. 로그에 "Application startup complete" 확인

**기대 결과**:
- FastAPI 앱이 포트 8000에서 실행
- 에러 없음

**통과 기준**: ✅ 앱 실행 완료

---

### TC-A1-002: 헬스 체크 엔드포인트
**목표**: /health 엔드포인트가 정상 작동하는가?

**요청** (Postman):
```
GET http://localhost:8000/health
```

**기대 응답**:
```json
{
  "status": "ok"
}
```

**통과 기준**: ✅ 상태 코드 200 + JSON 응답

---

### TC-A1-003: 환경 변수 로드
**목표**: .env 파일에서 환경 변수가 정상 로드되는가?

**테스트 방법**:
1. .env 파일 생성 (content of .env.example)
2. `docker-compose up` 실행
3. 로그에서 DATABASE_URL 설정 확인

**기대 결과**: 환경 변수 로드 성공

**통과 기준**: ✅ 오류 없음

---

## 3. Task A-2 테스트: PostgreSQL + Docker 설정

### TC-A2-001: PostgreSQL 컨테이너 실행
**목표**: PostgreSQL이 정상 실행되는가?

**테스트 단계**:
```bash
docker ps | grep postgres
# 컨테이너 상태: "healthy" 확인
```

**기대 결과**: PostgreSQL 컨테이너 실행 중

**통과 기준**: ✅ 상태 "healthy"

---

### TC-A2-002: PostgreSQL 연결
**목표**: FastAPI에서 PostgreSQL 연결이 정상인가?

**테스트 방법**:
```bash
# 방법 1: Docker 내부에서 테스트
docker exec danngam_fastapi python -c "from app.database import engine; engine.connect(); print('연결 성공')"

# 방법 2: psql로 직접 연결
psql -h localhost -U danngam_user -d danngam -c "SELECT 1"
```

**기대 결과**: 연결 성공

**통과 기준**: ✅ "연결 성공" 메시지

---

### TC-A2-003: PgAdmin 접근
**목표**: PgAdmin 웹 인터페이스가 정상인가?

**테스트 단계**:
1. 브라우저 열기
2. http://localhost:5050 접속
3. 로그인 (email: admin@danngam.com, password: admin)
4. PostgreSQL 서버 추가 확인

**기대 결과**: PgAdmin에서 danngam DB 보임

**통과 기준**: ✅ PgAdmin 접속 + DB 확인

---

## 4. 통합 테스트

### TC-A-INTEGRATION-001: 전체 스택 실행
**목표**: FastAPI + PostgreSQL + PgAdmin이 모두 정상 작동하는가?

**체크리스트**:
- [ ] docker-compose up 실행 가능
- [ ] FastAPI: http://localhost:8000/health → 200
- [ ] PgAdmin: http://localhost:5050 → 로그인 가능
- [ ] PostgreSQL: 데이터베이스 'danngam' 존재
- [ ] 로그에 에러 없음

**통과 기준**: ✅ 모두 확인

---

## 5. 테스트 리포트 템플릿

```markdown
# Phase A 테스트 리포트

**테스트 일시**: 2026-02-14
**테스트자**: QA 팀
**버전**: Phase A (기초 구축)

## 결과 요약
| Task | 테스트 | 통과 | 실패 |
|------|--------|------|------|
| A-1 | 3개 | 3개 | 0개 |
| A-2 | 3개 | 3개 | 0개 |

## 상세 결과

### Task A-1
- TC-A1-001: ✅ PASS
- TC-A1-002: ✅ PASS
- TC-A1-003: ✅ PASS

### Task A-2
- TC-A2-001: ✅ PASS
- TC-A2-002: ✅ PASS
- TC-A2-003: ✅ PASS

## 발견된 이슈
- 없음

## 승인
- 개발 완료: ✅
- 테스트 완료: ✅
- 다음 Phase 진행 가능: ✅
```

---

## 6. 빠른 참고 명령어

```bash
# Docker 실행
docker-compose up

# Docker 종료
docker-compose down

# 로그 확인
docker-compose logs -f fastapi
docker-compose logs -f postgres

# PostgreSQL 직접 접속
docker exec -it danngam_postgres psql -U danngam_user -d danngam

# FastAPI 헬스 체크
curl http://localhost:8000/health

# 컨테이너 재시작
docker-compose restart
```

---

## 7. 문제 해결

### 문제: PostgreSQL 연결 실패
```
해결책:
1. postgres 컨테이너 상태 확인: docker ps
2. 로그 확인: docker-compose logs postgres
3. 포트 충돌 확인: lsof -i :5432
```

### 문제: FastAPI 포트 충돌
```
해결책:
1. 포트 사용 확인: lsof -i :8000
2. docker-compose.yml의 포트 변경
3. Docker 재시작
```

---

**다음 Phase 준비 완료**: Task A-3 (DB 스키마 생성) 테스트 계획 작성
