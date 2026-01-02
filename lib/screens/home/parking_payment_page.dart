import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/home/parking/vehicle_info_section.dart';
import 'package:localizy/screens/home/parking/duration_selection_section.dart';
import 'package:localizy/screens/home/parking/payment_method_section.dart';

class ParkingPaymentPage extends StatefulWidget {
  const ParkingPaymentPage({super.key});

  @override
  State<ParkingPaymentPage> createState() => _ParkingPaymentPageState();
}

class _ParkingPaymentPageState extends State<ParkingPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _licensePlateController = TextEditingController();
  final _parkingZoneController = TextEditingController();
  
  String? _selectedPaymentMethod;
  String? _selectedDuration;
  DateTime? _startTime;
  int _parkingFee = 0;
  
  final Map<String, Map<String, dynamic>> _durationPrices = {
    '1h': {'price': 10000, 'label': '1 hour', 'icon': Icons.access_time},
    '2h': {'price': 18000, 'label': '2 hours', 'icon': Icons.access_time},
    '4h': {'price': 35000, 'label': '4 hours', 'icon': Icons.schedule},
    '8h': {'price': 65000, 'label': '8 hours', 'icon': Icons.schedule},
    '1day': {'price': 100000, 'label': '1 day', 'icon': Icons.today},
  };

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _parkingZoneController.dispose();
    super.dispose();
  }

  void _selectDuration(String duration) {
    setState(() {
      _selectedDuration = duration;
      _parkingFee = _durationPrices[duration]! ['price'] as int;
    });
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPaymentMethod == null) {
      _showErrorSnackBar('Please select a payment method');
      return;
    }

    if (_selectedDuration == null) {
      _showErrorSnackBar('Please select parking duration');
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Processing payment...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait a moment',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors. grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Simulate payment processing
    await Future. delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      _showSuccessDialog();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog() {
    final l10n = AppLocalizations.of(context)!;
    final ticketCode = 'PKT${DateTime.now().millisecondsSinceEpoch. toString().substring(5)}';
    final endTime = _startTime!.add(_getDurationFromKey(_selectedDuration!));
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child:  Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color:  Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors. green.shade600,
                    size: 56,
                  ),
                ),
                
                const SizedBox(height:  24),
                
                const Text(
                  'Payment Successful!',
                  style:  TextStyle(
                    fontSize:  24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Your parking ticket has been activated',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors. grey.shade600,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Ticket code
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green. shade400, Colors.green.shade700],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'PARKING TICKET CODE',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ticketCode,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors. white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton. icon(
                        onPressed:  () {
                          Clipboard.setData(ClipboardData(text: ticketCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text('Code copied'),
                                ],
                              ),
                              backgroundColor: Colors.green.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius. circular(10),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                        label: const Text(
                          'Copy Code',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color:  Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Ticket details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        Icons.directions_car,
                        'License Plate',
                        _licensePlateController.text. toUpperCase(),
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        Icons.location_on,
                        'Zone',
                        _parkingZoneController.text.toUpperCase(),
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        Icons.access_time,
                        'Duration',
                        _durationPrices[_selectedDuration! ]!['label'],
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        Icons.schedule,
                        'Start Time',
                        DateFormat('HH:mm - dd/MM/yyyy').format(_startTime!),
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        Icons.event_available,
                        'End Time',
                        DateFormat('HH:mm - dd/MM/yyyy').format(endTime),
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        Icons.payments,
                        'Payment',
                        _getPaymentMethodName(l10n, _selectedPaymentMethod!),
                        isHighlight: true,
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        Icons.attach_money,
                        'Amount',
                        '${_formatCurrency(_parkingFee)} VND',
                        isHighlight: true,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:  () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Back to home
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:  () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          // TODO: Navigate to ticket details
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'View Ticket',
                          style:  TextStyle(
                            fontSize:  16,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isHighlight ? Colors.green.shade700 : Colors.grey.shade600,
        ),
        const SizedBox(width:  12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize:  14,
            fontWeight: isHighlight ? FontWeight.bold :  FontWeight.w600,
            color: isHighlight ? Colors. green.shade700 : Colors. black87,
          ),
        ),
      ],
    );
  }

  Duration _getDurationFromKey(String key) {
    switch (key) {
      case '1h': 
        return const Duration(hours: 1);
      case '2h':
        return const Duration(hours: 2);
      case '4h':
        return const Duration(hours:  4);
      case '8h':
        return const Duration(hours: 8);
      case '1day':
        return const Duration(days: 1);
      default:
        return const Duration(hours: 1);
    }
  }

  String _getPaymentMethodName(AppLocalizations l10n, String method) {
    switch (method) {
      case 'momo':
        return l10n.paymentMomo;
      case 'zalopay':
        return l10n.paymentZaloPay;
      case 'bank':
        return l10n. paymentBankTransfer;
      case 'card':
        return l10n. paymentCard;
      default: 
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations. of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l10n.parkingPayment,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header info card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration:  BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green. shade400, Colors.green.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade200,
                            blurRadius:  10,
                            offset:  const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white. withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_parking,
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
                                  'Quick Payment',
                                  style: TextStyle(
                                    fontSize:  18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Safe & Convenient',
                                  style: TextStyle(
                                    fontSize:  14,
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
                    
                    // Vehicle Information Section
                    VehicleInfoSection(
                      licensePlateController: _licensePlateController,
                      parkingZoneController:  _parkingZoneController,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Duration Selection Section
                    DurationSelectionSection(
                      durationPrices: _durationPrices,
                      selectedDuration: _selectedDuration,
                      onSelectDuration: _selectDuration,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Payment Method Section
                    PaymentMethodSection(
                      selectedPaymentMethod: _selectedPaymentMethod,
                      onSelectPaymentMethod: _selectPaymentMethod,
                    ),
                    
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom payment bar
          if (_selectedDuration != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius:  10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payment',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${_formatCurrency(_parkingFee)} VND',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width:  double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _processPayment,
                        style:  ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment:  MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _selectedPaymentMethod != null
                                  ? 'Pay Now'
                                  : 'Select Payment Method',
                              style: const TextStyle(
                                fontSize:  18,
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
            ),
        ],
      ),
    );
  }
}