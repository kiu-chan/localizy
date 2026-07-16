import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/settings_repository.dart';
import '../../domain/website_config.dart';

/// Cấu hình public của website (liên hệ + nội dung pháp lý).
/// Refresh bằng ref.invalidate(websiteConfigProvider).
final websiteConfigProvider = FutureProvider<WebsiteConfig>(
  (ref) => ref.watch(settingsRepositoryProvider).getWebsiteConfig(),
);
