import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/services/profile_service.dart';

class UserProvider extends ChangeNotifier {
  UserProvider() : _profileService = ProfileService.instance;

  final ProfileService _profileService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  List<UserModel> _registeredUsers = [];
  bool _registeredUsersLoading = false;
  String? _registeredUsersError;

  List<String> _selectedInterests = [];

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get selectedInterests => _currentUser?.interests ?? _selectedInterests;
  List<UserModel> get registeredUsers => _registeredUsers;
  bool get registeredUsersLoading => _registeredUsersLoading;
  String? get registeredUsersError => _registeredUsersError;

  // Load user profile
  Future<void> loadProfile() async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _profileService.getProfile();
      _selectedInterests = _currentUser?.interests ?? [];
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Update profile
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _profileService.updateProfile(userData);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Upload avatar
  Future<bool> uploadAvatar(String imagePath) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _profileService.uploadAvatar(imagePath);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update interests
  Future<bool> updateInterests(List<String> interests) async {
    _setLoading(true);
    _clearError();

    try {
      // Update in service
      await _profileService.updateInterests(interests);

      // Update locally
      _selectedInterests = interests;
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(interests: interests);
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load registered users
  Future<void> loadRegisteredUsers({int limit = 10}) async {
    _registeredUsersLoading = true;
    _registeredUsersError = null;
    notifyListeners();

    try {
      _registeredUsers = await _profileService.getRegisteredUsers(limit: limit);
    } catch (e) {
      _registeredUsersError = e.toString();
    } finally {
      _registeredUsersLoading = false;
      notifyListeners();
    }
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
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

  Future<bool> submitVerification({
    required String phoneNumber,
    required String citizenshipFrontPath,
    required String citizenshipBackPath,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _profileService.submitVerification(
        phoneNumber: phoneNumber,
        citizenshipFrontPath: citizenshipFrontPath,
        citizenshipBackPath: citizenshipBackPath,
      );

      if (success) {
        // Refresh user profile to get updated verification status
        await loadProfile();
      }

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
}
