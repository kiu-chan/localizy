import 'dart:convert';

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
  /// Will throw if API_BASE_URL is not set or empty.
  ///
  /// Make sure dotenv.load(...) has been called (e.g. in ConfigManager.initialize)
  /// before calling this.
  static void initialize() {
    final base = dotenv.env['API_BASE_URL'];
    if (base == null || base.isEmpty) {
      throw Exception('API_BASE_URL is not set in .env');
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

  /// Send GET request. Automatically attaches Authorization header if a token is stored.
  /// If [headers] are provided they will override default headers (including Authorization).
  Future<http.Response> get(String pathOrUrl, {Map<String, String>? headers}) async {
    final uri = _buildUri(pathOrUrl);
    final auth = await _authHeader();
    final merged = {...auth, ...?headers};
    return http.get(uri, headers: merged);
  }

  /// Send POST request with JSON body. Automatically attaches Authorization header if token is stored.
  /// If [headers] are provided they will override default headers.
  Future<http.Response> postJson(String pathOrUrl, Object body, {Map<String, String>? headers}) async {
    final uri = _buildUri(pathOrUrl);
    final auth = await _authHeader();
    final h = <String, String>{'Content-Type': 'application/json', ...auth, ...?headers};
    return http.post(uri, headers: h, body: json.encode(body));
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