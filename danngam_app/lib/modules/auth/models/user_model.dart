/// User Model - 소셜 로그인 지원
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final double rating;
  final int reviewCount;

  // Social Login
  final String? loginProvider; // 'google', 'kakao', 'apple'
  final String? accessToken;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    required this.rating,
    required this.reviewCount,
    this.loginProvider,
    this.accessToken,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phone_number'] ?? '',
      profileImageUrl: json['profile_image_url'] ?? json['profile_image'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      loginProvider: json['login_provider'],
      accessToken: json['access_token'],
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'login_provider': loginProvider,
      'access_token': accessToken,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with method
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    double? rating,
    int? reviewCount,
    String? loginProvider,
    String? accessToken,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      loginProvider: loginProvider ?? this.loginProvider,
      accessToken: accessToken ?? this.accessToken,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Auth Response Model
class AuthResponseModel {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final UserModel user;

  AuthResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  /// Create from JSON
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: json['expires_in'] ?? 3600,
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'user': user.toJson(),
    };
  }
}

/// OTP Response Model
class OtpResponseModel {
  final String message;
  final int expiresIn;

  OtpResponseModel({
    required this.message,
    required this.expiresIn,
  });

  /// Create from JSON
  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      message: json['message'] ?? '',
      expiresIn: json['expires_in'] ?? 300,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'expires_in': expiresIn,
    };
  }
}
