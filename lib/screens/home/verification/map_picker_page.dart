import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localizy/l10n/app_localizations.dart';

class MapPickerPage extends StatefulWidget {
  final Map<String, double>? initialLocation;

  const MapPickerPage({
    super.key,
    this.initialLocation,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  GoogleMapController?  _mapController;
  LatLng _centerLocation = const LatLng(21.0285, 105.8542);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (widget. initialLocation != null) {
      _centerLocation = LatLng(
        widget.initialLocation! ['lat']!,
        widget.initialLocation!['lng']! ,
      );
    } else {
      await _loadCurrentLocation();
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator. isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator. requestPermission();
      }
      
      if (permission == LocationPermission.denied || 
          permission == LocationPermission. deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _centerLocation = LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error: $e');
    }
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _centerLocation = position.target;
    });
  }

  void _onConfirm() {
    Navigator.pop(context, {
      'lat': _centerLocation.latitude,
      'lng':  _centerLocation.longitude,
      'address': 'Lat:  ${_centerLocation.latitude.toStringAsFixed(6)}, '
                 'Lng: ${_centerLocation.longitude.toStringAsFixed(6)}',
    });
  }

  void _moveToMyLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 17,
          ),
        ),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.selectLocation),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:  Text(localizations.selectLocation),
        backgroundColor: Colors.green. shade700,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _centerLocation,
              zoom: 15,
            ),
            onCameraMove: _onCameraMove,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType:  MapType.normal,
          ),

          // Icon location với chân nhọn chỉ chính xác vào center
          Center(
            child: Transform. translate(
              offset: const Offset(0, -25),
              child: Icon(
                Icons.location_on,
                size: 50,
                color:  Colors.red.shade700,
                shadows: const [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black45,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // Thông tin tọa độ
          Positioned(
            top:  16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize. min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            localizations.mapPickerInstruction,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        Icon(Icons.gps_fixed, size: 18, color: Colors. red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Lat: ${_centerLocation. latitude.toStringAsFixed(6)}\n'
                            'Lng: ${_centerLocation. longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                              fontSize:  13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
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

          // Nút vị trí hiện tại
          Positioned(
            right: 16,
            bottom: 100,
            child: FloatingActionButton(
              heroTag: 'my_location',
              onPressed:  _moveToMyLocation,
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Colors.green. shade700),
            ),
          ),

          // Nút xác nhận
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor:  Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  localizations.confirmLocation,
                  style: const TextStyle(
                    fontSize:  16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}