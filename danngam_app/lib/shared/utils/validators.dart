/// Validators for form inputs
class Validators {
  Validators._();

  /// Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '전화번호를 입력해주세요';
    }

    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 10) {
      return '올바른 전화번호를 입력해주세요';
    }

    if (digitsOnly.length > 15) {
      return '올바른 전화번호를 입력해주세요';
    }

    return null;
  }

  /// Validate OTP (6 digits)
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return '인증번호를 입력해주세요';
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length != 6) {
      return '6자리 숫자를 입력해주세요';
    }

    return null;
  }

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailRegex.hasMatch(value)) {
      return '올바른 이메일을 입력해주세요';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }

    if (value.length < 8) {
      return '비밀번호는 최소 8자 이상이어야 합니다';
    }

    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
      return '비밀번호에 영문자가 포함되어야 합니다';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return '비밀번호에 숫자가 포함되어야 합니다';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, {String fieldName = '필드'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(
    String? value,
    int minLength, {
    String fieldName = '필드',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }

    if (value.length < minLength) {
      return '$fieldName은 최소 $minLength자 이상이어야 합니다';
    }

    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String fieldName = '필드',
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      return '$fieldName은 최대 $maxLength자 이하여야 합니다';
    }

    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL을 입력해주세요';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return '올바른 URL을 입력해주세요';
    }

    return null;
  }

  /// Validate number
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '숫자를 입력해주세요';
    }

    if (double.tryParse(value) == null) {
      return '올바른 숫자를 입력해주세요';
    }

    return null;
  }

  /// Validate credit card
  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return '신용카드 번호를 입력해주세요';
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 13 || digitsOnly.length > 19) {
      return '올바른 신용카드 번호를 입력해주세요';
    }

    return null;
  }
}
