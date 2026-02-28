# Flutter 프론트엔드 구현 가이드

**작성일**: 2026-02-17
**상태**: 개발 준비 완료
**버전**: 1.0.0
**프레임워크**: Flutter 3.0+, Dart 3.0+

---

## 📱 프로젝트 구조

```
danngam_app/
├── lib/
│   ├── main.dart                          # 진입점
│   ├── config/
│   │   ├── app_config.dart               # 설정
│   │   ├── app_theme.dart                # 테마
│   │   ├── app_colors.dart               # 색상
│   │   └── feature_flags.dart            # 기능 플래그
│   ├── routes/
│   │   └── app_router.dart               # 라우팅
│   ├── modules/
│   │   ├── auth/                         # 인증 모듈
│   │   │   ├── screens/
│   │   │   │   ├── splash_screen.dart
│   │   │   │   ├── onboarding_screen.dart
│   │   │   │   ├── social_login_screen.dart
│   │   │   │   └── phone_otp_screen.dart  ⏳ 새로 생성
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   ├── services/
│   │   │   │   ├── auth_service.dart
│   │   │   │   └── social_login_service.dart
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   ├── send_otp_response.dart  ⏳ 새로 생성
│   │   │   │   └── verify_otp_response.dart ⏳ 새로 생성
│   │   │   └── auth_module.dart
│   │   ├── equipment/                    # 장비 검색 모듈 (F-2)
│   │   │   ├── screens/
│   │   │   ├── providers/
│   │   │   ├── services/
│   │   │   └── models/
│   │   ├── booking/                      # 예약 모듈 (F-3)
│   │   ├── chat/                         # 채팅 모듈 (F-4)
│   │   └── review/                       # 리뷰 모듈 (F-4)
│   └── shared/
│       ├── widgets/
│       │   ├── app_button.dart
│       │   ├── app_text_field.dart
│       │   └── equipment_card.dart
│       ├── utils/
│       │   ├── api_client.dart
│       │   ├── validators.dart
│       │   └── logger.dart
│       └── constants/
│           ├── app_strings.dart
│           ├── app_colors.dart
│           └── app_dimensions.dart
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

---

## 🚀 빠른 시작 (5분)

### Step 1: 환경 설정

```bash
# Flutter 설치 확인
flutter --version
dart --version

# 프로젝트 디렉토리로 이동
cd danngam/danngam_app

# 의존성 설치
flutter pub get

# 코드 생성 (필요시)
flutter pub run build_runner build
```

### Step 2: 앱 실행

```bash
# Android 에뮬레이터
flutter run

# iOS 시뮬레이터
flutter run -d macos

# 웹 (개발용)
flutter run -d chrome

# 실제 기기
flutter run -d <device_id>
```

### Step 3: 백엔드 연결 설정

```dart
// lib/shared/utils/api_client.dart

class ApiClient {
  // 로컬 개발
  static const String API_BASE = 'http://10.0.2.2:8000/api/v1';  // Android
  // static const String API_BASE = 'http://localhost:8000/api/v1';  // iOS

  // 개발 서버
  // static const String API_BASE = 'https://dev-api.danngam.com/api/v1';

  // 프로덕션
  // static const String API_BASE = 'https://api.danngam.com/api/v1';
}
```

---

## 📋 의존성 (pubspec.yaml)

```yaml
name: danngam_app
description: A new Flutter application.

version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # UI
  cupertino_icons: ^1.0.0

  # 상태 관리
  provider: ^6.0.0

  # API 통신
  http: ^1.1.0
  dio: ^5.3.0  # 또는 http 선택

  # 로컬 저장소
  shared_preferences: ^2.2.0
  sqflite: ^2.3.0  # 또는 hive

  # JSON 직렬화
  json_serializable: ^6.7.0
  json_annotation: ^4.8.0

  # 소셜 로그인
  kakao_flutter_sdk: ^1.9.0

  # 유틸
  intl: ^0.19.0
  table_calendar: ^3.0.0  # 달력 위젯
  image_picker: ^1.0.0   # 이미지 선택
  permission_handler: ^11.4.0  # 권한 관리

  # 로깅
  logger: ^2.0.0

  # 에러 추적 (선택)
  sentry_flutter: ^7.8.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

  # 코드 생성
  build_runner: ^2.4.0
  json_serializable: ^6.7.0

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/data/

  fonts:
    - family: Pretendard
      fonts:
        - asset: assets/fonts/Pretendard-Regular.ttf
        - asset: assets/fonts/Pretendard-Bold.ttf
          weight: 700
```

---

## 🛠️ Phase별 구현 가이드

### **Phase F-1: 로그인 화면** (2026-02-22 ~ 2026-02-25)

#### 파일 구조

```
lib/modules/auth/
├── screens/
│   ├── splash_screen.dart         ✅ 기본틀 있음 (수정)
│   ├── onboarding_screen.dart     ✅ 기본틀 있음 (수정)
│   ├── social_login_screen.dart   ✅ 기본틀 있음 (수정)
│   └── phone_otp_screen.dart      ⏳ 새로 생성
├── providers/
│   └── auth_provider.dart         ✅ (수정 필요)
├── services/
│   ├── auth_service.dart          ✅ (수정 필요)
│   └── social_login_service.dart  ✅ (수정 필요)
└── models/
    ├── user_model.dart            ✅
    ├── send_otp_response.dart     ⏳ 새로 생성
    └── verify_otp_response.dart   ⏳ 새로 생성
```

---

#### 1️⃣ SplashScreen 수정 (1시간)

**파일**: `lib/modules/auth/screens/splash_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // 1. SharedPreferences에서 토큰 확인
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    // 2. 2초 대기
    await Future.delayed(const Duration(seconds: 2));

    // 3. 토큰 유무에 따라 화면 이동
    if (token != null && mounted) {
      // 토큰 있음: AuthProvider에 설정 후 메인 화면
      context.read<AuthProvider>().setToken(token);
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      // 토큰 없음: 온보딩 화면
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 이미지
            Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Danngam',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '당신의 농기계 파트너',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
```

---

#### 2️⃣ OnboardingScreen 수정 (1시간)

**파일**: `lib/modules/auth/screens/onboarding_screen.dart`

```dart
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      image: 'assets/images/onboarding1.png',
      title: '당나무에 오신 걸 환영합니다!',
      description: '농기계 공유로 비용을 아끼세요',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding2.png',
      title: '검색하고 비교하세요',
      description: '위치 기반 장비 검색',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding3.png',
      title: '예약하고 사용하세요',
      description: '간편한 예약 시스템',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(page.image, height: 300),
                      const SizedBox(height: 40),
                      Text(
                        page.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
            // 페이지 인디케이터
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => Container(
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index
                          ? Colors.blue
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
            // 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goToLogin,
                      child: const Text('건너뛰기'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == pages.length - 1 ? '시작' : '다음',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String description;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });
}
```

---

#### 3️⃣ SocialLoginScreen 수정 (1시간)

**파일**: `lib/modules/auth/screens/social_login_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/social_login_service.dart';

class SocialLoginScreen extends StatefulWidget {
  const SocialLoginScreen({Key? key}) : super(key: key);

  @override
  State<SocialLoginScreen> createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends State<SocialLoginScreen> {
  bool _isLoading = false;

  Future<void> _loginWithKakao() async {
    setState(() => _isLoading = true);
    try {
      final service = context.read<SocialLoginService>();
      final result = await service.loginWithKakao();

      if (result && mounted) {
        // 성공 → 휴대폰 입력 화면
        Navigator.of(context).pushNamed('/phone-otp');
      }
    } catch (e) {
      _showError('카카오 로그인 실패: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _loginWithPhone() {
    Navigator.of(context).pushNamed('/phone-otp');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 로고
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  Image.asset('assets/images/logo.png', width: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'Danngam',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '당신의 농기계 파트너',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loginWithKakao,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              '🟨 카카오로 로그인',
                              style: TextStyle(color: Colors.black87),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _loginWithPhone,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('📱 휴대폰으로 로그인'),
                    ),
                  ),
                ],
              ),
            ),
            // 약관
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: RichText(
                text: TextSpan(
                  text: '로그인하면 ',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: '이용약관',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                      ),
                    ),
                    const TextSpan(text: '에 동의합니다'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

#### 4️⃣ PhoneOtpScreen 생성 (3시간) ⭐ 핵심

**파일**: `lib/modules/auth/screens/phone_otp_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({Key? key}) : super(key: key);

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _otpController;

  bool _showOtpInput = false;
  bool _isLoading = false;
  bool _canResendOtp = false;
  int _remainingSeconds = 180;
  Timer? _countdownTimer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final phone = _phoneController.text;

      // 검증
      if (!_isValidPhone(phone)) {
        throw '잘못된 휴대폰 형식입니다';
      }

      // API 호출
      final response = await authService.sendOtp(phone);

      // 성공
      if (mounted) {
        setState(() {
          _showOtpInput = true;
          _remainingSeconds = response.expiresIn ?? 180;
          _canResendOtp = false;
        });
        _startCountdown();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final phone = _phoneController.text;
      final otp = _otpController.text;

      // 검증
      if (otp.length != 6) {
        throw '6자리 코드를 입력해주세요';
      }

      // API 호출
      final response = await authService.verifyOtp(phone, otp);

      // 토큰 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', response.accessToken);

      // Provider에 설정
      if (mounted) {
        context.read<AuthProvider>().setToken(response.accessToken);

        // 메인 화면으로 이동
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        setState(() => _canResendOtp = true);
        timer.cancel();
      }
    });
  }

  bool _isValidPhone(String phone) {
    final pattern = RegExp(r'^01[0-9]-\d{3,4}-\d{4}$');
    return pattern.hasMatch(phone);
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('인증')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _showOtpInput ? _buildOtpInput() : _buildPhoneInput(),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              '휴대폰 번호를\n입력해주세요',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: '휴대폰 번호',
                hintText: '010-0000-0000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabled: !_isLoading,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendOtp,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('OTP 받기'),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              '인증 코드를\n입력해주세요',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '남은 시간: ${_formatDuration(_remainingSeconds)}',
              style: TextStyle(
                fontSize: 14,
                color: _remainingSeconds < 30 ? Colors.red : Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: '인증 코드',
                hintText: '000000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabled: !_isLoading,
              ),
              style: const TextStyle(fontSize: 20, letterSpacing: 10),
            ),
            const SizedBox(height: 20),
            if (_canResendOtp)
              TextButton(
                onPressed: _isLoading ? null : _sendOtp,
                child: const Text('코드 다시 받기'),
              )
            else
              Text(
                '${_formatDuration(_remainingSeconds)} 후 다시 받을 수 있습니다',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('확인'),
          ),
        ),
      ],
    );
  }
}
```

---

#### 5️⃣ AuthService 수정 (2시간)

**파일**: `lib/modules/auth/services/auth_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/send_otp_response.dart';
import '../models/verify_otp_response.dart';
import '../../shared/utils/api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({required ApiClient apiClient}) : _apiClient = apiClient;

  // OTP 발송
  Future<SendOtpResponse> sendOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiClient.baseUrl}/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode == 200) {
        return SendOtpResponse.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw 'OTP 발송 실패: $e';
    }
  }

  // OTP 검증
  Future<VerifyOtpResponse> verifyOtp(String phone, String otpCode) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiClient.baseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'otp_code': otpCode,
        }),
      );

      if (response.statusCode == 200) {
        return VerifyOtpResponse.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw 'OTP 검증 실패: $e';
    }
  }

  // 로그아웃
  Future<void> logout(String token) async {
    try {
      await http.post(
        Uri.parse('${ApiClient.baseUrl}/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      throw '로그아웃 실패: $e';
    }
  }

  String _handleError(http.Response response) {
    try {
      final error = jsonDecode(response.body);
      return error['detail'] ?? '알 수 없는 오류';
    } catch (_) {
      return '서버 오류: ${response.statusCode}';
    }
  }
}
```

---

#### 6️⃣ Response 모델 생성

**파일**: `lib/modules/auth/models/send_otp_response.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'send_otp_response.g.dart';

@JsonSerializable()
class SendOtpResponse {
  final String message;
  @JsonKey(name: 'otp_id')
  final String otpId;
  @JsonKey(name: 'expires_in')
  final int? expiresIn;
  final String status;

  SendOtpResponse({
    required this.message,
    required this.otpId,
    this.expiresIn,
    required this.status,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) =>
      _$SendOtpResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SendOtpResponseToJson(this);
}
```

**파일**: `lib/modules/auth/models/verify_otp_response.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'verify_otp_response.g.dart';

@JsonSerializable()
class VerifyOtpResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  VerifyOtpResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpResponseToJson(this);
}
```

---

### **Phase F-2: 장비 검색 화면** (2026-03-07)

```
파일 구조:
lib/modules/equipment/
├── screens/
│   ├── search_equipment_screen.dart   (위치 기반 검색)
│   ├── equipment_detail_screen.dart   (상세 정보)
│   └── filter_screen.dart             (필터)
├── models/
│   ├── equipment_model.dart
│   └── search_response.dart
├── providers/
│   └── equipment_provider.dart
└── services/
    └── equipment_service.dart

API 연동:
- GET /api/v1/equipments/nearby
- GET /api/v1/equipments/{id}
- GET /api/v1/equipments/categories
- GET /api/v1/equipments/search
```

---

### **Phase F-3: 예약 및 결제** (2026-03-14)

```
파일 구조:
lib/modules/booking/
├── screens/
│   ├── booking_screen.dart      (예약)
│   ├── payment_screen.dart      (결제)
│   └── payment_success_screen.dart
├── models/
├── providers/
└── services/

API 연동:
- POST /api/v1/bookings
- POST /api/v1/payments/initiate
- POST /api/v1/payments/confirm
```

---

### **Phase F-4: 채팅 및 리뷰** (2026-03-21)

```
파일 구조:
lib/modules/chat/
├── screens/
│   ├── chat_list_screen.dart
│   └── chat_detail_screen.dart
└── ...

lib/modules/review/
├── screens/
│   ├── review_list_screen.dart
│   └── review_write_screen.dart
└── ...

API 연동:
- GET /api/v1/chats
- POST /api/v1/chats/{id}/messages
- GET /api/v1/chats/{id}/messages
- POST /api/v1/reviews
- GET /api/v1/equipment/{id}/reviews
```

---

## 🧪 테스트 가이드

### Unit Test

```dart
// test/auth_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:danngam_app/modules/auth/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test('sendOtp - 정상 응답', () async {
      // 테스트 코드
    });

    test('sendOtp - 레이트 리미팅', () async {
      // 테스트 코드
    });

    test('verifyOtp - OTP 일치', () async {
      // 테스트 코드
    });
  });
}
```

### Widget Test

```dart
// test/auth_screen_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('SplashScreen - 토큰 확인', (WidgetTester tester) async {
    // 테스트 코드
  });

  testWidgets('PhoneOtpScreen - OTP 입력', (WidgetTester tester) async {
    // 테스트 코드
  });
}
```

---

## 🔧 빌드 및 배포

### Android

```bash
# 디버그 빌드
flutter build apk

# 릴리스 빌드
flutter build apk --release

# App Bundle (플레이스토어)
flutter build appbundle --release
```

### iOS

```bash
# 디버그 빌드
flutter build ios

# 릴리스 빌드
flutter build ios --release
```

### Web

```bash
# 웹 빌드
flutter build web

# 빌드된 파일 위치
build/web/
```

---

## 📋 체크리스트

### F-1 (로그인) 완료 기준
- [ ] SplashScreen 수정
- [ ] OnboardingScreen 수정
- [ ] SocialLoginScreen 수정
- [ ] PhoneOtpScreen 생성
- [ ] AuthService API 연동
- [ ] Response 모델 생성
- [ ] SharedPreferences 토큰 저장
- [ ] AuthProvider 상태 관리
- [ ] 에러 처리 완전
- [ ] 20개 테스트 케이스 통과

### 각 Phase별
- [ ] F-2: 장비 검색 (2026-03-07)
- [ ] F-3: 예약/결제 (2026-03-14)
- [ ] F-4: 채팅/리뷰 (2026-03-21)

---

## 🚀 개발 팁

### 1. Hot Reload 사용
```bash
# r: hot reload
# R: hot restart
```

### 2. 디버깅
```dart
// 로그 출력
print('Debug: $value');
// 또는
debugPrint('Debug: $value');

// 중단점 설정
// VS Code: Ctrl+F2
```

### 3. 성능 모니터링
```bash
# 성능 프로파일링
flutter run --profile

# 메모리 분석
flutter run --analyze-size
```

---

**작성일**: 2026-02-17
**상태**: 개발 준비 완료 ✅
**버전**: 1.0.0
