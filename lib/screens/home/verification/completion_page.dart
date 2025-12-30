import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CompletionPage extends StatelessWidget {
  final File? idDocument;
  final File? addressProof;
  final Map<String, double>? location;
  final String? paymentMethod;
  final DateTime? appointmentDate;
  final TimeOfDay? appointmentTime;
  final String? timeSlot;
  final VoidCallback onComplete;
  final VoidCallback onPrevious;

  const CompletionPage({
    super.key,
    this.idDocument,
    this.addressProof,
    this.location,
    this.paymentMethod,
    this.appointmentDate,
    this.appointmentTime,
    this.timeSlot,
    required this.onComplete,
    required this.onPrevious,
  });

  String _generateAddressCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ADDR-${timestamp.toString().substring(5)}';
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
    return '${weekdays[date.weekday % 7]}, ${date.day}/${date. month}/${date.year}';
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'momo':
        return 'Ví MoMo';
      case 'zalopay':
        return 'ZaloPay';
      case 'bank':
        return 'Chuyển khoản ngân hàng';
      case 'card':
        return 'Thẻ tín dụng/Ghi nợ';
      default: 
        return 'Không xác định';
    }
  }

  void _copyAddressCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Đã sao chép mã địa chỉ'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressCode = _generateAddressCode();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // Success animation/icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.shade50,
            ),
            child: Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green.shade700,
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Yêu cầu đã được gửi! ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Cảm ơn bạn đã hoàn tất quy trình xác minh',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height:  32),
          
          // Address code
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
                const Icon(
                  Icons.qr_code,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'MÃ ĐỊA CHỈ CỦA BẠN',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius. circular(8),
                  ),
                  child: Text(
                    addressCode,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors. green.shade700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton. icon(
                  onPressed:  () => _copyAddressCode(context, addressCode),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Sao chép mã'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors. white),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Summary card
          Card(
            elevation:  2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tóm tắt yêu cầu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    Icons.credit_card,
                    'Giấy tờ tùy thân',
                    'Đã tải lên',
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    Icons. receipt_long,
                    'Chứng minh địa chỉ',
                    'Đã tải lên',
                  ),
                  const SizedBox(height:  12),
                  _buildSummaryRow(
                    Icons.location_on,
                    'Vị trí',
                    location != null
                        ? '${location! ['lat']! . toStringAsFixed(4)}, ${location!['lng']!.toStringAsFixed(4)}'
                        : 'Đã xác nhận',
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    Icons.payment,
                    'Thanh toán',
                    paymentMethod != null
                        ?  _getPaymentMethodName(paymentMethod!)
                        : 'Hoàn tất',
                  ),
                  if (appointmentDate != null) ...[
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      Icons.calendar_today,
                      'Ngày hẹn',
                      _formatDate(appointmentDate!),
                    ),
                  ],
                  if (timeSlot != null) ...[
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      Icons.access_time,
                      'Khung giờ',
                      timeSlot!,
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // What's next section
          Card(
            elevation: 2,
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Bước tiếp theo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStepItem('1', 'Nhận email xác nhận trong vòng 5 phút'),
                  _buildStepItem('2', 'Nhân viên sẽ liên hệ trước 1 ngày'),
                  _buildStepItem('3', 'Xác minh địa chỉ tại thời gian đã hẹn'),
                  _buildStepItem('4', 'Nhận kết quả xác minh sau 24 giờ'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
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
                      Icon(Icons.warning_amber, color: Colors.orange. shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Lưu ý quan trọng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildNoteItem('Vui lòng lưu lại mã địa chỉ để tra cứu'),
                  _buildNoteItem('Chuẩn bị giấy tờ gốc để đối chiếu'),
                  _buildNoteItem('Có mặt đúng giờ tại địa chỉ đã đăng ký'),
                  _buildNoteItem('Liên hệ hotline 1900xxxx nếu cần hỗ trợ'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton. icon(
                  onPressed:  () => _copyAddressCode(context, addressCode),
                  icon: const Icon(Icons.share),
                  label: const Text('Chia sẻ'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.green.shade700),
                    foregroundColor: Colors.green. shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width:  12),
              Expanded(
                flex: 2,
                child:  ElevatedButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.home),
                  label: const Text('Về trang chủ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:  Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
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