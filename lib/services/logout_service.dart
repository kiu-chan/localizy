import 'package:flutter/material.dart';
import 'package:localizy/api/auth_api.dart';

/// LogoutService: chịu trách nhiệm dọn dẹp session (xoá token, cache, ...).
/// Giữ logic độc lập để tái sử dụng ở nhiều nơi.
class LogoutService {
  /// Xoá token và thực hiện các cleanup khác nếu cần.
  static Future<void> logout() async {
    // hiện tại AuthService.logout() đã xoá token trong flutter_secure_storage
    await AuthService.logout();
  }

  /// Xoá session rồi điều hướng về trang login (caller truyền loginPage).
  /// Sử dụng pushAndRemoveUntil để clear navigation stack.
  static Future<void> logoutAndRedirect(
    dynamic navigatorContext, {
    required Widget loginPage,
  }) async {
    await logout();

    // Nếu context không còn mounted (khó kiểm tra ở đây vì context kiểu dynamic),
    // caller chịu trách nhiệm kiểm tra trước khi gọi. Thông thường gọi từ widget.
    try {
      final ctx = navigatorContext as dynamic;
      Navigator.of(ctx).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => loginPage),
        (route) => false,
      );
    } catch (_) {
      // ignore navigation error
    }
  }
}