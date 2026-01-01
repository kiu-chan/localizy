import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:localizy/l10n/app_localizations.dart';

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
    if (!_formKey.currentState! .validate()) {
      return;
    }

    setState(() {
      _isSearching = true;
      _ticketInfo = null;
    });

    // Simulate API call
    await Future. delayed(const Duration(seconds: 1));

    // Mock data - replace with real API call
    setState(() {
      _isSearching = false;
      _ticketInfo = {
        'ticketCode': _searchMethod == 'ticket' 
            ? _ticketCodeController.text 
            : 'PKT${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        'licensePlate': _searchMethod == 'license'
            ? _licensePlateController.text
            : '30A-12345',
        'zone': 'A1',
        'status': 'active', // active, expired, paid
        'startTime': DateTime.now().subtract(const Duration(hours: 2)),
        'endTime': DateTime. now().add(const Duration(hours: 2)),
        'duration': '4 hours',
        'amount': 35000,
        'paymentMethod': 'MoMo',
        'paidAt': DateTime.now().subtract(const Duration(hours: 2)),
      };
    });
  }

  void _clearSearch() {
    setState(() {
      _ticketCodeController.clear();
      _licensePlateController.clear();
      _ticketInfo = null;
    });
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    );
  }

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
                        color: Colors.white. withOpacity(0.2),
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
                  color: Colors. white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black. withOpacity(0.05),
                      blurRadius:  10,
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
                      color: Colors.black.withOpacity(0.05),
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
                color: statusColor.withOpacity(0.3),
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
                color: Colors.black.withOpacity(0.05),
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
                '${_formatCurrency(_ticketInfo!['amount'])} VND',
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
                onPressed: () {
                  // TODO: Extend parking time
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Extension feature in development')),
                  );
                },
                icon: const Icon(Icons.add_circle),
                label: const Text('Extend'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor:  Colors.white,
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
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.bold :  FontWeight.w600,
            color: isHighlight ? Colors.orange.shade700 : Colors.black87,
          ),
          textAlign: TextAlign.right,
        ),
      ],
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