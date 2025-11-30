import 'package:http/http.dart' as apiClient;

import '../models/user_model.dart';
import '../network/api_endpoints.dart';
import '../repositories/user_repository.dart';

class ProfileService {
  ProfileService._();

  static final ProfileService instance = ProfileService._();
  final _repository = UserRepository.instance;

  Future<UserModel> getProfile() async {
    return _repository.getProfile();
  }

  Future<UserModel> updateProfile(Map<String, dynamic> userData) async {
    return _repository.updateProfile(userData);
  }

  Future<UserModel> uploadAvatar(String imagePath) async {
    return _repository.uploadAvatar(imagePath);
  }

  Future<void> updateInterests(List<String> interests) async {
    return _repository.updateInterests(interests);
  }

  Future<List<UserModel>> getRegisteredUsers({int limit = 10}) {
    return _repository.getRegisteredUsers(limit: limit);
  }

  Future<bool> submitVerification({
    required String phoneNumber,
    required String citizenshipFrontPath,
    required String citizenshipBackPath,
  }) async {
    return _repository.submitVerification(
      phoneNumber: phoneNumber,
      citizenshipFrontPath: citizenshipFrontPath,
      citizenshipBackPath: citizenshipBackPath,
    );
  }
}
