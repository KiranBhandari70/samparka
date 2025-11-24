import 'package:flutter/foundation.dart';

import '../data/models/user_model.dart';
import '../data/services/profile_service.dart';

class UserProvider extends ChangeNotifier {
  UserProvider() : _profileService = ProfileService.instance;

  final ProfileService _profileService;

  bool _isLoading = false;
  String? _error;
  UserModel? _currentUser;
  List<UserModel> _registeredUsers = [];
  bool _registeredUsersLoading = false;
  String? _registeredUsersError;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;
  List<UserModel> get registeredUsers => _registeredUsers;
  bool get registeredUsersLoading => _registeredUsersLoading;
  String? get registeredUsersError => _registeredUsersError;

  Future<void> loadProfile() async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _profileService.getProfile();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _profileService.updateProfile(userData);
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

  Future<bool> uploadAvatar(String imagePath) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _profileService.uploadAvatar(imagePath);
      _currentUser = updatedUser;
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

  Future<bool> updateInterests(List<String> interests) async {
    _setLoading(true);
    _clearError();

    try {
      await _profileService.updateInterests(interests);
      if (_currentUser != null) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          passwordHash: _currentUser!.passwordHash,
          authProvider: _currentUser!.authProvider,
          age: _currentUser!.age,
          interests: interests,
          bio: _currentUser!.bio,
          avatarUrl: _currentUser!.avatarUrl,
          locationLabel: _currentUser!.locationLabel,
          location: _currentUser!.location,
          role: _currentUser!.role,
          verificationStatus: _currentUser!.verificationStatus,
          verified: _currentUser!.verified,
          rewardBalance: _currentUser!.rewardBalance,
          blocked: _currentUser!.blocked,
          businessProfile: _currentUser!.businessProfile,
          createdAt: _currentUser!.createdAt,
          updatedAt: _currentUser!.updatedAt,
        );
      }
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

  Future<void> loadRegisteredUsers({int limit = 10}) async {
    _registeredUsersLoading = true;
    _registeredUsersError = null;
    notifyListeners();

    try {
      _registeredUsers =
          await _profileService.getRegisteredUsers(limit: limit);
    } catch (e) {
      _registeredUsersError = e.toString();
    } finally {
      _registeredUsersLoading = false;
      notifyListeners();
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
