# Danngam Backend API

FastAPI 기반의 Danngam 백엔드 API 서버입니다.

## 프로젝트 구조

```
danngam-backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI 앱 초기화
│   ├── config.py            # 설정 파일
│   ├── database.py          # 데이터베이스 설정
│   ├── models/              # SQLAlchemy ORM 모델
│   ├── schemas/             # Pydantic 스키마
│   ├── routers/             # API 라우터
│   └── utils/               # 유틸리티 함수
├── tests/                   # 테스트 코드
├── requirements.txt         # Python 의존성
├── .env.example             # 환경 변수 예제
├── docker-compose.yml       # Docker Compose 설정
├── Dockerfile               # Docker 이미지 설정
└── README.md
```

## 시작하기

### 1. 환경 설정

```bash
# .env 파일 생성
cp .env.example .env
```

### 2. Docker로 실행

```bash
# Docker Compose로 모든 서비스 시작
docker-compose up

# 백그라운드에서 실행
docker-compose up -d
```

### 3. 로컬에서 실행 (Docker 없이)

```bash
# 가상환경 생성
python -m venv venv
source venv/bin/activate  # macOS/Linux
# venv\Scripts\activate  # Windows

# 의존성 설치
pip install -r requirements.txt

# 앱 실행
uvicorn app.main:app --reload
```

## 서비스 접근

- **FastAPI 서버**: http://localhost:8000
- **API 문서 (Swagger)**: http://localhost:8000/docs
- **API 문서 (ReDoc)**: http://localhost:8000/redoc
- **PgAdmin**: http://localhost:5050
  - 이메일: admin@danngam.com
  - 비밀번호: admin
- **PostgreSQL**: localhost:5432

## API 엔드포인트

### 헬스 체크
```bash
curl http://localhost:8000/health
# 응답: {"status":"ok"}
```

## 테스트

```bash
pytest
pytest -v  # 상세 출력
pytest --cov  # 커버리지 확인
```

## 주요 기술 스택

- **Framework**: FastAPI 0.104.1
- **Server**: Uvicorn 0.24.0
- **Database**: PostgreSQL 15
- **ORM**: SQLAlchemy 2.0.23
- **Validation**: Pydantic 2.5.0
- **Authentication**: Python-Jose (JWT)
- **Testing**: Pytest

## 다음 단계

- [ ] Task A-2: PostgreSQL + Docker 설정 검증
- [ ] Task A-3: 데이터베이스 스키마 생성 (SQLAlchemy 모델 작성)
