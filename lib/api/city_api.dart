import 'package:localizy/api/main_api.dart';

class CityItem {
  final String id;
  final String name;
  final String code;

  const CityItem({required this.id, required this.name, required this.code});

  factory CityItem.fromJson(Map<String, dynamic> json) => CityItem(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        code: json['code'] as String? ?? '',
      );
}

class CityApi {
  /// GET /api/cities/active — Public
  static Future<List<CityItem>> getActiveCities() async {
    final data = await MainApi.instance.getJson('api/cities/active');
    final List<dynamic> items;
    if (data is Map<String, dynamic> && data.containsKey('items')) {
      items = data['items'] as List<dynamic>;
    } else if (data is List) {
      items = data;
    } else {
      return [];
    }
    return items.map((e) => CityItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
