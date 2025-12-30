import 'package:flutter/material.dart';

class AppointmentPage extends StatefulWidget {
  final DateTime?   initialDate;
  final TimeOfDay? initialTime;
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback onPrevious;

  const AppointmentPage({
    super.key,
    this.initialDate,
    this.initialTime,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String?   _selectedTimeSlot;

  final List<Map<String, dynamic>> _timeSlots = [
    {'time':   '08:00 - 10:00', 'available':  true},
    {'time':   '10:00 - 12:00', 'available':  true},
    {'time':  '13:00 - 15:00', 'available': false},
    {'time': '15:00 - 17:00', 'available': true},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now.add(const Duration(days: 1));
    final DateTime lastDate = now.add(const Duration(days: 30));

    final DateTime?  picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data:  Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade700,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTimeSlot(String timeSlot) {
    setState(() {
      _selectedTimeSlot = timeSlot;
      try {
        // Parse "08:00 - 10:00" -> "08:00"
        final startTime = timeSlot.split(' - ')[0].trim();
        // Split "08:00" by ":"
        final parts = startTime. split(':');
        if (parts.length == 2) {
          _selectedTime = TimeOfDay(
            hour: int.parse(parts[0].trim()),
            minute: int.parse(parts[1].trim()),
          );
        }
      } catch (e) {
        print('Error parsing time slot: $e');
        _selectedTime = const TimeOfDay(hour: 8, minute: 0);
      }
    });
  }

  void _confirmAppointment() {
    if (_selectedDate != null && _selectedTime != null) {
      widget.onNext({
        'date': _selectedDate,
        'time': _selectedTime,
        'timeSlot':   _selectedTimeSlot,
      });
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return '${weekdays[date.weekday % 7]}, ${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment:  CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                
                // Introduction Card
                _buildIntroCard(),
                
                const SizedBox(height: 20),
                
                // Date Selection Section
                _buildDateSection(),
                
                if (_selectedDate != null) ...[
                  const SizedBox(height: 20),
                  _buildTimeSlotSection(),
                ],
                
                if (_selectedDate != null && _selectedTimeSlot != null) ...[
                  const SizedBox(height: 20),
                  _buildSummaryCard(),
                ],
                
                const SizedBox(height: 20),
                
                // Notes section
                _buildNotesCard(),
                
                const SizedBox(height: 80), // Space for button
              ],
            ),
          ),
        ),
        
        // Fixed bottom button
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildIntroCard() {
    return Card(
      elevation: 2,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.blue.shade700,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Chọn ngày và giờ thuận tiện để nhân viên đến xác minh',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn ngày',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding:   const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedDate != null 
                  ? Colors.green.  shade50 
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedDate != null 
                    ? Colors.green. shade700 
                    : Colors.grey.  shade300,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color:  _selectedDate != null 
                      ? Colors.green.  shade700 
                      : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment. start,
                    children: [
                      Text(
                        _selectedDate != null 
                            ?  _formatDate(_selectedDate!) 
                            : 'Chọn ngày',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:   FontWeight.bold,
                          color: _selectedDate != null 
                              ?   Colors.black 
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedDate != null 
                            ?  'Nhấn để thay đổi' 
                            : 'Chọn ngày phù hợp với bạn',
                        style:   TextStyle(
                          fontSize:   12,
                          color:  Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn khung giờ',
          style:  TextStyle(
            fontSize:   18,
            fontWeight:   FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;
            final cardHeight = cardWidth * 0.55;
            
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _timeSlots.map((slot) {
                final isAvailable = slot['available'] as bool;
                final time = slot['time'] as String;
                final isSelected = _selectedTimeSlot == time;
                
                return SizedBox(
                  width:   cardWidth,
                  height:   cardHeight,
                  child:   _buildTimeSlotCard(
                    time:   time,
                    isAvailable: isAvailable,
                    isSelected: isSelected,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeSlotCard({
    required String time,
    required bool isAvailable,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: isAvailable ? () => _selectTimeSlot(time) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: !  isAvailable
              ? Colors. grey[200]
              : isSelected
                  ? Colors.green. shade700
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: !  isAvailable
                ? Colors.  grey. shade300
                : isSelected
                    ? Colors.green.shade700
                    : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                color: ! isAvailable
                    ? Colors.grey
                    : isSelected
                        ? Colors.white
                        :  Colors.green.shade700,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                time,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ! isAvailable
                      ? Colors.  grey
                      : isSelected
                          ? Colors.white
                          : Colors.black,
                ),
              ),
              if (!  isAvailable) ...[
                const SizedBox(height: 4),
                Text(
                  'Hết chỗ',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.  grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius:  BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade700, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.  all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color:  Colors.green.  shade700,
                  size:   24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Lịch hẹn của bạn',
                  style:  TextStyle(
                    fontSize:  16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              Icons.calendar_today,
              'Ngày',
              _formatDate(_selectedDate!  ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              Icons.access_time,
              'Khung giờ',
              _selectedTimeSlot!  ,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.  green. shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize:   12,
                  color: Colors. grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize:  14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation:  2,
      color:   Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets. all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Lưu ý',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildNoteItem('Nhân viên sẽ đến trong khung giờ đã chọn'),
            _buildNoteItem('Vui lòng có mặt tại địa chỉ vào thời gian hẹn'),
            _buildNoteItem('Chuẩn bị giấy tờ gốc để đối chiếu'),
          ],
        ),
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
            child: Text(text, style: const TextStyle(fontSize:  13)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final canProceed = _selectedDate != null && _selectedTimeSlot != null;
    
    return Container(
      padding:  const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:   Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child:  ElevatedButton(
            onPressed: canProceed ? _confirmAppointment : null,
            style: ElevatedButton. styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.  grey[300],
              shape: RoundedRectangleBorder(
                borderRadius:   BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Xác nhận lịch hẹn',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}