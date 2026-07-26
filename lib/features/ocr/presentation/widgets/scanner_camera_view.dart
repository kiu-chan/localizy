import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'scanner_controls.dart';
import 'scanner_frame_overlay.dart';
import 'scanner_result_overlay.dart';

class ScannerCameraView extends StatelessWidget {
  final CameraController controller;
  final bool isProcessing;
  final String detectedText;
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final VoidCallback onFlashToggle;

  const ScannerCameraView({
    super.key,
    required this.controller,
    required this.isProcessing,
    required this.detectedText,
    required this.onCapture,
    required this.onGallery,
    required this.onFlashToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * controller.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    final isTorchOn = controller.value.flashMode == FlashMode.torch;

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRect(
          child: Transform.scale(
            scale: scale,
            child: Center(child: CameraPreview(controller)),
          ),
        ),
        ScannerFrameOverlay(hint: l10n.scannerFrameHint),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ScannerBottomScrim(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (detectedText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ScannerResultOverlay(detectedText: detectedText),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ScannerGlassButton(
                      icon: Icons.photo_library_outlined,
                      tooltip: l10n.scannerGallery,
                      onPressed: isProcessing ? null : onGallery,
                    ),
                    ScannerShutterButton(
                      onPressed: onCapture,
                      isBusy: isProcessing,
                    ),
                    ScannerGlassButton(
                      icon: isTorchOn ? Icons.flash_on : Icons.flash_off,
                      tooltip: l10n.scannerFlash,
                      iconColor: isTorchOn ? Colors.amber : Colors.white,
                      onPressed: onFlashToggle,
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
