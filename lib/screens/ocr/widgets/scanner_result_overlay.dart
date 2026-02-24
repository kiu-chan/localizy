import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';

class ScannerResultOverlay extends StatelessWidget {
  final String detectedText;

  const ScannerResultOverlay({super.key, required this.detectedText});

  @override
  Widget build(BuildContext context) {
    if (detectedText.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final isScanning = detectedText.contains(l10n.recognizing) ||
        detectedText.contains(l10n.processing);

    return Positioned(
      bottom: 180,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: isScanning ? Colors.orange : Colors.green,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(
              isScanning ? Icons.search : Icons.check_circle,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              detectedText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
