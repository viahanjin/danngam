import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/social_login_service.dart';
import '../../../shared/utils/logger.dart';

/// Auth Provider - State management for authentication
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  late final SocialLoginService _socialLoginService;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _socialLoginService = SocialLoginService();
    _loadStoredToken();
  }

  // State variables
  UserModel? _user;
  String? _accessToken;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  int? _otpExpiresIn;

  // Getters
  UserModel? get user => _user;
  String? get accessToken => _accessToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  int? get otpExpiresIn => _otpExpiresIn;

  /// Send OTP to phone number
  Future<bool> sendOtp(String phoneNumber) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _authService.sendOtp(phoneNumber);
      _otpExpiresIn = response.expiresIn;

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Verify OTP and login
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _authService.verifyOtp(phoneNumber, otp);

      _accessToken = response.accessToken;
      _user = response.user;
      _isAuthenticated = true;

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Google Sign-In
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _socialLoginService.signInWithGoogle();
      if (user == null) {
        _setLoading(false);
        return false;
      }

      _user = user;
      _accessToken = user.accessToken;
      _isAuthenticated = true;

      // Store token locally
      await _saveToken(user.accessToken ?? '', 'google');

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Google 로그인 실패: $e');
      _setLoading(false);
      AppLogger.error('Google Sign-In error: $e', tag: 'AuthProvider');
      return false;
    }
  }

  /// Kakao Sign-In
  Future<bool> signInWithKakao() async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _socialLoginService.signInWithKakao();
      if (user == null) {
        _setLoading(false);
        return false;
      }

      _user = user;
      _accessToken = user.accessToken;
      _isAuthenticated = true;

      // Store token locally
      await _saveToken(user.accessToken ?? '', 'kakao');

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Kakao 로그인 실패: $e');
      _setLoading(false);
      AppLogger.error('Kakao Sign-In error: $e', tag: 'AuthProvider');
      return false;
    }
  }

  /// Apple Sign-In
  Future<bool> signInWithApple() async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _socialLoginService.signInWithApple();
      if (user == null) {
        _setLoading(false);
        return false;
      }

      _user = user;
      _accessToken = user.accessToken;
      _isAuthenticated = true;

      // Store token locally
      await _saveToken(user.accessToken ?? '', 'apple');

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Apple 로그인 실패: $e');
      _setLoading(false);
      AppLogger.error('Apple Sign-In error: $e', tag: 'AuthProvider');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      _setLoading(true);
      _clearError();

      // Sign out from social providers
      if (_user?.loginProvider == 'google') {
        await _socialLoginService.signOutGoogle();
      } else if (_user?.loginProvider == 'kakao') {
        await _socialLoginService.signOutKakao();
      }

      await _authService.logout();

      // Clear stored token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('login_provider');

      _accessToken = null;
      _user = null;
      _isAuthenticated = false;
      _otpExpiresIn = null;

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Set user manually (for testing or manual login)
  void setUser(UserModel user) {
    _user = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  /// Clear OTP expiration
  void clearOtpExpiration() {
    _otpExpiresIn = null;
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Save token to local storage
  Future<void> _saveToken(String token, String provider) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      await prefs.setString('login_provider', provider);
    } catch (e) {
      AppLogger.error('Failed to save token: $e', tag: 'AuthProvider');
    }
  }

  /// Load stored token from local storage
  Future<void> _loadStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null && token.isNotEmpty) {
        _accessToken = token;
        // You might want to validate the token with the backend
        AppLogger.info('Loaded stored token', tag: 'AuthProvider');
      }
    } catch (e) {
      AppLogger.error('Failed to load stored token: $e', tag: 'AuthProvider');
    }
  }
}
