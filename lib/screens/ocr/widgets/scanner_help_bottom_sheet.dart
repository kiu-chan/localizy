import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';

class ScannerHelpBottomSheet {
  static void show(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.help_outline, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Text(
                  l10n.scannerHelpTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTip(Icons.camera_alt, l10n.scannerHelpTip1),
            _buildTip(Icons.photo_library, l10n.scannerHelpTip2),
            _buildTip(Icons.edit, l10n.scannerHelpTip3),
          ],
        ),
      ),
    );
  }

  static Widget _buildTip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.red.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
