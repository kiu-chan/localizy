import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'scanner_result_overlay.dart';

class ScannerCapturedImageView extends StatelessWidget {
  final String imagePath;
  final bool isProcessing;
  final String detectedText;
  final VoidCallback onRetake;

  const ScannerCapturedImageView({
    super.key,
    required this.imagePath,
    required this.isProcessing,
    required this.detectedText,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(File(imagePath), fit: BoxFit.cover),
        if (isProcessing)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ScannerResultOverlay(detectedText: detectedText),
        if (!isProcessing)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                heroTag: 'retake',
                onPressed: onRetake,
                backgroundColor: Colors.white,
                icon: const Icon(Icons.camera_alt, color: Colors.red),
                label: Text(
                  l10n.retake,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
