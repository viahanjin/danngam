import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../models/user_model.dart';
import '../../../shared/utils/logger.dart';

/// Social Login Service - Handles Google, Kakao, Apple authentication
class SocialLoginService {
  late GoogleSignIn _googleSignIn;

  SocialLoginService() {
    _initializeServices();
  }

  void _initializeServices() {
    // Google Sign-In
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile',
      ],
    );

    // Kakao SDK is initialized in main.dart
  }

  /// Google Sign-In
  Future<UserModel?> signInWithGoogle() async {
    try {
      AppLogger.info('Starting Google Sign-In', tag: 'SocialLoginService');

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        AppLogger.info('Google Sign-In cancelled by user', tag: 'SocialLoginService');
        return null;
      }

      final googleAuth = await googleUser.authentication;

      final user = UserModel(
        id: googleUser.id,
        name: googleUser.displayName ?? 'Google User',
        email: googleUser.email,
        phone: '',
        profileImageUrl: googleUser.photoUrl,
        rating: 0,
        reviewCount: 0,
        loginProvider: 'google',
        accessToken: googleAuth.accessToken,
      );

      AppLogger.info('Google Sign-In successful: ${user.email}', tag: 'SocialLoginService');
      return user;
    } catch (e) {
      AppLogger.error('Google Sign-In error: $e', tag: 'SocialLoginService');
      rethrow;
    }
  }

  /// Kakao Sign-In
  Future<UserModel?> signInWithKakao() async {
    try {
      AppLogger.info('Starting Kakao Sign-In', tag: 'SocialLoginService');

      OAuthToken? token;

      // Try KakaoTalk first, fallback to KakaoAccount
      try {
        token = await UserApi.instance.loginWithKakaoTalk();
      } catch (e) {
        AppLogger.info('KakaoTalk not installed, using KakaoAccount', tag: 'SocialLoginService');
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      AppLogger.info('Kakao token acquired', tag: 'SocialLoginService');

      // Get user info
      User kakaoUser = await UserApi.instance.me();

      final user = UserModel(
        id: kakaoUser.id.toString(),
        name: kakaoUser.kakaoAccount?.profile?.nickname ?? 'Kakao User',
        email: kakaoUser.kakaoAccount?.email ?? '',
        phone: '',
        profileImageUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
        rating: 0,
        reviewCount: 0,
        loginProvider: 'kakao',
        accessToken: token?.accessToken ?? '',
      );

      AppLogger.info('Kakao Sign-In successful: ${user.email}', tag: 'SocialLoginService');
      return user;
    } catch (e) {
      AppLogger.error('Kakao Sign-In error: $e', tag: 'SocialLoginService');
      rethrow;
    }
  }

  /// Apple Sign-In
  Future<UserModel?> signInWithApple() async {
    try {
      AppLogger.info('Starting Apple Sign-In', tag: 'SocialLoginService');

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [],
      );

      final accessToken = credential.identityToken;
      final tokenString = accessToken != null
          ? (accessToken is String ? accessToken : String.fromCharCodes(accessToken as List<int>))
          : '';

      final user = UserModel(
        id: credential.userIdentifier ?? '',
        name: _getFullName(credential),
        email: credential.email ?? '',
        phone: '',
        profileImageUrl: null,
        rating: 0,
        reviewCount: 0,
        loginProvider: 'apple',
        accessToken: tokenString,
      );

      AppLogger.info('Apple Sign-In successful: ${user.email}', tag: 'SocialLoginService');
      return user;
    } catch (e) {
      AppLogger.error('Apple Sign-In error: $e', tag: 'SocialLoginService');
      rethrow;
    }
  }

  /// Helper: Get full name from Apple credentials
  String _getFullName(AuthorizationCredentialAppleID credential) {
    if (credential.givenName != null && credential.familyName != null) {
      return '${credential.givenName} ${credential.familyName}'.trim();
    }
    if (credential.givenName != null) {
      return credential.givenName!;
    }
    return 'Apple User';
  }

  /// Google Sign-Out
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      AppLogger.info('Google Sign-Out successful', tag: 'SocialLoginService');
    } catch (e) {
      AppLogger.error('Google Sign-Out error: $e', tag: 'SocialLoginService');
      rethrow;
    }
  }

  /// Kakao Sign-Out (Logout)
  Future<void> signOutKakao() async {
    try {
      await UserApi.instance.logout();
      AppLogger.info('Kakao Sign-Out successful', tag: 'SocialLoginService');
    } catch (e) {
      AppLogger.error('Kakao Sign-Out error: $e', tag: 'SocialLoginService');
      rethrow;
    }
  }

  /// Kakao Unlink (계정 연결 해제)
  Future<void> unlinkKakao() async {
    try {
      await UserApi.instance.unlink();
      AppLogger.info('Kakao Unlink successful', tag: 'SocialLoginService');
    } catch (e) {
      AppLogger.error('Kakao Unlink error: $e', tag: 'SocialLoginService');
      rethrow;
    }
  }

  /// Get current Google user
  GoogleSignInAccount? getCurrentGoogleUser() {
    return _googleSignIn.currentUser;
  }

  /// Check if user is signed in with Google
  Future<bool> isGoogleSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}
