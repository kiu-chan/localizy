import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/core/services/notification_service.dart'
    show navigatorKey;

import 'pages/login_page.dart';
import 'providers/auth_provider.dart';

bool _handling = false;

/// Tạo handler cho ApiClient.onUnauthorized: token hết hạn (server trả 401)
/// → xóa phiên + đưa về màn login, bỏ qua nếu chưa đăng nhập.
/// Gắn trong main() sau khi tạo ProviderContainer.
void Function() makeSessionExpiryHandler(ProviderContainer container) {
  return () async {
    // Nhiều request song song cùng nhận 401 → chỉ xử lý một lần.
    if (_handling) return;
    if (container.read(authProvider).value == null) return;
    _handling = true;
    try {
      await container.read(authProvider.notifier).logout();
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } finally {
      _handling = false;
    }
  };
}
