import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class ParkingPaymentPage extends StatefulWidget {
  const ParkingPaymentPage({super. key});

  @override
  State<ParkingPaymentPage> createState() => _ParkingPaymentPageState();
}

class _ParkingPaymentPageState extends State<ParkingPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _licensePlateController = TextEditingController();
  final _parkingZoneController = TextEditingController();
  final _licensePlateFocusNode = FocusNode();
  final _parkingZoneFocusNode = FocusNode();
  
  String?  _selectedPaymentMethod;
  String? _selectedDuration;
  DateTime? _startTime;
  int _parkingFee = 0;
  
  final Map<String, Map<String, dynamic>> _durationPrices = {
    '1h': {'price': 10000, 'label': '1 giờ', 'icon': Icons.access_time},
    '2h': {'price': 18000, 'label': '2 giờ', 'icon': Icons.access_time},
    '4h': {'price': 35000, 'label': '4 giờ', 'icon': Icons.schedule},
    '8h': {'price': 65000, 'label': '8 giờ', 'icon': Icons.schedule},
    '1day': {'price': 100000, 'label': '1 ngày', 'icon': Icons. today},
  };

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    
    // Add listeners for focus changes
    _licensePlateFocusNode.addListener(() => setState(() {}));
    _parkingZoneFocusNode. addListener(() => setState(() {}));
    _licensePlateController.addListener(() => setState(() {}));
    _parkingZoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _parkingZoneController.dispose();
    _licensePlateFocusNode.dispose();
    _parkingZoneFocusNode. dispose();
    super.dispose();
  }

  void _selectDuration(String duration) {
    setState(() {
      _selectedDuration = duration;
      _parkingFee = _durationPrices[duration]!['price'] as int;
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
    if (!_formKey.currentState!. validate()) {
      return;
    }

    if (_selectedPaymentMethod == null) {
      _showErrorSnackBar('Vui lòng chọn phương thức thanh toán');
      return;
    }

    if (_selectedDuration == null) {
      _showErrorSnackBar('Vui lòng chọn thời gian đỗ');
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green. shade700),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Đang xử lý thanh toán...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vui lòng đợi trong giây lát',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey. shade600,
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
    final ticketCode = 'PKT${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
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
                    Icons. check_circle,
                    color: Colors.green.shade600,
                    size: 56,
                  ),
                ),
                
                const SizedBox(height:  24),
                
                const Text(
                  'Thanh toán thành công!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Vé đỗ xe của bạn đã được kích hoạt',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey. shade600,
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
                        'MÃ VÉ ĐỖ XE',
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
                          color: Colors.white,
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
                                  Text('Đã sao chép mã vé'),
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
                          'Sao chép mã',
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
                  child:  Column(
                    children: [
                      _buildDetailRow(
                        Icons.directions_car,
                        'Biển số xe',
                        _licensePlateController.text. toUpperCase(),
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        Icons.location_on,
                        'Khu vực',
                        _parkingZoneController.text.toUpperCase(),
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        Icons.access_time,
                        'Thời gian',
                        _durationPrices[_selectedDuration!]!['label'],
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        Icons.schedule,
                        'Bắt đầu',
                        DateFormat('HH:mm - dd/MM/yyyy').format(_startTime!),
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        Icons.event_available,
                        'Kết thúc',
                        DateFormat('HH:mm - dd/MM/yyyy').format(endTime),
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        Icons.payments,
                        'Thanh toán',
                        _getPaymentMethodName(_selectedPaymentMethod!),
                        isHighlight: true,
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        Icons.attach_money,
                        'Số tiền',
                        '${_formatCurrency(_parkingFee)} VNĐ',
                        isHighlight: true,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height:  24),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
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
                          'Đóng',
                          style:  TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:  ElevatedButton(
                        onPressed: () {
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
                          'Xem vé',
                          style: TextStyle(
                            fontSize: 16,
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
      children:  [
        Icon(
          icon,
          size: 20,
          color:  isHighlight ? Colors.green.shade700 : Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize:  14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
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

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'momo':
        return 'Ví MoMo';
      case 'zalopay':
        return 'ZaloPay';
      case 'bank':
        return 'Chuyển khoản';
      case 'card':
        return 'Thẻ ngân hàng';
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey. shade50,
      appBar:  AppBar(
        title: const Text(
          'Thanh toán đỗ xe',
          style: TextStyle(fontWeight: FontWeight.w600),
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
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green. shade400, Colors.green.shade700],
                          begin:  Alignment.topLeft,
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
                              color:  Colors.white. withOpacity(0.2),
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
                                  'Thanh toán nhanh',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'An toàn & Tiện lợi',
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
                    
                    // Vehicle Information Section
                    _buildSectionTitle('Thông tin xe', Icons.directions_car),
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius:  10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller:  _licensePlateController,
                            focusNode: _licensePlateFocusNode,
                            decoration: InputDecoration(
                              labelText: 'Biển số xe',
                              labelStyle: TextStyle(
                                color: (_licensePlateFocusNode.hasFocus || _licensePlateController.text. isNotEmpty)
                                    ? Colors.green.shade700
                                    :  Colors.grey,
                              ),
                              hintText: 'VD: 30A-12345',
                              prefixIcon: Icon(
                                Icons.directions_car,
                                color: _licensePlateFocusNode. hasFocus
                                    ? Colors.green. shade700
                                    : Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:  BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:  BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey. shade300),
                              ),
                              focusedBorder:  OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color:  Colors.green.shade700, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            textCapitalization: TextCapitalization. characters,
                            validator: (value) {
                              if (value == null || value. isEmpty) {
                                return 'Vui lòng nhập biển số xe';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller:  _parkingZoneController,
                            focusNode: _parkingZoneFocusNode,
                            decoration: InputDecoration(
                              labelText: 'Khu vực đỗ',
                              labelStyle: TextStyle(
                                color: (_parkingZoneFocusNode. hasFocus || _parkingZoneController.text.isNotEmpty)
                                    ? Colors. green.shade700
                                    : Colors.grey,
                              ),
                              hintText:  'VD: A1, B2, C3',
                              prefixIcon: Icon(
                                Icons.location_on,
                                color: _parkingZoneFocusNode.hasFocus
                                    ? Colors. green.shade700
                                    : Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:  BorderSide(color: Colors. grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius. circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            textCapitalization: TextCapitalization.characters,
                            validator: (value) {
                              if (value == null || value. isEmpty) {
                                return 'Vui lòng nhập khu vực đỗ';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Duration Selection
                    _buildSectionTitle('Thời gian đỗ', Icons.schedule),
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets. all(16),
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
                        children: _durationPrices.entries.map((entry) {
                          final isSelected = _selectedDuration == entry.key;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildDurationCard(
                              key: entry.key,
                              label: entry.value['label'],
                              price: entry.value['price'],
                              icon: entry.value['icon'],
                              isSelected: isSelected,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Payment Methods
                    _buildSectionTitle('Phương thức thanh toán', Icons.payment),
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets. all(16),
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
                        children: [
                          _buildPaymentMethodCard(
                            method: 'momo',
                            icon: Icons.account_balance_wallet,
                            title: 'Ví MoMo',
                            description: 'Thanh toán qua ví MoMo',
                            color: Colors.pink,
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentMethodCard(
                            method:  'zalopay',
                            icon: Icons.payment,
                            title: 'ZaloPay',
                            description: 'Thanh toán qua ZaloPay',
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentMethodCard(
                            method:  'bank',
                            icon: Icons.account_balance,
                            title: 'Chuyển khoản',
                            description: 'Chuyển khoản ngân hàng',
                            color: Colors.teal,
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentMethodCard(
                            method: 'card',
                            icon: Icons.credit_card,
                            title: 'Thẻ ngân hàng',
                            description: 'Thanh toán bằng thẻ',
                            color: Colors.orange,
                          ),
                        ],
                      ),
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
                    offset:  const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng thanh toán',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${_formatCurrency(_parkingFee)} VNĐ',
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
                      width: double.infinity,
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
                                  ? 'Thanh toán ngay'
                                  : 'Chọn phương thức thanh toán',
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.green.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDurationCard({
    required String key,
    required String label,
    required int price,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _selectDuration(key),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets. all(16),
        decoration:  BoxDecoration(
          color:  isSelected ? Colors.green.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green.shade700 : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children:  [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ?  Colors.green.shade700 :  Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child:  Icon(
                icon,
                color: isSelected ? Colors.white :  Colors.grey. shade600,
                size: 24,
              ),
            ),
            const SizedBox(width:  16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight. bold,
                      color: isSelected ? Colors.green.shade700 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatCurrency(price)} VNĐ',
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.green.shade600 : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.green.shade700 : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? Colors.green.shade700 : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors. white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String method,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final isSelected = _selectedPaymentMethod == method;
    
    return InkWell(
      onTap: () => _selectPaymentMethod(method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets. all(16),
        decoration:  BoxDecoration(
          color:  isSelected ? color. withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color :  Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color. withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child:  Icon(
                icon,
                color: color,
                size:  24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:  TextStyle(
                      fontSize:  16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color :  Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? color : Colors. transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors. white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}