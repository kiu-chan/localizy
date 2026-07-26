import 'package:flutter/material.dart';
import 'package:localizy/core/theme/app_colors.dart';
import 'package:localizy/l10n/app_localizations.dart';

/// Popup xác nhận / chỉnh sửa biển số sau khi OCR.
///
/// Trả về biển số đã viết hoa nếu người dùng xác nhận, `null` nếu huỷ.
class PlateConfirmDialog extends StatefulWidget {
  final String detectedPlate;

  const PlateConfirmDialog({super.key, required this.detectedPlate});

  static Future<String?> show(BuildContext context, String detectedPlate) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PlateConfirmDialog(detectedPlate: detectedPlate),
    );
  }

  @override
  State<PlateConfirmDialog> createState() => _PlateConfirmDialogState();
}

class _PlateConfirmDialogState extends State<PlateConfirmDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.detectedPlate);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final plateNumber = _controller.text.trim().toUpperCase();
    if (plateNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterLicensePlate)),
      );
      return;
    }
    Navigator.pop(context, plateNumber);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.confirmLicensePlate,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.inkStrong,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.scannerEditHint,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 2,
              minLines: 1,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: AppColors.inkStrong,
              ),
              decoration: InputDecoration(
                hintText: l10n.enterLicensePlate,
                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                  color: AppColors.disabled,
                ),
                filled: true,
                fillColor: AppColors.fill,
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                border: _border(AppColors.border),
                enabledBorder: _border(AppColors.border),
                focusedBorder: _border(AppColors.primary, width: 2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.muted,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l10n.confirm,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
