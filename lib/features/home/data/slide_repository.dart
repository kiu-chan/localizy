import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/home_slide.dart';

final slideRepositoryProvider = Provider<SlideRepository>(
  (ref) => SlideRepository(ref.watch(apiClientProvider)),
);

class SlideRepository {
  SlideRepository(this._client);

  final ApiClient _client;

  static const _cacheKey = 'cached_home_slides';

  /// GET /api/homeslides/active — slide đang hoạt động, sort theo `order`,
  /// đồng thời lưu cache local để lần mở app sau hiển thị ngay.
  Future<List<HomeSlide>> getActiveSlides() async {
    final result = await _client.getJson('api/homeslides/active');
    final List<dynamic> rawList;
    if (result is Map<String, dynamic> && result.containsKey('items')) {
      rawList = result['items'] as List<dynamic>;
    } else if (result is List) {
      rawList = result;
    } else {
      return [];
    }
    final slides = rawList
        .map((e) => HomeSlide.fromJson(
              Map<String, dynamic>.from(e as Map),
              baseUrl: _client.baseUrl,
            ))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    await _saveCache(slides);
    return slides;
  }

  /// Slide từ cache local (SharedPreferences); rỗng nếu chưa có.
  Future<List<HomeSlide>> getCachedSlides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => HomeSlide.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveCache(List<HomeSlide> slides) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode(slides.map((s) => s.toJson()).toList()),
      );
    } catch (_) {}
  }
}
