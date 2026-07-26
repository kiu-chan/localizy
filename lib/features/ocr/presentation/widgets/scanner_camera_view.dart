import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'scanner_controls.dart';
import 'scanner_frame_overlay.dart';
import 'scanner_result_overlay.dart';

class ScannerCameraView extends StatefulWidget {
  final CameraController controller;
  final bool isProcessing;
  final String detectedText;
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final VoidCallback onFlashToggle;

  /// Toạ độ chạm đã chuẩn hoá (0..1) để camera lấy nét đúng chỗ.
  final ValueChanged<Offset> onFocusTap;

  const ScannerCameraView({
    super.key,
    required this.controller,
    required this.isProcessing,
    required this.detectedText,
    required this.onCapture,
    required this.onGallery,
    required this.onFlashToggle,
    required this.onFocusTap,
  });

  @override
  State<ScannerCameraView> createState() => _ScannerCameraViewState();
}

class _ScannerCameraViewState extends State<ScannerCameraView> {
  Offset? _focusPoint;

  void _handleTap(TapDownDetails details, Size size) {
    final local = details.localPosition;
    setState(() => _focusPoint = local);
    widget.onFocusTap(Offset(
      (local.dx / size.width).clamp(0.0, 1.0),
      (local.dy / size.height).clamp(0.0, 1.0),
    ));
    // Vòng lấy nét chỉ nhấp nháy rồi tắt.
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted && _focusPoint == local) setState(() => _focusPoint = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.sizeOf(context);
    var scale = size.aspectRatio * widget.controller.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    final isTorchOn = widget.controller.value.flashMode == FlashMode.torch;

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => _handleTap(details, size),
          child: ClipRect(
            child: Transform.scale(
              scale: scale,
              child: Center(child: CameraPreview(widget.controller)),
            ),
          ),
        ),
        ScannerFrameOverlay(hint: l10n.scannerFrameHint),
        if (_focusPoint != null)
          Positioned(
            left: _focusPoint!.dx - 32,
            top: _focusPoint!.dy - 32,
            child: IgnorePointer(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber, width: 2),
                ),
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ScannerBottomScrim(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.detectedText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ScannerResultOverlay(detectedText: widget.detectedText),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ScannerGlassButton(
                      icon: Icons.photo_library_outlined,
                      tooltip: l10n.scannerGallery,
                      onPressed: widget.isProcessing ? null : widget.onGallery,
                    ),
                    ScannerShutterButton(
                      onPressed: widget.onCapture,
                      isBusy: widget.isProcessing,
                    ),
                    ScannerGlassButton(
                      icon: isTorchOn ? Icons.flash_on : Icons.flash_off,
                      tooltip: l10n.scannerFlash,
                      iconColor: isTorchOn ? Colors.amber : Colors.white,
                      onPressed: widget.onFlashToggle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
