/// Slide banner trên trang chủ.
class HomeSlide {
  const HomeSlide({
    required this.id,
    this.imageUrl,
    required this.content,
    required this.order,
  });

  /// [baseUrl] dùng để nối đường dẫn ảnh tương đối thành URL đầy đủ.
  factory HomeSlide.fromJson(Map<String, dynamic> json, {String? baseUrl}) {
    String image = (json['imageUrl'] ?? '').toString();

    if (image.isNotEmpty &&
        !image.toLowerCase().startsWith('http') &&
        baseUrl != null) {
      final cleanedBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
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

  final String id;
  final String? imageUrl;
  final String content;
  final int order;

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl ?? '',
        'content': content,
        'order': order,
      };
}
