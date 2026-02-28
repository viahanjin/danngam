# FastAPI Phase B-1: 장비 API 기획서

**작성일**: 2026-02-17
**상태**: 기획 완료 (개발 대기)
**목표**: 6개 엔드포인트, 약 1,050줄 코드
**담당**: 개발자 (구현), 테스터 (검증)

---

## 📋 개요

### 목표
- 농기계 장비 검색, 조회, 가용성 확인 API 구현
- 위치 기반 검색 (PostGIS) 지원
- 장비 카테고리 조회
- 상세 검색 기능

### 주요 기능
- 이동형/고정형 장비 구분 검색
- 위치 기반 거리 계산 (Haversine 공식)
- 실시간 가용성 확인
- 가격 정렬 기능

---

## 🛠 개발 범위

### 생성할 파일/수정 파일

```
app/
├── schemas/
│   ├── equipment.py          # [NEW] 장비 스키마
│   └── __init__.py           # [MODIFY] 임포트 추가
├── routers/
│   ├── equipment.py          # [NEW] 장비 라우터
│   └── __init__.py           # [MODIFY] 임포트 추가
└── utils/
    ├── equipment.py          # [NEW] 장비 유틸리티
    └── __init__.py           # [MODIFY] 임포트 추가
```

### 코드라인 분배
```
schemas/equipment.py       : 200줄 (7개 스키마)
utils/equipment.py         : 150줄 (4개 함수)
routers/equipment.py       : 700줄 (6개 엔드포인트)
─────────────────────────────────
합계                      : 1,050줄
```

---

## 📊 데이터 스키마 정의

### 1. EquipmentListItem (장비 목록 아이템)

**용도**: 장비 목록 조회 응답

```python
class EquipmentListItem(BaseModel):
    """장비 목록 아이템 (검색/추천 결과)"""
    id: int                          # 장비 ID
    name: str                        # 장비명
    category: str                    # 카테고리 (예: "콤바인", "트랙터")
    equipment_type: str              # 유형 (MOBILE, FIXED)
    location: str                    # 위치 (시/도)
    price_per_day: float             # 일일 가격
    rating: float                    # 평점 (0~5)
    review_count: int                # 리뷰 수
    image_url: str                   # 썸네일 이미지 URL
    distance_km: Optional[float]     # 거리 (위치 검색 시에만)
```

**JSON 예시**:
```json
{
  "id": 1,
  "name": "콤바인 2024",
  "category": "콤바인",
  "equipment_type": "MOBILE",
  "location": "경기도 용인시",
  "price_per_day": 150000.0,
  "rating": 4.8,
  "review_count": 25,
  "image_url": "https://api.danngam.com/images/equipment/1.jpg",
  "distance_km": 2.5
}
```

---

### 2. NearbyEquipmentsResponse (근처 장비 응답)

**용도**: GET /api/v1/equipments/nearby 응답

```python
class NearbyEquipmentsResponse(BaseModel):
    """근처 장비 목록 응답"""
    total: int                       # 전체 검색 결과 수
    count: int                       # 이번 페이지 결과 수
    limit: int                       # 페이지 크기
    offset: int                      # 오프셋
    user_location: dict              # 사용자 위치 {lat, lng}
    search_radius_km: int            # 검색 반경
    results: List[EquipmentListItem] # 장비 목록
    filters_applied: dict            # 적용된 필터
```

**JSON 예시**:
```json
{
  "total": 45,
  "count": 10,
  "limit": 10,
  "offset": 0,
  "user_location": {
    "latitude": 37.2636,
    "longitude": 127.0286
  },
  "search_radius_km": 30,
  "results": [
    {
      "id": 1,
      "name": "콤바인 2024",
      "category": "콤바인",
      ...
    }
  ],
  "filters_applied": {
    "equipment_type": "MOBILE",
    "category": null,
    "sort_by": "distance"
  }
}
```

---

### 3. FixedEquipmentsResponse (고정형 장비 응답)

**용도**: GET /api/v1/equipments/fixed 응답

```python
class FixedEquipmentsResponse(BaseModel):
    """고정형 장비 목록 응답"""
    total: int                       # 전체 결과 수
    count: int                       # 이번 페이지 결과 수
    limit: int
    offset: int
    results: List[EquipmentListItem] # 고정형 장비 목록
```

---

### 4. EquipmentDetailResponse (장비 상세 조회 응답)

**용도**: GET /api/v1/equipments/{id} 응답

```python
class EquipmentImage(BaseModel):
    """장비 이미지"""
    id: int
    url: str
    alt_text: str
    order: int

class EquipmentDetailResponse(BaseModel):
    """장비 상세 정보"""
    id: int                          # 장비 ID
    name: str                        # 장비명
    category: str                    # 카테고리
    equipment_type: str              # MOBILE / FIXED

    # 기본 정보
    manufacturer: str                # 제조사
    year: int                        # 연식
    condition: str                   # 상태 (EXCELLENT, GOOD, FAIR)

    # 위치 정보 (FIXED인 경우)
    location: str                    # 주소
    latitude: float
    longitude: float

    # 가격 정보
    price_per_day: float             # 일일 가격
    price_per_week: float            # 주간 가격 (일일 * 6)
    price_per_month: float           # 월간 가격 (일일 * 25)
    setup_fee: Optional[float]       # 설치비

    # 사양 정보
    specifications: dict             # {엔진: "...", 너비: "..."}

    # 이미지
    images: List[EquipmentImage]     # 이미지 목록

    # 평가 정보
    rating: float                    # 평점
    review_count: int                # 리뷰 수

    # 가용성
    available: bool                  # 현재 가능 여부
    available_from: str              # YYYY-MM-DD
    booked_dates: List[str]          # 예약된 날짜들

    # 소유자 정보
    owner: dict                      # {id, name, rating, response_rate}

    # 메타
    created_at: str                  # ISO 8601
    updated_at: str                  # ISO 8601
```

---

### 5. CategoriesResponse (카테고리 응답)

**용도**: GET /api/v1/equipments/categories 응답

```python
class CategoryItem(BaseModel):
    """카테고리 아이템"""
    id: int
    name: str                        # 카테고리명
    icon: str                        # 아이콘 URL
    count: int                       # 해당 카테고리 장비 수
    subcategories: Optional[List[str]] # 서브카테고리

class CategoriesResponse(BaseModel):
    """카테고리 목록 응답"""
    categories: List[CategoryItem]
    total_count: int                 # 전체 장비 수
```

**JSON 예시**:
```json
{
  "categories": [
    {
      "id": 1,
      "name": "콤바인",
      "icon": "https://api.danngam.com/icons/combine.png",
      "count": 45,
      "subcategories": ["소형", "중형", "대형"]
    },
    {
      "id": 2,
      "name": "트랙터",
      "icon": "https://api.danngam.com/icons/tractor.png",
      "count": 120,
      "subcategories": ["소형", "중형", "대형"]
    }
  ],
  "total_count": 500
}
```

---

### 6. SearchResponse (통합 검색 응답)

**용도**: GET /api/v1/equipments/search 응답

```python
class SearchResponse(BaseModel):
    """통합 검색 응답"""
    query: str                       # 검색어
    filters: dict                    # 적용된 필터
    total: int                       # 전체 결과 수
    count: int                       # 이번 페이지 결과 수
    limit: int
    offset: int
    results: List[EquipmentListItem] # 검색 결과
```

---

### 7. AvailabilityResponse (가용성 응답)

**용도**: GET /api/v1/equipments/{id}/availability 응답

```python
class AvailabilityResponse(BaseModel):
    """장비 가용성 응답"""
    equipment_id: int
    equipment_name: str
    available: bool                  # 현재 가능 여부
    available_from: str              # YYYY-MM-DD
    booked_dates: List[str]          # 예약된 날짜 (YYYY-MM-DD 형식)
    price_per_day: float
    estimated_total: Optional[float] # 예상 총액 (요청 날짜 범위가 있을 경우)
```

---

## 🔌 API 엔드포인트 정의

### 1️⃣ GET /api/v1/equipments/nearby

**설명**: 사용자 위치 기반으로 근처 장비 검색

**요청 파라미터**:
```
lat (float, required)     - 사용자 위도 (예: 37.2636)
lng (float, required)     - 사용자 경도 (예: 127.0286)
radius (int, optional)    - 검색 반경 (km, 기본값: 30, 최대: 100)
type (str, optional)      - 장비 유형 (MOBILE, FIXED, 기본값: 모두)
category (str, optional)  - 카테고리 (예: "콤바인")
sort_by (str, optional)   - 정렬 기준 (distance, price_asc, price_desc, rating, 기본값: distance)
limit (int, optional)     - 페이지 크기 (기본값: 10, 최대: 50)
offset (int, optional)    - 오프셋 (기본값: 0)
min_rating (float, optional) - 최소 평점 (기본값: 0)
max_price (float, optional)  - 최대 일일가 (기본값: 무제한)
```

**요청 예시**:
```
GET /api/v1/equipments/nearby?lat=37.2636&lng=127.0286&radius=30&type=MOBILE&sort_by=distance&limit=10&offset=0
```

**응답**: NearbyEquipmentsResponse (HTTP 200)

**에러 처리**:
- 400: 유효하지 않은 좌표 (lat/lng 범위 확인)
- 400: 유효하지 않은 radius (1 <= radius <= 100)
- 400: 유효하지 않은 sort_by 값
- 500: 데이터베이스 오류

**비즈니스 로직**:
1. lat, lng 유효성 검사 (-90 <= lat <= 90, -180 <= lng <= 180)
2. PostGIS ST_Distance 함수로 거리 계산
3. radius 내의 MOBILE 또는 FIXED 장비 필터링
4. 정렬 기준 적용
5. 페이지네이션 처리
6. 각 장비마다 추가 정보 계산 (거리, 별점 평균)

---

### 2️⃣ GET /api/v1/equipments/fixed

**설명**: 고정형 장비 목록 (위치별로 설치된 장비)

**요청 파라미터**:
```
category (str, optional)  - 카테고리 필터
location (str, optional)  - 지역 검색 (시/도)
sort_by (str, optional)   - 정렬 (price_asc, price_desc, rating, 기본값: rating)
limit (int, optional)     - 페이지 크기 (기본값: 10)
offset (int, optional)    - 오프셋 (기본값: 0)
```

**요청 예시**:
```
GET /api/v1/equipments/fixed?location=경기도&sort_by=rating&limit=10
```

**응답**: FixedEquipmentsResponse (HTTP 200)

**에러 처리**:
- 400: 유효하지 않은 파라미터
- 500: 데이터베이스 오류

---

### 3️⃣ GET /api/v1/equipments/{id}

**설명**: 장비 상세 정보 조회

**요청 파라미터**:
```
id (int, path) - 장비 ID
```

**요청 예시**:
```
GET /api/v1/equipments/1
```

**응답**: EquipmentDetailResponse (HTTP 200)

**에러 처리**:
- 404: 장비를 찾을 수 없음
- 500: 데이터베이스 오류

**비즈니스 로직**:
1. 장비 ID로 조회
2. 관련 이미지 로드
3. 예약된 날짜 계산
4. 평가 및 리뷰 통계 계산
5. 소유자 정보 추가

---

### 4️⃣ GET /api/v1/equipments/categories

**설명**: 장비 카테고리 목록 조회

**요청 파라미터**: 없음

**요청 예시**:
```
GET /api/v1/equipments/categories
```

**응답**: CategoriesResponse (HTTP 200)

**에러 처리**:
- 500: 데이터베이스 오류

---

### 5️⃣ GET /api/v1/equipments/search

**설명**: 통합 검색 (장비명, 카테고리, 위치)

**요청 파라미터**:
```
q (str, required)         - 검색어
type (str, optional)      - 장비 유형 (MOBILE, FIXED)
category (str, optional)  - 카테고리
location (str, optional)  - 지역
sort_by (str, optional)   - 정렬 (relevance, price_asc, price_desc, rating, 기본값: relevance)
limit (int, optional)     - 페이지 크기 (기본값: 10)
offset (int, optional)    - 오프셋 (기본값: 0)
```

**요청 예시**:
```
GET /api/v1/equipments/search?q=콤바인&location=경기도&sort_by=price_asc
```

**응답**: SearchResponse (HTTP 200)

**에러 처리**:
- 400: 검색어 길이 부족 (최소 2글자)
- 400: 유효하지 않은 파라미터
- 500: 데이터베이스 오류

**비즈니스 로직**:
1. 검색어 유효성 검사 (최소 2글자)
2. 장비명, 카테고리, 설명 등에서 전문 검색
3. 필터링 적용
4. 관련성(relevance) 정렬
5. 페이지네이션

---

### 6️⃣ GET /api/v1/equipments/{id}/availability

**설명**: 특정 장비의 가용성 조회 및 예상 가격 계산

**요청 파라미터**:
```
id (int, path)            - 장비 ID
start_date (str, optional) - 시작 날짜 (YYYY-MM-DD)
end_date (str, optional)   - 종료 날짜 (YYYY-MM-DD)
```

**요청 예시**:
```
GET /api/v1/equipments/1/availability?start_date=2026-03-01&end_date=2026-03-07
```

**응답**: AvailabilityResponse (HTTP 200)

**에러 처리**:
- 404: 장비를 찾을 수 없음
- 400: 유효하지 않은 날짜 형식
- 400: start_date > end_date
- 500: 데이터베이스 오류

**비즈니스 로직**:
1. 장비 조회
2. 해당 기간 예약 확인
3. 날짜 범위 내 가용성 판단
4. 예상 가격 계산 (일일 가격 × 일수 × (1 + 8% 수수료))
5. 예약된 날짜 목록 반환

---

## 🛠 유틸리티 함수

### utils/equipment.py

#### 1️⃣ haversine_distance(lat1, lng1, lat2, lng2) → float

**설명**: Haversine 공식을 이용한 두 점 간 거리 계산

**입력**:
```python
lat1: float  # 시작점 위도
lng1: float  # 시작점 경도
lat2: float  # 끝점 위도
lng2: float  # 끝점 경도
```

**출력**: 거리 (km)

**구현 상세**:
```
지구 반지름: 6371 km
공식: a = sin²(Δφ/2) + cos φ1 ⋅ cos φ2 ⋅ sin²(Δλ/2)
     c = 2 ⋅ atan2( √a, √(1−a) )
     d = R ⋅ c
```

**테스트 케이스**:
- (37.2636, 127.0286) → (37.2985, 127.0408): ~4.5km
- 같은 좌표: 0km
- 극단값 처리: 유효성 검사

---

#### 2️⃣ calculate_booking_price(price_per_day, days, has_setup_fee=False) → float

**설명**: 예약 가격 계산 (수수료 포함)

**입력**:
```python
price_per_day: float    # 일일 가격
days: int               # 대여 기간 (일)
has_setup_fee: bool     # 설치비 포함 여부
```

**출력**: 총 가격 (세금 포함)

**계산 로직**:
```
기본료 = price_per_day × days
수수료 = 기본료 × 0.08 (8%)
설치비 = 해당 시 포함
합계 = 기본료 + 수수료 + 설치비
```

**예시**:
```
price_per_day = 150,000
days = 3
수수료 = 450,000 × 0.08 = 36,000
총액 = 450,000 + 36,000 = 486,000
```

---

#### 3️⃣ is_equipment_available(equipment_id, start_date, end_date) → bool

**설명**: 특정 기간의 장비 가용성 확인

**입력**:
```python
equipment_id: int       # 장비 ID
start_date: date        # 시작 날짜
end_date: date          # 종료 날짜
```

**출력**: True (가능), False (불가능)

**로직**:
1. equipment_id로 장비 조회
2. 해당 기간의 예약(status=APPROVED) 확인
3. 예약된 날짜가 겹치는지 확인
4. 겹치지 않으면 True, 겹치면 False

---

#### 4️⃣ format_equipment_response(equipment_obj, include_distance=False, distance_km=None) → dict

**설명**: 장비 객체를 응답 포맷으로 변환

**입력**:
```python
equipment_obj: Equipment   # SQLAlchemy 모델 객체
include_distance: bool     # 거리 정보 포함 여부
distance_km: Optional[float] # 거리 (km)
```

**출력**: dict (JSON 직렬화 가능)

**처리**:
1. 장비 기본 정보 추출
2. 이미지 목록 로드
3. 평가 통계 계산
4. 거리 정보 추가 (필요 시)
5. 날짜 포맷팅 (ISO 8601)

---

## ✅ 인수 기준 (Acceptance Criteria)

### 기능 요구사항
- [ ] 6개 엔드포인트 모두 정상 작동
- [ ] 위치 기반 검색 (PostGIS) 정상 작동
- [ ] 거리 계산 정확도 ±1km
- [ ] 정렬 기능 (거리, 가격, 평점) 정상 작동
- [ ] 페이지네이션 정상 작동
- [ ] 장비 카테고리 분류 정확
- [ ] 가용성 계산 정확
- [ ] 예상 가격 계산 정확

### 비기능 요구사항
- [ ] 응답 시간 < 500ms (평균)
- [ ] 동시 100명 사용자 부하 테스트 통과
- [ ] 코드 커버리지 >= 80%
- [ ] 모든 엔드포인트 에러 핸들링 구현
- [ ] API 문서화 (자동 생성 - Swagger/OpenAPI)

### 코드 품질
- [ ] 모든 함수에 docstring 작성
- [ ] Type hints 완전히 적용
- [ ] PEP 8 준수
- [ ] 임시 코드/TODO 제거
- [ ] 테스트 케이스 작성 및 통과 (최소 14개)

---

## 📝 구현 순서 (권장)

### Step 1: 스키마 작성 (schemas/equipment.py)
- 모든 7개 스키마 정의
- 시간: 2시간

### Step 2: 유틸리티 함수 작성 (utils/equipment.py)
- 4개 함수 구현 및 단위 테스트
- 시간: 3시간

### Step 3: 라우터 구현 (routers/equipment.py)
- 6개 엔드포인트 순차적 구현
  1. GET /nearby (가장 복잡)
  2. GET /fixed
  3. GET /{id}
  4. GET /categories
  5. GET /search
  6. GET /{id}/availability
- 시간: 4시간

### Step 4: 통합 테스트 (tests/test_equipment.py)
- Postman 테스트 또는 pytest
- 시간: 2시간

---

## 🧪 테스트 케이스 (최소 14개)

### 근처 장비 검색 (GET /nearby)
1. 정상 검색 (반경 30km)
2. 위치 필터링 (MOBILE만)
3. 거리순 정렬
4. 가격순 정렬 (오름차순)
5. 가격순 정렬 (내림차순)
6. 평점 필터링
7. 페이지네이션
8. 유효하지 않은 좌표 (에러)
9. 검색 결과 없음

### 고정형 장비 (GET /fixed)
10. 지역별 필터링
11. 카테고리별 필터링
12. 정렬 기능

### 장비 상세 (GET /{id})
13. 정상 조회
14. 없는 장비 (404)

---

## 📞 주의사항

### 성능
- PostGIS 쿼리 최적화 필수
  - 인덱스: location 컬럼에 GIST 인덱스
  - 쿼리: ST_DistanceSphere 또는 ST_Distance 사용
- N+1 문제 방지
  - eager loading (joinedload) 사용
  - 필요한 컬럼만 선택

### 보안
- 사용자 입력 검증 (최대 범위 확인)
- SQL injection 방지 (ORM 사용)
- 레이트 리미팅 (필요 시)

### 데이터 일관성
- 예약된 날짜 확인 시 트랜잭션 사용
- 가격 계산 로직 검증

---

## 📋 체크리스트

**개발자**:
- [ ] 스키마 작성 완료
- [ ] 유틸리티 함수 테스트 완료
- [ ] 6개 엔드포인트 구현 완료
- [ ] 자동 문서(Swagger) 확인
- [ ] 테스터에게 전달

**테스터**:
- [ ] 14개 테스트 케이스 모두 실행
- [ ] Postman으로 엔드포인트 테스트
- [ ] 성능 테스트 (응답 시간)
- [ ] 부하 테스트 (동시 100명)
- [ ] 버그 리포트 작성

---

**담당**: 개발자 (구현)
**마감**: 2026-02-21 (예상 5일 개발 기간)
**상태**: 기획 완료, 개발 대기
