import 'dart:io';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';

class UserRepository {
  UserRepository._();

  static final UserRepository instance = UserRepository._();
  final _apiClient = ApiClient.instance;

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);

      if (response.statusCode == 200) {
        final data = _apiClient.parseResponse(response);
        // Backend returns { success: true, user: {...} }
        final userData = data?['user'] as Map<String, dynamic>? ?? data ?? {};
        return UserModel.fromJson(userData);
      }

      throw Exception('Failed to load profile: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.updateProfile,
        body: userData,
      );

      if (response.statusCode == 200) {
        final data = _apiClient.parseResponse(response);
        // Backend returns { success: true, user: {...} }
        final userData = data?['user'] ?? data;
        return UserModel.fromJson(userData as Map<String, dynamic>);
      }

      throw Exception('Failed to update profile: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  Future<UserModel> uploadAvatar(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Selected image does not exist.');
      }

      final response = await _apiClient.postMultipart(
        ApiEndpoints.uploadAvatar,
        file: file,
        fileFieldName: 'avatar',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _apiClient.parseResponse(response);
        final userJson = data?['user'] as Map<String, dynamic>?;

        if (userJson != null) {
          return UserModel.fromJson(userJson);
        }

        // Fallback: fetch the latest profile if user data was not returned
        return await getProfile();
      }

      throw Exception('Failed to upload avatar: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error uploading avatar: $e');
    }
  }

  Future<void> updateInterests(List<String> interests) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.interests,
        body: {'interests': interests},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update interests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating interests: $e');
    }
  }

  Future<List<UserModel>> getRegisteredUsers({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.registeredUsers}?limit=$limit',
      );

      if (response.statusCode == 200) {
        final data = _apiClient.parseResponse(response);
        final users = data?['users'] as List<dynamic>? ?? [];
        return users
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to load registered users: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching registered users: $e');
    }
  }

  Future<List<EventModel>> getUserEvents(String userId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userEvents(userId));

      if (response.statusCode == 200) {
        final responseData = _apiClient.parseResponse(response);
        // Backend returns { success: true, events: [...] }
        final data = responseData?['events'] as List<dynamic>? ?? 
                     _apiClient.parseListResponse(response) ?? [];
        return data.map((json) => EventModel.fromJson(json as Map<String, dynamic>)).toList();
      }

      throw Exception('Failed to load user events: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching user events: $e');
    }
  }
}
