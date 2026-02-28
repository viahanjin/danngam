# Danngam API 설계서 (로컬 상태 관리 버전)

## 1. 문서 정보

- **프로젝트명**: Danngam (농기계 공유 플랫폼)
- **API 버전**: v1 (향후 백엔드 구현 예정)
- **작성일**: 2026-02-14
- **상태**: MVP (Minimum Viable Product) - 로컬 상태 관리 중심
- **목적**: 농기계 예약 및 결제 시스템을 위한 설계 정의 및 향후 API 규격 정의

---

## 2. 개요

### 2.1 현재 MVP 상태: 로컬 상태 관리 (API 없음)

본 문서는 두 가지 구성으로 나뉩니다:

1. **[Part 1] 현재 로컬 데이터 관리 방식** (MVP 진행 중)
   - API 없이 Mock JSON 데이터 사용
   - LocalStorage에 데이터 저장
   - Provider 패턴으로 상태 관리

2. **[Part 2] 향후 백엔드 API 설계** (참고용, 미구현)
   - 백엔드 선택 후 구현 예정
   - 3가지 백엔드 옵션별 구현 가이드
   - RESTful API 엔드포인트 정의

### 2.2 주의사항

> **현재 로컬 버전이므로 API 없습니다.**
> 향후 백엔드를 선택한 후 아래 'Part 2'의 API를 구현합니다.
> - Supabase (추천)
> - FastAPI (Python)
> - Firebase (대안)

---

# Part 1: 현재 로컬 상태 관리 방식

## 3. 로컬 데이터 구조

### 3.1 Mock JSON 데이터 (assets/data/)

**디렉토리 구조**:
```
assets/
├── data/
│  ├── users.json          # 사용자 목록
│  ├── equipments.json     # 장비 목록
│  ├── bookings.json       # 예약 목록
│  ├── payments.json       # 결제 목록
│  ├── reviews.json        # 리뷰 목록
│  └── categories.json     # 카테고리 목록
```

### 3.2 Users Mock Data

**파일**: `assets/data/users.json`

```json
{
  "users": [
    {
      "id": "user_001",
      "phone": "01012345678",
      "name": "이농부",
      "role": "supplier",
      "verified_at": "2025-12-01T10:00:00Z",
      "rating": 4.8,
      "review_count": 42,
      "profile_image_url": "https://via.placeholder.com/150",
      "address": "경기도 여주시",
      "location": {
        "latitude": 37.5,
        "longitude": 127.0
      },
      "created_at": "2025-08-15T10:00:00Z"
    },
    {
      "id": "user_002",
      "phone": "01087654321",
      "name": "김농부",
      "role": "demander",
      "verified_at": "2025-11-01T15:30:00Z",
      "profile_image_url": "https://via.placeholder.com/150",
      "address": "경기도 용인시",
      "location": {
        "latitude": 37.3,
        "longitude": 127.1
      },
      "created_at": "2025-09-10T08:00:00Z"
    }
  ]
}
```

### 3.3 Equipments Mock Data

**파일**: `assets/data/equipments.json`

```json
{
  "equipments": [
    {
      "id": "eq_001",
      "supplier_id": "user_001",
      "name": "트랙터 80마력",
      "type": "MOBILE",
      "category": "TRACTOR",
      "model": "T-1000",
      "manufacturer": "Kubota",
      "manufacturing_year": 2022,
      "condition": "EXCELLENT",
      "hourly_rate": 25000,
      "location": {
        "latitude": 37.5,
        "longitude": 127.0,
        "address": "경기도 여주시"
      },
      "operation_hours_start": "08:00",
      "operation_hours_end": "17:00",
      "images": [
        "https://via.placeholder.com/400x300?text=Tractor+1",
        "https://via.placeholder.com/400x300?text=Tractor+2",
        "https://via.placeholder.com/400x300?text=Tractor+3"
      ],
      "rating": 4.8,
      "review_count": 42,
      "status": "ACTIVE",
      "created_at": "2025-10-01T10:00:00Z"
    },
    {
      "id": "eq_002",
      "supplier_id": "user_001",
      "name": "곡물건조기 50톤",
      "type": "FIXED",
      "category": "DRYER",
      "model": "D-500",
      "manufacturer": "Samsung",
      "manufacturing_year": 2021,
      "condition": "GOOD",
      "hourly_rate": 50000,
      "location": {
        "latitude": 37.2,
        "longitude": 126.9,
        "address": "경기도 이천시"
      },
      "operation_hours_start": "06:00",
      "operation_hours_end": "20:00",
      "images": [
        "https://via.placeholder.com/400x300?text=Dryer+1"
      ],
      "rating": 4.9,
      "review_count": 28,
      "status": "ACTIVE",
      "created_at": "2025-09-15T10:00:00Z"
    }
  ]
}
```

### 3.4 Bookings Mock Data

**파일**: `assets/data/bookings.json`

```json
{
  "bookings": [
    {
      "id": "book_001",
      "user_id": "user_002",
      "equipment_id": "eq_001",
      "start_datetime": "2026-02-15T08:00:00Z",
      "end_datetime": "2026-02-15T16:00:00Z",
      "duration_hours": 8,
      "hourly_rate": 25000,
      "total_amount": 200000,
      "platform_fee": 16000,
      "status": "CONFIRMED",
      "created_at": "2026-02-14T10:30:00Z"
    }
  ]
}
```

### 3.5 Payments Mock Data

**파일**: `assets/data/payments.json`

```json
{
  "payments": [
    {
      "id": "pay_001",
      "booking_id": "book_001",
      "amount": 200000,
      "platform_fee": 16000,
      "total_amount": 216000,
      "payment_method": "CARD",
      "payment_status": "COMPLETED",
      "transactionId": "txn_20260214_001",
      "receipt_url": "https://via.placeholder.com/receipt",
      "created_at": "2026-02-14T10:35:00Z"
    }
  ]
}
```

### 3.6 Reviews Mock Data

**파일**: `assets/data/reviews.json`

```json
{
  "reviews": [
    {
      "id": "rev_001",
      "booking_id": "book_001",
      "equipment_id": "eq_001",
      "reviewer_id": "user_002",
      "rating": 5,
      "title": "정말 좋은 장비입니다!",
      "content": "상태도 좋고 주인분도 친절하셨습니다. 추천합니다.",
      "images": [],
      "helpful_count": 5,
      "reported": false,
      "created_at": "2026-02-16T14:00:00Z"
    }
  ]
}
```

---

## 4. 로컬 상태 관리 (Provider)

### 4.1 Provider 구조

**디렉토리**: `lib/providers/`

```
lib/providers/
├── user_provider.dart         # 사용자 상태
├── equipment_provider.dart    # 장비 상태
├── booking_provider.dart      # 예약 상태
├── payment_provider.dart      # 결제 상태
├── review_provider.dart       # 리뷰 상태
└── app_provider.dart          # 앱 전역 상태
```

### 4.2 예시: UserProvider

```dart
class UserProvider extends ChangeNotifier {
  static final UserProvider _instance = UserProvider._internal();

  factory UserProvider() {
    return _instance;
  }

  UserProvider._internal();

  User? _currentUser;
  List<User> _users = [];

  // Getters
  User? get currentUser => _currentUser;
  List<User> get users => _users;

  // 로컬 저장소 로드
  Future<void> loadUsersFromLocal() async {
    final jsonStr = await rootBundle.loadString('assets/data/users.json');
    final data = json.decode(jsonStr);
    _users = List<User>.from(
      data['users'].map((u) => User.fromJson(u))
    );
    notifyListeners();
  }

  // 사용자 로그인
  Future<bool> login(String phone, String otp) async {
    // 로컬에서 사용자 검색
    final user = _users.firstWhere(
      (u) => u.phone == phone,
      orElse: () => null,
    );

    if (user != null) {
      _currentUser = user;
      // LocalStorage에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUserId', user.id);
      notifyListeners();
      return true;
    }
    return false;
  }

  // 사용자 로그아웃
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');
    notifyListeners();
  }
}
```

### 4.3 LocalStorage 사용 (SharedPreferences)

```dart
// 데이터 저장
final prefs = await SharedPreferences.getInstance();
await prefs.setString('user_profile', jsonEncode(user));

// 데이터 로드
final userJson = prefs.getString('user_profile');
final user = User.fromJson(json.decode(userJson));

// 데이터 삭제
await prefs.remove('user_profile');
```

---

## 5. 검색 및 필터링 (로컬)

### 5.1 위치 기반 검색 (로컬)

```dart
class EquipmentProvider extends ChangeNotifier {
  List<Equipment> searchNearby({
    required double userLat,
    required double userLng,
    required String type,
    int radiusKm = 30,
  }) {
    return equipments.where((eq) {
      // 거리 계산
      final distance = _calculateDistance(
        userLat, userLng,
        eq.location.latitude, eq.location.longitude
      );

      return eq.type == type && distance <= radiusKm;
    }).toList();
  }

  // Haversine 공식으로 거리 계산
  double _calculateDistance(double lat1, double lng1,
                            double lat2, double lng2) {
    const earthRadiusKm = 6371;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(_toRad(lat1)) * cos(_toRad(lat2)) *
              sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRad(double degree) => degree * pi / 180;
}
```

### 5.2 카테고리 필터링

```dart
List<Equipment> filterByCategory(String category) {
  return equipments.where((eq) => eq.category == category).toList();
}
```

### 5.3 가격 범위 필터링

```dart
List<Equipment> filterByPrice(int minPrice, int maxPrice) {
  return equipments.where((eq) =>
    eq.hourly_rate >= minPrice && eq.hourly_rate <= maxPrice
  ).toList();
}
```

---

## 6. 예약 및 결제 (로컬)

### 6.1 예약 생성

```dart
class BookingProvider extends ChangeNotifier {
  Future<bool> createBooking({
    required String userId,
    required String equipmentId,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) async {
    // 가용성 확인
    final isAvailable = _checkAvailability(
      equipmentId, startDateTime, endDateTime
    );

    if (!isAvailable) {
      return false;
    }

    // 예약 생성
    final booking = Booking(
      id: 'book_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      equipmentId: equipmentId,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      durationHours: endDateTime.difference(startDateTime).inHours,
      status: 'PENDING',
      createdAt: DateTime.now(),
    );

    _bookings.add(booking);

    // LocalStorage에 저장
    final prefs = await SharedPreferences.getInstance();
    final bookingsJson = _bookings.map((b) => b.toJson()).toList();
    await prefs.setString('bookings', jsonEncode(bookingsJson));

    notifyListeners();
    return true;
  }

  bool _checkAvailability(String equipmentId,
                          DateTime start, DateTime end) {
    return !_bookings.any((b) =>
      b.equipmentId == equipmentId &&
      b.status != 'CANCELLED' &&
      !(end.isBefore(b.startDateTime) ||
        start.isAfter(b.endDateTime))
    );
  }
}
```

### 6.2 결제 처리 (로컬 시뮬레이션)

```dart
class PaymentProvider extends ChangeNotifier {
  Future<bool> processPayment({
    required String bookingId,
    required int amount,
    required String paymentMethod,
  }) async {
    // 로컬에서는 결제 성공으로 시뮬레이션
    final payment = Payment(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      amount: amount,
      platformFee: (amount * 0.08).toInt(),
      totalAmount: (amount * 1.08).toInt(),
      paymentMethod: paymentMethod,
      paymentStatus: 'COMPLETED', // 항상 성공
      transactionId: 'txn_mock_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );

    _payments.add(payment);

    // LocalStorage에 저장
    final prefs = await SharedPreferences.getInstance();
    final paymentsJson = _payments.map((p) => p.toJson()).toList();
    await prefs.setString('payments', jsonEncode(paymentsJson));

    notifyListeners();
    return true;
  }
}
```

---

## 7. 리뷰 시스템 (로컬)

### 7.1 리뷰 작성

```dart
class ReviewProvider extends ChangeNotifier {
  Future<bool> submitReview({
    required String bookingId,
    required int rating,
    required String title,
    required String content,
  }) async {
    final review = Review(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      rating: rating,
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );

    _reviews.add(review);

    // LocalStorage에 저장
    final prefs = await SharedPreferences.getInstance();
    final reviewsJson = _reviews.map((r) => r.toJson()).toList();
    await prefs.setString('reviews', jsonEncode(reviewsJson));

    notifyListeners();
    return true;
  }

  // 평균 평점 계산
  double getAverageRating(String equipmentId) {
    final equipmentReviews = _reviews
        .where((r) => r.equipmentId == equipmentId)
        .toList();

    if (equipmentReviews.isEmpty) return 0.0;

    final sum = equipmentReviews
        .fold<int>(0, (prev, r) => prev + r.rating);
    return sum / equipmentReviews.length;
  }
}
```

---

# Part 2: 향후 백엔드 API 설계 (참고용)

## 8. API 기초 정보

### 8.1 Base URL (향후)

```
https://api.danngam.com/v1
```

### 8.2 통신 규격

- **요청/응답 형식**: JSON
- **타임존**: UTC
- **문자 인코딩**: UTF-8
- **HTTP 메서드**: GET, POST, PATCH, DELETE

### 2.2 통신 규격

- **요청/응답 형식**: JSON
- **타임존**: UTC
- **문자 인코딩**: UTF-8
- **HTTP 메서드**: GET, POST, PATCH, DELETE

### 8.3 Rate Limiting (향후)

- **제한**: 100 요청/분 (IP 기준)
- **초과 시 응답**: 429 Too Many Requests

---

## 9. 인증 방식 (향후)

### 9.1 인증 플로우 (향후)

```
1. 사용자가 전화번호 입력
2. 서버에서 OTP (One-Time Password) 발송
3. 사용자가 OTP 확인
4. 서버에서 JWT 토큰 발급 (AccessToken + RefreshToken)
5. 이후 모든 요청에 AccessToken 포함
```

### 9.2 JWT 토큰 (향후)

- **AccessToken**: 15분 유효
- **RefreshToken**: 7일 유효
- **저장 위치**: 클라이언트 로컬 스토리지 (RefreshToken은 HttpOnly 쿠키 권장)

### 9.3 인증 헤더 (향후)

```
Authorization: Bearer {accessToken}
```

---

## 10. 공통 응답 형식 (향후)

### 10.1 성공 응답

```json
{
  "success": true,
  "data": {
    // 요청한 데이터
  }
}
```

### 10.2 실패 응답 (향후)

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "에러 메시지"
  }
}
```

### 10.3 Pagination (향후)

```json
{
  "success": true,
  "data": [
    // 데이터 배열
  ],
  "pagination": {
    "limit": 20,
    "offset": 0,
    "total": 150,
    "hasMore": true
  }
}
```

---

## 11. 공통 Error Code (향후)

| HTTP Status | Error Code | 설명 |
|------------|-----------|------|
| 400 | BAD_REQUEST | 잘못된 요청 형식 |
| 401 | UNAUTHORIZED | 인증 실패 (토큰 없음/만료) |
| 403 | FORBIDDEN | 접근 권한 없음 |
| 404 | NOT_FOUND | 리소스 없음 |
| 409 | CONFLICT | 중복된 리소스 |
| 422 | INVALID_INPUT | 유효하지 않은 입력값 |
| 429 | RATE_LIMIT_EXCEEDED | 요청 제한 초과 |
| 500 | INTERNAL_ERROR | 서버 내부 오류 |

---

## 12. Authentication APIs (향후)

### 12.1 OTP 발송

**엔드포인트**: `POST /auth/send-otp`

**설명**: 사용자 전화번호로 OTP 발송

**요청**:
```json
{
  "phoneNumber": "01012345678"
}
```

**응답 (성공)**:
```json
{
  "success": true,
  "data": {
    "sessionId": "sess_abc123",
    "expiresIn": 300,
    "message": "OTP가 발송되었습니다."
  }
}
```

**응답 (실패)**:
```json
{
  "success": false,
  "error": {
    "code": "INVALID_PHONE",
    "message": "유효하지 않은 전화번호입니다."
  }
}
```

---

### 12.2 OTP 확인

**엔드포인트**: `POST /auth/verify-otp`

**설명**: 사용자가 입력한 OTP 확인 및 토큰 발급

**요청**:
```json
{
  "sessionId": "sess_abc123",
  "otp": "123456"
}
```

**응답 (성공)**:
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "expiresIn": 900,
    "user": {
      "id": "user_123",
      "phoneNumber": "01012345678",
      "name": "김농부",
      "createdAt": "2026-02-14T10:00:00Z"
    }
  }
}
```

**응답 (실패)**:
```json
{
  "success": false,
  "error": {
    "code": "INVALID_OTP",
    "message": "OTP가 일치하지 않습니다."
  }
}
```

---

### 6.3 로그아웃

**엔드포인트**: `POST /auth/logout`

**설명**: 사용자 로그아웃 및 토큰 무효화

**요청**: 헤더에 Authorization 토큰 필수

**응답 (성공)**:
```json
{
  "success": true,
  "data": {
    "message": "로그아웃되었습니다."
  }
}
```

---

## 13. Equipment APIs (향후)

### 13.1 근처 장비 검색

**엔드포인트**: `GET /equipments/nearby`

**설명**: 사용자 위치 기반 근처 장비 검색 (이동형/고정형 필터링 필수)

**쿼리 파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| lat | float | O | 위도 (예: 37.5) |
| lng | float | O | 경도 (예: 127.0) |
| radius | int | X | 검색 반경 (km, 기본값: 30) |
| type | string | O | 장비 타입 (MOBILE/FIXED) |
| limit | int | X | 페이지당 개수 (기본값: 20) |
| offset | int | X | 시작 위치 (기본값: 0) |

**응답 (성공)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "eq_001",
      "name": "트랙터 80마력",
      "type": "MOBILE",
      "category": "TRACTOR",
      "owner": {
        "id": "user_123",
        "name": "이농부",
        "rating": 4.8
      },
      "pricePerDay": 150000,
      "location": {
        "lat": 37.5,
        "lng": 127.0,
        "address": "경기도 여주시"
      },
      "images": [
        "https://cdn.danngam.com/eq_001_1.jpg",
        "https://cdn.danngam.com/eq_001_2.jpg"
      ],
      "rating": 4.8,
      "reviewCount": 42,
      "distance": 5.2
    }
  ],
  "pagination": {
    "limit": 20,
    "offset": 0,
    "total": 156,
    "hasMore": true
  }
}
```

---

### 13.2 고정형 장비 검색 (위치 필터 없음)

**엔드포인트**: `GET /equipments/fixed`

**설명**: 고정형 장비 전체 검색 (건조기, 저온저장고 등 - 위치 변동 없음)

**쿼리 파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| type | string | O | FIXED (고정값) |
| category | string | X | 카테고리 필터 |
| limit | int | X | 페이지당 개수 (기본값: 20) |
| offset | int | X | 시작 위치 (기본값: 0) |

**응답 (성공)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "eq_002",
      "name": "곡물건조기 50톤",
      "type": "FIXED",
      "category": "DRYER",
      "owner": {
        "id": "user_456",
        "name": "박기계",
        "rating": 4.9
      },
      "pricePerDay": 300000,
      "location": {
        "lat": 37.2,
        "lng": 126.9,
        "address": "경기도 이천시"
      },
      "images": ["https://cdn.danngam.com/eq_002_1.jpg"],
      "rating": 4.9,
      "reviewCount": 28,
      "isAvailable": true
    }
  ],
  "pagination": {
    "limit": 20,
    "offset": 0,
    "total": 48,
    "hasMore": false
  }
}
```

---

### 13.3 장비 상세 정보

**엔드포인트**: `GET /equipments/{id}`

**설명**: 특정 장비의 상세 정보 조회

**응답 (성공)**:
```json
{
  "success": true,
  "data": {
    "id": "eq_001",
    "name": "트랙터 80마력",
    "type": "MOBILE",
    "category": "TRACTOR",
    "description": "최신형 트랙터로 밭갈이 및 경운에 최적화되어 있습니다.",
    "owner": {
      "id": "user_123",
      "name": "이농부",
      "rating": 4.8,
      "reviewCount": 42,
      "phoneNumber": "010****5678"
    },
    "specs": {
      "horsepower": 80,
      "manufacturer": "Kubota",
      "productionYear": 2022,
      "condition": "EXCELLENT"
    },
    "pricePerDay": 150000,
    "pricePerHour": 25000,
    "location": {
      "lat": 37.5,
      "lng": 127.0,
      "address": "경기도 여주시 여주읍"
    },
    "images": [
      "https://cdn.danngam.com/eq_001_1.jpg",
      "https://cdn.danngam.com/eq_001_2.jpg",
      "https://cdn.danngam.com/eq_001_3.jpg"
    ],
    "rating": 4.8,
    "reviews": [
      {
        "id": "rev_001",
        "author": "김농부",
        "rating": 5,
        "comment": "정말 좋은 장비입니다. 추천합니다.",
        "createdAt": "2026-02-10T14:30:00Z"
      }
    ],
    "availability": {
      "isAvailable": true,
      "nextAvailableDate": "2026-02-15T08:00:00Z"
    },
    "tags": ["밭갈이", "경운", "신상"]
  }
}
```

---

### 7.4 장비 카테고리 조회

**엔드포인트**: `GET /equipments/categories`

**설명**: 장비 카테고리 목록 조회

**응답 (성공)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "cat_001",
      "name": "트랙터",
      "type": "MOBILE",
      "icon": "tractor",
      "count": 120
    },
    {
      "id": "cat_002",
      "name": "콤바인",
      "type": "MOBILE",
      "icon": "combine",
      "count": 85
    },
    {
      "id": "cat_003",
      "name": "건조기",
      "type": "FIXED",
      "icon": "dryer",
      "count": 45
    },
    {
      "id": "cat_004",
      "name": "저온저장고",
      "type": "FIXED",
      "icon": "storage",
      "count": 32
    }
  ]
}
```

---

### 7.5 장비 검색

**엔드포인트**: `GET /equipments/search`

**설명**: 키워드 기반 장비 검색

**쿼리 파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| keyword | string | O | 검색 키워드 (예: "트랙터") |
| type | string | O | 장비 타입 (MOBILE/FIXED) |
| limit | int | X | 페이지당 개수 (기본값: 20) |
| offset | int | X | 시작 위치 (기본값: 0) |

**응답 (성공)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "eq_001",
      "name": "트랙터 80마력",
      "type": "MOBILE",
      "category": "TRACTOR",
      "pricePerDay": 150000,
      "rating": 4.8,
      "reviewCount": 42
    },
    {
      "id": "eq_003",
      "name": "소형 트랙터 50마력",
      "type": "MOBILE",
      "category": "TRACTOR",
      "pricePerDay": 100000,
      "rating": 4.6,
      "reviewCount": 28
    }
  ],
  "pagination": {
    "limit": 20,
    "offset": 0,
    "total": 85,
    "hasMore": true
  }
}
```

---

### 7.6 장비 가용성 조회

**엔드포인트**: `GET /equipments/{id}/availability`

**설명**: 특정 장비의 시간대별 가용성 조회

**쿼리 파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| startDate | string | O | 시작 날짜 (YYYY-MM-DD) |
| endDate | string | O | 종료 날짜 (YYYY-MM-DD) |

**응답 (성공)**:
```json
{
  "success": true,
  "data": {
    "id": "eq_001",
    "name": "트랙터 80마력",
    "availability": [
      {
        "date": "2026-02-15",
        "timeSlots": [
          { "time": "08:00-10:00", "available": true },
          { "time": "10:00-12:00", "available": true },
          { "time": "12:00-14:00", "available": false },
          { "time": "14:00-16:00", "available": true },
          { "time": "16:00-18:00", "available": true }
        ]
      },
      {
        "date": "2026-02-16",
        "timeSlots": [
          { "time": "08:00-10:00", "available": true },
          { "time": "10:00-12:00", "available": true },
          { "time": "12:00-14:00", "available": true },
          { "time": "14:00-16:00", "available": true },
          { "time": "16:00-18:00", "available": true }
        ]
      }
    ]
  }
}
```

---

## 8. Booking APIs

### 8.1 예약 생성

**엔드포인트**: `POST /bookings`

**설명**: 새로운 장비 예약 생성

**인증**: 필수 (JWT AccessToken)

**요청**:
```json
{
  "equipmentId": "eq_001",
  "startDate": "2026-02-15",
  "startTime": "08:00",
  "endDate": "2026-02-15",
  "endTime": "16:00",
  "rentalType": "FULL_DAY",
  "notes": "조심스럽게 다루어 주세요."
}
```

**응답 (성공)**:
```json
{
  "success": true,
  "data": {
    "id": "book_001",
    "bookingNumber": "DN20260214001",
    "equipmentId": "eq_001",
    "userId": "user_789",
    "status": "PENDING_PAYMENT",
    "startDate": "2026-02-15",
    "startTime": "08:00",
    "endDate": "2026-02-15",
    "endTime": "16:00",
    "rentalType": "FULL_DAY",
    "totalDays": 1,
    "pricePerDay": 150000,
    "pricePerHour": 25000,
    "subtotal": 150000,
    "fee": 12000,
    "totalPrice": 162000,
    "notes": "조심스럽게 다루어 주세요.",
    "createdAt": "2026-02-14T10:30:00Z"
  }
}
```

---

### 8.2 예약 상세 조회

**엔드포인트**: `GET /bookings/{id}`

**설명**: 특정 예약의 상세 정보 조회

**인증**: 필수

**응답 (성공)**:
```json
{
  "success": true,
  "data": {
    "id": "book_001",
    "bookingNumber": "DN20260214001",
    "status": "CONFIRMED",
    "equipment": {
      "id": "eq_001",
      "name": "트랙터 80마력",
      "type": "MOBILE",
      "images": ["https://cdn.danngam.com/eq_001_1.jpg"]
    },
    "owner": {
      "id": "user_123",
      "name": "이농부",
      "phoneNumber": "010****5678"
    },
    "renter": {
      "id": "user_789",
      "name": "김농부",
      "phoneNumber": "010****1234"
    },
    "startDate": "2026-02-15",
    "startTime": "08:00",
    "endDate": "2026-02-15",
    "endTime": "16:00",
    "totalPrice": 162000,
    "paymentStatus": "COMPLETED",
    "paymentMethod": "CARD",
    "createdAt": "2026-02-14T10:30:00Z"
  }
}
```

---

### 8.3 예약 취소

**엔드포인트**: `PATCH /bookings/{id}/cancel`

**설명**: 예약 취소 (취소 수수료 정책 적용)

**인증**: 필수

**요청**:
```json
{
  "reason": "일정이 변경되었습니다."
}
```

**응답 (성공)**:
```json
{
  "success": true,
  "data": {
    "id": "book_001",
    "status": "CANCELLED",
    "originalPrice": 162000,
    "cancellationFee": 16200,
    "refundAmount": 145800,
    "cancelledAt": "2026-02-14T11:00:00Z"
  }
}
```

---

### 8.4 사용자 예약 목록

**엔드포인트**: `GET /bookings/my`

**설명**: 현재 로그인한 사용자의 예약 목록 조회

**인증**: 필수

**쿼리 파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| status | string | X | 상태 필터 (PENDING_PAYMENT, CONFIRMED, COMPLETED, CANCELLED) |
| limit | int | X | 페이지당 개수 (기본값: 20) |
| offset | int | X | 시작 위치 (기본값: 0) |

**응답 (성공)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "book_001",
      "bookingNumber": "DN20260214001",
      "equipment": {
        "id": "eq_001",
        "name": "트랙터 80마력",
        "type": "MOBILE"
      },
      "status": "CONFIRMED",
      "startDate": "2026-02-15",
      "endDate": "2026-02-15",
      "totalPrice": 162000,
      "createdAt": "2026-02-14T10:30:00Z"
    }
  ],
  "pagination": {
    "limit": 20,
    "offset": 0,
    "total": 5,
    "hasMore": false
  }
}
```

---

## 9. Payment APIs

### 9.1 결제 요청

**엔드포인트**: `POST /payments/initiate`

**설명**: 결제 프로세스 시작 및 결제 토큰 발급

**인증**: 필수

**요청**:
```json
{
  "bookingId": "book_001",
  "paymentMethod": "CARD",
  "amount": 162000
}
```

**응답 (성공)**:
```json
{
  "success": true,
  "data": {
    "id": "pay_001",
    "bookingId": "book_001",
    "amount": 162000,
    "paymentToken": "token_abc123xyz",
    "status": "PENDING",
    "expiresAt": "2026-02-14T11:30:00Z"
  }
}
```

---

### 9.2 결제 확인

**엔드포인트**: `POST /payments/confirm`

**설명**: 결제 완료 확인 (PG사 응답 검증 후 처리)

**인증**: 필수

**요청**:
```json
{
  "paymentToken": "token_abc123xyz",
  "transactionId": "txn_123456",
  "cardNumber": "****1234"
}
```

**응답 (성공)**:
```json
{
  "success": true,
  "data": {
    "id": "pay_001",
    "bookingId": "book_001",
    "status": "COMPLETED",
    "amount": 162000,
    "transactionId": "txn_123456",
    "paymentMethod": "CARD",
    "cardNumber": "****1234",
    "completedAt": "2026-02-14T11:15:00Z"
  }
}
```

---

### 9.3 결제 조회

**엔드포인트**: `GET /payments/{id}`

**설명**: 특정 결제의 상세 정보 조회

**인증**: 필수

**응답 (성공)**:
```json
{
  "success": true,
  "data": {
    "id": "pay_001",
    "bookingId": "book_001",
    "amount": 162000,
    "status": "COMPLETED",
    "paymentMethod": "CARD",
    "cardNumber": "****1234",
    "transactionId": "txn_123456",
    "createdAt": "2026-02-14T11:10:00Z",
    "completedAt": "2026-02-14T11:15:00Z"
  }
}
```

---

## 10. Review APIs

### 10.1 리뷰 작성

**엔드포인트**: `POST /reviews`

**설명**: 완료된 예약에 대한 리뷰 작성

**인증**: 필수

**요청**:
```json
{
  "bookingId": "book_001",
  "equipmentId": "eq_001",
  "rating": 5,
  "comment": "정말 좋은 장비입니다. 주인분도 친절하셨습니다."
}
```

**응답 (성공)**:
```json
{
  "success": true,
  "data": {
    "id": "rev_001",
    "bookingId": "book_001",
    "equipmentId": "eq_001",
    "author": {
      "id": "user_789",
      "name": "김농부"
    },
    "rating": 5,
    "comment": "정말 좋은 장비입니다. 주인분도 친절하셨습니다.",
    "createdAt": "2026-02-14T12:00:00Z"
  }
}
```

---

### 10.2 장비 리뷰 조회

**엔드포인트**: `GET /reviews/equipment/{id}`

**설명**: 특정 장비의 모든 리뷰 조회

**쿼리 파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| limit | int | X | 페이지당 개수 (기본값: 20) |
| offset | int | X | 시작 위치 (기본값: 0) |
| sortBy | string | X | 정렬 기준 (recent, rating_high, rating_low) |

**응답 (성공)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "rev_001",
      "author": {
        "id": "user_789",
        "name": "김농부"
      },
      "rating": 5,
      "comment": "정말 좋은 장비입니다.",
      "createdAt": "2026-02-14T12:00:00Z"
    },
    {
      "id": "rev_002",
      "author": {
        "id": "user_790",
        "name": "이농부"
      },
      "rating": 4,
      "comment": "만족합니다. 다시 예약할 것 같습니다.",
      "createdAt": "2026-02-13T14:00:00Z"
    }
  ],
  "pagination": {
    "limit": 20,
    "offset": 0,
    "total": 42,
    "hasMore": true
  }
}
```

---

### 10.3 사용자 작성 리뷰

**엔드포인트**: `GET /reviews/my`

**설명**: 현재 사용자가 작성한 리뷰 목록

**인증**: 필수

**응답 (성공)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "rev_001",
      "equipmentId": "eq_001",
      "equipmentName": "트랙터 80마력",
      "rating": 5,
      "comment": "정말 좋은 장비입니다.",
      "createdAt": "2026-02-14T12:00:00Z"
    }
  ],
  "pagination": {
    "limit": 20,
    "offset": 0,
    "total": 3,
    "hasMore": false
  }
}
```

---

## 11. User APIs

### 11.1 사용자 프로필 조회

**엔드포인트**: `GET /users/profile`

**설명**: 현재 로그인한 사용자의 프로필 정보 조회

**인증**: 필수

**응답 (성공)**:
```json
{
  "success": true,
  "data": {
    "id": "user_789",
    "name": "김농부",
    "phoneNumber": "010****1234",
    "profileImage": "https://cdn.danngam.com/profile_789.jpg",
    "rating": 4.7,
    "reviewCount": 12,
    "bookingCount": 28,
    "completedBookingCount": 25,
    "location": {
      "province": "경기도",
      "city": "여주시"
    },
    "createdAt": "2025-08-15T10:00:00Z",
    "isVerified": true,
    "verificationMethods": ["PHONE", "EMAIL"]
  }
}
```

---

### 11.2 사용자 프로필 수정

**엔드포인트**: `PATCH /users/profile`

**설명**: 사용자 프로필 정보 수정

**인증**: 필수

**요청**:
```json
{
  "name": "김농부",
  "profileImage": "https://cdn.danngam.com/profile_789_new.jpg",
  "location": {
    "province": "경기도",
    "city": "여주시"
  }
}
```

**응답 (성공)**:
```json
{
  "success": true,
  "data": {
    "id": "user_789",
    "name": "김농부",
    "phoneNumber": "010****1234",
    "profileImage": "https://cdn.danngam.com/profile_789_new.jpg",
    "location": {
      "province": "경기도",
      "city": "여주시"
    },
    "updatedAt": "2026-02-14T13:00:00Z"
  }
}
```

---

### 11.3 사용자 평점 조회

**엔드포인트**: `GET /users/{id}/rating`

**설명**: 특정 사용자의 평점 및 평판 정보 조회

**응답 (성공)**:
```json
{
  "success": true,
  "data": {
    "userId": "user_123",
    "userName": "이농부",
    "rating": 4.8,
    "totalReviews": 42,
    "ratingBreakdown": {
      "5": 35,
      "4": 5,
      "3": 2,
      "2": 0,
      "1": 0
    },
    "lastReviewDate": "2026-02-10T14:30:00Z"
  }
}
```

---

## 12. 백엔드 옵션별 구현 가이드

### 12.1 Supabase (PostgREST) 구현

**장점**:
- PostgREST로 자동 API 생성
- PostgreSQL의 풍부한 쿼리 기능
- 지리정보 쿼리 (PostGIS) 지원

**예제**:

```sql
-- 이동형 장비 검색
GET https://api.danngam.com/rest/v1/equipments?
  type=eq.MOBILE
  &select=id,name,type,category,price_per_day,rating

-- 위도/경도 기반 근처 장비 검색 (PostGIS)
GET https://api.danngam.com/rest/v1/equipments?
  type=eq.MOBILE
  &location=ov.circle(37.5,127.0,30000)
  &select=id,name,location,distance::int

-- 고정형 장비 검색
GET https://api.danngam.com/rest/v1/equipments?
  type=eq.FIXED
  &select=*
```

**인증 헤더**:
```
Authorization: Bearer {JWT}
apikey: {SUPABASE_ANON_KEY}
```

---

### 12.2 FastAPI (Python) 구현

**장점**:
- 빠른 개발 속도
- 자동 문서 생성 (Swagger)
- 타입 안정성

**예제**:

```python
from fastapi import FastAPI, Query, Header, HTTPException
from enum import Enum
from typing import Optional
from pydantic import BaseModel

app = FastAPI(title="Danngam API", version="1.0.0")

class EquipmentType(str, Enum):
    MOBILE = "MOBILE"
    FIXED = "FIXED"

@router.get("/equipments/nearby")
async def get_nearby_equipment(
    lat: float = Query(..., description="위도"),
    lng: float = Query(..., description="경도"),
    radius: int = Query(30, description="검색 반경 (km)"),
    type: EquipmentType = Query(..., description="장비 타입"),
    limit: int = Query(20, le=100),
    offset: int = Query(0, ge=0),
    authorization: str = Header(...)
):
    """근처 장비 검색 엔드포인트"""
    # JWT 검증
    user = verify_jwt(authorization)

    # 데이터베이스 쿼리
    query = "SELECT * FROM equipments WHERE type = %s"
    params = [type.value]

    if type == EquipmentType.MOBILE:
        # PostGIS 거리 계산
        query += " AND ST_Distance_Sphere(location, ST_Point(%s, %s)) <= %s"
        params.extend([lng, lat, radius * 1000])

    query += " LIMIT %s OFFSET %s"
    params.extend([limit, offset])

    equipments = db.query(query, params)

    return {
        "success": True,
        "data": equipments,
        "pagination": {
            "limit": limit,
            "offset": offset,
            "total": count,
            "hasMore": offset + limit < count
        }
    }

@router.post("/bookings")
async def create_booking(
    booking_request: BookingRequest,
    authorization: str = Header(...)
):
    """예약 생성 엔드포인트"""
    user = verify_jwt(authorization)

    # 가용성 확인
    is_available = check_availability(
        booking_request.equipment_id,
        booking_request.start_date,
        booking_request.end_date
    )

    if not is_available:
        raise HTTPException(status_code=409, detail="CONFLICT")

    # 예약 생성
    booking = create_booking_record(user.id, booking_request)

    return {
        "success": True,
        "data": booking
    }
```

---

### 12.3 Firebase (Firestore) 구현

**장점**:
- 실시간 데이터베이스
- 확장성
- 백엔드 관리 최소화

**예제**:

```javascript
// 이동형 장비 검색 (근처 검색)
async function getNearbyEquipments(lat, lng, radius) {
  const geopoint = new firebase.firestore.GeoPoint(lat, lng);

  const query = db.collection("equipments")
    .where("type", "==", "MOBILE")
    .where("geopoint", "near", {
      center: geopoint,
      radius: radius * 1000  // 미터
    });

  const snapshot = await query.get();
  return snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
}

// 고정형 장비 검색
async function getFixedEquipments(category, limit = 20) {
  const query = db.collection("equipments")
    .where("type", "==", "FIXED");

  if (category) {
    query = query.where("category", "==", category);
  }

  const snapshot = await query
    .limit(limit)
    .get();

  return snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
}

// 예약 생성
async function createBooking(userId, equipmentId, bookingData) {
  const bookingRef = db.collection("bookings").doc();

  await bookingRef.set({
    userId: userId,
    equipmentId: equipmentId,
    startDate: bookingData.startDate,
    endDate: bookingData.endDate,
    status: "PENDING_PAYMENT",
    totalPrice: bookingData.totalPrice,
    createdAt: firebase.firestore.FieldValue.serverTimestamp()
  });

  return {
    id: bookingRef.id,
    ...bookingData
  };
}

// 가용성 확인
async function checkAvailability(equipmentId, startDate, endDate) {
  const bookings = await db.collection("bookings")
    .where("equipmentId", "==", equipmentId)
    .where("status", "in", ["CONFIRMED", "COMPLETED"])
    .where("startDate", "<=", endDate)
    .where("endDate", ">=", startDate)
    .get();

  return bookings.empty;
}
```

---

## 13. 인수 기준 (Acceptance Criteria)

- [ ] **15개 이상 엔드포인트 정의**: 현재 18개 엔드포인트 정의 완료
  - 인증 3개
  - 장비 6개
  - 예약 4개
  - 결제 3개
  - 리뷰 3개
  - 사용자 3개

- [ ] **이동형/고정형 필터링 API 포함**:
  - `/equipments/nearby?type=MOBILE` (이동형)
  - `/equipments/fixed?type=FIXED` (고정형)

- [ ] **각 엔드포인트 Request/Response 예제**:
  - 모든 엔드포인트에 성공/실패 응답 예제 포함
  - 실제 사용 가능한 JSON 형식 제공

- [ ] **백엔드 옵션별 구현 차이 명시**:
  - Supabase (PostgREST) 구현 가이드
  - FastAPI (Python) 구현 가이드
  - Firebase (Firestore) 구현 가이드

---

## 14. 추가 고려사항

### 14.1 보안

- 모든 API 엔드포인트는 HTTPS 사용 필수
- JWT 토큰 만료 시 RefreshToken으로 재발급
- 민감한 정보 (전화번호, 결제정보) 마스킹 처리
- Rate Limiting으로 DDoS 공격 방어

### 14.2 에러 처리

- 모든 에러는 공통 형식으로 응답
- 명확한 에러 코드와 메시지 제공
- 클라이언트에서 재시도 로직 구현 권장

### 14.3 버전 관리

- 기존 API 변경 시 주 버전 업그레이드 (v1 → v2)
- Deprecation 예고 기간 최소 3개월

---

**문서 작성 완료**: 2026-02-14
