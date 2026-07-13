import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'scanner_result_overlay.dart';

class ScannerCameraView extends StatelessWidget {
  final CameraController controller;
  final bool isProcessing;
  final String detectedText;
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final VoidCallback onHelp;
  final VoidCallback onFlashToggle;

  const ScannerCameraView({
    super.key,
    required this.controller,
    required this.isProcessing,
    required this.detectedText,
    required this.onCapture,
    required this.onGallery,
    required this.onHelp,
    required this.onFlashToggle,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * controller.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Stack(
      fit: StackFit.expand,
      children: [
        Transform.scale(
          scale: scale,
          child: Center(child: CameraPreview(controller)),
        ),
        Positioned(
          top: 40,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'help',
            onPressed: onHelp,
            backgroundColor: Colors.black54,
            child: const Icon(Icons.question_mark, color: Colors.white),
          ),
        ),
        ScannerResultOverlay(detectedText: detectedText),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: 'gallery',
                onPressed: isProcessing ? null : onGallery,
                backgroundColor: Colors.white,
                child: const Icon(Icons.photo_library, color: Colors.blue),
              ),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: FloatingActionButton.large(
                  heroTag: 'capture',
                  onPressed: isProcessing ? null : onCapture,
                  backgroundColor: Colors.white,
                  child: isProcessing
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.camera_alt, size: 40, color: Colors.red),
                ),
              ),
              FloatingActionButton(
                heroTag: 'flash',
                onPressed: onFlashToggle,
                backgroundColor: Colors.white,
                child: Icon(
                  controller.value.flashMode == FlashMode.torch
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
