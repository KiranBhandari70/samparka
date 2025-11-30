import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/environment.dart';
import '../models/reward_transaction_model.dart';

class RewardService {
  static RewardService? _instance;
  static RewardService get instance => _instance ??= RewardService._();
  RewardService._();

  final String _baseUrl = Environment.apiBaseUrl;

  // Get reward dashboard data for a user
  Future<RewardDashboardData> getRewardDashboard(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/rewards/dashboard/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return RewardDashboardData.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch reward dashboard');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch reward dashboard: $e');
    }
  }

  // Get reward history for a user with pagination
  Future<List<RewardTransaction>> getRewardHistory(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/rewards/history/$userId?limit=$limit&offset=$offset'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List<dynamic>)
              .map((item) => RewardTransaction.fromJson(item))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch reward history');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch reward history: $e');
    }
  }

  // Redeem reward points
  Future<Map<String, dynamic>> redeemRewardPoints({
    required String userId,
    required int amount,
    required String partnerName,
    required String offerDescription,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/rewards/redeem'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
          'partnerName': partnerName,
          'offerDescription': offerDescription,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Failed to redeem points');
        }
      } else {
        throw Exception(data['message'] ?? 'Failed to redeem points');
      }
    } catch (e) {
      throw Exception('Failed to redeem points: $e');
    }
  }

  // Calculate reward points for a given amount (0.5%)
  static int calculateRewardPoints(double amount) {
    return (amount * 0.005).floor(); // 0.5% rounded down
  }
}
