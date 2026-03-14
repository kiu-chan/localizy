import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:localizy/api/address_api.dart';
import 'package:localizy/api/main_api.dart';
import 'package:localizy/api/parking_api.dart';
import 'package:localizy/configs/currency_config.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PaymentCheckPage extends StatefulWidget {
  const PaymentCheckPage({super.key});

  @override
  State<PaymentCheckPage> createState() => _PaymentCheckPageState();
}

class _PaymentCheckPageState extends State<PaymentCheckPage> {
  final _formKey = GlobalKey<FormState>();
  final _ticketCodeController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _ticketCodeFocusNode = FocusNode();
  final _licensePlateFocusNode = FocusNode();
  
  bool _isSearching = false;
  Map<String, dynamic>? _ticketInfo;
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
    _ticketCodeFocusNode. dispose();
    _licensePlateFocusNode.dispose();
    super.dispose();
  }

  Future<void> _searchTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSearching = true;
      _ticketInfo = null;
    });

    try {
      final ParkingTicket t;
      if (_searchMethod == 'ticket') {
        t = await ParkingApi.getByTicketCode(_ticketCodeController.text.trim());
      } else {
        t = await ParkingApi.getByLicensePlate(_licensePlateController.text.trim());
      }

      String zoneName = t.addressId;
      try {
        final rawZones = await MainApi.instance.getJson('api/addresses/parking-zones');
        final zones = (rawZones as List)
            .map((e) => ParkingZoneItem.fromJson(e as Map<String, dynamic>))
            .toList();
        final zone = zones.firstWhere((z) => z.id == t.addressId, orElse: () => ParkingZoneItem(id: '', code: '', name: '', latitude: 0, longitude: 0, availableSpots: 0, totalSpots: 0, pricePerHour: 0));
        if (zone.name.isNotEmpty) zoneName = zone.name;
      } catch (_) {}

      setState(() {
        _isSearching = false;
        _ticketInfo = {
          'ticketCode': t.ticketCode,
          'licensePlate': t.licensePlate,
          'zone': zoneName,
          'status': t.status,
          'startTime': t.startTime,
          'endTime': t.endTime,
          'duration': t.duration,
          'amount': t.amount,
          'paymentMethod': t.paymentMethod,
          'paidAt': t.paidAt ?? t.startTime,
        };
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.toString().contains('404') ? 'Ticket not found' : 'Error. Please try again.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _clearSearch() {
    setState(() {
      _ticketCodeController.clear();
      _licensePlateController.clear();
      _ticketInfo = null;
    });
  }

  String _formatCurrency(num amount) => CurrencyConfig.format(amount.toDouble());

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':  
        return Colors.green;
      case 'expired': 
        return Colors.red;
      case 'paid':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active': 
        return 'Active';
      case 'expired': 
        return 'Expired';
      case 'paid': 
        return 'Paid';
      default:  
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'active':  
        return Icons.check_circle;
      case 'expired':  
        return Icons.error;
      case 'paid': 
        return Icons.paid;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations. of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l10n.paymentCheck,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors. white,
        elevation: 0,
        actions: [
          if (_ticketInfo != null)
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
                width:  double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade700],
                    begin: Alignment. topLeft,
                    end:  Alignment.bottomRight,
                  ),
                  borderRadius:  BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade200,
                      blurRadius:  10,
                      offset:  const Offset(0, 4),
                    ),
                  ],
                ),
                child:  Row(
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
                        crossAxisAlignment:  CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Search Parking Ticket',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors. white,
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
                        'Ticket Code',
                        Icons.confirmation_number,
                        'ticket',
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        'License Plate',
                        Icons.directions_car,
                        'license',
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height:  24),
              
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
                        style:  TextStyle(
                          fontSize:  16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ticketCodeController,
                        focusNode: _ticketCodeFocusNode,
                        decoration:  InputDecoration(
                          labelText: 'Ticket Code',
                          labelStyle: TextStyle(
                            color: (_ticketCodeFocusNode. hasFocus || _ticketCodeController.text.isNotEmpty)
                                ? Colors.orange.shade700
                                : Colors.grey,
                          ),
                          hintText: 'e.g.:  PKT123456',
                          prefixIcon: Icon(
                            Icons.confirmation_number,
                            color: _ticketCodeFocusNode. hasFocus
                                ? Colors.orange.shade700
                                : Colors.grey,
                          ),
                          suffixIcon: _ticketCodeController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons. clear),
                                  onPressed: () => _ticketCodeController.clear(),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:  BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey. shade300),
                          ),
                          focusedBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color:  Colors.orange.shade700, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        textCapitalization: TextCapitalization. characters,
                        validator: (value) {
                          if (value == null || value. isEmpty) {
                            return 'Please enter ticket code';
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      const Text(
                        'Enter license plate number',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _licensePlateController,
                        focusNode: _licensePlateFocusNode,
                        decoration:  InputDecoration(
                          labelText: 'License Plate',
                          labelStyle: TextStyle(
                            color: (_licensePlateFocusNode.hasFocus || _licensePlateController.text.isNotEmpty)
                                ? Colors.orange.shade700
                                : Colors.grey,
                          ),
                          hintText: 'e.g.: 30A-12345',
                          prefixIcon: Icon(
                            Icons.directions_car,
                            color: _licensePlateFocusNode.hasFocus
                                ? Colors.orange.shade700
                                : Colors.grey,
                          ),
                          suffixIcon: _licensePlateController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => _licensePlateController.clear(),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:  BorderSide(color: Colors. orange.shade700, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter license plate';
                          }
                          return null;
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    SizedBox(
                      width:  double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSearching ? null : _searchTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor:  Colors.white,
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
                                mainAxisAlignment:  MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'Search',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:  FontWeight.w600,
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
              if (_ticketInfo != null) ...[
                const SizedBox(height:  24),
                _buildTicketInfo(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon, String method) {
    final isSelected = _searchMethod == method;
    return InkWell(
      onTap: () {
        setState(() {
          _searchMethod = method;
          _ticketInfo = null;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets. symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange. shade700 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey. shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white :  Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketInfo() {
    final status = _ticketInfo! ['status'] as String;
    final statusColor = _getStatusColor(status);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius. circular(16),
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
              Icon(
                _getStatusIcon(status),
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height:  12),
              Text(
                _getStatusText(status),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (status == 'active') ...[
                const SizedBox(height: 8),
                Text(
                  'Remaining: ${_calculateTimeRemaining(_ticketInfo!['endTime'])}',
                  style: const TextStyle(
                    fontSize:  16,
                    color:  Colors.white70,
                  ),
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
            color: Colors. white,
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
            crossAxisAlignment:  CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long, color: Colors.orange.shade700, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Ticket Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height:  20),
              
              _buildInfoRow(
                Icons.confirmation_number,
                'Ticket Code',
                _ticketInfo!['ticketCode'],
                showCopy: true,
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.directions_car,
                'License Plate',
                _ticketInfo!['licensePlate'],
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons. location_on,
                'Zone',
                _ticketInfo! ['zone'],
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.access_time,
                'Duration',
                _ticketInfo! ['duration'],
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.schedule,
                'Start Time',
                DateFormat('HH:mm - dd/MM/yyyy').format(_ticketInfo!['startTime']),
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.event_available,
                'End Time',
                DateFormat('HH:mm - dd/MM/yyyy').format(_ticketInfo!['endTime']),
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.payment,
                'Payment',
                _ticketInfo! ['paymentMethod'],
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.attach_money,
                'Amount',
                _formatCurrency(_ticketInfo!['amount'] as num),
                isHighlight: true,
              ),
              const Divider(height:  24),
              _buildInfoRow(
                Icons.check_circle,
                'Paid At',
                DateFormat('HH:mm - dd/MM/yyyy').format(_ticketInfo!['paidAt']),
              ),
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
                onPressed: () => _downloadAsImage(_ticketInfo!),
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

  Widget _buildInfoRow(IconData icon, String label, String value, {bool showCopy = false, bool isHighlight = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color:  isHighlight ? Colors.orange. shade700 : Colors.grey. shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
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
            child:  Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.copy,
                size: 16,
                color: Colors.orange.shade700,
              ),
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

  Future<void> _downloadAsImage(Map<String, dynamic> info) async {
    final bytes = await _captureWidgetAsImage(_buildReceiptWidget(info));
    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate image')),
        );
      }
      return;
    }
    final dir = await getTemporaryDirectory();
    final code = (info['ticketCode'] ?? DateTime.now().millisecondsSinceEpoch).toString();
    final file = File('${dir.path}/parking_receipt_$code.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Parking Receipt · Localizy');
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
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    } finally {
      entry.remove();
    }
  }

  Widget _buildReceiptWidget(Map<String, dynamic> info) {
    final status = info['status'] as String? ?? '';
    final amount = info['amount'] as num? ?? 0;
    final amountStr = _formatCurrency(amount);
    final startTime = info['startTime'] as DateTime?;
    final dateStr = startTime != null ? DateFormat('HH:mm - dd/MM/yyyy').format(startTime) : '';

    final IconData statusIcon;
    final String statusStr;
    final Color statusColor;
    switch (status) {
      case 'active':
        statusIcon = Icons.check_circle_outline;
        statusStr = 'Active';
        statusColor = const Color(0xFF43A047);
        break;
      case 'expired':
        statusIcon = Icons.check_circle_outline;
        statusStr = 'Expired';
        statusColor = const Color(0xFF757575);
        break;
      case 'cancelled':
        statusIcon = Icons.cancel_outlined;
        statusStr = 'Cancelled';
        statusColor = const Color(0xFFE53935);
        break;
      default:
        statusIcon = Icons.hourglass_empty;
        statusStr = 'Pending';
        statusColor = const Color(0xFFFB8C00);
    }

    const headerColor = Color(0xFF1565C0);

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
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [headerColor, Color(0xFF0D47A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: Colors.white.withValues(alpha: 0.7), size: 14),
                        const SizedBox(width: 5),
                        Text(
                          'L O C A L I Z Y',
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
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                      ),
                      child: const Icon(Icons.local_parking, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Parking Payment',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: Colors.white, size: 13),
                          const SizedBox(width: 5),
                          Text(
                            statusStr,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        info['licensePlate'] ?? '',
                        style: const TextStyle(
                          color: Color(0xFF1565C0),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Dashed separator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: List.generate(
                    32,
                    (i) => Expanded(
                      child: Container(
                        height: 1.5,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        color: i.isEven ? Colors.grey.shade200 : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
              // Details
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Column(
                  children: [
                    _buildReceiptDetailRow('Ticket Code', info['ticketCode'] ?? ''),
                    _buildReceiptDetailRow('Date', dateStr),
                    _buildReceiptDetailRow('Zone', info['zone'] ?? ''),
                    _buildReceiptDetailRow('Duration', info['duration'] ?? ''),
                    _buildReceiptDetailRow('Payment', info['paymentMethod'] ?? ''),
                    _buildReceiptDetailRow('Status', statusStr, valueColor: statusColor),
                  ],
                ),
              ),
              // Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  border: Border(top: BorderSide(color: Colors.grey.shade100)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_outlined, size: 12, color: headerColor),
                        const SizedBox(width: 5),
                        Text(
                          'Official Receipt · Localizy',
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
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
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

  Widget _buildReceiptDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w400),
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

  String _calculateTimeRemaining(DateTime endTime) {
    final remaining = endTime.difference(DateTime. now());
    if (remaining.isNegative) return 'Expired';
    
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    
    if (hours > 0) {
      return '$hours hours $minutes mins';
    } else {
      return '$minutes mins';
    }
  }
}