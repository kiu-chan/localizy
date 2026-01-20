import 'package:flutter/material.dart';
import 'package:localizy/api/address_api.dart';
import 'package:localizy/l10n/app_localizations.dart';

/// Callback khi người dùng chọn chỉ đường
typedef OnGetDirections = void Function(AddressCoordinate address);

/// Bottom sheet hiển thị thông tin địa chỉ và tùy chọn chỉ đường
class AddressDetailBottomSheet extends StatelessWidget {
  final AddressCoordinate address;
  final OnGetDirections? onGetDirections;

  const AddressDetailBottomSheet({
    super.key,
    required this.address,
    this.onGetDirections,
  });

  /// Hiển thị bottom sheet
  static void show(
    BuildContext context, {
    required AddressCoordinate address,
    OnGetDirections? onGetDirections,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressDetailBottomSheet(
        address: address,
        onGetDirections: onGetDirections,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Thông tin địa chỉ
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.green.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.id,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${address.lat.toStringAsFixed(6)}\nLng: ${address.lng.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Nút chỉ đường
          if (onGetDirections != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onGetDirections?.call(address);
                },
                icon: const Icon(Icons.directions, size: 20),
                label: Text(l10n?.getDirections ?? 'Get Directions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          // Nút đóng
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n?.close ?? 'Close'),
            ),
          ),
        ],
      ),
    );
  }
}