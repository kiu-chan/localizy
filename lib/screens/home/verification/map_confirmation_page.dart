import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localizy/screens/home/verification/map_picker_page.dart';

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
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    if (_selectedLocation != null) {
      _address = 'Lat: ${_selectedLocation!['lat']! . toStringAsFixed(6)}, Lng: ${_selectedLocation!['lng']!.toStringAsFixed(6)}';
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerPage(
          initialLocation: _selectedLocation,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedLocation = {
          'lat': result['lat'] as double,
          'lng':  result['lng'] as double,
        };
        _address = result['address'] as String;
      });
      
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate. newLatLng(
            LatLng(_selectedLocation!['lat']!, _selectedLocation!['lng']!),
          ),
        );
      }
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      widget.onNext(_selectedLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                
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
                          Icons.info_outline,
                          color: Colors.blue. shade700,
                          size:  28,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Xác nhận vị trí chính xác của địa chỉ cần xác minh trên bản đồ',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height:  20),
                
                // Map preview
                SizedBox(
                  height:  250,
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child:  _selectedLocation == null
                        ? _buildEmptyMapPlaceholder()
                        : _buildMapPreview(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Select location button
                SizedBox(
                  width:  double.infinity,
                  child: OutlinedButton. icon(
                    onPressed: _openMapPicker,
                    icon: Icon(
                      _selectedLocation == null 
                          ? Icons.add_location 
                          : Icons.edit_location,
                    ),
                    label: Text(
                      _selectedLocation == null 
                          ? 'Chọn vị trí trên bản đồ' 
                          : 'Thay đổi vị trí',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.green.shade700, width: 2),
                      foregroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                if (_selectedLocation != null) ...[
                  const SizedBox(height: 20),
                  
                  // Location details
                  Card(
                    elevation: 2,
                    color: Colors.green.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color:  Colors.green.shade700, width: 2),
                    ),
                    child:  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment:  CrossAxisAlignment.start,
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
                            _address,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                
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
                
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        
        // Fixed bottom button
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildEmptyMapPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 80,
            color: Colors.grey[400],
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
      ),
    );
  }

  Widget _buildMapPreview() {
    return GoogleMap(
      key: ValueKey('map_${_selectedLocation!['lat']}_${_selectedLocation!['lng']}'),
      initialCameraPosition: CameraPosition(
        target: LatLng(
          _selectedLocation!['lat']!,
          _selectedLocation!['lng']!,
        ),
        zoom: 15,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('selected'),
          position: LatLng(
            _selectedLocation!['lat']!,
            _selectedLocation!['lng']!,
          ),
        ),
      },
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      scrollGesturesEnabled: false,
      zoomGesturesEnabled: false,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }

  Widget _buildLocationRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors. green.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors. grey[600],
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
        crossAxisAlignment: CrossAxisAlignment. start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors. white,
        boxShadow:  [
          BoxShadow(
            color: Colors.grey. withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _selectedLocation != null ?  _confirmLocation : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors. green.shade700,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors. grey[300],
              shape: RoundedRectangleBorder(
                borderRadius:  BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Xác nhận và tiếp tục',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight. bold,
                  ),
                ),
                SizedBox(width:  8),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}