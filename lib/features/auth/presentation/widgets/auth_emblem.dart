import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Hoạt ảnh hiển thị trong vòng tròn trắng đầu màn hình xác thực.
enum AuthEmblemKind {
  login('assets/animations/auth_login.json', Icons.login),
  register('assets/animations/auth_register.json', Icons.person_add_alt_1),
  forgotPassword('assets/animations/auth_forgot_password.json', Icons.lock_reset),
  emailSent('assets/animations/auth_email_sent.json', Icons.mark_email_read);

  const AuthEmblemKind(this.asset, this.fallbackIcon);

  final String asset;

  /// Dùng khi file hoạt ảnh lỗi/thiếu — không để trống chỗ này.
  final IconData fallbackIcon;

  /// Chỉ "đã gửi email" là hoạt ảnh một lần rồi dừng; còn lại lặp.
  bool get repeats => this != AuthEmblemKind.emailSent;
}

/// Hoạt ảnh Lottie theo từng form, đặt thẳng lên nền sóng xanh (không khung).
/// Đổi form thì hoạt ảnh mờ chồng sang cái mới.
class AuthEmblem extends StatelessWidget {
  const AuthEmblem({super.key, required this.kind, this.size = 180});

  final AuthEmblemKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: Lottie.asset(
          kind.asset,
          key: ValueKey(kind),
          width: size,
          height: size,
          fit: BoxFit.contain,
          repeat: kind.repeats,
          errorBuilder: (context, error, stackTrace) => Icon(
            kind.fallbackIcon,
            size: size * 0.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
