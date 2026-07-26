import 'package:flutter/material.dart';

/// Khung ngắm biển số: làm tối vùng ngoài khung và vẽ 4 góc bo màu nhấn.
class ScannerFrameOverlay extends StatelessWidget {
  final String? hint;

  const ScannerFrameOverlay({super.key, this.hint});

  /// Tỉ lệ khung ngắm, đủ rộng cho cả biển dài và biển vuông.
  static const double _aspectRatio = 2.2;
  static const double _widthFactor = 0.86;

  static Rect frameRect(Size size) {
    final width = size.width * _widthFactor;
    final height = width / _aspectRatio;
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.42),
      width: width,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final rect = frameRect(size);

        return Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _FramePainter(rect)),
              ),
            ),
            if (hint != null)
              Positioned(
                top: rect.bottom + 20,
                left: 24,
                right: 24,
                child: Text(
                  hint!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                    shadows: [
                      Shadow(color: Colors.black54, blurRadius: 8),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FramePainter extends CustomPainter {
  final Rect rect;

  _FramePainter(this.rect);

  static const double _radius = 20;
  static const double _cornerLength = 28;
  static const double _stroke = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(_radius));

    // Vùng tối bên ngoài khung.
    final scrim = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRRect(rrect),
    );
    canvas.drawPath(scrim, Paint()..color = Colors.black.withValues(alpha: 0.55));

    // Viền mảnh quanh khung.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.35),
    );

    // 4 góc bo đậm.
    final cornerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;

    canvas.drawPath(_cornersPath(), cornerPaint);
  }

  Path _cornersPath() {
    final p = Path();
    const r = _radius;
    const len = _cornerLength;

    // Trên trái
    p.moveTo(rect.left, rect.top + r + len);
    p.lineTo(rect.left, rect.top + r);
    p.arcToPoint(Offset(rect.left + r, rect.top), radius: const Radius.circular(r));
    p.lineTo(rect.left + r + len, rect.top);

    // Trên phải
    p.moveTo(rect.right - r - len, rect.top);
    p.lineTo(rect.right - r, rect.top);
    p.arcToPoint(Offset(rect.right, rect.top + r), radius: const Radius.circular(r));
    p.lineTo(rect.right, rect.top + r + len);

    // Dưới phải
    p.moveTo(rect.right, rect.bottom - r - len);
    p.lineTo(rect.right, rect.bottom - r);
    p.arcToPoint(Offset(rect.right - r, rect.bottom), radius: const Radius.circular(r));
    p.lineTo(rect.right - r - len, rect.bottom);

    // Dưới trái
    p.moveTo(rect.left + r + len, rect.bottom);
    p.lineTo(rect.left + r, rect.bottom);
    p.arcToPoint(Offset(rect.left, rect.bottom - r), radius: const Radius.circular(r));
    p.lineTo(rect.left, rect.bottom - r - len);

    return p;
  }

  @override
  bool shouldRepaint(_FramePainter oldDelegate) => oldDelegate.rect != rect;
}
