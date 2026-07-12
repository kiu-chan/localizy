class CityItem {
  const CityItem({required this.id, required this.name, required this.code});

  factory CityItem.fromJson(Map<String, dynamic> json) => CityItem(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        code: json['code'] as String? ?? '',
      );

  final String id;
  final String name;
  final String code;
}
