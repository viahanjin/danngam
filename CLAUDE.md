# CLAUDE.md - DANGAM 프로젝트 Claude Code 가이드

**Claude Code 작업 규칙 및 프로젝트 지시사항 v1.0**

---

## 🎯 프로젝트 개요

**프로젝트명**: DANGAM (단감) - 농작업·농기계 매칭 플랫폼
**기간**: 14주 (7 Sprints)
**개발팀**: 10명 (백엔드, 모바일, DevOps, QA)
**기술 스택**: Node.js/TypeScript (Backend), Flutter/Dart (Mobile), PostgreSQL, MongoDB, Redis

---

## 📋 작업 전 필수 읽기

Claude Code가 이 프로젝트에서 작업하기 전에 **반드시** 읽어야 할 문서:

1. **docs/TODO.md** - 전체 개발 로드맵 및 체크리스트
2. **docs/API_설계서.md** - 모든 API 엔드포인트 설계
3. **docs/DATABASE_SCHEMA.md** (데이터_모델_설계.md) - DB 테이블 구조 및 관계도
4. **docs/DEVELOPMENT_CONVENTION.md** - 코딩 컨벤션 및 폴더 구조
5. **docs/개발_가이드.md** - Git Workflow, 로컬 환경 설정 (Flutter & Backend)

---

## 🛠️ Claude Code 행동 규칙

### 1. Plan Mode 필수 사용

**모든 비자명한 작업은 Plan Mode에서 시작**하세요.

```
사용 시점:
- 새로운 기능 개발 (기존 코드 수정도 포함)
- 여러 파일 수정이 필요한 경우
- 아키텍처 변경
- 버그 수정이 명확하지 않은 경우

예외 (Plan Mode 불필요):
- 오타 수정
- 한 줄짜리 버그 수정
- 주석/문서 수정만
- 설정 파일 간단한 변경
```

### 2. 기술 스택 준수

#### 백엔드 (Node.js/TypeScript)
```
- Express.js 라우팅
- TypeScript strict mode (strictNullChecks: true)
- Class-based 서비스 구조
- Dependency Injection (선택사항 - tsyringe)
- 에러: 커스텀 AppError 클래스 사용
- 로깅: logger 유틸 (console.log 금지)
- DB: pg (PostgreSQL), mongoose (MongoDB)
- 캐시: redis
```

#### 모바일 (Flutter/Dart)
```
- Flutter 3.13+
- Riverpod 2.0 (상태관리)
- go_router (네비게이션)
- dio + retrofit (HTTP)
- Clean Architecture (Data/Domain/Presentation)
- GetIt (의존성 주입)
- Freezed (코드 생성)
```

### 3. 마이크로서비스 구조 유지

백엔드는 8개 독립적인 서비스로 구성되어 있습니다. **각 서비스의 폴더 구조 준수**:

```
services/
├── auth/
│   ├── *.service.ts
│   ├── *.controller.ts
│   ├── *.route.ts
│   ├── *.dto.ts
│   ├── *.validator.ts
│   └── __tests__/
├── user/
├── work-order/
├── matching/
├── chat/
├── review/
├── invoice/
└── notification/
```

### 4. 데이터 흐름 이해

```
Request
  ↓
Route Handler (*.route.ts)
  ↓
Controller (*.controller.ts) - HTTP 검증/응답
  ↓
Service (*.service.ts) - 비즈니스 로직
  ↓
Repository (DB 접근)
  ↓
Response (표준 포맷)
```

---

## ✅ 코딩 기준 & 체크리스트

### 백엔드

**모든 작업 완료 전 확인**:

- [ ] TypeScript 에러 0개 (`npm run typecheck`)
- [ ] ESLint 통과 (`npm run lint` - no errors)
- [ ] 테스트 커버리지 80% 이상 (`npm run test:coverage`)
- [ ] API 응답 포맷 일관성 (success, data, error)
- [ ] 에러 처리: try-catch → 커스텀 AppError 발생
- [ ] 민감 정보 하드코딩 없음 (비밀번호, API_KEY, JWT_SECRET)
- [ ] 입력 검증: DTO + Validator 패턴 사용
- [ ] DB 쿼리: 절대 문자열 연결 금지 (Parameterized Query)
- [ ] 로깅: `logger.error/warn/info/debug` 사용
- [ ] 주석: JSDoc 필수 (public 메서드/클래스)

### 모바일

**모든 작업 완료 전 확인**:

- [ ] Dart analyzer 통과 (`flutter analyze`)
- [ ] 테스트 작성 (`flutter test`)
- [ ] 상태관리: Riverpod 사용 (setState 금지)
- [ ] Clean Architecture 준수 (Data/Domain/Presentation 분리)
- [ ] 에러 처리: try-catch → AppError 발생
- [ ] 비동기: async/await 사용 (then 체인 금지)
- [ ] 위젯: StatelessWidget 우선 (필요시 Riverpod Consumer)
- [ ] 국제화: 한글 문자열 하드코딩 금지 (i18n 또는 상수)
- [ ] 주석: Dartdoc 필수 (public 함수/클래스)

---

## 🔍 코드 검토 기준

Claude Code 작성 후 자동 검토:

### 1단계: 문법 및 타입
```bash
npm run lint        # 백엔드
flutter analyze     # 모바일
npm run typecheck   # TypeScript
```

### 2단계: 테스트
```bash
npm run test        # 백엔드
npm run test:coverage
flutter test        # 모바일
```

### 3단계: 아키텍처
- [ ] 올바른 폴더 구조
- [ ] 모듈 간 의존성 최소화
- [ ] 순환 의존성 없음
- [ ] 책임 분리 (Service/Controller/Repository)

### 4단계: 보안
- [ ] SQL Injection 방지 (Parameterized Query)
- [ ] XSS 방지 (입력 검증)
- [ ] 민감 정보 보호 (하드코딩 금지, 암호화)
- [ ] Rate Limiting 적용 (필요시)

---

## 📝 커밋 메시지 규칙

**모든 커밋은 Conventional Commits 포맷**:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**예시**:
```
feat(auth): add phone login with SMS verification

- Implement requestSmsCode endpoint
- Add SMS code validation (6 digits)
- Add JWT token generation with 7-day expiry
- Include rate limiting (3 requests/5 minutes)

Closes #123
```

**금지 메시지**:
```
❌ "fix bug"
❌ "update"
❌ "changes"
❌ "working on feature"
```

---

## 🚫 절대 금지 사항

### 백엔드

```typescript
❌ var userId = '123';              → const userId = '123';
❌ const data: any = response;      → const data: UserResponse = response;
❌ console.log('debug');            → logger.debug('debug');
❌ async function foo() {           → async function foo() { await ... }
   fetchData();
}
❌ const KEY = 'sk-1234567890';    → const KEY = process.env.API_KEY || '';
❌ SELECT * FROM users WHERE id = '${id}'; → Parameterized Query
```

### 모바일

```dart
❌ final _data;                                → final _data = ...;
❌ setState(() { ... });                      → Riverpod Consumer 사용
❌ .then().then().then()                     → async/await 사용
❌ String name = 'John';  // hardcoded       → 상수 또는 i18n
❌ try { ... } catch (e) { }                 → AppError로 전환
```

---

## 📚 문서 참조 순서

작업 시 다음 순서로 문서 확인:

1. **docs/TODO.md** - 작업할 기능 확인
2. **docs/API_설계서.md** - API 엔드포인트 설계 (백엔드 개발 시)
3. **docs/데이터_모델_설계.md** - DB 스키마 확인
4. **docs/DEVELOPMENT_CONVENTION.md** - 코딩 스타일 및 폴더 구조
5. **docs/개발_가이드.md** - 로컬 환경 셋업, 빌드 명령어
6. **REPOSITORY_SETUP.md** - 레파지토리 구조 (참고용)
7. **FLUTTER_SPRINT_PLAN.md** - Flutter 개발 로드맵 (모바일 개발 시)

---

## 🔄 작업 플로우

### 1단계: 요구사항 파악

```
tasks/issue 받기
  ↓
TODO.md에서 관련 기능 확인
  ↓
API_SPECIFICATION.md / DATABASE_SCHEMA.md 확인
  ↓
Plan Mode 진입 (비자명한 작업인 경우)
```

### 2단계: 계획 수립

```
아키텍처 설계 (어느 파일을 수정할지)
  ↓
테스트 전략 수립
  ↓
예상 소요 시간 계산
  ↓
ExitPlanMode (사용자 승인 받기)
```

### 3단계: 구현

```
코드 작성
  ↓
테스트 작성 (80% 커버리지)
  ↓
컨벤션 확인 (lint, format)
  ↓
보안 체크 (민감 정보, SQL Injection 등)
```

### 4단계: 검증

```
npm run lint / flutter analyze
  ↓
npm run test / flutter test
  ↓
npm run typecheck (백엔드)
  ↓
코드 리뷰 (자체 검토)
```

### 5단계: 커밋

```
git add (특정 파일만)
  ↓
git commit (Conventional Commits 포맷)
  ↓
git push (origin feature-branch)
  ↓
PR 생성 또는 작업 완료 보고
```

---

## 💾 메모리 관리

Claude Code는 프로젝트 구조와 컨벤션을 자동으로 기억합니다.

**저장할 정보**:
- 폴더 구조 및 파일 네이밍 규칙
- 기술 스택 (버전 포함)
- 반복되는 패턴 (Service/Controller/DTO)
- API 응답 포맷
- 테스트 작성 패턴

**프로젝트 진행 중 학습**:
- 기존 코드 읽기
- 에러 패턴 분석
- 팀의 선호도 파악

---

## 🎓 학습 자료

### 백엔드 참고
- **Express Best Practices**: docs/API_SPECIFICATION.md
- **TypeScript**: tsconfig.json (strict mode)
- **마이크로서비스 패턴**: src/services/ 폴더 구조
- **테스트**: docs/TESTING_STRATEGY.md

### 모바일 참고
- **Flutter**: lib/features/ (Clean Architecture)
- **Riverpod**: lib/providers/
- **테스트**: test/, integration_test/
- **네비게이션**: lib/app/routes.dart

---

## 📞 도움 요청 기준

다음 상황에서 사용자에게 확인 요청:

1. **요구사항 불명확**: "이 기능을 어떻게 구현할까요?"
2. **기술 선택**: "A와 B 중 어떤 방식이 좋을까요?"
3. **스코프 조정**: "지금 구현이 너무 크면 줄일까요?"
4. **우선순위**: "A, B, C 중 먼저 뭘 할까요?"
5. **커밋 승인**: PR 생성 전 변경사항 확인

**절대 자동 결정하지 마세요**:
- ❌ 중요한 파일 삭제
- ❌ DB 스키마 변경
- ❌ API 엔드포인트 변경
- ❌ 배포 설정 수정

---

## ⚡ 빠른 참조

### 파일 생성 체크리스트

```
새 서비스 추가 (예: payment)
├─ src/services/payment/
│  ├─ payment.service.ts ✓ (JSDoc)
│  ├─ payment.controller.ts ✓ (JSDoc)
│  ├─ payment.route.ts ✓
│  ├─ payment.dto.ts ✓
│  ├─ payment.validator.ts ✓
│  ├─ payment.error.ts ✓
│  └─ __tests__/
│     ├─ payment.service.test.ts ✓ (80% 커버리지)
│     └─ payment.controller.test.ts ✓
└─ db/migrations/XXX_add_payment_table.sql ✓
```

### 테스트 명령어

```bash
# 백엔드
npm run lint          # ESLint
npm run typecheck     # TypeScript
npm run test          # Jest
npm run test:coverage # 커버리지 보고

# 모바일
flutter analyze       # Dart 분석
flutter test         # 테스트
```

---

## 📊 프로젝트 상태 추적

현재 Sprint 진행 상황:

- **현재 Sprint**: 1-2 (기초 구축)
- **완료된 기능**: (TODO.md 참조)
- **진행 중**: (GitHub Issues 참조)
- **예정**: (TODO.md 참조)

---

## 🎯 최종 체크리스트

**모든 작업 완료 후**:

```
코드 품질
✓ ESLint/Dart analyzer 통과
✓ TypeScript 에러 0개
✓ 테스트 커버리지 80% 이상
✓ 모든 테스트 통과

문서화
✓ JSDoc/Dartdoc 작성
✓ README 업데이트 (필요시)

보안
✓ 민감 정보 하드코딩 없음
✓ SQL Injection 방지
✓ XSS 방지

커밋
✓ Conventional Commits 포맷
✓ 메시지 명확함
✓ PR 설명 완성
```

---

**마지막 업데이트**: 2026-02-28
**버전**: 1.0
