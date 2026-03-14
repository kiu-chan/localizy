import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:localizy/api/address_api.dart';
import 'package:localizy/api/main_api.dart';
import 'package:localizy/api/transaction_api.dart';
import 'package:localizy/configs/currency_config.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/home/parking/parking_zone_detail_map_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AllTransactionsTab extends StatefulWidget {
  const AllTransactionsTab({super.key});

  @override
  State<AllTransactionsTab> createState() => _AllTransactionsTabState();
}

class _AllTransactionsTabState extends State<AllTransactionsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        MainApi.instance.getJson('api/transactions/my-transactions'),
        MainApi.instance.getJson('api/addresses/parking-zones'),
      ]);

      final rawData = results[0];
      final rawZones = results[1];
      debugPrint('[AllTransactionsTab] my-transactions response: ${jsonEncode(rawData)}');

      final zoneMap = {
        for (final z in (rawZones as List).map((e) => ParkingZoneItem.fromJson(e as Map<String, dynamic>)))
          z.id: z,
      };

      setState(() {
        _transactions = (rawData as List).map((e) {
          final raw = e as Map<String, dynamic>;
          final t = Transaction.fromJson(raw);

          // For parking type, match zone by location field (zone ID)
          final zone = t.type == 'parking' ? zoneMap[t.location] : null;

          // For verification type, parse lat/lng from location string "Lat: X, Lng: Y"
          double? lat = zone?.latitude;
          double? lng = zone?.longitude;
          String displayLocation = zone != null ? '${zone.code} - ${zone.name}' : t.location;

          if (lat == null && t.type == 'verification') {
            final match = RegExp(r'Lat:\s*([\d.]+),\s*Lng:\s*([\d.]+)').firstMatch(t.location);
            if (match != null) {
              lat = double.tryParse(match.group(1)!);
              lng = double.tryParse(match.group(2)!);
            }
          }

          return {
            'id': t.id,
            'type': t.type,
            'title': t.title,
            'location': displayLocation,
            'amount': t.amount,
            'status': t.status,
            'paymentMethod': t.paymentMethod,
            'date': t.date,
            'licensePlate': t.licensePlate,
            'duration': t.duration,
            'lat': lat,
            'lng': lng,
            'zoneCode': zone?.code,
            'zoneName': zone?.name,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[AllTransactionsTab] Error loading: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshTransactions() async {
    await _loadTransactions();
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
              onPressed: _loadTransactions,
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
      onRefresh: _refreshTransactions,
      color: Colors.green.shade700,
      child: _transactions.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                return _buildTransactionCard(_transactions[index]);
              },
            ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showTransactionDetail(transaction),
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
                      color: _getTypeColor(transaction['type']).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getTypeIcon(transaction['type']),
                      color: _getTypeColor(transaction['type']),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction['location'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatCurrency(context, transaction['amount']),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getStatusIcon(transaction['status']),
                            size: 14,
                            color: _getStatusColor(transaction['status']),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getStatusText(transaction['status']),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(transaction['status']),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                        _formatDate(transaction['date']),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(_getPaymentIcon(transaction['paymentMethod']),
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        _getPaymentMethodName(context, transaction['paymentMethod']),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  if (transaction['licensePlate'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        transaction['licensePlate'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMap(Map<String, dynamic> transaction) {
    final lat = transaction['lat'];
    final lng = transaction['lng'];
    if (lat == null || lng == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParkingZoneDetailMapPage(
          zoneId: transaction['id'] ?? '',
          zoneCode: transaction['zoneCode'] ?? transaction['id'] ?? '',
          zoneName: transaction['zoneName'] ?? transaction['title'] ?? '',
          latitude: (lat as num).toDouble(),
          longitude: (lng as num).toDouble(),
        ),
      ),
    );
  }

  void _showTransactionDetail(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransactionDetailSheet(transaction),
    );
  }

  Future<void> _downloadAsImage(Map<String, dynamic> transaction) async {
    final amountStr = _formatCurrency(context, transaction['amount'] ?? 0);
    final dateStr = _formatDate(transaction['date'] ?? DateTime.now());
    final paymentStr =
        _getPaymentMethodName(context, transaction['paymentMethod'] ?? '');
    final bytes = await _captureWidgetAsImage(
      _buildReceiptWidget(
        transaction: transaction,
        amountStr: amountStr,
        dateStr: dateStr,
        paymentStr: paymentStr,
      ),
    );
    if (bytes == null) return;
    final dir = await getTemporaryDirectory();
    final id =
        (transaction['id'] ?? DateTime.now().millisecondsSinceEpoch).toString();
    final file = File('${dir.path}/receipt_$id.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
        [XFile(file.path)], text: 'Transaction Receipt · Localizy');
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
    required Map<String, dynamic> transaction,
    required String amountStr,
    required String dateStr,
    required String paymentStr,
  }) {
    final type = transaction['type'] as String? ?? '';
    final status = transaction['status'] as String? ?? '';

    final Color headerColor;
    final IconData typeIcon;
    switch (type) {
      case 'parking':
        headerColor = const Color(0xFF1565C0);
        typeIcon = Icons.local_parking;
        break;
      case 'verification':
        headerColor = const Color(0xFF6A1B9A);
        typeIcon = Icons.verified_outlined;
        break;
      default:
        headerColor = const Color(0xFF2E7D32);
        typeIcon = Icons.receipt_long;
    }

    final IconData statusIcon;
    final String statusStr;
    final Color statusColor;
    switch (status) {
      case 'success':
        statusIcon = Icons.check_circle_outline;
        statusStr = 'Success';
        statusColor = const Color(0xFF43A047);
        break;
      case 'failed':
        statusIcon = Icons.cancel_outlined;
        statusStr = 'Failed';
        statusColor = const Color(0xFFE53935);
        break;
      default:
        statusIcon = Icons.hourglass_empty;
        statusStr = 'Pending';
        statusColor = const Color(0xFFFB8C00);
    }

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
              color: Colors.black.withOpacity(0.10),
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      headerColor,
                      Color.lerp(headerColor, Colors.black, 0.22)!,
                    ],
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
                            color: Colors.white.withOpacity(0.7), size: 14),
                        const SizedBox(width: 5),
                        Text(
                          'C I T I Z E N',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
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
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.25), width: 1.5),
                      ),
                      child: Icon(typeIcon, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      transaction['title'] ?? '',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      amountStr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: Colors.white, size: 13),
                          const SizedBox(width: 5),
                          Text(
                            statusStr,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
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
                    _buildReceiptDetailRow(
                        'Transaction ID', transaction['id'] ?? ''),
                    _buildReceiptDetailRow('Date', dateStr),
                    _buildReceiptDetailRow(
                        'Location', transaction['location'] ?? ''),
                    if (transaction['licensePlate'] != null)
                      _buildReceiptDetailRow('License Plate',
                          transaction['licensePlate'] as String),
                    if (transaction['duration'] != null)
                      _buildReceiptDetailRow(
                          'Duration', transaction['duration'] as String),
                    _buildReceiptDetailRow('Payment', paymentStr),
                    _buildReceiptDetailRow('Status', statusStr,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_outlined,
                            size: 12, color: headerColor),
                        const SizedBox(width: 5),
                        Text(
                          'Official Receipt · Citizen',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 10),
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

  Widget _buildTransactionDetailSheet(Map<String, dynamic> transaction) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                          color: _getTypeColor(transaction['type']).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getTypeIcon(transaction['type']),
                          color: _getTypeColor(transaction['type']),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  _getStatusIcon(transaction['status']),
                                  size: 16,
                                  color: _getStatusColor(transaction['status']),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getStatusText(transaction['status']),
                                  style: TextStyle(
                                    color: _getStatusColor(transaction['status']),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Amount',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatCurrency(context, transaction['amount']),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow('Transaction ID', transaction['id']),
                  _buildDetailRow('Date & Time', _formatDate(transaction['date'])),
                  _buildDetailRow('Location', transaction['location']),
                  if (transaction['licensePlate'] != null)
                    _buildDetailRow('License Plate', transaction['licensePlate']),
                  if (transaction['duration'] != null)
                    _buildDetailRow('Duration', transaction['duration']),
                  _buildDetailRow(
                    'Payment Method',
                    _getPaymentMethodName(context, transaction['paymentMethod']),
                    icon: _getPaymentIcon(transaction['paymentMethod']),
                  ),
                  const SizedBox(height: 24),
                  if (transaction['lat'] != null && transaction['lng'] != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _openMap(transaction);
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
                      onPressed: () => _downloadAsImage(transaction),
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
            child: Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text(
            'No Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
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
    switch (status) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle;
      case 'failed':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'success':
        return 'Success';
      case 'failed':
        return 'Failed';
      case 'pending':
        return 'Pending';
      default:
        return 'Unknown';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'parking':
        return Colors.blue;
      case 'verification':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'parking':
        return Icons.local_parking;
      case 'verification':
        return Icons.verified_outlined;
      default:
        return Icons.receipt;
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
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
    switch (method) {
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