import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Nền gradient xanh với 3 lớp sóng động — dùng chung cho các màn auth.
/// (Trước đây mỗi màn login/register/forgot giữ một bản copy riêng.)
class WaveBackground extends StatefulWidget {
  const WaveBackground({super.key});

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.shade400,
            Colors.green.shade700,
          ],
        ),
      ),
      child: Stack(
        children: [
          _buildWave(_controller1, alpha: 0.08, amplitude: 30, frequency: 1.5, offset: 0),
          _buildWave(_controller2, alpha: 0.06, amplitude: 40, frequency: 1.2, offset: 100),
          _buildWave(_controller3, alpha: 0.04, amplitude: 50, frequency: 1.0, offset: 200),
        ],
      ),
    );
  }

  Widget _buildWave(
    AnimationController controller, {
    required double alpha,
    required double amplitude,
    required double frequency,
    required double offset,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _WavePainter(
            animationValue: controller.value,
            color: Colors.white.withValues(alpha: alpha),
            amplitude: amplitude,
            frequency: frequency,
            offset: offset,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.animationValue,
    required this.color,
    required this.amplitude,
    required this.frequency,
    required this.offset,
  });

  final double animationValue;
  final Color color;
  final double amplitude;
  final double frequency;
  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(0, 0);

    for (double y = 0; y <= size.height; y += 1) {
      final waveValue = math.sin(
            (y / size.height * 2 * math.pi * frequency) +
                (animationValue * 2 * math.pi) +
                (offset / 100),
          ) *
          amplitude;
      path.lineTo(waveValue + size.width / 2, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
