import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/environment.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  String get baseUrl => Environment.apiBaseUrl;

  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (Environment.apiKey.isNotEmpty) 'Authorization': 'Bearer ${Environment.apiKey}',
  };

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

    final response = await http.get(
      uri,
      headers: {..._defaultHeaders, ...?headers},
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

    final response = await http.post(
      uri,
      headers: {..._defaultHeaders, ...?headers},
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

    final response = await http.put(
      uri,
      headers: {..._defaultHeaders, ...?headers},
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

    final response = await http.patch(
      uri,
      headers: {..._defaultHeaders, ...?headers},
      body: bodyObject ?? (body != null ? jsonEncode(body) : null),
    );

    return response;
  }

  Future<http.Response> delete(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await http.delete(
      uri,
      headers: {..._defaultHeaders, ...?headers},
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
