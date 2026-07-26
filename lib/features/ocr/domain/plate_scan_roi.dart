/// Vùng ngắm (khung quét) đã chuẩn hoá theo khung hình đang hiển thị.
///
/// Toạ độ nằm trong [0, 1] so với vùng preview; [viewportAspect] là tỉ lệ
/// rộng/cao của vùng preview đó — cần để ánh xạ ngược về toạ độ ảnh gốc,
/// vì preview được hiển thị kiểu "cover" (ảnh bị cắt bớt hai bên hoặc trên dưới).
class PlateScanRoi {
  final double left;
  final double top;
  final double right;
  final double bottom;
  final double viewportAspect;

  const PlateScanRoi({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.viewportAspect,
  });

  double get width => right - left;
  double get height => bottom - top;
}
