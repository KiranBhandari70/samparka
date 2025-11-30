import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/environment.dart';
import '../models/offer_model.dart';
import '../network/api_client.dart';

class OfferService {
  static OfferService? _instance;
  static OfferService get instance => _instance ??= OfferService._();
  OfferService._();

  final String _baseUrl = Environment.apiBaseUrl;
  final ApiClient _apiClient = ApiClient.instance;

  // Get all active offers
  Future<List<OfferModel>> getAllOffers({
    String? category,
    int? minPoints,
    int? maxPoints,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (category != null && category != 'all') queryParams['category'] = category;
      if (minPoints != null) queryParams['minPoints'] = minPoints.toString();
      if (maxPoints != null) queryParams['maxPoints'] = maxPoints.toString();

      final uri = Uri.parse('$_baseUrl/api/v1/offers').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List<dynamic>).map((item) => OfferModel.fromJson(item)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch offers');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch offers: $e');
    }
  }

  // Get offers by business
  Future<List<OfferModel>> getBusinessOffers(String businessId, {bool includeInactive = false}) async {
    try {
      final queryParams = includeInactive ? {'includeInactive': 'true'} : null;
      final uri = Uri.parse('$_baseUrl/api/v1/offers/business/$businessId')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List<dynamic>).map((item) => OfferModel.fromJson(item)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch business offers');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch business offers: $e');
    }
  }

  // Create a new offer (FIXED)
  Future<OfferModel> createOffer({
    required String userId,
    required String title,
    required String description,
    required String businessName,
    required String category,
    required String discountType,
    required double discountValue,
    required int pointsRequired,
    required DateTime validUntil,
    File? imageFile,
    String? termsAndConditions,
    int? maxRedemptions,
    Map<String, dynamic>? location,
    Map<String, dynamic>? contactInfo,
  }) async {
    try {
      final fields = {
        'userId': userId,
        'title': title,
        'description': description,
        'businessName': businessName,
        'category': category,
        'discountType': discountType,
        'discountValue': discountValue.toString(),
        'pointsRequired': pointsRequired.toString(),
        'validUntil': validUntil.toIso8601String(),
      };

      if (termsAndConditions != null) fields['termsAndConditions'] = termsAndConditions;
      if (maxRedemptions != null) fields['maxRedemptions'] = maxRedemptions.toString();
      if (location != null) fields['location'] = jsonEncode(location);
      if (contactInfo != null) fields['contactInfo'] = jsonEncode(contactInfo);

      final response = await _apiClient.postMultipart(
        '/api/v1/offers',
        fields: fields,
        file: imageFile,
        fileFieldName: 'image',
      );

      final status = response.statusCode;

      if (status < 200 || status >= 300) {
        throw Exception("Server returned HTTP $status: ${response.body}");
      }

      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        return OfferModel.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to create offer');
      }
    } catch (e) {
      throw Exception('Failed to create offer: $e');
    }
  }

  // Update an offer (FIXED)
  Future<OfferModel> updateOffer({
    required String offerId,
    required String userId,
    String? title,
    String? description,
    String? businessName,
    String? category,
    String? discountType,
    double? discountValue,
    int? pointsRequired,
    DateTime? validUntil,
    File? imageFile,
    String? termsAndConditions,
    int? maxRedemptions,
    bool? isActive,
    Map<String, dynamic>? location,
    Map<String, dynamic>? contactInfo,
  }) async {
    try {
      final fields = {'userId': userId};

      if (title != null) fields['title'] = title;
      if (description != null) fields['description'] = description;
      if (businessName != null) fields['businessName'] = businessName;
      if (category != null) fields['category'] = category;
      if (discountType != null) fields['discountType'] = discountType;
      if (discountValue != null) fields['discountValue'] = discountValue.toString();
      if (pointsRequired != null) fields['pointsRequired'] = pointsRequired.toString();
      if (validUntil != null) fields['validUntil'] = validUntil.toIso8601String();
      if (termsAndConditions != null) fields['termsAndConditions'] = termsAndConditions;
      if (maxRedemptions != null) fields['maxRedemptions'] = maxRedemptions.toString();
      if (isActive != null) fields['isActive'] = isActive.toString();
      if (location != null) fields['location'] = jsonEncode(location);
      if (contactInfo != null) fields['contactInfo'] = jsonEncode(contactInfo);

      final response = await _apiClient.putMultipart(
        '/api/v1/offers/$offerId',
        fields: fields,
        file: imageFile,
        fileFieldName: 'image',
      );

      final status = response.statusCode;

      if (status < 200 || status >= 300) {
        throw Exception("Server returned HTTP $status: ${response.body}");
      }

      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        return OfferModel.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update offer');
      }
    } catch (e) {
      throw Exception('Failed to update offer: $e');
    }
  }

  // Delete an offer
  Future<void> deleteOffer(String offerId, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/v1/offers/$offerId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to delete offer');
        }
      } else {
        throw Exception(data['message'] ?? 'Failed to delete offer');
      }
    } catch (e) {
      throw Exception('Failed to delete offer: $e');
    }
  }

  // Redeem an offer
  Future<RedemptionResult> redeemOffer(String offerId, String userId) async {
    try {
      final token = await ApiClient.instance.getToken();

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/offers/$offerId/redeem'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': userId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          return RedemptionResult.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to redeem offer');
        }
      } else {
        throw Exception("HTTP ${response.statusCode}: ${data['message']}");
      }
    } catch (e) {
      throw Exception('Failed to redeem offer: $e');
    }
  }

  // Get offer categories
  Future<List<OfferCategory>> getOfferCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/offers/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List<dynamic>).map((item) => OfferCategory.fromJson(item)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch categories');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
}
