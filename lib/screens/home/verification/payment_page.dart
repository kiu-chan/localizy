import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String? initialPaymentMethod;
  final Function(String) onNext;
  final VoidCallback onPrevious;

  const PaymentPage({
    super.key,
    this.initialPaymentMethod,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String?  _selectedPaymentMethod;
  final int _verificationFee = 100000;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = widget.initialPaymentMethod;
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  void _processPayment() {
    if (_selectedPaymentMethod != null) {
      // TODO: Implement actual payment processing
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title:  const Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Đang xử lý... '),
            ],
          ),
          content: const Text('Vui lòng đợi trong giây lát'),
        ),
      );

      // Simulate payment processing
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context); // Close loading dialog
        widget.onNext(_selectedPaymentMethod!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment:  CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // Introduction
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding:  const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons. info_outline,
                    color: Colors.blue.shade700,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Thanh toán phí xác minh để tiếp tục quy trình',
                      style:  TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Fee summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow:  [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius:  8,
                  offset:  const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Tổng thanh toán',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_verificationFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Phí xác minh địa chỉ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors. white70,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Payment methods
          const Text(
            'Chọn phương thức thanh toán',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height:  16),
          
          _buildPaymentMethodCard(
            method: 'momo',
            icon: Icons. account_balance_wallet,
            title: 'Ví MoMo',
            description: 'Thanh toán qua ví điện tử MoMo',
            color: Colors.pink,
          ),
          
          const SizedBox(height: 12),
          
          _buildPaymentMethodCard(
            method:  'zalopay',
            icon: Icons.payment,
            title: 'ZaloPay',
            description:  'Thanh toán qua ví điện tử ZaloPay',
            color: Colors.blue,
          ),
          
          const SizedBox(height: 12),
          
          _buildPaymentMethodCard(
            method: 'bank',
            icon: Icons.account_balance,
            title: 'Chuyển khoản ngân hàng',
            description: 'Chuyển khoản trực tiếp qua ngân hàng',
            color:  Colors.green,
          ),
          
          const SizedBox(height: 12),
          
          _buildPaymentMethodCard(
            method: 'card',
            icon: Icons.credit_card,
            title: 'Thẻ tín dụng/Ghi nợ',
            description: 'Thanh toán bằng thẻ Visa, MasterCard',
            color: Colors.orange,
          ),
          
          const SizedBox(height: 24),
          
          // Fee breakdown
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding:  const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chi tiết phí',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  _buildFeeRow('Phí xác minh cơ bản', '80,000 VNĐ'),
                  _buildFeeRow('Phí di chuyển', '20,000 VNĐ'),
                  const Divider(height: 24),
                  _buildFeeRow(
                    'Tổng cộng',
                    '100,000 VNĐ',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Important notes
          Card(
            elevation: 2,
            color:  Colors.amber.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child:  Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Lưu ý',
                        style:  TextStyle(
                          fontSize:  16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height:  12),
                  _buildNoteItem('Phí không được hoàn lại sau khi thanh toán'),
                  _buildNoteItem('Bạn sẽ nhận được hóa đơn qua email'),
                  _buildNoteItem('Quá trình xác minh sẽ bắt đầu sau khi thanh toán thành công'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Payment button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selectedPaymentMethod != null ? _processPayment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock),
                  const SizedBox(width: 8),
                  Text(
                    _selectedPaymentMethod != null
                        ? 'Thanh toán ${_verificationFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ'
                        : 'Chọn phương thức thanh toán',
                    style:  const TextStyle(
                      fontSize:  16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Security note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Thanh toán được bảo mật bởi SSL',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
        ],
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
    
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius:  BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.green. shade700 : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _selectPaymentMethod(method),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color. withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:  Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width:  16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:  const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.green.shade700 : Colors.grey,
                    width: 2,
                  ),
                  color: isSelected ? Colors.green. shade700 : Colors.transparent,
                ),
                child: isSelected
                    ?  const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors. white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:  TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight. bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green.shade700 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}