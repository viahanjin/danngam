# Flutter Phase F-1: 인증 & 로그인 화면 기획서

**작성일**: 2026-02-15
**담당**: 기획자 (Planner)
**상태**: 개발 준비 완료
**Phase**: F-1 (로그인 화면 구현)

---

## 📋 Executive Summary

**Phase F-1**은 Flutter 앱의 **사용자 인증 화면**을 구현하는 단계입니다.
- 스플래시 화면
- 온보딩 화면
- 소셜 로그인 (카카오)
- OTP 인증 화면
- 메인 홈 화면 진입

**목표**: 4개 화면 + 백엔드 API 연동 완성

**주요 기능**:
- 카카오 소셜 로그인
- OTP 기반 휴대폰 인증
- JWT 토큰 저장 및 관리
- 로그인 상태 유지

---

## 🎯 Phase F-1 목표

### 주요 목표
1. **로그인 흐름 완성**: 스플래시 → 온보딩 → 로그인 → OTP → 메인
2. **백엔드 API 연동**: 3개 인증 API 연결
3. **상태 관리**: Provider 패턴으로 로그인 상태 관리
4. **토큰 저장**: SharedPreferences로 JWT 토큰 영구 저장

### 성공 기준
- [ ] 4개 화면 모두 구현
- [ ] 백엔드 API 연동 정상
- [ ] 토큰 저장/로드 정상
- [ ] 로그인 상태 유지 (앱 재시작 후에도)
- [ ] 에러 처리 완전
- [ ] 로딩 UI 표시
- [ ] 사용자 경험 개선 (스켈레톤, 애니메이션)

---

## 📱 화면 플로우 (Wireframe)

```
┌──────────────┐
│  스플래시    │
│  (2초 로딩)  │  ← 토큰 확인
└──────┬───────┘
       │
       ├─ 토큰 있음 ──→ ┌──────────────┐
       │              │   메인 화면   │
       │              │  (로그인됨)   │
       │              └──────────────┘
       │
       └─ 토큰 없음 ──→ ┌──────────────┐
                      │ 온보딩 화면   │
                      │(이미지 + 텍스트)
                      └──────┬────────┘
                             │
                      ┌──────▼────────┐
                      │ 로그인 화면   │
                      │(카카오 버튼)  │
                      └──────┬────────┘
                             │
                      ┌──────▼────────┐
                      │ OTP 입력      │
                      │(휴대폰 + OTP) │
                      └──────┬────────┘
                             │
                      ┌──────▼────────┐
                      │ 메인 화면     │
                      │(로그인 완료)  │
                      └───────────────┘
```

---

## 🔐 로그인 흐름 상세

### 흐름 1: 신규 사용자 (토큰 없음)

```
1. 스플래시 화면 (2초)
   ↓
2. 온보딩 화면 (이미지 + "당나무에 오신 걸 환영합니다" 텍스트)
   [다음] 또는 [건너뛰기] 클릭
   ↓
3. 로그인 화면 (2가지 옵션)
   옵션 A: [카카오로 로그인] ← 권장
   옵션 B: [휴대폰 번호로 로그인] ← 대체
   ↓
4. 사용자 선택 (예: 카카오)
   - 카카오 앱으로 이동
   - 사용자가 허락
   - 카카오에서 정보 받음 (name, email)
   ↓
5. 휴대폰 번호 입력 화면
   "010-1234-5678" 입력
   [OTP 받기] 클릭

   (백엔드 호출)
   POST /api/v1/auth/send-otp
   {"phone": "010-1234-5678"}

   응답: {"message": "OTP 발송됨", "otp_id": "123456", ...}
   ↓
6. OTP 입력 화면
   "123456" 입력
   [확인] 클릭

   (백엔드 호출)
   POST /api/v1/auth/verify-otp
   {"phone": "010-1234-5678", "otp_code": "123456"}

   응답: {"access_token": "eyJ...", "token_type": "bearer", ...}
   ↓
7. 토큰 저장
   SharedPreferences.setString('access_token', 'eyJ...')
   AuthProvider.setToken('eyJ...')
   ↓
8. 메인 화면으로 이동
```

### 흐름 2: 기존 사용자 (토큰 있음)

```
1. 스플래시 화면 (2초)
   ↓
2. 로컬 저장소에서 토큰 로드
   SharedPreferences.getString('access_token')
   ↓
3. 토큰 있음? → YES
   ↓
4. 메인 화면으로 바로 이동
   (로그인 과정 생략)
```

### 흐름 3: 로그아웃

```
1. 메인 화면 → 설정 탭
   ↓
2. [로그아웃] 클릭
   ↓
3. 백엔드 호출
   POST /api/v1/auth/logout
   Authorization: Bearer {access_token}
   ↓
4. 응답: {"message": "로그아웃됨"}
   ↓
5. 토큰 삭제
   SharedPreferences.remove('access_token')
   AuthProvider.clear()
   ↓
6. 로그인 화면으로 돌아가기
```

---

## 📱 화면별 요구사항

### 1️⃣ 스플래시 화면 (SplashScreen)

**목적**: 앱 시작 시 로딩 화면, 토큰 확인

**UI 요소**:
```
┌─────────────────────────┐
│                         │
│        🌾 Danngam       │
│   당신의 농기계 파트너    │
│                         │
│      [로딩 애니메이션]   │
│                         │
└─────────────────────────┘
```

**기능**:
1. 앱 로고 표시 (1초)
2. SharedPreferences에서 토큰 확인
3. 토큰 있으면 → 메인 화면
4. 토큰 없으면 → 온보딩 화면

**코드 구조**:
```dart
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
            Image.asset('assets/logo.png', width: 100),
            const SizedBox(height: 20),
            const Text(
              'Danngam',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '당신의 농기계 파트너',
              style: TextStyle(fontSize: 14, color: Colors.grey),
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

### 2️⃣ 온보딩 화면 (OnboardingScreen)

**목적**: 앱 소개, 기본 기능 설명

**UI 요소**:
```
┌─────────────────────────┐
│  [이미지 페이지 1/3]    │
│                         │
│  🚜 당나무에 오신 걸    │
│     환영합니다!         │
│                         │
│  농기계 공유로 비용을   │
│  아끼세요               │
│                         │
│  [●] [○] [○]           │  ← 페이지 인디케이터
│                         │
│  [다음] [건너뛰기]      │
└─────────────────────────┘
```

**페이지 구성** (총 3페이지):
1. 환영 페이지
2. 검색 페이지
3. 예약 페이지

**기능**:
1. 좌우 스와이프로 페이지 이동
2. 페이지 인디케이터 표시
3. [다음] 버튼으로 다음 페이지
4. [건너뛰기] 버튼으로 로그인 화면으로

**코드 구조**:
```dart
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
      image: 'assets/onboarding1.png',
      title: '당나무에 오신 걸 환영합니다!',
      description: '농기계 공유로 비용을 아끼세요',
    ),
    OnboardingPage(
      image: 'assets/onboarding2.png',
      title: '검색하고 비교하세요',
      description: '위치 기반 장비 검색',
    ),
    OnboardingPage(
      image: 'assets/onboarding3.png',
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
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(page: pages[index]);
                },
              ),
            ),
            // 페이지 인디케이터
            Row(
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
                        ? AppColors.primary
                        : AppColors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: '건너뛰기',
                      onPressed: _goToLogin,
                      variant: AppButtonVariant.outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: _currentPage == pages.length - 1 ? '시작' : '다음',
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
```

---

### 3️⃣ 로그인 화면 (SocialLoginScreen)

**목적**: 사용자 인증 방식 선택

**UI 요소**:
```
┌─────────────────────────┐
│                         │
│   🌾 Danngam            │
│                         │
│   당신의 농기계 파트너   │
│                         │
│   ─────────────────     │
│                         │
│  [🟨 카카오로 로그인]   │
│                         │
│  [📱 휴대폰으로 로그인] │
│                         │
│   ─────────────────     │
│                         │
│  약관 동의 [링크]       │
│                         │
└─────────────────────────┘
```

**기능**:
1. 카카오 로그인 버튼 클릭
   - 카카오 앱 또는 웹으로 이동
   - 사용자 정보 (이름, 이메일) 받음
   - 휴대폰 입력 화면으로 이동

2. 휴대폰 로그인 버튼 클릭
   - 휴대폰 입력 화면으로 이동

**코드 구조**:
```dart
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
      // 1. 카카오 로그인
      final socialService = context.read<SocialLoginService>();
      final result = await socialService.loginWithKakao();

      if (result) {
        // 2. 성공 → 휴대폰 입력 화면으로
        if (mounted) {
          Navigator.of(context).pushNamed('/phone-input');
        }
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
    Navigator.of(context).pushNamed('/phone-input');
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
                  Image.asset('assets/logo.png', width: 80),
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
                  AppButton(
                    label: '🟨 카카오로 로그인',
                    onPressed: _isLoading ? null : _loginWithKakao,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: '📱 휴대폰으로 로그인',
                    onPressed: _isLoading ? null : _loginWithPhone,
                    variant: AppButtonVariant.outlined,
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
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  children: [
                    TextSpan(
                      text: '이용약관',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: AppColors.primary,
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

### 4️⃣ OTP 입력 화면 (PhoneOtpScreen)

**목적**: 휴대폰 번호 입력 → OTP 발송 → OTP 입력

**UI 요소 - 상태 1: 휴대폰 입력**:
```
┌─────────────────────────┐
│                         │
│  휴대폰 번호를          │
│  입력해주세요           │
│                         │
│  ┌─────────────────┐   │
│  │ 010-1234-5678  │   │
│  └─────────────────┘   │
│                         │
│  [OTP 받기]            │
│                         │
└─────────────────────────┘
```

**UI 요소 - 상태 2: OTP 입력**:
```
┌─────────────────────────┐
│                         │
│  문자로 받은            │
│  인증 코드를 입력해주세요 │
│                         │
│  남은 시간: 02:45       │
│                         │
│  ┌─ ─ ─ ─ ─ ─┐         │
│  │ 1 2 3 4 5 6 │       │ ← 6자리 입력
│  └─ ─ ─ ─ ─ ─┘         │
│                         │
│  [다시 받기] (5초 후)   │
│                         │
└─────────────────────────┘
```

**기능**:
1. 휴대폰 번호 입력
   - 형식: 010-0000-0000
   - 검증: 11자리 숫자

2. [OTP 받기] 클릭
   ```
   POST /api/v1/auth/send-otp
   {"phone": "010-1234-5678"}

   응답: {"message": "OTP 발송됨", "otp_id": "123456", "expires_in": 180}
   ```

3. OTP 입력 화면으로 전환
   - 6자리 숫자 입력 필드
   - 타이머 표시 (3분)
   - [다시 받기] 버튼 (5초 후 활성화)

4. OTP 입력 후 [확인] 클릭
   ```
   POST /api/v1/auth/verify-otp
   {"phone": "010-1234-5678", "otp_code": "123456"}

   응답: {"access_token": "eyJ...", "token_type": "bearer", "expires_in": 86400}
   ```

5. 토큰 저장
   ```dart
   final prefs = await SharedPreferences.getInstance();
   await prefs.setString('access_token', response.accessToken);
   context.read<AuthProvider>().setToken(response.accessToken);
   ```

6. 메인 화면으로 이동

**에러 처리**:
- OTP 불일치: "인증 코드가 일치하지 않습니다"
- OTP 만료: "인증 코드가 만료되었습니다. 다시 받아주세요"
- 레이트 리미팅: "요청이 너무 많습니다. 잠시 후 다시 시도해주세요"

**코드 구조**:
```dart
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
      setState(() {
        _showOtpInput = true;
        _remainingSeconds = response.expiresIn ?? 180;
        _canResendOtp = false;
      });

      // 타이머 시작
      _startCountdown();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
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
      context.read<AuthProvider>().setToken(response.accessToken);

      // 메인 화면으로
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
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
    return RegExp(r'^01[0-9]-\d{3,4}-\d{4}$').hasMatch(phone);
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
            AppTextField(
              controller: _phoneController,
              label: '휴대폰 번호',
              hint: '010-0000-0000',
              enabled: !_isLoading,
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
        AppButton(
          label: 'OTP 받기',
          onPressed: _isLoading ? null : _sendOtp,
          isLoading: _isLoading,
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
            AppTextField(
              controller: _otpController,
              label: '인증 코드',
              hint: '000000',
              keyboardType: TextInputType.number,
              maxLength: 6,
              enabled: !_isLoading,
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
        AppButton(
          label: '확인',
          onPressed: _isLoading ? null : _verifyOtp,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
```

---

## 🏗️ 아키텍처 및 상태 관리

### Provider 패턴 구조

```dart
// 1. 서비스 계층 (API 호출)
class AuthService {
  final ApiClient apiClient;

  Future<SendOtpResponse> sendOtp(String phone) async {
    final response = await apiClient.post('/auth/send-otp', {'phone': phone});
    return SendOtpResponse.fromJson(response);
  }

  Future<VerifyOtpResponse> verifyOtp(String phone, String otp) async {
    final response = await apiClient.post('/auth/verify-otp', {
      'phone': phone,
      'otp_code': otp,
    });
    return VerifyOtpResponse.fromJson(response);
  }
}

// 2. 상태 관리 (Provider)
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  String? _accessToken;
  bool _isAuthenticated = false;

  AuthProvider({required AuthService authService}) : _authService = authService;

  String? get accessToken => _accessToken;
  bool get isAuthenticated => _isAuthenticated;

  void setToken(String token) {
    _accessToken = token;
    _isAuthenticated = true;
    notifyListeners();
  }

  void clearToken() {
    _accessToken = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    clearToken();
  }
}

// 3. API 클라이언트
class ApiClient {
  final String baseUrl = 'http://localhost:8000/api/v1';
  String? _accessToken;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final headers = {
      'Content-Type': 'application/json',
      if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    return jsonDecode(response.body);
  }
}
```

---

## 📋 인수 기준 (Acceptance Criteria)

### AC-1: 스플래시 화면
- [ ] 로고와 텍스트 표시
- [ ] 2초 로딩
- [ ] 토큰 확인 로직
- [ ] 토큰 있으면 메인 화면으로 이동
- [ ] 토큰 없으면 온보딩 화면으로 이동

### AC-2: 온보딩 화면
- [ ] 3개 페이지 구성
- [ ] 좌우 스와이프 가능
- [ ] 페이지 인디케이터 표시
- [ ] [다음] 버튼으로 다음 페이지
- [ ] [건너뛰기] 버튼으로 로그인 화면 이동
- [ ] 마지막 페이지에서 [시작] 버튼 표시

### AC-3: 로그인 화면
- [ ] 카카오 로그인 버튼 클릭 가능
- [ ] 휴대폰 로그인 버튼 클릭 가능
- [ ] 카카오 로그인 성공 시 휴대폰 입력 화면으로 이동
- [ ] 에러 메시지 표시
- [ ] 로딩 상태 표시

### AC-4: OTP 입력 화면
- [ ] 휴대폰 번호 입력 필드
- [ ] 휴대폰 형식 검증 (010-0000-0000)
- [ ] [OTP 받기] 버튼 클릭 → API 호출
- [ ] OTP 입력 필드로 전환
- [ ] 3분 타이머 표시
- [ ] 6자리 OTP 입력
- [ ] [확인] 버튼 클릭 → API 호출
- [ ] 토큰 저장 (SharedPreferences)
- [ ] 메인 화면으로 이동
- [ ] 에러 처리 (불일치, 만료, 레이트 리미팅)

### AC-5: 상태 관리
- [ ] AuthProvider로 로그인 상태 관리
- [ ] JWT 토큰 저장 (SharedPreferences)
- [ ] 앱 재시작 후에도 토큰 유지
- [ ] 토큰을 API 요청 헤더에 자동 추가
- [ ] 로그아웃 시 토큰 삭제

---

## 📁 파일 구조

```
lib/modules/auth/
├── screens/
│   ├── splash_screen.dart          ✅ (수정)
│   ├── onboarding_screen.dart      ✅ (수정)
│   ├── social_login_screen.dart    ✅ (수정)
│   └── phone_otp_screen.dart       ⏳ (새로 생성)
├── providers/
│   └── auth_provider.dart          ✅ (수정)
├── services/
│   ├── auth_service.dart           ✅ (수정)
│   └── social_login_service.dart   ✅ (수정)
├── models/
│   ├── user_model.dart             ✅ (수정)
│   ├── send_otp_response.dart      ⏳ (새로 생성)
│   └── verify_otp_response.dart    ⏳ (새로 생성)
└── auth_module.dart                ⏳ (export 파일)

lib/shared/
├── widgets/
│   └── ... (기존)
└── utils/
    └── api_client.dart             ✅ (수정)
```

---

## 📊 개발 일정

| 날짜 | 작업 | 예상 시간 | 상태 |
|------|------|---------|------|
| 2/22 | 스플래시 + 온보딩 수정 | 2h | ⏳ |
| 2/22 | 로그인 화면 수정 | 1h | ⏳ |
| 2/23 | OTP 입력 화면 (새로 생성) | 3h | ⏳ |
| 2/24 | API 연동 테스트 | 2h | ⏳ |
| 2/25 | 에러 처리 + 개선 | 2h | ⏳ |
| **합계** | - | **10h** | - |

---

## 🧪 테스트 시나리오

### 테스트 케이스

1. **신규 사용자 흐름**
   - [ ] 스플래시 → 온보딩 → 로그인 → OTP → 메인
   - [ ] 각 화면 전환 정상

2. **로그인 성공**
   - [ ] 휴대폰 번호 입력
   - [ ] OTP 받기 (API 호출)
   - [ ] OTP 입력
   - [ ] 확인 (API 호출)
   - [ ] 토큰 저장
   - [ ] 메인 화면 진입

3. **로그인 실패**
   - [ ] 휴대폰 형식 오류
   - [ ] OTP 불일치
   - [ ] OTP 만료
   - [ ] 레이트 리미팅

4. **기존 사용자 흐름**
   - [ ] 스플래시 → 토큰 확인 → 메인 화면

5. **앱 재시작**
   - [ ] 로그인 → 토큰 저장
   - [ ] 앱 재시작
   - [ ] 토큰 로드 → 메인 화면 (로그인 화면 건너뜀)

---

## 📞 FAQ

### Q1: 카카오 로그인 후 휴대폰을 묻는 이유?
**A**: 백엔드가 휴대폰을 필수 정보로 요구. 카카오에서 휴대폰을 받을 수 없으므로 별도 입력 필요.

### Q2: SharedPreferences는 안전한가?
**A**: 로컬 기기에만 저장되므로 안전. 프로덕션에서는 더 안전한 저장소(Keychain/Keystore) 사용 권장.

### Q3: 토큰 만료 시 refresh token은?
**A**: Phase F-2 이후에 구현. 현재는 단순 access token만 사용.

### Q4: 에러 처리는 어떻게?
**A**: 각 API 응답의 상태 코드 확인. 400, 401, 429 등에 따라 다른 메시지 표시.

---

**작성자**: 기획팀
**작성일**: 2026-02-15
**버전**: 1.0.0
**상태**: 개발 준비 완료
