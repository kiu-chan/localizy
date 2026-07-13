import 'package:flutter/material.dart';

/// Bảng màu dùng chung của app. Mọi màu mới phải khai báo ở đây,
/// không hardcode `Color(0x...)` trong widget.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF4285F4);
  static const Color primaryDark = Color(0xFF1565C0);

  /// Nền nhạt cho vùng được chọn / highlight theo màu brand.
  static const Color primarySurface = Color(0xFFEBF3FF);

  // Text
  static const Color ink = Color(0xFF2D3142);
  static const Color inkStrong = Color(0xFF1A1A2E);
  static const Color muted = Color(0xFF6B7280);
  static const Color disabled = Color(0xFF9CA3AF);

  // Surfaces
  static const Color surface = Colors.white;
  static const Color background = Color(0xFFF5F7FA);

  /// Nền xám nhạt cho segmented control, chip, ô đếm...
  static const Color fill = Color(0xFFF1F3F6);
  static const Color border = Color(0xFFE3E8EF);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFE53935);
  static const Color warning = Color(0xFFF57C00);

  /// Khối "Lưu ý quan trọng".
  static const Color warningSurface = Color(0xFFFFF8E6);
  static const Color warningBorder = Color(0xFFFFE1A8);
  static const Color warningInk = Color(0xFF5C5346);
}

/// Đổ bóng dùng chung cho card / thanh nổi.
abstract final class AppShadows {
  static const BoxShadow card = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static const List<BoxShadow> cardList = [card];
}
