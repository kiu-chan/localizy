import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localizy/api/address_api.dart';
import 'package:localizy/api/main_api.dart';
import 'package:localizy/api/parking_api.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/home/parking/parking_zone_detail_map_page.dart';

class ParkingTransactionsTab extends StatefulWidget {
  const ParkingTransactionsTab({super.key});

  @override
  State<ParkingTransactionsTab> createState() => _ParkingTransactionsTabState();
}

class _ParkingTransactionsTabState extends State<ParkingTransactionsTab> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _transactions = [];
  Map<String, ParkingZoneItem> _zoneMap = {};

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
      final rawTickets = await MainApi.instance.getJson('api/parking/my-tickets');
      debugPrint('[ParkingTab] my-tickets response: ${jsonEncode(rawTickets)}');

      final rawZones = await MainApi.instance.getJson('api/addresses/parking-zones');
      debugPrint('[ParkingTab] parking-zones response: ${jsonEncode(rawZones)}');

      final items = (rawTickets as List)
          .map((e) => ParkingTicket.fromJson(e as Map<String, dynamic>))
          .toList();

      final zones = (rawZones as List)
          .map((e) => ParkingZoneItem.fromJson(e as Map<String, dynamic>))
          .toList();

      final zoneMap = {for (final z in zones) z.id: z};

      setState(() {
        _zoneMap = zoneMap;
        _transactions = items.map((t) {
          final zone = _zoneMap[t.addressId];
          final location = zone != null ? '${zone.code} - ${zone.name}' : t.addressId;
          return {
            'id': t.ticketCode.isNotEmpty ? t.ticketCode : t.id,
            'title': 'Parking Payment',
            'location': location,
            'licensePlate': t.licensePlate,
            'amount': t.amount,
            'status': t.uiStatus,
            'date': t.startTime,
            'paymentMethod': t.paymentMethod,
            'duration': t.duration,
            // Zone map data for navigation
            'zoneId': zone?.id ?? t.addressId,
            'zoneCode': zone?.code ?? '',
            'zoneName': zone?.name ?? '',
            'lat': zone?.latitude,
            'lng': zone?.longitude,
            'availableSpots': zone?.availableSpots ?? 0,
            'totalSpots': zone?.totalSpots ?? 0,
            'pricePerHour': zone?.pricePerHour ?? 0,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[ParkingTab] Error loading: $e');
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
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_parking,
                      color: Colors.blue,
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
                      Icon(Icons.timer, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        transaction['duration'],
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
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

  void _showTransactionDetail(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransactionDetailSheet(transaction),
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
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_parking,
                          color: Colors.blue,
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
                  _buildDetailRow('License Plate', transaction['licensePlate']),
                  _buildDetailRow('Duration', transaction['duration']),
                  _buildDetailRow(
                    'Payment Method',
                    _getPaymentMethodName(context, transaction['paymentMethod']),
                    icon: _getPaymentIcon(transaction['paymentMethod']),
                  ),
                  const SizedBox(height: 24),
                  // View on Map button — chỉ hiện khi có tọa độ
                  if (transaction['lat'] != null && transaction['lng'] != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ParkingZoneDetailMapPage(
                                zoneId: transaction['zoneId'] as String,
                                zoneCode: transaction['zoneCode'] as String,
                                zoneName: transaction['zoneName'] as String,
                                latitude: (transaction['lat'] as double),
                                longitude: (transaction['lng'] as double),
                                availableSpots: transaction['availableSpots'] as int,
                                totalSpots: transaction['totalSpots'] as int,
                                pricePerHour: transaction['pricePerHour'] as int,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('View on Map'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.support_agent),
                          label: const Text('Support'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
            child: Icon(Icons.local_parking, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text(
            'No Parking Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your parking history will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(BuildContext context, int amount) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'vi') {
      return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
    }
    return NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 0)
        .format(amount / 23000);
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