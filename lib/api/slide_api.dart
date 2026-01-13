import 'package:localizy/api/main_api.dart';

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
}

/// Service riêng để lấy slide
class SlideService {
  /// Lấy các slide active từ endpoint: GET api/homeslides/active
  /// Trả về danh sách đã sort theo field `order`.
  static Future<List<HomeSlide>> getActiveSlides() async {
    final result = await MainApi.instance.getJson('api/homeslides/active');
    if (result is List) {
      final slides = result
          .map((e) => HomeSlide.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      slides.sort((a, b) => a.order.compareTo(b.order));
      return slides;
    }
    return [];
  }
}