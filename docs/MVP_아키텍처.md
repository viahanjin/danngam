# Flutter MVP (Model-View-Presenter) 패턴 아키텍처 설계

**작성일**: 2026-02-14
**버전**: 2.0 (로컬 상태 관리 중심)
**프로젝트**: danngam (농기계 공유 플랫폼)
**상태**: MVP(Minimum Viable Product) - 로컬 데이터 기반

---

## 1. MVP 패턴 개요

### 1.1 정의 및 특징

MVP(Model-View-Presenter) 패턴은 애플리케이션의 관심사를 세 가지 계층으로 분리하는 아키텍처 패턴입니다.

- **Model**: 비즈니스 로직과 데이터 관리를 담당합니다.
- **View**: 사용자 인터페이스를 담당하며, UI 이벤트를 Presenter로 전달합니다.
- **Presenter**: Model과 View 사이의 중개자로, 비즈니스 로직을 처리하고 View에 데이터를 제공합니다.

### 1.2 Flutter에서의 장점

- **테스트 용이성**: Presenter를 독립적으로 단위 테스트할 수 있습니다.
- **관심사 분리**: 각 계층이 명확한 책임을 가집니다.
- **코드 재사용성**: Repository 패턴과 함께 사용하여 데이터 소스를 추상화합니다.
- **유지보수성**: 기능 추가 및 버그 수정이 용이합니다.
- **스케일러빌리티**: 프로젝트 확장 시 구조를 유지하기 쉽습니다.

### 1.3 danngam에서의 선택 이유

danngam 프로젝트는 다음과 같은 요구사항이 있습니다:

- 이동형/고정형 장비의 복잡한 필터링 및 정렬 로직
- 예약, 결제, 리뷰 등 다양한 비즈니스 로직
- 테스트 가능한 구조 필요
- 향후 확장성 고려 (로컬 → 백엔드 전환)

MVP 패턴은 이러한 요구사항을 효과적으로 처리할 수 있습니다.

---

## 2. MVP - 로컬 아키텍처 개요

### 2.1 현재 MVP 상태 (로컬 중심)

danngam MVP는 다음과 같은 특징을 가집니다:

```
┌──────────────────────────────────────────────────────────┐
│                    Flutter App (UI)                       │
│  (Screens, Widgets, User Interactions)                   │
└─────────────────────────┬──────────────────────────────┘
                          │
                ┌─────────▼─────────┐
                │   Provider        │ (상태 관리)
                │   ChangeNotifier  │
                └─────────┬─────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
   ┌────▼────┐    ┌────────▼───┐    ┌────▼────┐
   │ Equipment│    │  Booking   │    │   Chat  │
   │ Provider │    │  Provider  │    │ Provider│
   └────┬────┘    └──────┬─────┘    └────┬────┘
        │                │               │
┌───────▼────────────────▼───────────────▼────────────────┐
│          Repository (데이터 소스 추상화)                │
│  - Local DataSource (MockJSON, SharedPreferences)       │
│  - Remote DataSource (준비됨, 향후 활성화)              │
└───────┬────────────────┬────────────────────┬───────────┘
        │                │                    │
   ┌────▼──────┐  ┌──────▼──────┐  ┌────────▼──────┐
   │ Mock JSON  │  │ LocalStorage │  │  (향후)      │
   │            │  │ (sqflite /   │  │  Remote API  │
   │ assets/    │  │  Shared      │  │              │
   │ data/      │  │  Preferences)│  │              │
   └────────────┘  └──────────────┘  └───────────────┘
```

### 2.2 로컬 데이터 관리 방식

**MVP 단계 데이터 흐름**:
1. Mock JSON 데이터로 시작 (assets/data/*.json)
2. Provider로 상태 관리
3. LocalStorage로 사용자 입력값 저장 (SharedPreferences, sqflite)
4. Repository 패턴으로 데이터 소스 추상화

---

## 3. 디렉토리 구조 (로컬 버전)

```
lib/
├── core/
│   ├── error/
│   │   ├── exception.dart          # 애플리케이션 예외 정의
│   │   ├── failure.dart            # 실패 상태 처리
│   │   └── error_handler.dart      # 에러 핸들링 유틸
│   ├── utils/
│   │   ├── constants.dart          # 상수 정의
│   │   ├── extensions.dart         # 확장 메서드
│   │   └── validators.dart         # 검증 로직
│   └── local_storage/
│       ├── shared_preferences_helper.dart  # SharedPreferences 래퍼
│       └── database_helper.dart            # sqflite 래퍼 (선택)
├── features/
│   ├── auth/
│   │   ├── contract/
│   │   │   └── auth_contract.dart
│   │   ├── presenter/
│   │   │   └── auth_presenter.dart
│   │   ├── provider/
│   │   │   └── auth_provider.dart        # Provider 기반 상태 관리
│   │   ├── view/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   └── data/
│   │       ├── repository/
│   │       │   └── auth_repository_impl.dart
│   │       ├── datasource/
│   │       │   ├── auth_local_datasource.dart
│   │       │   └── auth_mock_datasource.dart (Mock JSON)
│   │       └── model/
│   │           └── auth_model.dart
│   ├── equipment/
│   │   ├── contract/
│   │   │   └── equipment_contract.dart
│   │   ├── presenter/
│   │   │   └── equipment_presenter.dart
│   │   ├── provider/
│   │   │   └── equipment_provider.dart
│   │   ├── view/
│   │   │   ├── equipment_list_screen.dart
│   │   │   ├── equipment_detail_screen.dart
│   │   │   └── equipment_registration_screen.dart
│   │   └── data/
│   │       ├── repository/
│   │       │   └── equipment_repository_impl.dart
│   │       ├── datasource/
│   │       │   ├── equipment_mock_datasource.dart
│   │       │   └── equipment_local_datasource.dart
│   │       └── model/
│   │           └── equipment_model.dart
│   ├── booking/
│   │   ├── contract/
│   │   │   └── booking_contract.dart
│   │   ├── presenter/
│   │   │   └── booking_presenter.dart
│   │   ├── provider/
│   │   │   └── booking_provider.dart
│   │   ├── view/
│   │   │   ├── booking_list_screen.dart
│   │   │   └── create_booking_screen.dart
│   │   └── data/
│   │       ├── repository/
│   │       │   └── booking_repository_impl.dart
│   │       ├── datasource/
│   │       │   ├── booking_mock_datasource.dart
│   │       │   └── booking_local_datasource.dart
│   │       └── model/
│   │           └── booking_model.dart
│   ├── chat/
│   │   ├── contract/
│   │   │   └── chat_contract.dart
│   │   ├── presenter/
│   │   │   └── chat_presenter.dart
│   │   ├── provider/
│   │   │   └── chat_provider.dart
│   │   ├── view/
│   │   │   └── chat_screen.dart
│   │   └── data/
│   │       ├── repository/
│   │       │   └── chat_repository_impl.dart
│   │       ├── datasource/
│   │       │   ├── chat_mock_datasource.dart
│   │       │   └── chat_local_datasource.dart
│   │       └── model/
│   │           └── chat_model.dart
│   └── review/
│       ├── contract/
│       │   └── review_contract.dart
│       ├── presenter/
│       │   └── review_presenter.dart
│       ├── view/
│       │   └── review_screen.dart
│       └── data/
│           ├── repository/
│           │   └── review_repository_impl.dart
│           ├── datasource/
│           │   ├── review_mock_datasource.dart
│           │   └── review_local_datasource.dart
│           └── model/
│               └── review_model.dart
├── shared/
│   ├── widgets/
│   │   ├── app_button.dart         # 공용 버튼
│   │   ├── app_text_field.dart     # 공용 텍스트필드
│   │   ├── app_card.dart           # 공용 카드
│   │   ├── loading_widget.dart     # 로딩 위젯
│   │   └── error_widget.dart       # 에러 위젯
│   ├── models/
│   │   ├── pagination_model.dart   # 페이지네이션
│   │   └── common_constants.dart   # 공용 상수
│   └── theme/
│       ├── app_theme.dart          # 앱 테마
│       ├── app_colors.dart         # 색상
│       └── app_text_styles.dart    # 텍스트 스타일
├── di/
│   ├── service_locator.dart        # 서비스 로케이터 설정
│   └── modules/
│       ├── auth_module.dart
│       ├── equipment_module.dart
│       ├── booking_module.dart
│       └── chat_module.dart
├── routes/
│   ├── app_routes.dart             # 라우트 정의
│   └── app_router.dart             # 라우터 구현
├── assets/
│   └── data/                       # Mock JSON 데이터
│       ├── equipments.json
│       ├── users.json
│       ├── bookings.json
│       └── chats.json
└── main.dart                       # 앱 진입점
```

---

## 4. Contract Interface 정의 (확장)

Contract는 View와 Presenter 사이의 계약(인터페이스)를 정의합니다.

### 4.1 EquipmentContract

```dart
// lib/features/equipment/contract/equipment_contract.dart

abstract class EquipmentView {
  void showLoading();
  void hideLoading();
  void showEquipmentList(List<EquipmentModel> equipment);
  void showError(String message);
  void showEquipmentDetail(EquipmentModel equipment);
  void showFilteredEquipment(List<EquipmentModel> equipment);
}

abstract class EquipmentPresenter {
  void attachView(EquipmentView view);
  void detachView();
  Future<void> loadEquipment();
  Future<void> getEquipmentDetail(String equipmentId);
  Future<void> filterEquipment({
    String? category,
    EquipmentType? type,
    double? maxPrice,
    required Location location,
  });
  Future<void> sortEquipment(SortOption sortOption);
  Future<void> searchEquipment(String query);
}
```

### 4.2 BookingContract

```dart
// lib/features/booking/contract/booking_contract.dart

abstract class BookingView {
  void showLoading();
  void hideLoading();
  void showBookingList(List<BookingModel> bookings);
  void showBookingSuccess(String message);
  void showError(String message);
  void navigateToPayment(String bookingId);
}

abstract class BookingPresenter {
  void attachView(BookingView view);
  void detachView();
  Future<void> loadMyBookings();
  Future<void> createBooking(BookingModel booking);
  Future<void> cancelBooking(String bookingId);
  Future<void> updateBookingStatus(String bookingId, BookingStatus status);
  double calculateTotalAmount(double hourlyRate, DateTime startTime, DateTime endTime);
}
```

### 4.3 ChatContract (NEW)

```dart
// lib/features/chat/contract/chat_contract.dart

abstract class ChatView {
  void showLoading();
  void hideLoading();
  void showChatList(List<ChatRoomModel> rooms);
  void showChatMessages(List<ChatMessageModel> messages);
  void showError(String message);
  void scrollToBottom();
  void messageAdded(ChatMessageModel message);
}

abstract class ChatPresenter {
  void attachView(ChatView view);
  void detachView();
  Future<void> loadChatRooms();
  Future<void> loadChatMessages(String roomId);
  Future<void> sendMessage(String roomId, String content);
  Future<void> createChatRoom(String otherUserId);
  Future<void> deleteChatRoom(String roomId);
  Future<void> markAsRead(String roomId);
}
```

### 4.4 EquipmentRegistrationContract (NEW)

```dart
// lib/features/equipment/contract/equipment_registration_contract.dart

abstract class EquipmentRegistrationView {
  void showLoading();
  void hideLoading();
  void showRegistrationSuccess(String message);
  void showValidationError(String fieldName, String message);
  void showError(String message);
  void navigateToEquipmentList();
}

abstract class EquipmentRegistrationPresenter {
  void attachView(EquipmentRegistrationView view);
  void detachView();
  Future<void> registerEquipment(EquipmentModel equipment);
  Future<void> validateEquipmentData(EquipmentModel equipment);
  Future<void> uploadImages(List<String> imagePaths);
  Future<void> updateEquipment(EquipmentModel equipment);
  Future<void> deleteEquipment(String equipmentId);
}
```

### 4.5 ReviewContract

```dart
// lib/features/review/contract/review_contract.dart

abstract class ReviewView {
  void showLoading();
  void hideLoading();
  void showReviewSuccess(String message);
  void showReviewError(String message);
  void showReviews(List<ReviewModel> reviews);
}

abstract class ReviewPresenter {
  void attachView(ReviewView view);
  void detachView();
  Future<void> submitReview(ReviewModel review);
  Future<void> getEquipmentReviews(String equipmentId);
  Future<void> getSupplierReviews(String supplierId);
  Future<void> deleteReview(String reviewId);
}
```

---

## 5. Provider를 이용한 상태 관리

### 5.1 Provider 소개

Provider는 Flutter의 상태 관리 라이브러리로, ChangeNotifier를 상속받아 상태를 관리합니다.

**프로젝트에서 사용 이유**:
- 간단한 상태 관리에 적합
- Repository 패턴과 통합 가능
- Mock 데이터와 쉽게 호환

### 5.2 EquipmentProvider

```dart
// lib/features/equipment/provider/equipment_provider.dart

import 'package:flutter/foundation.dart';
import 'package:danngam/features/equipment/data/model/equipment_model.dart';
import 'package:danngam/features/equipment/data/repository/equipment_repository.dart';

class EquipmentProvider extends ChangeNotifier {
  final EquipmentRepository repository;

  List<EquipmentModel> _equipment = [];
  List<EquipmentModel> _filteredEquipment = [];
  bool _isLoading = false;
  String? _errorMessage;
  EquipmentModel? _selectedEquipment;

  EquipmentProvider({required this.repository});

  // Getters
  List<EquipmentModel> get equipment => _equipment;
  List<EquipmentModel> get filteredEquipment => _filteredEquipment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  EquipmentModel? get selectedEquipment => _selectedEquipment;

  // 장비 목록 로드
  Future<void> loadEquipment() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.getEquipment();

    result.fold(
      (failure) {
        _errorMessage = failure.toString();
        _isLoading = false;
      },
      (equipment) {
        _equipment = equipment;
        _filteredEquipment = equipment;
        _isLoading = false;
        _errorMessage = null;
      },
    );

    notifyListeners();
  }

  // 장비 상세 조회
  Future<void> getEquipmentDetail(String equipmentId) async {
    _isLoading = true;
    notifyListeners();

    final result = await repository.getEquipmentById(equipmentId);

    result.fold(
      (failure) {
        _errorMessage = failure.toString();
        _isLoading = false;
      },
      (equipment) {
        _selectedEquipment = equipment;
        _isLoading = false;
      },
    );

    notifyListeners();
  }

  // 필터링
  Future<void> filterEquipment({
    String? category,
    EquipmentType? type,
    double? maxPrice,
    required Location location,
  }) async {
    _isLoading = true;
    notifyListeners();

    var filtered = _equipment;

    if (category != null) {
      filtered = filtered.where((e) => e.category == category).toList();
    }

    if (type != null) {
      filtered = filtered.where((e) => e.type == type).toList();
    }

    if (maxPrice != null) {
      filtered = filtered.where((e) => e.pricePerHour <= maxPrice).toList();
    }

    _filteredEquipment = filtered;
    _isLoading = false;
    notifyListeners();
  }

  // 검색
  void searchEquipment(String query) {
    if (query.isEmpty) {
      _filteredEquipment = _equipment;
    } else {
      _filteredEquipment = _equipment
          .where((e) =>
              e.name.toLowerCase().contains(query.toLowerCase()) ||
              e.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // 정렬
  void sortEquipment(SortOption sortOption) {
    switch (sortOption) {
      case SortOption.priceLow:
        _filteredEquipment.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
        break;
      case SortOption.priceHigh:
        _filteredEquipment.sort((a, b) => b.pricePerHour.compareTo(a.pricePerHour));
        break;
      case SortOption.rating:
        _filteredEquipment.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
      case SortOption.newest:
        _filteredEquipment.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    notifyListeners();
  }
}

enum SortOption { priceLow, priceHigh, rating, newest }
```

### 5.3 BookingProvider

```dart
// lib/features/booking/provider/booking_provider.dart

import 'package:flutter/foundation.dart';
import 'package:danngam/features/booking/data/model/booking_model.dart';
import 'package:danngam/features/booking/data/repository/booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository repository;

  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;
  BookingModel? _currentBooking;

  BookingProvider({required this.repository});

  // Getters
  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  BookingModel? get currentBooking => _currentBooking;

  // 예약 목록 로드
  Future<void> loadBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.getMyBookings();

    result.fold(
      (failure) {
        _errorMessage = failure.toString();
        _isLoading = false;
      },
      (bookings) {
        _bookings = bookings;
        _isLoading = false;
      },
    );

    notifyListeners();
  }

  // 예약 생성
  Future<void> createBooking(BookingModel booking) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.createBooking(booking);

    result.fold(
      (failure) {
        _errorMessage = failure.toString();
        _isLoading = false;
      },
      (createdBooking) {
        _currentBooking = createdBooking;
        _bookings.add(createdBooking);
        _isLoading = false;
        // LocalStorage에 저장
        _saveBookingLocally(createdBooking);
      },
    );

    notifyListeners();
  }

  // 예약 취소
  Future<void> cancelBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    final result = await repository.cancelBooking(bookingId);

    result.fold(
      (failure) {
        _errorMessage = failure.toString();
        _isLoading = false;
      },
      (_) {
        _bookings.removeWhere((b) => b.id == bookingId);
        _isLoading = false;
      },
    );

    notifyListeners();
  }

  // 예약 상태 업데이트
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    _isLoading = true;
    notifyListeners();

    final result = await repository.updateBookingStatus(bookingId, status);

    result.fold(
      (failure) {
        _errorMessage = failure.toString();
        _isLoading = false;
      },
      (_) {
        final index = _bookings.indexWhere((b) => b.id == bookingId);
        if (index >= 0) {
          _bookings[index] = _bookings[index].copyWith(status: status);
        }
        _isLoading = false;
      },
    );

    notifyListeners();
  }

  void _saveBookingLocally(BookingModel booking) {
    // SharedPreferences 또는 sqflite를 사용하여 저장
  }
}

enum BookingStatus { pending, confirmed, ongoing, completed, cancelled }
```

### 5.4 ChatProvider (NEW)

```dart
// lib/features/chat/provider/chat_provider.dart

import 'package:flutter/foundation.dart';
import 'package:danngam/features/chat/data/model/chat_model.dart';
import 'package:danngam/features/chat/data/repository/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository repository;

  List<ChatRoomModel> _chatRooms = [];
  List<ChatMessageModel> _currentMessages = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedRoomId;

  ChatProvider({required this.repository});

  // Getters
  List<ChatRoomModel> get chatRooms => _chatRooms;
  List<ChatMessageModel> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedRoomId => _selectedRoomId;

  // 채팅방 목록 로드
  Future<void> loadChatRooms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.getChatRooms();

    result.fold(
      (failure) {
        _errorMessage = failure.toString();
        _isLoading = false;
      },
      (rooms) {
        _chatRooms = rooms;
        _isLoading = false;
      },
    );

    notifyListeners();
  }

  // 채팅 메시지 로드
  Future<void> loadChatMessages(String roomId) async {
    _selectedRoomId = roomId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.getChatMessages(roomId);

    result.fold(
      (failure) {
        _errorMessage = failure.toString();
        _isLoading = false;
      },
      (messages) {
        _currentMessages = messages;
        _isLoading = false;
        _saveChatMessagesLocally(roomId, messages);
      },
    );

    notifyListeners();
  }

  // 메시지 전송
  Future<void> sendMessage(String roomId, String content) async {
    if (content.isEmpty) return;

    final message = ChatMessageModel(
      id: DateTime.now().toString(),
      roomId: roomId,
      senderId: 'current_user_id',
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _currentMessages.add(message);
    notifyListeners();

    final result = await repository.sendMessage(roomId, message);

    result.fold(
      (failure) {
        _errorMessage = failure.toString();
        // 로컬 메시지 삭제
        _currentMessages.remove(message);
      },
      (_) {
        _saveChatMessagesLocally(roomId, _currentMessages);
      },
    );

    notifyListeners();
  }

  void _saveChatMessagesLocally(String roomId, List<ChatMessageModel> messages) {
    // SharedPreferences 또는 sqflite를 사용하여 저장
  }
}
```

### 5.5 UserProvider

```dart
// lib/features/auth/provider/user_provider.dart

import 'package:flutter/foundation.dart';
import 'package:danngam/features/auth/data/model/user_model.dart';
import 'package:danngam/features/auth/data/repository/auth_repository.dart';
import 'package:danngam/core/local_storage/shared_preferences_helper.dart';

class UserProvider extends ChangeNotifier {
  final AuthRepository repository;
  final SharedPreferencesHelper localStorageHelper;

  UserModel? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  UserProvider({
    required this.repository,
    required this.localStorageHelper,
  });

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 앱 초기화 시 저장된 사용자 정보 로드
  Future<void> initializeUser() async {
    _isLoading = true;
    notifyListeners();

    final savedUser = await localStorageHelper.getUser();
    if (savedUser != null) {
      _currentUser = savedUser;
      _isLoggedIn = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  // 로그인
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.login(email, password);

    result.fold(
      (failure) {
        _errorMessage = failure.toString();
        _isLoading = false;
      },
      (user) {
        _currentUser = user;
        _isLoggedIn = true;
        _isLoading = false;
        // LocalStorage에 저장
        localStorageHelper.saveUser(user);
      },
    );

    notifyListeners();
  }

  // 로그아웃
  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    await localStorageHelper.clearUser();
    notifyListeners();
  }

  // 사용자 정보 업데이트
  Future<void> updateUserProfile(UserModel updatedUser) async {
    _isLoading = true;
    notifyListeners();

    final result = await repository.updateUserProfile(updatedUser);

    result.fold(
      (failure) {
        _errorMessage = failure.toString();
        _isLoading = false;
      },
      (_) {
        _currentUser = updatedUser;
        _isLoading = false;
        localStorageHelper.saveUser(updatedUser);
      },
    );

    notifyListeners();
  }
}
```

---

## 6. Mock Data 구조

### 6.1 Mock JSON 데이터 저장 위치

```
assets/
└── data/
    ├── equipments.json
    ├── users.json
    ├── bookings.json
    └── chats.json
```

### 6.2 equipments.json

```json
{
  "equipments": [
    {
      "id": "eq_001",
      "name": "100마력 트랙터",
      "category": "트랙터",
      "type": "mobile",
      "description": "현대적인 100마력 트랙터로 농사 전반에 사용 가능합니다",
      "images": [
        "https://via.placeholder.com/300x200?text=Tractor+1"
      ],
      "pricePerHour": 50000,
      "location": {
        "latitude": 37.7749,
        "longitude": -122.4194,
        "address": "서울시 강남구"
      },
      "status": "available",
      "averageRating": 4.5,
      "reviewCount": 12,
      "supplierId": "supplier_001",
      "createdAt": "2025-01-01T10:00:00Z",
      "updatedAt": "2025-02-10T10:00:00Z"
    },
    {
      "id": "eq_002",
      "name": "콤바인 수확기",
      "category": "수확기",
      "type": "fixed",
      "description": "벼와 보리 수확에 최적화된 콤바인 수확기",
      "images": [
        "https://via.placeholder.com/300x200?text=Combine+1"
      ],
      "pricePerHour": 80000,
      "location": {
        "latitude": 36.8099,
        "longitude": 127.0856,
        "address": "전주시 완산구"
      },
      "status": "available",
      "averageRating": 4.8,
      "reviewCount": 25,
      "supplierId": "supplier_002",
      "createdAt": "2025-01-05T10:00:00Z",
      "updatedAt": "2025-02-08T10:00:00Z"
    }
  ]
}
```

### 6.3 users.json

```json
{
  "users": [
    {
      "id": "user_001",
      "name": "김농부",
      "email": "kim@farm.com",
      "phone": "010-1234-5678",
      "userType": "farmer",
      "profileImage": "https://via.placeholder.com/100x100?text=Profile",
      "rating": 4.7,
      "reviewCount": 8,
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-02-10T00:00:00Z"
    },
    {
      "id": "user_002",
      "name": "이공급자",
      "email": "lee@supplier.com",
      "phone": "010-9876-5432",
      "userType": "supplier",
      "profileImage": "https://via.placeholder.com/100x100?text=Supplier",
      "rating": 4.9,
      "reviewCount": 45,
      "createdAt": "2024-12-01T00:00:00Z",
      "updatedAt": "2025-02-10T00:00:00Z"
    }
  ]
}
```

### 6.4 bookings.json

```json
{
  "bookings": [
    {
      "id": "booking_001",
      "userId": "user_001",
      "equipmentId": "eq_001",
      "startTime": "2025-03-01T08:00:00Z",
      "endTime": "2025-03-01T17:00:00Z",
      "totalAmount": 450000,
      "status": "pending",
      "notes": "농사 정리용",
      "createdAt": "2025-02-10T10:00:00Z",
      "updatedAt": "2025-02-10T10:00:00Z"
    }
  ]
}
```

### 6.5 chats.json

```json
{
  "chatRooms": [
    {
      "id": "room_001",
      "participantIds": ["user_001", "user_002"],
      "lastMessage": "네, 예약 가능합니다",
      "lastMessageTime": "2025-02-10T15:30:00Z",
      "unreadCount": 2,
      "createdAt": "2025-02-05T10:00:00Z"
    }
  ],
  "messages": [
    {
      "id": "msg_001",
      "roomId": "room_001",
      "senderId": "user_002",
      "content": "안녕하세요. 트랙터 대여 가능한가요?",
      "timestamp": "2025-02-10T10:00:00Z",
      "isRead": true
    },
    {
      "id": "msg_002",
      "roomId": "room_001",
      "senderId": "user_001",
      "content": "네, 예약 가능합니다",
      "timestamp": "2025-02-10T15:30:00Z",
      "isRead": false
    }
  ]
}
```

---

## 7. LocalStorage 관리

### 7.1 SharedPreferencesHelper (사용자 정보, 간단한 데이터)

```dart
// lib/core/local_storage/shared_preferences_helper.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:danngam/features/auth/data/model/user_model.dart';

class SharedPreferencesHelper {
  static const String _userKey = 'user_data';
  static const String _bookingKey = 'bookings_data';
  static const String _chatKey = 'chat_data';

  final SharedPreferences _prefs;

  SharedPreferencesHelper({required SharedPreferences prefs}) : _prefs = prefs;

  // 사용자 정보 저장
  Future<bool> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      return await _prefs.setString(_userKey, userJson);
    } catch (e) {
      return false;
    }
  }

  // 저장된 사용자 정보 로드
  Future<UserModel?> getUser() async {
    try {
      final userJson = _prefs.getString(_userKey);
      if (userJson == null) return null;
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  // 사용자 정보 삭제
  Future<bool> clearUser() async {
    return await _prefs.remove(_userKey);
  }

  // 예약 정보 저장
  Future<bool> saveBooking(String bookingJson) async {
    try {
      final bookings = _prefs.getStringList(_bookingKey) ?? [];
      bookings.add(bookingJson);
      return await _prefs.setStringList(_bookingKey, bookings);
    } catch (e) {
      return false;
    }
  }

  // 저장된 예약 정보 로드
  Future<List<String>> getBookings() async {
    return _prefs.getStringList(_bookingKey) ?? [];
  }

  // 채팅 메시지 저장
  Future<bool> saveChatMessages(String roomId, String messagesJson) async {
    try {
      return await _prefs.setString('$_chatKey:$roomId', messagesJson);
    } catch (e) {
      return false;
    }
  }

  // 저장된 채팅 메시지 로드
  Future<String?> getChatMessages(String roomId) async {
    return _prefs.getString('$_chatKey:$roomId');
  }
}
```

### 7.2 MockDataLoader (Mock JSON 데이터 로드)

```dart
// lib/core/utils/mock_data_loader.dart

import 'package:flutter/services.dart';
import 'dart:convert';

class MockDataLoader {
  // Mock JSON 데이터 로드
  static Future<List<T>> loadJsonData<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // 'data' 또는 복수형 키로 배열 찾기
      late List<dynamic> items;
      if (jsonData.containsKey('data')) {
        items = jsonData['data'] as List<dynamic>;
      } else {
        // 첫 번째 배열 찾기
        for (final key in jsonData.keys) {
          if (jsonData[key] is List) {
            items = jsonData[key] as List<dynamic>;
            break;
          }
        }
      }

      return items.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading mock data: $e');
      return [];
    }
  }
}
```

---

## 8. Repository 패턴 (로컬 ↔ 원격 전환 준비)

### 8.1 Repository 인터페이스

```dart
// lib/features/equipment/data/repository/equipment_repository.dart

import 'package:dartz/dartz.dart';
import 'package:danngam/core/error/failure.dart';
import 'package:danngam/features/equipment/data/model/equipment_model.dart';

abstract class EquipmentRepository {
  Future<Either<Failure, List<EquipmentModel>>> getEquipment();
  Future<Either<Failure, EquipmentModel>> getEquipmentById(String id);
  Future<Either<Failure, List<EquipmentModel>>> searchEquipment(String query);
  Future<Either<Failure, EquipmentModel>> addEquipment(EquipmentModel equipment);
  Future<Either<Failure, void>> updateEquipment(EquipmentModel equipment);
  Future<Either<Failure, void>> deleteEquipment(String id);
}
```

### 8.2 Repository 구현 (로컬 중심)

```dart
// lib/features/equipment/data/repository/equipment_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:danngam/core/error/failure.dart';
import 'package:danngam/features/equipment/data/datasource/equipment_mock_datasource.dart';
import 'package:danngam/features/equipment/data/datasource/equipment_local_datasource.dart';
import 'package:danngam/features/equipment/data/model/equipment_model.dart';
import 'package:danngam/features/equipment/data/repository/equipment_repository.dart';

class EquipmentRepositoryImpl implements EquipmentRepository {
  final EquipmentMockDataSource mockDataSource;
  final EquipmentLocalDataSource localDataSource;

  // 향후 원격 데이터소스 추가
  // final EquipmentRemoteDataSource remoteDataSource;

  EquipmentRepositoryImpl({
    required this.mockDataSource,
    required this.localDataSource,
    // required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<EquipmentModel>>> getEquipment() async {
    try {
      // MVP 단계: Mock 데이터 사용
      final equipment = await mockDataSource.getEquipment();
      // 로컬 캐시에 저장
      await localDataSource.cacheEquipment(equipment);
      return Right(equipment);

      // 향후 백엔드 연동 시:
      // try {
      //   final remoteEquipment = await remoteDataSource.getEquipment();
      //   await localDataSource.cacheEquipment(remoteEquipment);
      //   return Right(remoteEquipment);
      // } catch (e) {
      //   final cachedEquipment = await localDataSource.getCachedEquipment();
      //   return Right(cachedEquipment);
      // }
    } catch (e) {
      return Left(ServerFailure('장비 목록을 불러올 수 없습니다'));
    }
  }

  @override
  Future<Either<Failure, EquipmentModel>> getEquipmentById(String id) async {
    try {
      final equipment = await mockDataSource.getEquipmentById(id);
      return Right(equipment);
    } catch (e) {
      return Left(ServerFailure('장비 정보를 불러올 수 없습니다'));
    }
  }

  @override
  Future<Either<Failure, List<EquipmentModel>>> searchEquipment(String query) async {
    try {
      final results = await mockDataSource.searchEquipment(query);
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('검색에 실패했습니다'));
    }
  }

  @override
  Future<Either<Failure, EquipmentModel>> addEquipment(EquipmentModel equipment) async {
    try {
      final newEquipment = await localDataSource.addEquipment(equipment);
      return Right(newEquipment);
    } catch (e) {
      return Left(ServerFailure('장비를 추가할 수 없습니다'));
    }
  }

  @override
  Future<Either<Failure, void>> updateEquipment(EquipmentModel equipment) async {
    try {
      await localDataSource.updateEquipment(equipment);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('장비 정보를 업데이트할 수 없습니다'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEquipment(String id) async {
    try {
      await localDataSource.deleteEquipment(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('장비를 삭제할 수 없습니다'));
    }
  }
}
```

### 8.3 DataSource 구현

```dart
// lib/features/equipment/data/datasource/equipment_mock_datasource.dart

import 'package:danngam/core/utils/mock_data_loader.dart';
import 'package:danngam/features/equipment/data/model/equipment_model.dart';

abstract class EquipmentMockDataSource {
  Future<List<EquipmentModel>> getEquipment();
  Future<EquipmentModel> getEquipmentById(String id);
  Future<List<EquipmentModel>> searchEquipment(String query);
}

class EquipmentMockDataSourceImpl implements EquipmentMockDataSource {
  @override
  Future<List<EquipmentModel>> getEquipment() async {
    return await MockDataLoader.loadJsonData<EquipmentModel>(
      'assets/data/equipments.json',
      (json) => EquipmentModel.fromJson(json),
    );
  }

  @override
  Future<EquipmentModel> getEquipmentById(String id) async {
    final equipments = await getEquipment();
    return equipments.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('Equipment not found'),
    );
  }

  @override
  Future<List<EquipmentModel>> searchEquipment(String query) async {
    final equipments = await getEquipment();
    return equipments
        .where((e) =>
            e.name.toLowerCase().contains(query.toLowerCase()) ||
            e.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

// Local DataSource (SharedPreferences, sqflite 사용)
abstract class EquipmentLocalDataSource {
  Future<void> cacheEquipment(List<EquipmentModel> equipment);
  Future<List<EquipmentModel>> getCachedEquipment();
  Future<EquipmentModel> addEquipment(EquipmentModel equipment);
  Future<void> updateEquipment(EquipmentModel equipment);
  Future<void> deleteEquipment(String id);
}

class EquipmentLocalDataSourceImpl implements EquipmentLocalDataSource {
  final SharedPreferencesHelper helper;

  EquipmentLocalDataSourceImpl({required this.helper});

  @override
  Future<void> cacheEquipment(List<EquipmentModel> equipment) async {
    // 구현
  }

  @override
  Future<List<EquipmentModel>> getCachedEquipment() async {
    // 구현
    return [];
  }

  @override
  Future<EquipmentModel> addEquipment(EquipmentModel equipment) async {
    // 로컬 저장
    return equipment;
  }

  @override
  Future<void> updateEquipment(EquipmentModel equipment) async {
    // 로컬 업데이트
  }

  @override
  Future<void> deleteEquipment(String id) async {
    // 로컬 삭제
  }
}
```

---

## 9. 향후 백엔드 마이그레이션 가이드

### 9.1 마이그레이션 전략

**Phase 1 (현재): 로컬 중심**
- Mock JSON 데이터 사용
- SharedPreferences/sqflite로 상태 저장
- Repository로 추상화

**Phase 2: 하이브리드**
- Remote DataSource 활성화
- 네트워크 연결 시 원격 데이터 사용
- 연결 실패 시 로컬 캐시 사용

**Phase 3: 완전 백엔드**
- Mock DataSource 제거
- 완전 원격 API 의존

### 9.2 API 클라이언트 준비 (향후)

```dart
// lib/core/network/api_client.dart (향후 구현)

import 'package:dio/dio.dart';

abstract class ApiClient {
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters});
  Future<Response> post(String endpoint, {dynamic data});
  Future<Response> put(String endpoint, {dynamic data});
  Future<Response> delete(String endpoint);
}

class DioApiClient implements ApiClient {
  final Dio _dio;

  DioApiClient({required Dio dio}) : _dio = dio {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // 인터셉터 설정
  }

  @override
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(endpoint, queryParameters: queryParameters);
  }

  @override
  Future<Response> post(String endpoint, {dynamic data}) async {
    return await _dio.post(endpoint, data: data);
  }

  @override
  Future<Response> put(String endpoint, {dynamic data}) async {
    return await _dio.put(endpoint, data: data);
  }

  @override
  Future<Response> delete(String endpoint) async {
    return await _dio.delete(endpoint);
  }
}
```

### 9.3 Remote DataSource 준비 (향후)

```dart
// lib/features/equipment/data/datasource/equipment_remote_datasource.dart (향후)

abstract class EquipmentRemoteDataSource {
  Future<List<EquipmentModel>> getEquipment();
  Future<EquipmentModel> getEquipmentById(String id);
  Future<EquipmentModel> addEquipment(EquipmentModel equipment);
  Future<void> updateEquipment(EquipmentModel equipment);
  Future<void> deleteEquipment(String id);
}

class EquipmentRemoteDataSourceImpl implements EquipmentRemoteDataSource {
  final ApiClient apiClient;

  EquipmentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<EquipmentModel>> getEquipment() async {
    try {
      final response = await apiClient.get('/api/equipments');
      final equipments = (response.data['equipments'] as List)
          .map((item) => EquipmentModel.fromJson(item))
          .toList();
      return equipments;
    } catch (e) {
      throw Exception('Failed to fetch equipments');
    }
  }

  @override
  Future<EquipmentModel> getEquipmentById(String id) async {
    final response = await apiClient.get('/api/equipments/$id');
    return EquipmentModel.fromJson(response.data['equipment']);
  }

  @override
  Future<EquipmentModel> addEquipment(EquipmentModel equipment) async {
    final response = await apiClient.post('/api/equipments', data: equipment.toJson());
    return EquipmentModel.fromJson(response.data['equipment']);
  }

  @override
  Future<void> updateEquipment(EquipmentModel equipment) async {
    await apiClient.put('/api/equipments/${equipment.id}', data: equipment.toJson());
  }

  @override
  Future<void> deleteEquipment(String id) async {
    await apiClient.delete('/api/equipments/$id');
  }
}
```

### 9.4 Repository 마이그레이션 방법

```dart
// 향후: Repository에서 RemoteDataSource 활성화

class EquipmentRepositoryImpl implements EquipmentRepository {
  final EquipmentMockDataSource mockDataSource;
  final EquipmentLocalDataSource localDataSource;
  final EquipmentRemoteDataSource remoteDataSource;  // 추가

  EquipmentRepositoryImpl({
    required this.mockDataSource,
    required this.localDataSource,
    required this.remoteDataSource,  // 추가
  });

  @override
  Future<Either<Failure, List<EquipmentModel>>> getEquipment() async {
    try {
      // 네트워크 요청 우선
      final equipment = await remoteDataSource.getEquipment();
      await localDataSource.cacheEquipment(equipment);
      return Right(equipment);
    } on NetworkException catch (e) {
      // 네트워크 실패 시 로컬 캐시 사용
      try {
        final cached = await localDataSource.getCachedEquipment();
        return Right(cached);
      } catch (_) {
        return Left(NetworkFailure(e.message));
      }
    }
  }
}
```

---

## 10. Dependency Injection (GetIt) 설정

### 10.1 ServiceLocator 설정

```dart
// lib/di/service_locator.dart

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:danngam/core/local_storage/shared_preferences_helper.dart';
import 'package:danngam/di/modules/auth_module.dart';
import 'package:danngam/di/modules/equipment_module.dart';
import 'package:danngam/di/modules/booking_module.dart';
import 'package:danngam/di/modules/chat_module.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core 의존성
  await _setupCore();

  // Feature 모듈
  AuthModule.init();
  EquipmentModule.init();
  BookingModule.init();
  ChatModule.init();
}

Future<void> _setupCore() async {
  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // LocalStorage Helper
  getIt.registerSingleton<SharedPreferencesHelper>(
    SharedPreferencesHelper(prefs: prefs),
  );
}
```

### 10.2 EquipmentModule

```dart
// lib/di/modules/equipment_module.dart

import 'package:get_it/get_it.dart';
import 'package:danngam/features/equipment/contract/equipment_contract.dart';
import 'package:danngam/features/equipment/presenter/equipment_presenter.dart';
import 'package:danngam/features/equipment/provider/equipment_provider.dart';
import 'package:danngam/features/equipment/data/datasource/equipment_mock_datasource.dart';
import 'package:danngam/features/equipment/data/datasource/equipment_local_datasource.dart';
import 'package:danngam/features/equipment/data/repository/equipment_repository_impl.dart';

class EquipmentModule {
  static void init() {
    final getIt = GetIt.instance;

    // DataSources
    getIt.registerLazySingleton<EquipmentMockDataSource>(
      () => EquipmentMockDataSourceImpl(),
    );

    getIt.registerLazySingleton<EquipmentLocalDataSource>(
      () => EquipmentLocalDataSourceImpl(
        helper: getIt<SharedPreferencesHelper>(),
      ),
    );

    // Repository
    getIt.registerLazySingleton<EquipmentRepository>(
      () => EquipmentRepositoryImpl(
        mockDataSource: getIt<EquipmentMockDataSource>(),
        localDataSource: getIt<EquipmentLocalDataSource>(),
      ),
    );

    // Presenter
    getIt.registerLazySingleton<EquipmentPresenter>(
      () => EquipmentPresenterImpl(
        repository: getIt<EquipmentRepository>(),
      ),
    );

    // Provider (선택적)
    getIt.registerLazySingleton<EquipmentProvider>(
      () => EquipmentProvider(
        repository: getIt<EquipmentRepository>(),
      ),
    );
  }
}
```

---

## 11. Error Handling

### 11.1 Failure 클래스

```dart
// lib/core/error/failure.dart

abstract class Failure {
  const Failure();

  @override
  String toString() => 'Failure';
}

class NetworkFailure extends Failure {
  final String message;

  const NetworkFailure(this.message);

  @override
  String toString() => 'NetworkFailure: $message';
}

class ServerFailure extends Failure {
  final String message;

  const ServerFailure(this.message);

  @override
  String toString() => 'ServerFailure: $message';
}

class ValidationFailure extends Failure {
  final String message;

  const ValidationFailure(this.message);

  @override
  String toString() => 'ValidationFailure: $message';
}

class CacheFailure extends Failure {
  final String message;

  const CacheFailure(this.message);

  @override
  String toString() => 'CacheFailure: $message';
}

class UnauthorizedFailure extends Failure {
  final String message;

  const UnauthorizedFailure(this.message);

  @override
  String toString() => 'UnauthorizedFailure: $message';
}
```

### 11.2 Exception 정의

```dart
// lib/core/error/exception.dart

abstract class AppException implements Exception {
  final String message;

  AppException({required this.message});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({required String message}) : super(message: message);
}

class ServerException extends AppException {
  final int? statusCode;

  ServerException({required String message, this.statusCode})
      : super(message: message);
}

class ValidationException extends AppException {
  ValidationException({required String message}) : super(message: message);
}

class CacheException extends AppException {
  CacheException({required String message}) : super(message: message);
}
```

---

## 12. 테스트 전략

### 12.1 Unit Test (Provider)

```dart
// test/features/equipment/provider/equipment_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:danngam/features/equipment/provider/equipment_provider.dart';
import 'package:danngam/features/equipment/data/model/equipment_model.dart';
import 'package:danngam/features/equipment/data/repository/equipment_repository.dart';

class MockEquipmentRepository extends Mock implements EquipmentRepository {}

void main() {
  late EquipmentProvider provider;
  late MockEquipmentRepository mockRepository;

  setUp(() {
    mockRepository = MockEquipmentRepository();
    provider = EquipmentProvider(repository: mockRepository);
  });

  group('EquipmentProvider', () {
    test('loadEquipment should update equipment list', () async {
      // Arrange
      final mockEquipments = [
        EquipmentModel(
          id: '1',
          name: '트랙터',
          category: '트랙터',
          type: EquipmentType.mobile,
          description: '100마력 트랙터',
          images: ['image.jpg'],
          pricePerHour: 50000,
          location: Location(latitude: 37.7749, longitude: -122.4194),
          status: EquipmentStatus.available,
          averageRating: 4.5,
          reviewCount: 10,
          supplierId: 'supplier1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getEquipment())
          .thenAnswer((_) async => Right(mockEquipments));

      // Act
      await provider.loadEquipment();

      // Assert
      expect(provider.equipment, mockEquipments);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
    });

    test('searchEquipment should filter equipment by query', () {
      // Arrange
      provider._equipment = [
        EquipmentModel(...),
        EquipmentModel(...),
      ];

      // Act
      provider.searchEquipment('트랙터');

      // Assert
      expect(provider.filteredEquipment.length, greaterThan(0));
    });
  });
}
```

---

## 13. 성능 최적화 (로컬 중심)

### 13.1 Mock 데이터 로딩 최적화

```dart
// 한 번만 로드하고 캐싱
class EquipmentProvider extends ChangeNotifier {
  static List<EquipmentModel>? _cachedEquipment;

  Future<void> loadEquipment() async {
    if (_cachedEquipment != null) {
      _equipment = _cachedEquipment!;
      notifyListeners();
      return;
    }

    // 첫 로드 시에만 파일 읽기
    final result = await repository.getEquipment();
    // ...
  }
}
```

### 13.2 ListBuilder 최적화

```dart
// ListView.builder 사용 (lazy loading)
ListView.builder(
  itemCount: provider.filteredEquipment.length,
  itemBuilder: (context, index) => EquipmentCard(
    equipment: provider.filteredEquipment[index],
  ),
)
```

### 13.3 이미지 캐싱

```dart
// cached_network_image 라이브러리 사용
CachedNetworkImage(
  imageUrl: equipment.images.first,
  placeholder: (context, url) => Container(
    color: Colors.grey[300],
    child: const Center(child: CircularProgressIndicator()),
  ),
)
```

---

## 14. 인수 기준

### MVP 완성 기준

- [x] MVP 로컬 아키텍처 정의 (로컬 상태 관리 중심)
- [x] 디렉토리 구조 확정 (Mock JSON, LocalStorage 포함)
- [x] Contract Interface 정의 (Equipment, Booking, Chat, Registration, Review)
- [x] Provider 기반 상태 관리 (5가지 Provider 예제)
- [x] Mock Data 구조 정의 (JSON 형식)
- [x] LocalStorage 관리 (SharedPreferences, sqflite 준비)
- [x] Repository 패턴 (로컬 중심, 향후 확장 가능)
- [x] 향후 마이그레이션 가이드 (API 클라이언트, Remote DataSource)
- [x] Dependency Injection (GetIt 설정)
- [x] Error Handling (Failure, Exception)
- [x] 테스트 전략 (Unit Test)
- [x] 성능 최적화 (로컬 중심)

### 기술 스택

**필수**:
- Flutter 3.0+
- Dart 3.0+
- Provider (상태 관리)
- GetIt (의존성 주입)
- dartz (Either/Result)
- shared_preferences (로컬 저장)

**선택**:
- sqflite (로컬 DB, 복잡한 쿼리 필요 시)
- cached_network_image (이미지 캐싱)
- dio (향후 API 클라이언트)

---

## 15. 개발 로드맵

### Sprint 1: 기본 구조 및 인증
1. 서비스 로케이터 및 DI 설정
2. 인증 화면 (로그인/회원가입)
3. UserProvider 구현
4. SharedPreferences로 사용자 정보 저장

### Sprint 2: 장비 검색 및 필터링
1. Mock JSON 데이터 준비
2. EquipmentProvider 구현
3. 장비 목록 화면
4. 필터링 및 정렬 기능

### Sprint 3: 예약 기능
1. BookingProvider 구현
2. 예약 생성/취소
3. 예약 상태 관리
4. LocalStorage에 예약 저장

### Sprint 4: 채팅 기능
1. ChatProvider 구현
2. 채팅방 목록 및 메시지
3. 실시간 메시지 (로컬)
4. 채팅 메시지 저장

### Sprint 5: 장비 등록 (공급자)
1. EquipmentRegistrationPresenter/Contract
2. 이미지 업로드 (로컬)
3. 장비 정보 입력
4. LocalStorage 저장

### Sprint 6: 백엔드 준비
1. API 클라이언트 구현
2. Remote DataSource 준비
3. Repository 마이그레이션 로직
4. 네트워크 인터셉터

---

## 참고 자료

- [Flutter Official](https://flutter.dev)
- [Provider Package](https://pub.dev/packages/provider)
- [GetIt Service Locator](https://pub.dev/packages/get_it)
- [Dartz - Functional Programming](https://pub.dev/packages/dartz)
- [Flutter Testing](https://flutter.dev/docs/testing)
- [Clean Architecture in Flutter](https://medium.com/flutter-community/clean-architecture-in-flutter)

---

**마지막 수정**: 2026-02-14
**버전**: 2.0
**상태**: MVP - 로컬 중심 아키텍처 완성
