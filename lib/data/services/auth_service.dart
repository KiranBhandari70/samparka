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

      final data = _apiClient.parseResponse(response);

      if (response.statusCode == 200) {
        if (data != null && data['success'] == true) {
          // Store token if provided
          if (data['token'] != null) {
            await _storageService.saveToken(data['token'] as String);
          }
          return data;
        }
        throw Exception(data?['message'] ?? 'Invalid response format');
      }

      // Extract error message from response
      final errorMessage = data?['message'] ?? 'Login failed';
      throw Exception(errorMessage);
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
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

      final data = _apiClient.parseResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data != null && data['success'] == true) {
          // Store token if provided
          if (data['token'] != null) {
            await _storageService.saveToken(data['token'] as String);
          }
          return data;
        }
        throw Exception(data?['message'] ?? 'Invalid response format');
      }

      // Extract error message from response
      final errorMessage = data?['message'] ?? 'Registration failed';
      throw Exception(errorMessage);
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
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





  Future<bool> isAuthenticated() async {
    // Check if token exists in storage
    return await _storageService.hasToken();
  }
}
