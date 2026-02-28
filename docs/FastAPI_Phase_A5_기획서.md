# FastAPI Phase A-5: 장비 API 상세 기획서

**작성일**: 2026-02-15
**담당**: 기획자 (Planner)
**상태**: 개발 준비 완료
**Phase**: A-5 (장비 검색 API 구현)

---

## 📋 Executive Summary

**Phase A-5**는 당나무 서비스의 **장비 검색 및 상세 조회 기능**을 구현하는 단계입니다. 위치 기반 검색, 필터링, 정렬 등 고급 검색 기능을 FastAPI로 완성하며, PostGIS를 활용한 지리정보 쿼리를 구현합니다.

**목표**: 6개 장비 검색 API + 위치 기반 검색 로직 완성

**주요 기능**:
- 위치 기반 검색 (반경 30km)
- 장비 유형별 필터링 (이동형/고정형)
- 카테고리, 가격, 평점 필터링
- 페이지네이션 및 정렬
- 장비 상세 정보 조회
- 가용성 확인

---

## 🎯 Phase A-5 목표

### 주요 목표
1. **위치 기반 검색**: GPS 좌표 기반 반경 30km 검색
2. **필터링 & 정렬**: 가격, 평점, 거리, 카테고리
3. **페이지네이션**: limit/offset 기반 조회
4. **가용성 확인**: 예약 가능 여부 실시간 판단

### 성공 기준
- [ ] 모든 6개 엔드포인트 정상 작동
- [ ] 위치 기반 검색 (Haversine 공식)
- [ ] 다양한 필터링 옵션 지원
- [ ] 페이지네이션 동작
- [ ] 가용성 계산 로직 정상
- [ ] Postman 테스트 통과
- [ ] 응답 시간 < 200ms (n=100)

---

## 📊 장비 API 설계

### API 엔드포인트 목록

| # | 메서드 | 엔드포인트 | 설명 | 쿼리 파라미터 |
|---|--------|-----------|------|--------------|
| 1 | GET | `/api/v1/equipments/nearby` | 위치 기반 검색 | lat, lng, radius, type, sort |
| 2 | GET | `/api/v1/equipments/fixed` | 고정형만 검색 | category, min_price, max_price, sort |
| 3 | GET | `/api/v1/equipments/{id}` | 상세 정보 | - |
| 4 | GET | `/api/v1/equipments/categories` | 카테고리 목록 | - |
| 5 | GET | `/api/v1/equipments/search` | 통합 검색 | keyword, lat, lng, category, min_price, max_price |
| 6 | GET | `/api/v1/equipments/{id}/availability` | 가용성 조회 | start_date, end_date |

---

## 🔐 API 엔드포인트 상세 설계

### 1. GET /api/v1/equipments/nearby

**설명**: 사용자 위치 기반으로 반경 내의 장비 검색

#### Request

```
GET /api/v1/equipments/nearby?lat=37.5&lng=127.0&radius=30&type=MOBILE&sort=distance&limit=20&offset=0
```

**쿼리 파라미터**:

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|-------|------|
| lat | float | O | - | 위도 (-90~90) |
| lng | float | O | - | 경도 (-180~180) |
| radius | int | X | 30 | 검색 반경 (km) |
| type | string | X | ALL | MOBILE (이동형), FIXED (고정형), ALL |
| sort | string | X | distance | distance, price_asc, price_desc, rating |
| limit | int | X | 20 | 페이지 크기 |
| offset | int | X | 0 | 페이지 시작 위치 |

#### Response (200 OK)

```json
{
  "success": true,
  "data": {
    "total": 45,
    "limit": 20,
    "offset": 0,
    "equipments": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "name": "크레인 10톤",
        "category": "크레인",
        "type": "MOBILE",
        "price_per_hour": 50000,
        "rating": 4.5,
        "review_count": 23,
        "distance_km": 2.3,
        "location": {
          "lat": 37.52,
          "lng": 127.02
        },
        "image_url": "https://...",
        "available": true
      }
    ]
  },
  "meta": {
    "response_time_ms": 145,
    "timestamp": "2026-02-15T10:30:00Z"
  }
}
```

#### 에러 응답

| 상태 코드 | 설명 | 예시 |
|----------|------|------|
| 200 | 정상 검색 | `{"success": true, "data": {...}}` |
| 400 | 잘못된 좌표 | `{"detail": "Invalid latitude/longitude"}` |
| 422 | 검증 오류 | `{"detail": "latitude must be between -90 and 90"}` |

#### 비즈니스 로직

```python
async def nearby_equipments(
    lat: float,
    lng: float,
    radius: int = 30,
    type: Optional[str] = "ALL",
    sort: str = "distance",
    limit: int = 20,
    offset: int = 0,
    db: Session = Depends(get_db)
) -> NearbyEquipmentsResponse:
    """
    위치 기반 검색 로직

    1. 좌표 검증 (lat, lng)
    2. 반경 내 장비 조회 (PostGIS ST_Distance)
    3. 유형 필터링 (MOBILE, FIXED)
    4. 정렬 (거리, 가격, 평점)
    5. 페이지네이션
    6. 응답 구성
    """
    # 1. 좌표 검증
    if not (-90 <= lat <= 90):
        raise HTTPException(status_code=400, detail="Invalid latitude")
    if not (-180 <= lng <= 180):
        raise HTTPException(status_code=400, detail="Invalid longitude")

    # 2. PostGIS 쿼리 (ST_Distance)
    # SELECT *, ST_Distance(location, ST_Point(lng, lat)) as distance
    # FROM equipments
    # WHERE ST_Distance(location, ST_Point(lng, lat)) <= radius * 1000 (미터)

    # 3. 유형 필터링
    if type and type != "ALL":
        # WHERE equipment_type = type
        pass

    # 4. 정렬
    if sort == "distance":
        # ORDER BY distance ASC
    elif sort == "price_asc":
        # ORDER BY price_per_hour ASC
    elif sort == "price_desc":
        # ORDER BY price_per_hour DESC
    elif sort == "rating":
        # ORDER BY rating DESC, review_count DESC

    # 5. 페이지네이션
    # LIMIT limit OFFSET offset

    # 6. 응답
    return NearbyEquipmentsResponse(...)
```

---

### 2. GET /api/v1/equipments/fixed

**설명**: 고정형 장비만 검색 (정지 상태의 장비)

#### Request

```
GET /api/v1/equipments/fixed?category=지게차&min_price=10000&max_price=100000&sort=rating&limit=20&offset=0
```

**쿼리 파라미터**:

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|-------|------|
| category | string | X | - | 카테고리 (지게차, 크레인, 굴착기 등) |
| min_price | int | X | 0 | 최소 시간당 가격 |
| max_price | int | X | 999999 | 최대 시간당 가격 |
| sort | string | X | rating | rating, price_asc, price_desc |
| limit | int | X | 20 | 페이지 크기 |
| offset | int | X | 0 | 페이지 시작 위치 |

#### Response (200 OK)

```json
{
  "success": true,
  "data": {
    "total": 12,
    "limit": 20,
    "offset": 0,
    "equipments": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440001",
        "name": "지게차 2.5톤",
        "category": "지게차",
        "type": "FIXED",
        "price_per_hour": 25000,
        "rating": 4.8,
        "review_count": 45,
        "supplier": {
          "id": "550e8400-e29b-41d4-a716-446655440002",
          "name": "삼성건설",
          "rating": 4.7
        },
        "location": {
          "lat": 37.55,
          "lng": 127.05
        },
        "image_url": "https://...",
        "available": true
      }
    ]
  }
}
```

---

### 3. GET /api/v1/equipments/{id}

**설명**: 장비의 상세 정보 조회

#### Request

```
GET /api/v1/equipments/550e8400-e29b-41d4-a716-446655440000
```

#### Response (200 OK)

```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "크레인 10톤",
    "category": "크레인",
    "description": "중장비 운반 전문 크레인",
    "type": "MOBILE",
    "price_per_hour": 50000,
    "rating": 4.5,
    "review_count": 23,
    "status": "AVAILABLE",
    "supplier": {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "name": "대우중공업",
      "phone": "010-1234-5678",
      "rating": 4.6,
      "review_count": 150
    },
    "location": {
      "lat": 37.5,
      "lng": 127.0,
      "address": "서울시 강남구 테헤란로"
    },
    "images": [
      {
        "url": "https://...",
        "display_order": 0
      }
    ],
    "specifications": {
      "capacity_ton": 10,
      "weight_ton": 45,
      "height_m": 25
    },
    "reviews": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440003",
        "rating": 5,
        "comment": "매우 안정적이고 빠른 배송",
        "reviewer": {
          "name": "김철수",
          "rating": 4.8
        },
        "created_at": "2026-02-10T10:30:00Z"
      }
    ]
  }
}
```

---

### 4. GET /api/v1/equipments/categories

**설명**: 전체 카테고리 목록 조회

#### Request

```
GET /api/v1/equipments/categories
```

#### Response (200 OK)

```json
{
  "success": true,
  "data": {
    "categories": [
      {
        "name": "크레인",
        "count": 15,
        "icon": "crane"
      },
      {
        "name": "지게차",
        "count": 23,
        "icon": "forklift"
      },
      {
        "name": "굴착기",
        "count": 18,
        "icon": "excavator"
      },
      {
        "name": "콘크리트펌프",
        "count": 8,
        "icon": "pump"
      }
    ]
  }
}
```

---

### 5. GET /api/v1/equipments/search

**설명**: 키워드 + 위치 + 필터 조합 검색

#### Request

```
GET /api/v1/equipments/search?keyword=크레인&lat=37.5&lng=127.0&category=크레인&min_price=40000&max_price=60000&limit=20&offset=0
```

**쿼리 파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| keyword | string | X | 장비명 또는 설명 검색 |
| lat | float | X | 위도 (지정 시 위치 기반) |
| lng | float | X | 경도 (지정 시 위치 기반) |
| radius | int | X | 검색 반경 (km, 기본 30) |
| category | string | X | 카테고리 필터 |
| min_price | int | X | 최소 가격 |
| max_price | int | X | 최대 가격 |
| min_rating | float | X | 최소 평점 (0~5) |
| sort | string | X | distance, price_asc, price_desc, rating |

#### Response (200 OK)

```json
{
  "success": true,
  "data": {
    "total": 8,
    "limit": 20,
    "offset": 0,
    "equipments": [...]
  }
}
```

---

### 6. GET /api/v1/equipments/{id}/availability

**설명**: 특정 날짜 범위의 장비 가용성 확인

#### Request

```
GET /api/v1/equipments/550e8400-e29b-41d4-a716-446655440000/availability?start_date=2026-02-20&end_date=2026-02-27
```

**쿼리 파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| start_date | date | O | 시작 날짜 (YYYY-MM-DD) |
| end_date | date | O | 종료 날짜 (YYYY-MM-DD) |

#### Response (200 OK)

```json
{
  "success": true,
  "data": {
    "equipment_id": "550e8400-e29b-41d4-a716-446655440000",
    "equipment_name": "크레인 10톤",
    "start_date": "2026-02-20",
    "end_date": "2026-02-27",
    "available": true,
    "availability_by_date": [
      {
        "date": "2026-02-20",
        "available": true,
        "booked_hours": []
      },
      {
        "date": "2026-02-21",
        "available": true,
        "booked_hours": []
      },
      {
        "date": "2026-02-22",
        "available": false,
        "booked_hours": ["09:00-17:00"]
      }
    ],
    "estimated_price": {
      "per_hour": 50000,
      "total_hours": 168,
      "subtotal": 8400000,
      "platform_fee": 672000,
      "total": 9072000
    }
  }
}
```

#### 비즈니스 로직

```python
async def check_availability(
    equipment_id: UUID,
    start_date: date,
    end_date: date,
    db: Session = Depends(get_db)
) -> AvailabilityResponse:
    """
    가용성 확인 로직

    1. 장비 존재 여부 확인
    2. 기간 검증 (end >= start)
    3. 예약 조회 (해당 기간 겹치는 예약)
    4. 일자별 예약 시간대 정리
    5. 가격 계산
    6. 응답 구성
    """
    # 1. 장비 확인
    equipment = db.query(Equipment).filter(Equipment.id == equipment_id).first()
    if not equipment:
        raise HTTPException(status_code=404, detail="Equipment not found")

    # 2. 기간 검증
    if start_date >= end_date:
        raise HTTPException(status_code=400, detail="start_date must be before end_date")

    # 3. 예약 조회
    bookings = db.query(Booking).filter(
        Booking.equipment_id == equipment_id,
        Booking.start_time <= end_date,
        Booking.end_time >= start_date,
        Booking.status.in_(["APPROVED", "ONGOING"])
    ).all()

    # 4. 일자별 정리
    # ...

    # 5. 가격 계산
    # total_hours = (end_date - start_date).days * 24
    # total = equipment.price_per_hour * total_hours

    # 6. 응답
    return AvailabilityResponse(...)
```

---

## 💾 데이터 모델

### Equipment (이미 정의됨)

```python
class Equipment(Base):
    __tablename__ = "equipment"

    id: UUID
    name: str
    category: str
    description: str
    type: EquipmentType  # MOBILE, FIXED
    status: EquipmentStatus  # AVAILABLE, RENTED, MAINTENANCE
    price_per_hour: float
    rating: float = 0.0
    review_count: int = 0
    location: geometry.Geometry  # PostGIS Point
    supplier_id: UUID  # FK to User
    created_at: datetime
    updated_at: datetime
```

### EquipmentImage (이미 정의됨)

```python
class EquipmentImage(Base):
    __tablename__ = "equipment_images"

    id: UUID
    equipment_id: UUID  # FK
    image_url: str
    display_order: int
    created_at: datetime
```

### Booking (이미 정의됨) - 가용성 확인에 사용

```python
class Booking(Base):
    __tablename__ = "bookings"

    id: UUID
    equipment_id: UUID  # FK
    renter_id: UUID  # FK
    supplier_id: UUID  # FK
    start_time: datetime
    end_time: datetime
    status: BookingStatus
    total_amount: float
    platform_fee: float
```

---

## 🔑 Pydantic 스키마

### 응답 스키마 구조

```python
# 장비 목록 응답 (공통)
class EquipmentListItem(BaseModel):
    id: UUID
    name: str
    category: str
    type: str
    price_per_hour: float
    rating: float
    review_count: int
    image_url: Optional[str]
    available: bool

class EquipmentListResponse(BaseModel):
    success: bool
    data: Dict
    meta: Dict  # response_time_ms, timestamp

# 카테고리 응답
class CategoryItem(BaseModel):
    name: str
    count: int
    icon: str

class CategoriesResponse(BaseModel):
    success: bool
    data: Dict

# 가용성 응답
class DailyAvailability(BaseModel):
    date: date
    available: bool
    booked_hours: List[str]

class EstimatedPrice(BaseModel):
    per_hour: float
    total_hours: int
    subtotal: float
    platform_fee: float
    total: float

class AvailabilityResponse(BaseModel):
    success: bool
    data: Dict
```

---

## 📝 구현 체크리스트

### 개발자 (Developer)

- [ ] **Pydantic 스키마 작성**
  - [ ] EquipmentListItem
  - [ ] NearbyEquipmentsResponse
  - [ ] FixedEquipmentsResponse
  - [ ] EquipmentDetailResponse
  - [ ] CategoriesResponse
  - [ ] SearchResponse
  - [ ] AvailabilityResponse

- [ ] **유틸리티 함수 작성** (app/utils/equipment.py)
  - [ ] Haversine 거리 계산
  - [ ] PostGIS ST_Distance 쿼리
  - [ ] 기간별 예약 조회
  - [ ] 가격 계산

- [ ] **라우터 구현** (app/routers/equipment.py)
  - [ ] GET /api/v1/equipments/nearby
  - [ ] GET /api/v1/equipments/fixed
  - [ ] GET /api/v1/equipments/{id}
  - [ ] GET /api/v1/equipments/categories
  - [ ] GET /api/v1/equipments/search
  - [ ] GET /api/v1/equipments/{id}/availability

- [ ] **데이터베이스 쿼리 작성**
  - [ ] PostGIS ST_Distance 쿼리
  - [ ] 필터링 (category, price, rating)
  - [ ] 정렬 (distance, price, rating)
  - [ ] 페이지네이션

- [ ] **에러 처리**
  - [ ] 400: 잘못된 요청 (좌표, 날짜)
  - [ ] 404: 찾을 수 없음 (장비)
  - [ ] 422: 검증 오류

- [ ] **성능 최적화**
  - [ ] 인덱스 확인 (location, price, category)
  - [ ] 쿼리 최적화 (N+1 해결)
  - [ ] 응답 시간 < 200ms

---

### 테스터 (Tester)

**테스트 케이스 작성 및 검증**:

#### 1. 위치 기반 검색 (nearby)
- [ ] 정상 검색 (lat, lng 유효)
- [ ] 반경 필터링 (radius 별로 결과 개수 변화)
- [ ] 유형 필터링 (MOBILE, FIXED, ALL)
- [ ] 정렬 (distance, price_asc, price_desc, rating)
- [ ] 페이지네이션 (limit, offset)
- [ ] 에러: 잘못된 좌표 (lat > 90 또는 lng > 180)
- [ ] 에러: radius 음수
- [ ] 응답 시간 측정

#### 2. 고정형 검색 (fixed)
- [ ] 정상 검색
- [ ] 카테고리 필터링
- [ ] 가격 범위 필터링
- [ ] 정렬 (rating, price_asc, price_desc)
- [ ] 페이지네이션

#### 3. 상세 조회 ({id})
- [ ] 정상 조회
- [ ] 404: 존재하지 않는 ID
- [ ] 응답에 리뷰 포함
- [ ] 응답에 공급자 정보 포함

#### 4. 카테고리 목록 (categories)
- [ ] 정상 조회
- [ ] 모든 카테고리 포함
- [ ] 각 카테고리의 장비 수 정확

#### 5. 통합 검색 (search)
- [ ] 키워드 검색
- [ ] 위치 기반 검색
- [ ] 복합 필터 (keyword + category + price)
- [ ] 정렬 기능

#### 6. 가용성 확인 (availability)
- [ ] 정상 조회
- [ ] 예약 있는 날짜 표시
- [ ] 가격 계산 정확성
- [ ] 404: 존재하지 않는 장비
- [ ] 400: 잘못된 날짜 범위

#### 성능 테스트
- [ ] 응답 시간 < 200ms (n=100 이상)
- [ ] 동시 요청 (10명 이상)
- [ ] 대용량 데이터 (1000+개 장비)

---

## 🧪 Postman 테스트 시나리오

### 시나리오 1: 사용자가 근처 장비를 찾는다
1. GET `/api/v1/equipments/nearby?lat=37.5&lng=127.0&radius=30`
2. 결과에서 크레인 선택
3. GET `/api/v1/equipments/{id}`로 상세 정보 조회
4. GET `/api/v1/equipments/{id}/availability?start_date=2026-02-20&end_date=2026-02-27`로 가용성 확인
5. 예약 진행

### 시나리오 2: 고정형 장비를 가격순으로 검색
1. GET `/api/v1/equipments/fixed?sort=price_asc&min_price=10000&max_price=50000`
2. 결과 페이지네이션 테스트

### 시나리오 3: 통합 검색
1. GET `/api/v1/equipments/search?keyword=크레인&category=크레인&min_price=40000&lat=37.5&lng=127.0`

---

## 📅 구현 일정

| Task | 담당 | 소요 시간 | 상태 |
|------|------|---------|------|
| 스키마 작성 | 개발자 | 2시간 | ⏳ |
| 유틸 함수 | 개발자 | 3시간 | ⏳ |
| 라우터 구현 | 개발자 | 4시간 | ⏳ |
| 테스트 케이스 작성 | 테스터 | 2시간 | ⏳ |
| Postman 테스트 | 테스터 | 2시간 | ⏳ |
| **합계** | - | **13시간** | - |

**예상 완료**: 2026-02-18 (금요일)

---

## 📋 인수 기준 (Acceptance Criteria)

### AC-1: 위치 기반 검색
- [ ] GET /api/v1/equipments/nearby 정상 작동
- [ ] Haversine 공식 또는 PostGIS로 거리 계산
- [ ] 반경 30km 기본값
- [ ] MOBILE/FIXED 필터링
- [ ] distance, price, rating 정렬
- [ ] 페이지네이션 (limit/offset)
- [ ] 응답 시간 < 200ms

### AC-2: 고정형 검색
- [ ] GET /api/v1/equipments/fixed 정상 작동
- [ ] 카테고리 필터링
- [ ] 가격 범위 필터링 (min_price, max_price)
- [ ] 정렬 기능
- [ ] 페이지네이션

### AC-3: 상세 조회
- [ ] GET /api/v1/equipments/{id} 정상 작동
- [ ] 장비 정보 완전 조회
- [ ] 이미지 리스트 포함
- [ ] 공급자 정보 포함
- [ ] 리뷰 포함

### AC-4: 카테고리
- [ ] GET /api/v1/equipments/categories 정상 작동
- [ ] 모든 카테고리 반환
- [ ] 각 카테고리 장비 수 정확

### AC-5: 통합 검색
- [ ] GET /api/v1/equipments/search 정상 작동
- [ ] 키워드 검색 (name, description)
- [ ] 위치 기반 필터
- [ ] 복합 필터

### AC-6: 가용성
- [ ] GET /api/v1/equipments/{id}/availability 정상 작동
- [ ] 예약 있는 날짜 표시
- [ ] 예상 가격 계산 정확
- [ ] 평면 데이터 8% 수수료 포함

---

## 🔍 테스트 데이터

현재 데이터베이스에 있는 샘플 데이터:
- 장비 10개
- 서울 지역 위치 (Lat: 37.4~37.6, Lng: 126.9~127.1)
- 다양한 카테고리 (지게차, 크레인, 굴착기 등)
- MOBILE/FIXED 타입 혼합

**추가 데이터**: 필요시 테스트용 데이터 추가 가능

---

## 📞 FAQ

### Q1: PostGIS 없이 구현 가능한가?
**A**: 가능하지만 위치 기반 검색 성능이 낮음. Haversine 공식 사용:
```python
def haversine(lat1, lng1, lat2, lng2):
    R = 6371  # 지구 반경 (km)
    lat1, lng1, lat2, lng2 = map(radians, [lat1, lng1, lat2, lng2])
    dlat = lat2 - lat1
    dlng = lng2 - lng1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlng/2)**2
    return 2 * R * asin(sqrt(a))
```

### Q2: 가용성 계산은 어떻게 하나?
**A**: Booking 테이블에서 겹치는 예약 조회:
```sql
SELECT * FROM bookings
WHERE equipment_id = ?
  AND start_time <= ?
  AND end_time >= ?
  AND status IN ('APPROVED', 'ONGOING')
```

### Q3: 수수료는 몇 %인가?
**A**: 8% (total_amount * 0.08)

### Q4: 응답 시간 최적화는?
**A**:
- 인덱스: location, category, price_per_hour
- N+1 쿼리 해결: SQLAlchemy joinedload
- 캐싱: Redis (카테고리, 자주 검색하는 위치)

---

**작성자**: 기획팀
**작성일**: 2026-02-15
**버전**: 1.0.0
**상태**: 개발 준비 완료
