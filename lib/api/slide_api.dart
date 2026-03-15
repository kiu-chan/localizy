import 'dart:convert';

import 'package:localizy/api/main_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model cho slide
class HomeSlide {
  final String id;
  final String? imageUrl;
  final String content;
  final int order;

  HomeSlide({
    required this.id,
    this.imageUrl,
    required this.content,
    required this.order,
  });

  factory HomeSlide.fromJson(Map<String, dynamic> json) {
    String image = (json['imageUrl'] ?? '').toString();

    // Nếu là đường dẫn tương đối, nối với baseUrl từ MainApi
    if (image.isNotEmpty && !image.toLowerCase().startsWith('http')) {
      final base = MainApi.instance.baseUrl;
      final cleanedBase = base.endsWith('/') ? base : '$base/';
      final cleanedImage = image.startsWith('/') ? image.substring(1) : image;
      image = '$cleanedBase$cleanedImage';
    }

    return HomeSlide(
      id: json['id'] ?? '',
      imageUrl: image.isNotEmpty ? image : null,
      content: json['content'] ?? '',
      order: json['order'] is int
          ? json['order'] as int
          : int.tryParse('${json['order']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl ?? '',
        'content': content,
        'order': order,
      };
}

/// Service riêng để lấy slide
class SlideService {
  static const _cacheKey = 'cached_home_slides';

  /// Lấy các slide active từ endpoint: GET api/homeslides/active
  /// Trả về danh sách đã sort theo field `order`.
  static Future<List<HomeSlide>> getActiveSlides() async {
    final result = await MainApi.instance.getJson('api/homeslides/active');
    final List<dynamic> rawList;
    if (result is Map<String, dynamic> && result.containsKey('items')) {
      rawList = result['items'] as List<dynamic>;
    } else if (result is List) {
      rawList = result;
    } else {
      return [];
    }
    final slides = rawList
        .map((e) => HomeSlide.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    slides.sort((a, b) => a.order.compareTo(b.order));
    await _saveCache(slides);
    return slides;
  }

  /// Lấy slide từ cache local (SharedPreferences).
  /// Trả về danh sách rỗng nếu chưa có cache.
  static Future<List<HomeSlide>> getCachedSlides() async {
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

  static Future<void> _saveCache(List<HomeSlide> slides) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode(slides.map((s) => s.toJson()).toList()),
      );
    } catch (_) {}
  }
}