import 'package:flutter/material.dart';

class MapConfirmationPage extends StatefulWidget {
  final Map<String, double>? initialLocation;
  final Function(Map<String, double>) onNext;
  final VoidCallback onPrevious;

  const MapConfirmationPage({
    super.key,
    this.initialLocation,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<MapConfirmationPage> createState() => _MapConfirmationPageState();
}

class _MapConfirmationPageState extends State<MapConfirmationPage> {
  Map<String, double>? _selectedLocation;
  String _address = '';

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    if (_selectedLocation != null) {
      _address = 'Số 1 Đại Cồ Việt, Hai Bà Trưng, Hà Nội';
    }
  }

  void _selectLocation() {
    // TODO: Open map picker
    setState(() {
      _selectedLocation = {'lat': 21.0285, 'lng': 105.8542};
      _address = 'Số 1 Đại Cồ Việt, Hai Bà Trưng, Hà Nội';
    });
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      widget.onNext(_selectedLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // Introduction
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons. info_outline,
                    color: Colors.blue. shade700,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child:  Text(
                      'Xác nhận vị trí chính xác của địa chỉ cần xác minh trên bản đồ',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Map placeholder
          Container(
            height:  300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child:  _selectedLocation == null
                ? Column(
                    mainAxisAlignment:  MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 80,
                        color: Colors. grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa chọn vị trí',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      // Map placeholder with marker
                      Center(
                        child: Column(
                          mainAxisAlignment:  MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size:  60,
                              color: Colors. red. shade700,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black. withValues(alpha: 0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                'Lat: ${_selectedLocation!['lat']! .toStringAsFixed(4)}, '
                                'Lng: ${_selectedLocation!['lng']! .toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          
          const SizedBox(height: 16),
          
          // Select location button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _selectLocation,
              icon: const Icon(Icons.my_location),
              label: Text(_selectedLocation == null 
                  ? 'Chọn vị trí trên bản đồ' 
                  : 'Thay đổi vị trí'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.green.shade700),
                foregroundColor: Colors.green.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          if (_selectedLocation != null) ...[
            const SizedBox(height: 24),
            
            // Location details
            Card(
              elevation:  2,
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
                        Icon(
                          Icons.check_circle,
                          color:  Colors.green.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Vị trí đã chọn',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildLocationRow(
                      Icons.location_on,
                      'Tọa độ',
                      'Lat: ${_selectedLocation! ['lat']!.toStringAsFixed(6)}, '
                      'Lng: ${_selectedLocation!['lng']!.toStringAsFixed(6)}',
                    ),
                    const SizedBox(height: 12),
                    _buildLocationRow(
                      Icons.home,
                      'Địa chỉ',
                      _address,
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height:  24),
          
          // Important notes
          Card(
            elevation: 2,
            color: Colors.amber.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment:  CrossAxisAlignment.start,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:  FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildNoteItem('Vui lòng đánh dấu chính xác vị trí cần xác minh'),
                  _buildNoteItem('Kiểm tra kỹ tọa độ và địa chỉ hiển thị'),
                  _buildNoteItem('Vị trí này sẽ được sử dụng cho việc xác minh'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Continue button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selectedLocation != null ?  _confirmLocation : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors. green.shade700,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors. grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Xác nhận và tiếp tục',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color:  Colors.green.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:  TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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