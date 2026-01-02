import 'package:flutter/material.dart';

class DurationSelectionSection extends StatelessWidget {
  final Map<String, Map<String, dynamic>> durationPrices;
  final String?  selectedDuration;
  final Function(String) onSelectDuration;

  const DurationSelectionSection({
    Key? key,
    required this.durationPrices,
    required this.selectedDuration,
    required this. onSelectDuration,
  }) : super(key: key);

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, size: 24, color:  Colors.green.shade700),
            const SizedBox(width:  8),
            const Text(
              'Parking Duration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height:  12),
        
        Container(
          padding: const EdgeInsets.all(16),
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
            children: durationPrices.entries.map((entry) {
              final isSelected = selectedDuration == entry. key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDurationCard(
                  context:  context,
                  key: entry.key,
                  label: entry.value['label'],
                  price:  entry.value['price'],
                  icon: entry.value['icon'],
                  isSelected: isSelected,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationCard({
    required BuildContext context,
    required String key,
    required String label,
    required int price,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onSelectDuration(key),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets. all(16),
        decoration:  BoxDecoration(
          color:  isSelected ? Colors.green.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors. green.shade700 : Colors. grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ?  Colors.green.shade700 :  Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child:  Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey. shade600,
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
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.green.shade700 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatCurrency(price)} VND',
                    style:  TextStyle(
                      fontSize:  14,
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
}