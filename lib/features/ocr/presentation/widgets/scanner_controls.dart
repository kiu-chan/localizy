import 'package:flutter/material.dart';

/// Lớp phủ gradient tối ở đáy màn hình để các nút luôn đọc được trên nền camera.
class ScannerBottomScrim extends StatelessWidget {
  final Widget child;

  const ScannerBottomScrim({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 48, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87],
        ),
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}

/// Nút tròn nền mờ dùng cho thanh điều khiển của scanner.
class ScannerGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color iconColor;
  final String? tooltip;

  const ScannerGlassButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor = Colors.white,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.white.withValues(alpha: 0.18),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(
              icon,
              size: 24,
              color: enabled ? iconColor : iconColor.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút chụp kiểu camera: vòng trắng ngoài, lõi tròn bên trong.
class ScannerShutterButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isBusy;

  const ScannerShutterButton({super.key, required this.onPressed, this.isBusy = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBusy ? null : onPressed,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 84,
        height: 84,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 4),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: isBusy ? 40 : 64,
              height: isBusy ? 40 : 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            if (isBusy)
              const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
