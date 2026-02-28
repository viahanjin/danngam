import 'dart:convert';
import '../../../shared/utils/api_client.dart';
import '../../../shared/utils/logger.dart';
import '../models/user_model.dart';

/// Auth Service - Handles authentication API calls
class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Send OTP to phone number
  Future<OtpResponseModel> sendOtp(String phoneNumber) async {
    try {
      AppLogger.info(
        'Sending OTP to $phoneNumber',
        tag: 'AuthService',
      );

      // Mock mode for development
      AppLogger.info(
        'Mock OTP: 123456 (expires in 300 seconds)',
        tag: 'AuthService',
      );

      return OtpResponseModel(
        message: 'OTP 발송됨. 테스트 코드: 123456',
        expiresIn: 300,
      );

      // Production API call
      // final response = await _apiClient.post(
      //   '/auth/send-otp',
      //   body: {
      //     'phone_number': phoneNumber,
      //   },
      // );
      //
      // if (response.statusCode == 200) {
      //   final json = _parseJson(response.body);
      //   return OtpResponseModel.fromJson(json);
      // } else {
      //   throw Exception('Failed to send OTP: ${response.body}');
      // }
    } catch (e) {
      AppLogger.error(
        'Error sending OTP: $e',
        tag: 'AuthService',
      );
      rethrow;
    }
  }

  /// Verify OTP and login
  Future<AuthResponseModel> verifyOtp(
    String phoneNumber,
    String otp,
  ) async {
    try {
      AppLogger.info(
        'Verifying OTP for $phoneNumber',
        tag: 'AuthService',
      );

      // Mock mode for development - accept "123456" as valid OTP
      if (otp == '123456') {
        AppLogger.info(
          'Mock OTP verification successful',
          tag: 'AuthService',
        );

        final mockUser = UserModel(
          id: 'test_user_1',
          name: '테스트 사용자',
          phone: phoneNumber,
          email: 'test@danngam.com',
          rating: 4.5,
          reviewCount: 10,
        );

        final authResponse = AuthResponseModel(
          accessToken: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
          tokenType: 'bearer',
          expiresIn: 86400,
          user: mockUser,
        );

        // Store access token
        _apiClient.setAccessToken(authResponse.accessToken);

        return authResponse;
      }

      throw Exception('Invalid OTP. Use 123456 for testing.');

      // Production API call
      // final response = await _apiClient.post(
      //   '/auth/verify-otp',
      //   body: {
      //     'phone_number': phoneNumber,
      //     'otp': otp,
      //   },
      // );
      //
      // if (response.statusCode == 200) {
      //   final json = _parseJson(response.body);
      //   final authResponse = AuthResponseModel.fromJson(json);
      //
      //   // Store access token
      //   _apiClient.setAccessToken(authResponse.accessToken);
      //
      //   return authResponse;
      // } else {
      //   throw Exception('Failed to verify OTP: ${response.body}');
      // }
    } catch (e) {
      AppLogger.error(
        'Error verifying OTP: $e',
        tag: 'AuthService',
      );
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      AppLogger.info(
        'Logging out',
        tag: 'AuthService',
      );

      await _apiClient.post('/auth/logout');

      // Clear access token
      _apiClient.clearAccessToken();
    } catch (e) {
      AppLogger.error(
        'Error logging out: $e',
        tag: 'AuthService',
      );
      rethrow;
    }
  }

  /// Helper method to parse JSON response
  Map<String, dynamic> _parseJson(String body) {
    try {
      if (body.isEmpty) {
        return {};
      }
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error(
        'Error parsing JSON: $e',
        tag: 'AuthService',
      );
      throw Exception('Invalid JSON response');
    }
  }
}

/// Singleton instance
final authService = AuthService();
