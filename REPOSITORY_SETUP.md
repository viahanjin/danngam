# 🚀 Danngam 프로젝트 - GitHub 레파지토리 설정

**조직**: `viadeveloperss`
**작성일**: 2026-02-24
**상태**: 레파지토리 생성 준비 완료

---

## 📦 레파지토리 구조 (옵션 2 - 분리형)

### 1️⃣ 백엔드 레파지토리
**레파지토리 명**: `danngam-backend`
**URL**: `https://github.com/viadeveloperss/danngam-backend`
**SSH**: `git@github.com:viadeveloperss/danngam-backend.git`
**설명**: Danngam Backend - FastAPI, PostgreSQL, PostGIS
**프라이빗**: Yes

**포함 항목**:
```
danngam-backend/
├── app/
│   ├── main.py              # FastAPI 앱
│   ├── database.py          # DB 연결
│   ├── config.py            # 환경 설정
│   ├── models/              # SQLAlchemy 모델 (8개)
│   ├── schemas/             # Pydantic 스키마
│   ├── routers/             # API 엔드포인트
│   │   ├── auth.py          # ✅ Phase A-4 완료 (3개)
│   │   └── equipment.py     # ⏳ Phase B-1 진행 중 (6개)
│   └── utils/               # 유틸리티 함수
├── tests/                   # 테스트 코드
├── docker-compose.yml       # PostgreSQL + PgAdmin
├── Dockerfile               # FastAPI 컨테이너
├── requirements.txt         # Python 의존성
└── README.md
```

---

### 2️⃣ 프론트엔드 레파지토리
**레파지토리 명**: `danngam-frontend`
**URL**: `https://github.com/viadeveloperss/danngam-frontend`
**SSH**: `git@github.com:viadeveloperss/danngam-frontend.git`
**설명**: Danngam Frontend - Flutter Mobile App
**프라이빗**: Yes

**포함 항목**:
```
danngam-frontend/
├── lib/
│   ├── main.dart
│   ├── config/              # 앱 설정
│   ├── modules/
│   │   ├── auth/            # ✅ Phase F-1 완료 (90%)
│   │   │   ├── screens/     # 4개 화면
│   │   │   ├── services/    # API 서비스
│   │   │   ├── providers/   # Provider 상태관리
│   │   │   └── models/      # 데이터 모델
│   │   ├── equipment/       # ⏳ Phase F-2 예정
│   │   ├── booking/         # ⏳ Phase F-3 예정
│   │   └── chat/            # ⏳ Phase F-4 예정
│   ├── shared/
│   │   ├── widgets/         # 공통 위젯
│   │   ├── utils/           # 유틸리티
│   │   └── constants/       # 상수
│   └── test/                # 테스트
├── pubspec.yaml             # Flutter 의존성
└── README.md
```

---

## 📋 Phase별 진행 상황

### Backend (FastAPI)
```
Phase A: ✅ 100% 완료 (4일)
├── A-1: 프로젝트 초기화 ✅
├── A-2: PostgreSQL + Docker ✅
├── A-3: DB 스키마 ✅
└── A-4: 인증 API ✅

Phase B: ⏳ 진행 중 (예정: 3주)
├── B-1: 장품 API (⏳ 진행 중)
├── B-2: 예약 API (⏳ 다음)
└── B-3: 결제 API (⏳ 다음)

Phase C, D: 📅 예정 중
```

### Frontend (Flutter)
```
Phase F-1: ✅ 90% 완료 (기획 + 구현)
├── SplashScreen ✅
├── OnboardingScreen ✅
├── SocialLoginScreen ✅
└── LoginScreen ✅

Phase F-2~F-4: 📅 예정 중
```

---

## 🔧 개발자가 할 일

### 단계 1: 레파지토리 클론

#### 백엔드 (FastAPI)
```bash
# HTTPS
git clone https://github.com/viadeveloperss/danngam-backend.git
cd danngam-backend

# 또는 SSH
git clone git@github.com:viadeveloperss/danngam-backend.git
cd danngam-backend
```

#### 프론트엔드 (Flutter)
```bash
# HTTPS
git clone https://github.com/viadeveloperss/danngam-frontend.git
cd danngam-frontend

# 또는 SSH
git clone git@github.com:viadeveloperss/danngam-frontend.git
cd danngam-frontend
```

---

### 단계 2: 의존성 설치

#### 백엔드
```bash
# Python 의존성
pip install -r requirements.txt

# 또는 가상환경 사용
python -m venv venv
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate     # Windows
pip install -r requirements.txt
```

#### 프론트엔드
```bash
# Flutter 의존성
flutter pub get

# 빌드 (옵션)
flutter pub get
flutter build apk     # Android
flutter build ios     # iOS
```

---

### 단계 3: 환경 설정

#### 백엔드
```bash
# .env 파일 생성
cp .env.example .env

# 다음 설정 확인
# - DATABASE_URL=postgresql://user:password@localhost:5432/danngam
# - SECRET_KEY=your_secret_key
# - API_BASE_URL=http://localhost:8000
```

#### 프론트엔드
```bash
# lib/config/api_config.dart 확인
# API_BASE_URL = 'http://localhost:8000'  # 개발
# API_BASE_URL = 'https://api.danngam.com'  # 운영
```

---

### 단계 4: 서버 실행

#### 백엔드 (FastAPI)
```bash
# Docker 사용 (권장)
docker-compose up -d

# 또는 직접 실행
python -m uvicorn app.main:app --reload --port 8000

# API 문서: http://localhost:8000/docs
```

#### 프론트엔드 (Flutter)
```bash
# 에뮬레이터 실행
flutter run

# 또는 특정 디바이스
flutter run -d <device_id>

# 빌드만
flutter build apk
flutter build ios
```

---

## 📚 기획 문서 위치

모든 기획 문서는 `/Users/hanjinjang/Desktop/회사/danngam/docs/` 에 저장되어 있습니다:

### 기획 & 설계
- `MVP_아키텍처.md` - 전체 아키텍처
- `FastAPI_Phase_A4_기획서.md` - 인증 API (완료)
- `FastAPI_Phase_B1_기획서.md` - 장품 API (진행 중)
- `FastAPI_Phase_B2_기획서.md` - 예약 API (준비 중)
- `Flutter_Phase_F1_기획서.md` - 로그인 화면
- `Flutter_Implementation_Guide.md` - F-1 구현 코드

### 데이터 & API
- `데이터_모델_설계.md` - 데이터베이스 스키마
- `API_설계서.md` - 전체 API 명세
- `화면_플로우.md` - UI 플로우

### 관리
- `TODO.md` - 전체 개발 로드맵
- `TEAM_SPRINT_PLAN.md` - 팀 스프린트 계획
- `CLAUDE.md` - 개발 가이드 & 팀 역할

---

## 👥 팀 역할 & 연락처

### 기획자 (Planner)
- 요구사항 명세서 작성
- API/Database 설계
- 기획 문서 검토

**담당 문서**:
- FastAPI_Phase_Bx_기획서.md
- Flutter_Phase_Fx_기획서.md

### 개발자 (Developer)
- 백엔드 (FastAPI, PostgreSQL)
- 프론트엔드 (Flutter, Dart)

**작업**:
1. Phase B-1 (장품 API) - 현재 진행 중
2. Phase F-2 (장품 검색 화면) - 대기 중
3. Phase B-2 (예약 API) - 대기 중

### 테스터 (QA/Tester)
- 기능 테스트 (Postman, Flutter)
- 성능 테스트
- 버그 리포팅

**테스트**:
- Postman Collection으로 API 테스트
- Flutter Widget Test
- E2E 테스트

---

## 🔐 GitHub 접근 설정

### SSH 키 설정 (권장)
```bash
# SSH 키 생성 (처음 한 번만)
ssh-keygen -t ed25519 -C "your.email@example.com"

# GitHub에 공개 키 등록
# https://github.com/settings/keys

# SSH 테스트
ssh -T git@github.com
# "Hi username! You've successfully authenticated."
```

### Git 설정
```bash
# 사용자 정보 설정
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 시작하기
git clone git@github.com:viadevelopers/danngam-backend.git
cd danngam-backend
```

---

## 📞 문제 해결

### 레파지토리 접근 거부
```
fatal: Could not read from remote repository.
```
→ SSH 키 확인: `ssh -T git@github.com`

### viadevelopers 조직에 속하지 않음
→ 조직 관리자에게 초대 요청

### 의존성 설치 실패
```bash
# 백엔드
pip install --upgrade pip
pip install -r requirements.txt

# 프론트엔드
flutter clean
flutter pub get
```

---

## ✅ 체크리스트

### 개발 시작 전
- [ ] viadevelopers 조직에 초대됨
- [ ] SSH 또는 HTTPS로 클론 가능
- [ ] 로컬 환경 설정 완료
- [ ] Docker 또는 Python 설치됨
- [ ] Flutter SDK 설치됨 (프론트엔드만)

### 개발 시작
- [ ] Phase 기획 문서 읽음
- [ ] CLAUDE.md 읽음 (역할 확인)
- [ ] TODO.md로 진행 상황 확인
- [ ] 로컬에서 앱 실행 확인

---

**다음 단계**: 개발자와 함께 레파지토리 생성 및 코드 푸시 진행

