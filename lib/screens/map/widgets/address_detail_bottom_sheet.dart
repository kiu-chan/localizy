import 'package:flutter/material.dart';
import 'package:localizy/api/address_api.dart';
import 'package:localizy/l10n/app_localizations.dart';

/// Callback khi người dùng chọn chỉ đường
typedef OnGetDirections = void Function(AddressCoordinate address);

/// Bottom sheet hiển thị thông tin chi tiết địa chỉ
class AddressDetailBottomSheet extends StatefulWidget {
  final String addressId;
  final double lat;
  final double lng;
  final OnGetDirections? onGetDirections;

  const AddressDetailBottomSheet({
    super.key,
    required this.addressId,
    required this.lat,
    required this.lng,
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
      isScrollControlled: true,
      builder: (context) => AddressDetailBottomSheet(
        addressId: address.id,
        lat: address.lat,
        lng: address.lng,
        onGetDirections: onGetDirections,
      ),
    );
  }

  @override
  State<AddressDetailBottomSheet> createState() => _AddressDetailBottomSheetState();
}

class _AddressDetailBottomSheetState extends State<AddressDetailBottomSheet> {
  AddressDetail? _detail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await AddressApi.getDetail(widget.addressId);
      if (mounted) {
        setState(() {
          _detail = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load details';
          _isLoading = false;
        });
      }
      debugPrint('Error loading address detail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Content
          Flexible(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  )
                : _errorMessage != null
                    ? _buildErrorState()
                    : _buildDetailContent(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _loadDetail();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent(AppLocalizations? l10n) {
    final detail = _detail!;
    final statusColor = detail.isVerified ? Colors.green.shade700 : Colors.orange;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với icon và tên
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  detail.parkingAvailable ? Icons.local_parking : Icons.location_on,
                  color: statusColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail.code,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                detail.isVerified ? Icons.verified : Icons.pending,
                                size: 12,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                detail.isVerified ? 'Đã xác minh' : detail.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            detail.cityName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Địa chỉ đầy đủ
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: l10n?.address ?? 'Address',
            value: detail.fullAddress,
          ),

          // Toạ độ
          _buildInfoRow(
            icon: Icons.my_location,
            label: l10n?.coordinates ?? 'Coordinates',
            value: detail.formattedCoordinates,
          ),

          // Người tạo
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Người tạo',
            value: detail.userName,
          ),

          // Validator
          if (detail.validatorName != null && detail.validatorName!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.verified_user_outlined,
              label: 'Người xác minh',
              value: detail.validatorName!,
            ),

          // Ghi chú xác minh
          if (detail.comments != null && detail.comments!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.comment_outlined,
              label: 'Ghi chú',
              value: detail.comments!,
            ),

          // Thông tin đỗ xe
          if (detail.parkingAvailable) ...[
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.local_parking, size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Thông tin đỗ xe',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            _buildInfoRow(
              icon: Icons.directions_car_outlined,
              label: 'Chỗ trống / Tổng',
              value: '${detail.availableSpots} / ${detail.totalParkingSpots}',
            ),
            _buildInfoRow(
              icon: Icons.attach_money,
              label: 'Giá đỗ xe',
              value: detail.formattedPricePerHour,
            ),
          ],

          // Ngày tạo
          if (detail.formattedCreatedAt != null)
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: l10n?.createdAt ?? 'Created',
              value: detail.formattedCreatedAt!,
            ),

          const SizedBox(height: 24),

          // Nút chỉ đường
          if (widget.onGetDirections != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onGetDirections?.call(
                    AddressCoordinate(
                      id: detail.id,
                      code: detail.code,
                      lat: detail.lat,
                      lng: detail.lng,
                    ),
                  );
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}