import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'scanner_controls.dart';
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
        if (isProcessing) Container(color: Colors.black.withValues(alpha: 0.35)),
        // Nền mờ để tiêu đề trên AppBar trong suốt luôn đọc được.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).padding.top + kToolbarHeight,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent],
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
                if (detectedText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ScannerResultOverlay(detectedText: detectedText),
                  ),
                SizedBox(
                  height: 52,
                  child: isProcessing
                      ? null
                      : TextButton.icon(
                          onPressed: onRetake,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withValues(alpha: 0.18),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: Text(l10n.retake),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
