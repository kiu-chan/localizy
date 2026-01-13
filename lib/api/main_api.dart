import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MainApi {
  MainApi._(this.baseUrl);

  static MainApi? _instance;

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

  Future<http.Response> get(String pathOrUrl, {Map<String, String>? headers}) {
    final uri = _buildUri(pathOrUrl);
    return http.get(uri, headers: headers);
  }

  Future<http.Response> postJson(String pathOrUrl, Object body, {Map<String, String>? headers}) {
    final uri = _buildUri(pathOrUrl);
    final h = <String, String>{'Content-Type': 'application/json', ...?headers};
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