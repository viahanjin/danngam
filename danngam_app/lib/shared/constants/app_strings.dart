/// Application String Constants
/// All static strings used in the app
class AppStrings {
  AppStrings._();

  // App Name
  static const String appName = 'Danngam';

  // Splash Screen
  static const String splashTitle = 'Danngam';
  static const String splashSubtitle = '움직이는 장비, 가까이 구하다';

  // Onboarding Screen
  static const String onboardingTitle1 = '다양한 장비를 쉽게 찾아보세요';
  static const String onboardingDesc1 = '이동형, 고정형 장비를 한곳에서 검색하고 비교하세요';
  static const String onboardingImage1 = 'assets/images/onboarding_1.png';

  static const String onboardingTitle2 = '가까운 곳에서 빌리세요';
  static const String onboardingDesc2 = '위치 기반으로 가장 가까운 장비를 찾아보세요';
  static const String onboardingImage2 = 'assets/images/onboarding_2.png';

  static const String onboardingTitle3 = '안전하게 예약하세요';
  static const String onboardingDesc3 = '신뢰할 수 있는 결제 시스템으로 안전하게 예약하세요';
  static const String onboardingImage3 = 'assets/images/onboarding_3.png';

  static const String getStarted = '시작하기';
  static const String skip = '건너뛰기';
  static const String next = '다음';

  // Login Screen
  static const String loginTitle = '전화번호로 로그인';
  static const String loginDesc = '계정이 없으면 자동으로 가입됩니다';
  static const String phoneNumber = '전화번호';
  static const String enterPhoneNumber = '010-1234-5678';
  static const String sendOtp = 'OTP 발송';
  static const String otp = 'OTP';
  static const String enterOtp = '인증번호 입력';
  static const String login = '로그인';
  static const String resendOtp = 'OTP 재발송';
  static const String otpExpiration = '5분 이내 인증해주세요';

  // Main Screen
  static const String mainTitle = 'Danngam';
  static const String mobile = '이동형';
  static const String fixed = '고정형';
  static const String search = '장비 검색';
  static const String filter = '필터';
  static const String sort = '정렬';
  static const String nearestDistance = '가장 가까운';
  static const String lowestPrice = '가장 저렴한';
  static const String highestRating = '평점높은순';
  static const String equipment = '장비';
  static const String price = '가격';
  static const String rating = '평점';
  static const String distance = '거리';

  // Equipment Card
  static const String viewDetails = '상세보기';
  static const String book = '예약하기';
  static const String perDay = '/일';
  static const String km = 'km';

  // Common
  static const String ok = '확인';
  static const String cancel = '취소';
  static const String save = '저장';
  static const String delete = '삭제';
  static const String edit = '수정';
  static const String loading = '로딩 중...';
  static const String error = '오류가 발생했습니다';
  static const String tryAgain = '다시 시도';
  static const String noResults = '검색 결과가 없습니다';
  static const String empty = '비어있습니다';

  // Error Messages
  static const String invalidPhoneNumber = '올바른 전화번호를 입력해주세요';
  static const String invalidOtp = '올바른 인증번호를 입력해주세요';
  static const String otpExpired = '인증번호가 만료되었습니다';
  static const String networkError = '네트워크 연결을 확인해주세요';
  static const String serverError = '서버 오류가 발생했습니다';
  static const String unexpectedError = '예기치 않은 오류가 발생했습니다';

  // Success Messages
  static const String otpSent = '인증번호를 발송했습니다';
  static const String loginSuccess = '로그인 성공';
  static const String logoutSuccess = '로그아웃 했습니다';
}
