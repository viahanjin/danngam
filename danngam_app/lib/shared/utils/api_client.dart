import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config/app_config.dart';

/// API Client for handling HTTP requests
class ApiClient {
  final String baseUrl;
  String? _accessToken;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  /// Set access token for authenticated requests
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// Clear access token (logout)
  void clearAccessToken() {
    _accessToken = null;
  }

  /// Build headers with authentication
  Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  /// GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl${AppConfig.apiVersion}$endpoint');
      final uriWithParams = queryParameters != null
          ? uri.replace(queryParameters: queryParameters)
          : uri;

      final response = await http
          .get(
            uriWithParams,
            headers: _buildHeaders(),
          )
          .timeout(AppConfig.apiTimeout);

      _logResponse('GET', endpoint, response);
      return response;
    } catch (e) {
      _logError('GET', endpoint, e);
      rethrow;
    }
  }

  /// POST request
  Future<http.Response> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl${AppConfig.apiVersion}$endpoint');
      final uriWithParams = queryParameters != null
          ? uri.replace(queryParameters: queryParameters)
          : uri;

      final response = await http
          .post(
            uriWithParams,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConfig.apiTimeout);

      _logResponse('POST', endpoint, response);
      return response;
    } catch (e) {
      _logError('POST', endpoint, e);
      rethrow;
    }
  }

  /// PUT request
  Future<http.Response> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl${AppConfig.apiVersion}$endpoint');
      final uriWithParams = queryParameters != null
          ? uri.replace(queryParameters: queryParameters)
          : uri;

      final response = await http
          .put(
            uriWithParams,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConfig.apiTimeout);

      _logResponse('PUT', endpoint, response);
      return response;
    } catch (e) {
      _logError('PUT', endpoint, e);
      rethrow;
    }
  }

  /// PATCH request
  Future<http.Response> patch(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl${AppConfig.apiVersion}$endpoint');
      final uriWithParams = queryParameters != null
          ? uri.replace(queryParameters: queryParameters)
          : uri;

      final response = await http
          .patch(
            uriWithParams,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConfig.apiTimeout);

      _logResponse('PATCH', endpoint, response);
      return response;
    } catch (e) {
      _logError('PATCH', endpoint, e);
      rethrow;
    }
  }

  /// DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl${AppConfig.apiVersion}$endpoint');
      final uriWithParams = queryParameters != null
          ? uri.replace(queryParameters: queryParameters)
          : uri;

      final response = await http
          .delete(
            uriWithParams,
            headers: _buildHeaders(),
          )
          .timeout(AppConfig.apiTimeout);

      _logResponse('DELETE', endpoint, response);
      return response;
    } catch (e) {
      _logError('DELETE', endpoint, e);
      rethrow;
    }
  }

  /// Log response
  void _logResponse(String method, String endpoint, http.Response response) {
    if (!AppConfig.enableNetworkLogging) return;

    // ignore: avoid_print
    print('[$method] $endpoint');
    // ignore: avoid_print
    print('Status Code: ${response.statusCode}');
    if (response.body.isNotEmpty) {
      // ignore: avoid_print
      print('Response: ${response.body}');
    }
  }

  /// Log error
  void _logError(String method, String endpoint, Object error) {
    if (!AppConfig.enableLogging) return;

    // ignore: avoid_print
    print('[$method] $endpoint - Error: $error');
  }
}

/// Singleton instance
final apiClient = ApiClient();
