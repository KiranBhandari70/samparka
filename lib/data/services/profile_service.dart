import '../models/user_model.dart';
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

  Future<String> uploadAvatar(String imagePath) async {
    return _repository.uploadAvatar(imagePath);
  }

  Future<void> updateInterests(List<String> interests) async {
    return _repository.updateInterests(interests);
  }
}
