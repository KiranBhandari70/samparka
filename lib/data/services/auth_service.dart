import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import 'storage_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();
  final _apiClient = ApiClient.instance;
  final _storageService = StorageService.instance;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = _apiClient.parseResponse(response);
        if (data != null) {
          // Store token if provided
          if (data['token'] != null) {
            await _storageService.saveToken(data['token'] as String);
          }
          return data;
        }
        throw Exception('Invalid response format');
      }

      throw Exception('Login failed: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  /// Login or register via Google OAuth.
  /// [idToken] is the Google ID token obtained from the client.
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.googleLogin,
        body: {
          'tokenId': idToken,
        },
      );

      if (response.statusCode == 200) {
        final data = _apiClient.parseResponse(response);
        if (data != null) {
          if (data['token'] != null) {
            await _storageService.saveToken(data['token'] as String);
          }
          return data;
        }
        throw Exception('Invalid response format');
      }

      throw Exception('Google login failed: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error during Google login: $e');
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        body: {
          'email': email,
          'password': password,
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _apiClient.parseResponse(response);
        if (data != null) {
          // Store token if provided
          if (data['token'] != null) {
            await _storageService.saveToken(data['token'] as String);
          }
          return data;
        }
        throw Exception('Invalid response format');
      }

      throw Exception('Registration failed: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
      // Clear stored token
      await _storageService.clearToken();
    } catch (e) {
      // Even if API call fails, clear local token
      await _storageService.clearToken();
      throw Exception('Error during logout: $e');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotPassword,
        body: {'email': email},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send reset email: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending reset email: $e');
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        body: {
          'token': token,
          'password': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to reset password: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error resetting password: $e');
    }
  }

  Future<void> verifyEmail(String token) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyEmail,
        body: {'token': token},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to verify email: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error verifying email: $e');
    }
  }

  Future<String?> refreshToken() async {
    try {
      final response = await _apiClient.post(ApiEndpoints.refreshToken);

      if (response.statusCode == 200) {
        final data = _apiClient.parseResponse(response);
        final token = data?['token'] as String?;
        if (token != null) {
          await _storageService.saveToken(token);
        }
        return token;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    // Check if token exists in storage
    return await _storageService.hasToken();
  }
}
