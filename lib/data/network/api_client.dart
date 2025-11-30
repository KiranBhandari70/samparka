import 'dart:convert';
import 'dart:io';
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

  Future<http.Response> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    File? file,
    String fileFieldName = 'image',
    List<Map<String, dynamic>>? files,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    // Add authorization header
    final token = await _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add fields
    if (fields != null) {
      request.fields.addAll(fields);
    }

    // Add multiple files if provided
    if (files != null) {
      for (final fileData in files) {
        final file = fileData['file'] as File;
        final fieldName = fileData['fieldName'] as String;
        if (await file.exists()) {
          final fileStream = http.ByteStream(file.openRead());
          final fileLength = await file.length();
          final fileName = file.path.split(Platform.pathSeparator).last;

          // Determine content type from file extension
          String contentType;
          final ext = fileName.toLowerCase().split('.').last;
          switch (ext) {
            case 'jpg':
            case 'jpeg':
              contentType = 'image/jpeg';
              break;
            case 'png':
              contentType = 'image/png';
              break;
            case 'gif':
              contentType = 'image/gif';
              break;
            case 'webp':
              contentType = 'image/webp';
              break;
            default:
              contentType = 'image/jpeg';
          }

          final multipartFile = http.MultipartFile(
            fieldName,
            fileStream,
            fileLength,
            filename: fileName,
            contentType: http.MediaType.parse(contentType),
          );
          request.files.add(multipartFile);
        }
      }
    } else if (file != null && await file.exists()) {
      // Single file support (backward compatibility)
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final fileName = file.path.split(Platform.pathSeparator).last;

      String contentType;
      final ext = fileName.toLowerCase().split('.').last;
      switch (ext) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        case 'webp':
          contentType = 'image/webp';
          break;
        default:
          contentType = 'image/jpeg';
      }

      final multipartFile = http.MultipartFile(
        fileFieldName,
        fileStream,
        fileLength,
        filename: fileName,
        contentType: http.MediaType.parse(contentType),
      );
      request.files.add(multipartFile);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  Future<http.Response> putMultipart(
    String endpoint, {
    Map<String, String>? fields,
    File? file,
    String fileFieldName = 'image',
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('PUT', uri);

    // Add authorization header
    final token = await _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add fields
    if (fields != null) {
      request.fields.addAll(fields);
    }

    // Add file if provided
    if (file != null && await file.exists()) {
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final fileName = file.path.split(Platform.pathSeparator).last;

      // Determine content type from file extension
      String contentType;
      final ext = fileName.toLowerCase().split('.').last;
      switch (ext) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        case 'webp':
          contentType = 'image/webp';
          break;
        default:
          contentType = 'image/jpeg'; // Default fallback
      }

      final multipartFile = http.MultipartFile(
        fileFieldName,
        fileStream,
        fileLength,
        filename: fileName,
        contentType: http.MediaType.parse(contentType),
      );
      request.files.add(multipartFile);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
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

  /// FIXED: Properly return stored JWT token
  Future<String?> getToken() async {
    return await _storageService.getToken();
  }
}

