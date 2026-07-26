import 'package:flutter/material.dart';
import 'package:localizy/core/theme/app_colors.dart';
import 'package:localizy/l10n/app_localizations.dart';

/// Thẻ hiển thị trạng thái nhận dạng / biển số đọc được.
/// Widget thường — vị trí do màn hình cha quyết định.
class ScannerResultOverlay extends StatelessWidget {
  final String detectedText;

  const ScannerResultOverlay({super.key, required this.detectedText});

  @override
  Widget build(BuildContext context) {
    if (detectedText.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final isScanning = detectedText.contains(l10n.recognizing) ||
        detectedText.contains(l10n.processing);
    final accent = isScanning ? AppColors.warning : AppColors.success;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent.withValues(alpha: 0.6), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isScanning)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: accent),
              )
            else
              Icon(Icons.check_circle_rounded, color: accent, size: 20),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                detectedText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
