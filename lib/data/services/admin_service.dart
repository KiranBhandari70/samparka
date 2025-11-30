import 'dart:convert';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../models/event_model.dart';

class AdminService {
  AdminService._();

  static final AdminService instance = AdminService._();
  final ApiClient _apiClient = ApiClient.instance;

  /// Fetch all users (admin only).
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await _apiClient.get(ApiEndpoints.adminUsers);

    if (response.statusCode != 200) {
      throw Exception('Failed to load users: ${response.statusCode}');
    }

    final data = _apiClient.parseResponse(response);
    final users = data?['users'] as List<dynamic>? ?? [];
    return users.cast<Map<String, dynamic>>();
  }

  /// Block or unblock a user.
  Future<void> setUserBlocked(String userId, bool blocked) async {
    final response = await _apiClient.patch(
      ApiEndpoints.adminBlockUser(userId),
      bodyObject: jsonEncode({'blocked': blocked}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user status: ${response.statusCode}');
    }
  }

  /// Fetch all events (admin can just call the public events endpoint).
  Future<List<EventModel>> getAllEvents() async {
    final response = await _apiClient.get('/api/v1/events');

    if (response.statusCode != 200) {
      throw Exception('Failed to load events: ${response.statusCode}');
    }

    final data = _apiClient.parseResponse(response);
    final events = data?['events'] as List<dynamic>? ?? [];
    return events
        .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get pending verification requests
  Future<List<Map<String, dynamic>>> getPendingVerifications() async {
    final response = await _apiClient.get(ApiEndpoints.adminPendingVerifications);

    if (response.statusCode != 200) {
      throw Exception('Failed to load verification requests: ${response.statusCode}');
    }

    final data = _apiClient.parseResponse(response);
    final users = data?['users'] as List<dynamic>? ?? [];
    return users.cast<Map<String, dynamic>>();
  }

  /// Review verification (approve or reject)
  Future<void> reviewVerification(String userId, String action, {String? rejectionReason}) async {
    final response = await _apiClient.patch(
      ApiEndpoints.adminReviewVerification(userId),
      body: {
        'action': action,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
      },
    );

    if (response.statusCode != 200) {
      final errorData = _apiClient.parseResponse(response);
      final errorMessage = errorData?['message'] as String?;
      throw Exception(errorMessage ?? 'Failed to review verification: ${response.statusCode}');
    }
  }
}


