import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainApi {
  MainApi._(this.baseUrl);

  static MainApi? _instance;

  /// Key used by AuthService / storage to persist token.
  static const String _tokenKey = 'auth_token';

  /// Secure storage instance used to read token when sending requests.
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Initialize the singleton using API_BASE_URL from .env.
  /// Make sure dotenv.load(...) has been called (e.g. in ConfigManager.initialize)
  /// before calling this.
  static void initialize() {
    final base = dotenv.env['API_BASE_URL'];
    if (base == null || base.isEmpty) {
      throw Exception('API_BASE_URL is not set in .env');
    }
    else {
      debugPrint('MainApi initialized with base URL: $base');
    }
    _instance = MainApi._(base);
  }

  /// Get instance. If not initialized explicitly, it will attempt to read
  /// API_BASE_URL from .env and create the instance. Throws if API_BASE_URL
  /// is missing/empty.
  static MainApi get instance {
    final base = dotenv.env['API_BASE_URL'];
    if (base == null || base.isEmpty) {
      throw Exception('API_BASE_URL is not set in .env');
    }
    return _instance ??= MainApi._(base);
  }

  final String baseUrl;

  Uri _buildUri(String pathOrUrl) {
    if (pathOrUrl.toLowerCase().startsWith('http')) {
      return Uri.parse(pathOrUrl);
    }
    // ensure no double slash
    final cleanedBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final cleanedPath = pathOrUrl.startsWith('/') ? pathOrUrl.substring(1) : pathOrUrl;
    return Uri.parse('$cleanedBase$cleanedPath');
  }

  /// Read stored token (if any) and return an Authorization header map.
  /// If no token is stored, returns an empty map.
  Future<Map<String, String>> _authHeader() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null && token.isNotEmpty) {
        return {'Authorization': 'Bearer $token'};
      }
    } catch (_) {
      // ignore storage errors and proceed without auth header
    }
    return {};
  }

  /// Merge auth header (if any) with provided headers. Provided headers override defaults.
  Future<Map<String, String>> _mergeHeaders([Map<String, String>? headers, String? contentType]) async {
    final auth = await _authHeader();
    final result = <String, String>{};
    if (contentType != null) {
      result['Content-Type'] = contentType;
    }
    // auth first, then provided headers override
    result.addAll(auth);
    if (headers != null) {
      result.addAll(headers);
    }
    return result;
  }

  /// Public helper: trả về headers mặc định (đã kèm Authorization nếu có),
  /// bạn có thể truyền contentType hoặc extra headers.
  Future<Map<String, String>> getDefaultHeaders({String? contentType, Map<String, String>? extra}) async {
    return await _mergeHeaders(extra, contentType);
  }

  /// Public helper: thêm Authorization header (nếu có) vào MultipartRequest.
  /// MultipartRequest không đi qua http.get/post helper nên cần gọi helper này
  /// trước khi gửi request.
  Future<void> attachAuthToMultipart(http.MultipartRequest request) async {
    try {
      final auth = await _authHeader();
      if (auth.isNotEmpty) {
        request.headers.addAll(auth);
      }
    } catch (_) {
      // ignore storage errors
    }
  }

  /// Send GET request. Automatically attaches Authorization header if a token is stored.
  /// If [headers] are provided they will override default headers (including Authorization).
  Future<http.Response> get(String pathOrUrl, {Map<String, String>? headers}) async {
    final uri = _buildUri(pathOrUrl);
    final merged = await _mergeHeaders(headers, null);
    return http.get(uri, headers: merged);
  }

  /// Send DELETE request.
  Future<http.Response> delete(String pathOrUrl, {Map<String, String>? headers, Object? body}) async {
    final uri = _buildUri(pathOrUrl);
    final merged = await _mergeHeaders(headers, body != null ? 'application/json' : null);
    if (body != null) {
      return http.delete(uri, headers: merged, body: json.encode(body));
    }
    return http.delete(uri, headers: merged);
  }

  /// Send POST request with JSON body. Automatically attaches Authorization header if token is stored.
  /// If [headers] are provided they will override default headers.
  Future<http.Response> postJson(String pathOrUrl, Object body, {Map<String, String>? headers}) async {
    final uri = _buildUri(pathOrUrl);
    final h = await _mergeHeaders(headers, 'application/json');
    return http.post(uri, headers: h, body: json.encode(body));
  }

  /// Send PUT request with JSON body.
  Future<http.Response> putJson(String pathOrUrl, Object body, {Map<String, String>? headers}) async {
    final uri = _buildUri(pathOrUrl);
    final h = await _mergeHeaders(headers, 'application/json');
    return http.put(uri, headers: h, body: json.encode(body));
  }

  /// Send PATCH request with JSON body.
  Future<http.Response> patchJson(String pathOrUrl, Object body, {Map<String, String>? headers}) async {
    final uri = _buildUri(pathOrUrl);
    final h = await _mergeHeaders(headers, 'application/json');
    return http.patch(uri, headers: h, body: json.encode(body));
  }

  /// Call GET and decode JSON response body; throws if status code is not 2xx.
  Future<dynamic> getJson(String pathOrUrl, {Map<String, String>? headers}) async {
    final resp = await get(pathOrUrl, headers: headers);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return json.decode(resp.body);
    }
    throw Exception('GET $pathOrUrl failed: ${resp.statusCode} ${resp.reasonPhrase}');
  }
}