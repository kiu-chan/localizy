// Tương thích ngược: logout đã chuyển về features/auth/ (authProvider.logout).
// Facade này sẽ bị xóa ở Giai đoạn 6 của lộ trình migrate.
import 'package:flutter/material.dart';
import 'package:localizy/features/auth/data/auth_repository.dart';

class LogoutService {
  /// Xoá token và user đã lưu.
  static Future<void> logout() => AuthRepository.instance.logout();

  /// Xoá session rồi điều hướng về trang login (caller truyền loginPage),
  /// dùng pushAndRemoveUntil để clear navigation stack.
  static Future<void> logoutAndRedirect(
    BuildContext context, {
    required Widget loginPage,
  }) async {
    await logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => loginPage),
      (route) => false,
    );
  }
}
