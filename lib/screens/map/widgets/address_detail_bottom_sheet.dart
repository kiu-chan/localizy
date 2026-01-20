import 'package:flutter/material.dart';
import 'package:localizy/api/address_api.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

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

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'landmark':
        return Icons.account_balance;
      case 'restaurant':
        return Icons.restaurant;
      case 'hotel':
        return Icons.hotel;
      case 'hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'shop':
        return Icons.shopping_cart;
      case 'park':
        return Icons.park;
      case 'station':
        return Icons.train;
      case 'airport':
        return Icons.flight;
      case 'cafe':
        return Icons.local_cafe;
      case 'bank':
        return Icons.account_balance_wallet;
      case 'atm':
        return Icons.atm;
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'gas_station':
        return Icons.local_gas_station;
      case 'parking':
        return Icons.local_parking;
      case 'gym':
        return Icons.fitness_center;
      case 'cinema':
        return Icons.movie;
      case 'museum':
        return Icons.museum;
      case 'library':
        return Icons.local_library;
      case 'church':
        return Icons.church;
      case 'mosque':
        return Icons.mosque;
      case 'temple':
        return Icons.temple_buddhist;
      default:
        return Icons.location_on;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'landmark':
        return Colors.purple;
      case 'restaurant':
        return Colors.orange;
      case 'hotel':
        return Colors.blue;
      case 'hospital':
        return Colors.red;
      case 'school':
        return Colors.amber.shade700;
      case 'shop':
        return Colors.teal;
      case 'park':
        return Colors.green;
      case 'station':
        return Colors.indigo;
      case 'airport':
        return Colors.cyan;
      case 'cafe':
        return Colors.brown;
      case 'bank':
        return Colors.blueGrey;
      default:
        return Colors.green.shade700;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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
    final typeColor = _getTypeColor(detail.type);

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
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getTypeIcon(detail.type),
                  color: typeColor,
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            detail.type,
                            style: TextStyle(
                              fontSize: 12,
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (detail.category != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              detail.category!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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

          // Địa chỉ
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: l10n?.address ?? 'Address',
            value: detail.address,
          ),

          // Toạ độ
          _buildInfoRow(
            icon: Icons.my_location,
            label: l10n?.coordinates ?? 'Coordinates',
            value: detail.formattedCoordinates,
          ),

          // Mô tả
          if (detail.description != null && detail.description!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.info_outline,
              label: l10n?.description ?? 'Description',
              value: detail.description!,
            ),

          // Số điện thoại
          if (detail.phone != null && detail.phone!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: l10n?.phone ?? 'Phone',
              value: detail.phone!,
              onTap: () => _launchPhone(detail.phone!),
              isLink: true,
            ),

          // Website
          if (detail.website != null && detail.website!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.language,
              label: l10n?.website ?? 'Website',
              value: detail.website!,
              onTap: () => _launchUrl(detail.website!),
              isLink: true,
            ),

          // Giờ hoạt động
          if (detail.openingHours != null && detail.openingHours!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.access_time,
              label: l10n?.openingHours ?? 'Opening Hours',
              value: detail.openingHours!,
            ),

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
    VoidCallback? onTap,
    bool isLink = false,
  }) {
    final content = Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: isLink ? Colors.blue : Colors.black87,
                    fontWeight: FontWeight.w500,
                    decoration: isLink ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
          if (isLink)
            Icon(
              Icons.open_in_new,
              size: 16,
              color: Colors.blue.shade400,
            ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }

    return content;
  }
}