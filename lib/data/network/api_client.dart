import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/environment.dart';
import '../services/storage_service.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();
  final _storageService = StorageService.instance;

  String get baseUrl => Environment.apiBaseUrl;

  Future<Map<String, String>> _getHeaders({Map<String, String>? additionalHeaders}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add JWT token if available
    final token = await _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Add any additional headers
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  Future<http.Response> get(
      String endpoint, {
        Map<String, String>? headers,
        Map<String, dynamic>? queryParams,
      }) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParams?.map(
            (key, value) => MapEntry(key, value.toString()),
      ),
    );

    final requestHeaders = await _getHeaders(additionalHeaders: headers);
    final response = await http.get(
      uri,
      headers: requestHeaders,
    );

    return response;
  }

  Future<http.Response> post(
      String endpoint, {
        Map<String, String>? headers,
        Map<String, dynamic>? body,
        Object? bodyObject,
      }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final requestHeaders = await _getHeaders(additionalHeaders: headers);
    final response = await http.post(
      uri,
      headers: requestHeaders,
      body: bodyObject ?? (body != null ? jsonEncode(body) : null),
    );

    return response;
  }

  Future<http.Response> put(
      String endpoint, {
        Map<String, String>? headers,
        Map<String, dynamic>? body,
        Object? bodyObject,
      }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final requestHeaders = await _getHeaders(additionalHeaders: headers);
    final response = await http.put(
      uri,
      headers: requestHeaders,
      body: bodyObject ?? (body != null ? jsonEncode(body) : null),
    );

    return response;
  }

  Future<http.Response> patch(
      String endpoint, {
        Map<String, String>? headers,
        Map<String, dynamic>? body,
        Object? bodyObject,
      }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final requestHeaders = await _getHeaders(additionalHeaders: headers);
    final response = await http.patch(
      uri,
      headers: requestHeaders,
      body: bodyObject ?? (body != null ? jsonEncode(body) : null),
    );

    return response;
  }

  Future<http.Response> delete(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final requestHeaders = await _getHeaders(additionalHeaders: headers);
    final response = await http.delete(
      uri,
      headers: requestHeaders,
    );

    return response;
  }

  Map<String, dynamic>? parseResponse(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  List<dynamic>? parseListResponse(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(response.body) as List<dynamic>?;
    } catch (e) {
      return null;
    }
  }
}
