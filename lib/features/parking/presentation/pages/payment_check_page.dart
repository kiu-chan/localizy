import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:localizy/core/config/currency_config.dart';
import 'package:localizy/core/widgets/receipt_share.dart';
import 'package:localizy/core/widgets/receipt_widget.dart';
import 'package:localizy/l10n/app_localizations.dart';

import '../../data/parking_repository.dart';
import '../../domain/parking_ticket.dart';

class PaymentCheckPage extends ConsumerStatefulWidget {
  const PaymentCheckPage({super.key});

  @override
  ConsumerState<PaymentCheckPage> createState() => _PaymentCheckPageState();
}

class _PaymentCheckPageState extends ConsumerState<PaymentCheckPage> {
  final _formKey = GlobalKey<FormState>();
  final _ticketCodeController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _ticketCodeFocusNode = FocusNode();
  final _licensePlateFocusNode = FocusNode();

  bool _isSearching = false;
  ParkingTicket? _ticket;
  String _zoneName = '';
  String _searchMethod = 'ticket'; // 'ticket' or 'license'

  @override
  void initState() {
    super.initState();
    _ticketCodeFocusNode.addListener(() => setState(() {}));
    _licensePlateFocusNode.addListener(() => setState(() {}));
    _ticketCodeController.addListener(() => setState(() {}));
    _licensePlateController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ticketCodeController.dispose();
    _licensePlateController.dispose();
    _ticketCodeFocusNode.dispose();
    _licensePlateFocusNode.dispose();
    super.dispose();
  }

  Future<void> _searchTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSearching = true;
      _ticket = null;
    });

    final repo = ref.read(parkingRepositoryProvider);
    try {
      final ticket = _searchMethod == 'ticket'
          ? await repo.getByTicketCode(_ticketCodeController.text.trim())
          : await repo.getByLicensePlate(_licensePlateController.text.trim());
      final zoneName = await repo.zoneNameFor(ticket.addressId);

      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _ticket = ticket;
        _zoneName = zoneName;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  e.toString().contains('404')
                      ? 'Ticket not found'
                      : 'Error. Please try again.',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _clearSearch() {
    setState(() {
      _ticketCodeController.clear();
      _licensePlateController.clear();
      _ticket = null;
    });
  }

  String _formatCurrency(num amount) =>
      CurrencyConfig.format(amount.toDouble());

  Color _getStatusColor(String status) => switch (status) {
        'active' => Colors.green,
        'expired' => Colors.red,
        'paid' => Colors.blue,
        _ => Colors.grey,
      };

  String _getStatusText(String status) => switch (status) {
        'active' => 'Active',
        'expired' => 'Expired',
        'paid' => 'Paid',
        _ => 'Unknown',
      };

  IconData _getStatusIcon(String status) => switch (status) {
        'active' => Icons.check_circle,
        'expired' => Icons.error,
        'paid' => Icons.paid,
        _ => Icons.info,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l10n.paymentCheck,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_ticket != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _clearSearch,
              tooltip: 'New Search',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Search Parking Ticket',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Check information & status',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Search method tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                          'Ticket Code', Icons.confirmation_number, 'ticket'),
                    ),
                    Expanded(
                      child: _buildTabButton(
                          'License Plate', Icons.directions_car, 'license'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Search form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_searchMethod == 'ticket') ...[
                      const Text(
                        'Enter parking ticket code',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildSearchField(
                        controller: _ticketCodeController,
                        focusNode: _ticketCodeFocusNode,
                        labelText: 'Ticket Code',
                        hintText: 'e.g.: PKT123456',
                        prefixIcon: Icons.confirmation_number,
                        emptyError: 'Please enter ticket code',
                      ),
                    ] else ...[
                      const Text(
                        'Enter license plate number',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildSearchField(
                        controller: _licensePlateController,
                        focusNode: _licensePlateFocusNode,
                        labelText: 'License Plate',
                        hintText: 'e.g.: 30A-12345',
                        prefixIcon: Icons.directions_car,
                        emptyError: 'Please enter license plate',
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSearching ? null : _searchTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSearching
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'Search',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              // Results
              if (_ticket != null) ...[
                const SizedBox(height: 24),
                _buildTicketInfo(_ticket!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required String emptyError,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: (focusNode.hasFocus || controller.text.isNotEmpty)
              ? Colors.orange.shade700
              : Colors.grey,
        ),
        hintText: hintText,
        prefixIcon: Icon(
          prefixIcon,
          color: focusNode.hasFocus ? Colors.orange.shade700 : Colors.grey,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => controller.clear(),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      textCapitalization: TextCapitalization.characters,
      validator: (value) =>
          (value == null || value.isEmpty) ? emptyError : null,
    );
  }

  Widget _buildTabButton(String label, IconData icon, String method) {
    final isSelected = _searchMethod == method;
    return InkWell(
      onTap: () {
        setState(() {
          _searchMethod = method;
          _ticket = null;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.shade700 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketInfo(ParkingTicket ticket) {
    final statusColor = _getStatusColor(ticket.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(_getStatusIcon(ticket.status),
                  color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text(
                _getStatusText(ticket.status),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (ticket.status == 'active') ...[
                const SizedBox(height: 8),
                Text(
                  'Remaining: ${_calculateTimeRemaining(ticket.endTime)}',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Ticket details card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long,
                      color: Colors.orange.shade700, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Ticket Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildInfoRow(Icons.confirmation_number, 'Ticket Code',
                  ticket.ticketCode,
                  showCopy: true),
              const Divider(height: 24),
              _buildInfoRow(
                  Icons.directions_car, 'License Plate', ticket.licensePlate),
              const Divider(height: 24),
              _buildInfoRow(Icons.location_on, 'Zone', _zoneName),
              const Divider(height: 24),
              _buildInfoRow(Icons.access_time, 'Duration', ticket.duration),
              const Divider(height: 24),
              _buildInfoRow(Icons.schedule, 'Start Time',
                  DateFormat('HH:mm - dd/MM/yyyy').format(ticket.startTime)),
              const Divider(height: 24),
              _buildInfoRow(Icons.event_available, 'End Time',
                  DateFormat('HH:mm - dd/MM/yyyy').format(ticket.endTime)),
              const Divider(height: 24),
              _buildInfoRow(Icons.payment, 'Payment', ticket.paymentMethod),
              const Divider(height: 24),
              _buildInfoRow(
                  Icons.attach_money, 'Amount', _formatCurrency(ticket.amount),
                  isHighlight: true),
              const Divider(height: 24),
              _buildInfoRow(
                  Icons.check_circle,
                  'Paid At',
                  DateFormat('HH:mm - dd/MM/yyyy')
                      .format(ticket.paidAt ?? ticket.startTime)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(Icons.search),
                label: const Text('New Search'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey.shade300, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _shareReceipt(ticket),
                icon: const Icon(Icons.download),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool showCopy = false, bool isHighlight = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isHighlight ? Colors.orange.shade700 : Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
        if (showCopy)
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Copied'),
                    ],
                  ),
                  backgroundColor: Colors.green.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(Icons.copy, size: 16, color: Colors.orange.shade700),
            ),
          ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight ? Colors.orange.shade700 : Colors.black87,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _shareReceipt(ParkingTicket ticket) {
    final (statusLabel, statusIcon, statusColor) = switch (ticket.status) {
      'active' => (
          'Active',
          Icons.check_circle_outline,
          const Color(0xFF43A047)
        ),
      'expired' => (
          'Expired',
          Icons.check_circle_outline,
          const Color(0xFF757575)
        ),
      'cancelled' => (
          'Cancelled',
          Icons.cancel_outlined,
          const Color(0xFFE53935)
        ),
      _ => ('Pending', Icons.hourglass_empty, const Color(0xFFFB8C00)),
    };

    return shareReceiptImage(
      context,
      receipt: ReceiptWidget(
        headerColor: const Color(0xFF1565C0),
        typeIcon: Icons.local_parking,
        subtitle: 'Parking Payment',
        amountText: _formatCurrency(ticket.amount),
        statusLabel: statusLabel,
        statusIcon: statusIcon,
        badgeText: ticket.licensePlate,
        rows: [
          ReceiptRow('Ticket Code', ticket.ticketCode),
          ReceiptRow('Date',
              DateFormat('HH:mm - dd/MM/yyyy').format(ticket.startTime)),
          ReceiptRow('Zone', _zoneName),
          ReceiptRow('Duration', ticket.duration),
          ReceiptRow('Payment', ticket.paymentMethod),
          ReceiptRow('Status', statusLabel, valueColor: statusColor),
        ],
      ),
      fileName: 'parking_receipt_${ticket.ticketCode}.png',
      shareText: 'Parking Receipt · Localizy',
    );
  }

  String _calculateTimeRemaining(DateTime endTime) {
    final remaining = endTime.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    return hours > 0 ? '$hours hours $minutes mins' : '$minutes mins';
  }
}
