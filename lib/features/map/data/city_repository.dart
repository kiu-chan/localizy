import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/core/network/api_client.dart';

import '../domain/city.dart';

final cityRepositoryProvider = Provider<CityRepository>(
  (ref) => CityRepository(ref.watch(apiClientProvider)),
);

/// Danh sách thành phố đang hoạt động — ít thay đổi nên cache trong provider.
final activeCitiesProvider = FutureProvider<List<CityItem>>(
  (ref) => ref.watch(cityRepositoryProvider).getActiveCities(),
);

class CityRepository {
  CityRepository(this._client);

  // ── Tương thích ngược cho facade CityApi (gỡ ở Giai đoạn 6) ────────────────
  static CityRepository? _instance;
  static CityRepository get instance =>
      _instance ??= CityRepository(ApiClient.instance);

  final ApiClient _client;

  /// GET /api/cities/active — Public
  Future<List<CityItem>> getActiveCities() async {
    final data = await _client.getJson('api/cities/active');
    final List<dynamic> items;
    if (data is Map<String, dynamic> && data.containsKey('items')) {
      items = data['items'] as List<dynamic>;
    } else if (data is List) {
      items = data;
    } else {
      return [];
    }
    return items
        .map((e) => CityItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
