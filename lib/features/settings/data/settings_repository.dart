import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/core/network/api_client.dart';

import '../domain/website_config.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(apiClientProvider)),
);

class SettingsRepository {
  SettingsRepository(this._client);

  final ApiClient _client;

  /// GET /api/settings/website-config — public, không cần token.
  /// Chứa thông tin liên hệ và nội dung pháp lý (terms, privacy).
  Future<WebsiteConfig> getWebsiteConfig() async {
    final data = await _client.getJson('api/settings/website-config');
    return WebsiteConfig.fromJson(data as Map<String, dynamic>);
  }
}
