import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/services/auth_service.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() : _authService = AuthService.instance {
    _initializeAuth();
  }

  final AuthService _authService;

  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;

  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userData => _userData;

  Future<void> _initializeAuth() async {
    _isInitializing = true;
    try {
      final hasToken = await _authService.isAuthenticated();
      if (hasToken) {
        // Try to get user profile to verify token
        try {
          final userRepo = UserRepository.instance;
          final user = await userRepo.getProfile();
          _isAuthenticated = true;
          _userData = user.toJson();
        } catch (e) {
          // Token might be invalid, clear it
          await _authService.logout();
          _isAuthenticated = false;
          _userData = null;
        }
      } else {
        _isAuthenticated = false;
        _userData = null;
      }
    } catch (e) {
      _isAuthenticated = false;
      _userData = null;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(email, password);
      // Backend returns { success: true, user: {...}, token: "..." }
      if (response['success'] == true && response['user'] != null) {
        _userData = response['user'];
        _isAuthenticated = true;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      // Extract clean error message
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      _setError(errorMsg);
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Login using Google ID token (obtained from google_sign_in).
  Future<bool> loginWithGoogle(String idToken) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.loginWithGoogle(idToken);
      _userData = response['user'] ?? response;
      _isAuthenticated = true;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  UserModel? get userModel {
    if (_userData == null) return null;
    try {
      return UserModel.fromJson(_userData!);
    } catch (e) {
      return null;
    }
  }

  String? get currentUserId => userModel?.id;


  Future<bool> register({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // API call
      final response = await _authService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      if (response == null || response['success'] != true) {
        throw Exception(response?['message'] ?? "Registration failed");
      }

      // Save user & token
      _userData = response['user'];
      _isAuthenticated = true;

      // Notify listeners
      _setLoading(false);
      notifyListeners();

      return true;
    } catch (e) {
      // Extract clean error message
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      _setError(errorMsg);
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }


  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.logout();
      _isAuthenticated = false;
      _userData = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
    }
  }



  Future<void> refreshUser() async {
    try {
      final userRepo = UserRepository.instance;
      final user = await userRepo.getProfile();
      _userData = user.toJson();
      notifyListeners();
    } catch (e) {
      // Silently fail - user data might still be valid
    }
  }


  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String? value) {
    _error = value;
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

}