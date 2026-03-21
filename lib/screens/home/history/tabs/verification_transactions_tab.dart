import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:localizy/api/main_api.dart';
import 'package:localizy/configs/currency_config.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/home/parking/parking_zone_detail_map_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class VerificationTransactionsTab extends StatefulWidget {
  const VerificationTransactionsTab({super.key});

  @override
  State<VerificationTransactionsTab> createState() =>
      _VerificationTransactionsTabState();
}

class _VerificationTransactionsTabState extends State<VerificationTransactionsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _verifications = [];

  @override
  void initState() {
    super.initState();
    _loadVerifications();
  }

  Future<void> _loadVerifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await MainApi.instance.getJson('api/validations/my-validations');
      debugPrint('[VerificationTab] my-validations response: ${jsonEncode(data)}');

      final List<dynamic> items;
      if (data is Map && data.containsKey('items')) {
        items = data['items'] as List<dynamic>;
      } else {
        items = data as List<dynamic>;
      }

      setState(() {
        _verifications = items
            .map((item) => item as Map<String, dynamic>)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[VerificationTab] Error loading: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshVerifications() async {
    await _loadVerifications();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadVerifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshVerifications,
      color: Colors.green.shade700,
      child: _verifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _verifications.length,
              itemBuilder: (context, index) {
                return _buildVerificationCard(_verifications[index]);
              },
            ),
    );
  }

  Widget _buildVerificationCard(Map<String, dynamic> verification) {
    final status = verification['status'] ?? 'Pending';
    final requestId = verification['requestId'] ?? '';
    final createdAt = verification['createdAt'] != null
        ? DateTime.parse(verification['createdAt'])
        : DateTime.now();

    final paymentInfo = verification['paymentInfo'];
    final amount = paymentInfo != null ? (paymentInfo['amount'] ?? 0).toInt() : 0;
    final paymentMethod = paymentInfo != null ? (paymentInfo['method'] ?? '') : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showVerificationDetail(verification),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.verified_outlined,
                      color: Colors.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Address Verification',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          requestId,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (amount > 0)
                        Text(
                          _formatCurrency(context, amount),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(status),
                              size: 14,
                              color: _getStatusColor(status),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  if (paymentMethod.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          _getPaymentIcon(paymentMethod),
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getPaymentMethodName(context, paymentMethod),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMap(double lat, double lng, String requestId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParkingZoneDetailMapPage(
          zoneId: requestId,
          zoneCode: requestId,
          zoneName: 'Verification Location',
          latitude: lat,
          longitude: lng,
        ),
      ),
    );
  }

  void _showVerificationDetail(Map<String, dynamic> verification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildVerificationDetailSheet(verification),
    );
  }

  Widget _buildVerificationDetailSheet(Map<String, dynamic> verification) {
    final status = verification['status'] ?? 'Pending';
    final requestId = verification['requestId'] ?? '';
    final notes = verification['notes'] ?? '';
    final createdAt = verification['createdAt'] != null
        ? DateTime.parse(verification['createdAt'])
        : DateTime.now();

    final paymentInfo = verification['paymentInfo'];
    final amount = paymentInfo != null ? (paymentInfo['amount'] ?? 0).toInt() : 0;
    final paymentMethod = paymentInfo != null ? (paymentInfo['method'] ?? '') : '';
    final paymentStatus = paymentInfo != null ? (paymentInfo['status'] ?? '') : '';

    final locationInfo = verification['locationInfo'];
    final latitude = locationInfo != null ? (locationInfo['latitude'] ?? 0.0) : 0.0;
    final longitude = locationInfo != null ? (locationInfo['longitude'] ?? 0.0) : 0.0;

    final documentFiles = verification['documentFiles'];
    final idType = documentFiles != null ? (documentFiles['idType'] ?? '') : '';
    final idDocumentUrl = documentFiles != null ? documentFiles['idDocumentUrl'] : null;
    final addressProofUrl = documentFiles != null ? documentFiles['addressProofUrl'] : null;

    final appointmentInfo = verification['appointmentInfo'];
    final appointmentDate = appointmentInfo != null && appointmentInfo['date'] != null
        ? DateTime.parse(appointmentInfo['date'])
        : null;
    final appointmentTimeSlot = appointmentInfo != null ? (appointmentInfo['timeSlot'] ?? '') : '';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.verified_outlined,
                          color: Colors.purple,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Address Verification',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(status),
                                    size: 16,
                                    color: _getStatusColor(status),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  if (amount > 0)
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Amount',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatCurrency(context, amount),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (amount > 0) const SizedBox(height: 24),
                  if (amount > 0) const Divider(),
                  if (amount > 0) const SizedBox(height: 16),
                  _buildDetailRow('Request ID', requestId),
                  _buildDetailRow('Date & Time', _formatDate(createdAt)),
                  _buildDetailRow(
                    'Location',
                    'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}',
                  ),
                  if (idType.isNotEmpty) _buildDetailRow('ID Type', idType),
                  if (paymentMethod.isNotEmpty)
                    _buildDetailRow(
                      'Payment Method',
                      _getPaymentMethodName(context, paymentMethod),
                      icon: _getPaymentIcon(paymentMethod),
                    ),
                  if (paymentStatus.isNotEmpty)
                    _buildDetailRow('Payment Status', paymentStatus),
                  if (appointmentDate != null)
                    _buildDetailRow(
                      'Appointment',
                      '${DateFormat('dd/MM/yyyy').format(appointmentDate)} - $appointmentTimeSlot',
                    ),
                  if (notes.isNotEmpty) _buildDetailRow('Notes', notes),
                  if (idDocumentUrl != null || addressProofUrl != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Documents',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (idDocumentUrl != null)
                          Expanded(
                            child: _buildDocumentPreview(
                              'ID Document',
                              idDocumentUrl,
                            ),
                          ),
                        if (idDocumentUrl != null && addressProofUrl != null)
                          const SizedBox(width: 12),
                        if (addressProofUrl != null)
                          Expanded(
                            child: _buildDocumentPreview(
                              'Address Proof',
                              addressProofUrl,
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (latitude != 0.0 || longitude != 0.0) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _openMap(latitude.toDouble(), longitude.toDouble(), requestId);
                        },
                        icon: const Icon(Icons.map, color: Colors.white),
                        label: const Text(
                          'View on Map',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadAsImage(verification),
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAsImage(Map<String, dynamic> verification) async {
    final status = verification['status'] as String? ?? 'Pending';
    final requestId = verification['requestId'] as String? ?? '';
    final createdAt = verification['createdAt'] != null
        ? DateTime.parse(verification['createdAt'] as String)
        : DateTime.now();
    final paymentInfo = verification['paymentInfo'];
    final amount =
        paymentInfo != null ? (paymentInfo['amount'] ?? 0).toInt() : 0;
    final paymentMethod =
        paymentInfo != null ? (paymentInfo['method'] as String? ?? '') : '';
    final locationInfo = verification['locationInfo'];
    final latitude =
        locationInfo != null ? (locationInfo['latitude'] ?? 0.0) : 0.0;
    final longitude =
        locationInfo != null ? (locationInfo['longitude'] ?? 0.0) : 0.0;
    final documentFiles = verification['documentFiles'];
    final idType =
        documentFiles != null ? (documentFiles['idType'] as String? ?? '') : '';

    final dateStr = _formatDate(createdAt);
    final paymentStr =
        paymentMethod.isNotEmpty ? _getPaymentMethodName(context, paymentMethod) : '';
    final amountStr = amount > 0 ? _formatCurrency(context, amount) : '';
    final lat = (latitude is num) ? latitude.toDouble() : 0.0;
    final lng = (longitude is num) ? longitude.toDouble() : 0.0;
    final locationStr = lat != 0.0 || lng != 0.0
        ? '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}'
        : '';

    final bytes = await _captureWidgetAsImage(
      _buildReceiptWidget(
        requestId: requestId,
        status: status,
        dateStr: dateStr,
        locationStr: locationStr,
        idType: idType,
        paymentStr: paymentStr,
        amountStr: amountStr,
      ),
    );
    if (bytes == null) return;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/verification_$requestId.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
        [XFile(file.path)], text: 'Verification Receipt · Localizy');
  }

  Future<Uint8List?> _captureWidgetAsImage(Widget widget) async {
    final key = GlobalKey();
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -10000,
        top: 0,
        child: Material(
          child: RepaintBoundary(
            key: key,
            child: Directionality(
              textDirection: ui.TextDirection.ltr,
              child: widget,
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(entry);
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 80));
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    } finally {
      entry.remove();
    }
  }

  Widget _buildReceiptWidget({
    required String requestId,
    required String status,
    required String dateStr,
    required String locationStr,
    required String idType,
    required String paymentStr,
    required String amountStr,
  }) {
    final Color statusColor;
    final IconData statusIcon;
    final String statusLabel;
    switch (status.toLowerCase()) {
      case 'verified':
        statusColor = const Color(0xFF43A047);
        statusIcon = Icons.check_circle_outline;
        statusLabel = 'Verified';
        break;
      case 'rejected':
        statusColor = const Color(0xFFE53935);
        statusIcon = Icons.cancel_outlined;
        statusLabel = 'Rejected';
        break;
      default:
        statusColor = const Color(0xFFFB8C00);
        statusIcon = Icons.hourglass_empty;
        statusLabel = 'Pending';
    }

    const headerColor = Color(0xFF6A1B9A);

    return Container(
      width: 360,
      color: const Color(0xFFEEF0F3),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [headerColor, Color(0xFF4A148C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 14),
                        const SizedBox(width: 5),
                        Text(
                          'C I T I Z E N',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.5),
                      ),
                      child: const Icon(Icons.verified_outlined,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Address Verification',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (amountStr.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        amountStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // ── Dashed separator ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: List.generate(
                    32,
                    (i) => Expanded(
                      child: Container(
                        height: 1.5,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        color: i.isEven
                            ? Colors.grey.shade200
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
              // ── Details ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Column(
                  children: [
                    _buildReceiptDetailRow('Request ID', requestId),
                    _buildReceiptDetailRow('Date', dateStr),
                    if (locationStr.isNotEmpty)
                      _buildReceiptDetailRow('Location', locationStr),
                    if (idType.isNotEmpty)
                      _buildReceiptDetailRow('ID Type', idType),
                    if (paymentStr.isNotEmpty)
                      _buildReceiptDetailRow('Payment', paymentStr),
                    _buildReceiptDetailRow('Status', statusLabel,
                        valueColor: statusColor),
                  ],
                ),
              ),
              // ── Footer ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  border:
                      Border(top: BorderSide(color: Colors.grey.shade100)),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_outlined,
                            size: 12, color: headerColor),
                        SizedBox(width: 5),
                        Text(
                          'Official Certificate · Citea',
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptDetailRow(String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? const Color(0xFF111111),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview(String label, String url) {
    final baseUrl = MainApi.instance.baseUrl;
    final fullUrl = url.startsWith('http') ? url : '$baseUrl$url';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              fullUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, color: Colors.grey.shade400),
                      const SizedBox(height: 4),
                      Text(
                        'Image',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: Colors.grey.shade700),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_outlined, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text(
            'No Verification Requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your verification history will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(BuildContext context, int amount) {
    return CurrencyConfig.format(amount.toDouble());
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help;
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'momo':
        return Icons.account_balance_wallet;
      case 'zalopay':
        return Icons.payment;
      case 'bank':
        return Icons.account_balance;
      case 'card':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodName(BuildContext context, String method) {
    final l10n = AppLocalizations.of(context)!;
    switch (method.toLowerCase()) {
      case 'momo':
        return l10n.paymentMomo;
      case 'zalopay':
        return l10n.paymentZaloPay;
      case 'bank':
        return l10n.paymentBankTransfer;
      case 'card':
        return l10n.paymentCard;
      default:
        return l10n.paymentUnknown;
    }
  }
}