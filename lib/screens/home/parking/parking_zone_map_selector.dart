import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localizy/configs/map_config.dart';
import 'package:localizy/l10n/app_localizations.dart';

class ParkingZoneMapSelector extends StatefulWidget {
  const ParkingZoneMapSelector({super.key});

  @override
  State<ParkingZoneMapSelector> createState() => _ParkingZoneMapSelectorState();
}

class _ParkingZoneMapSelectorState extends State<ParkingZoneMapSelector> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = MapConfig.defaultPosition;
  String? _selectedZone;
  bool _isLoading = true;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  
  // Mock data - Danh sách các khu vực đỗ xe
  final List<ParkingZone> _parkingZones = [
    ParkingZone(
      id: '1',
      code: 'A1',
      name: 'Parking Zone A1',
      position: const LatLng(10.7769, 106.7009),
      availableSpots: 15,
      totalSpots: 20,
      pricePerHour: 10000,
    ),
    ParkingZone(
      id: '2',
      code: 'A2',
      name: 'Parking Zone A2',
      position: const LatLng(10.7740, 106.6990),
      availableSpots:  8,
      totalSpots: 15,
      pricePerHour: 10000,
    ),
    ParkingZone(
      id: '3',
      code:  'B1',
      name: 'Parking Zone B1',
      position: const LatLng(10.7750, 106.7020),
      availableSpots:  20,
      totalSpots: 25,
      pricePerHour: 12000,
    ),
    ParkingZone(
      id: '4',
      code: 'B2',
      name: 'Parking Zone B2',
      position: const LatLng(10.7780, 106.7000),
      availableSpots:  0,
      totalSpots: 18,
      pricePerHour: 12000,
    ),
    ParkingZone(
      id: '5',
      code:  'C1',
      name: 'Parking Zone C1',
      position: const LatLng(10.7730, 106.7030),
      availableSpots:  12,
      totalSpots: 15,
      pricePerHour: 15000,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || 
          permission == LocationPermission. deniedForever) {
        setState(() {
          _isLoading = false;
        });
        _addParkingZoneMarkers();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 15),
        );
        
        _addParkingZoneMarkers();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _addParkingZoneMarkers();
      }
    }
  }

  void _addParkingZoneMarkers() {
    setState(() {
      _markers.clear();
      _circles.clear();
      
      // Add current location marker
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );

      // Add parking zone markers and circles
      for (var zone in _parkingZones) {
        final isAvailable = zone.availableSpots > 0;
        final isSelected = _selectedZone == zone.code;
        
        _markers.add(
          Marker(
            markerId: MarkerId(zone.id),
            position: zone.position,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isSelected 
                  ? BitmapDescriptor.hueBlue
                  : isAvailable 
                      ? BitmapDescriptor.hueGreen 
                      : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: zone. code,
              snippet: '${zone.availableSpots}/${zone.totalSpots} spots',
            ),
            onTap: () => _selectParkingZone(zone),
          ),
        );

        // Add circle around parking zone
        _circles.add(
          Circle(
            circleId: CircleId(zone.id),
            center: zone.position,
            radius: 50, // 50 meters
            fillColor: (isSelected 
                ? Colors.blue 
                : isAvailable 
                    ? Colors.green 
                    : Colors.red).withOpacity(0.2),
            strokeColor: isSelected 
                ? Colors.blue 
                : isAvailable 
                    ? Colors.green 
                    : Colors.red,
            strokeWidth: 2,
          ),
        );
      }
    });
  }

  void _selectParkingZone(ParkingZone zone) {
    if (zone.availableSpots == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:  Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Zone ${zone.code} is full. Please select another zone.'),
              ),
            ],
          ),
          backgroundColor: Colors.orange. shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _selectedZone = zone.code;
    });
    
    _addParkingZoneMarkers();
    
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(zone.position, 17),
    );
  }

  void _confirmSelection() {
    if (_selectedZone != null) {
      Navigator.pop(context, _selectedZone);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Please select a parking zone')),
            ],
          ),
          backgroundColor: Colors.blue.shade700,
          behavior: SnackBarBehavior. floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Parking Zone',
          style:  TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectedZone != null)
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: _confirmSelection,
              tooltip: 'Confirm',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: _markers,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Legend
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Legend',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem(Colors.green, 'Available'),
                  const SizedBox(height: 4),
                  _buildLegendItem(Colors.red, 'Full'),
                  const SizedBox(height: 4),
                  _buildLegendItem(Colors.blue, 'Selected'),
                ],
              ),
            ),
          ),

          // Bottom sheet with parking zones list
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.15,
            maxChildSize: 0.7,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius. vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius:  10,
                      offset:  Offset(0, -2),
                    ),
                  ],
                ),
                child:  Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Title
                    Padding(
                      padding: const EdgeInsets. symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Icons.local_parking, 
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Available Parking Zones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Divider(height: 24),
                    
                    // Parking zones list
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _parkingZones.length,
                        separatorBuilder: (context, index) => const SizedBox(height:  12),
                        itemBuilder: (context, index) {
                          final zone = _parkingZones[index];
                          final isSelected = _selectedZone == zone.code;
                          final isAvailable = zone.availableSpots > 0;
                          
                          return InkWell(
                            onTap: () => _selectParkingZone(zone),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration:  BoxDecoration(
                                color: isSelected 
                                    ? Colors.blue.shade50 
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border. all(
                                  color:  isSelected 
                                      ?  Colors.blue.shade700 
                                      : Colors. grey.shade200,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Zone icon
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue. shade700
                                          : isAvailable 
                                              ? Colors.green.shade700 
                                              : Colors.red.shade700,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons. local_parking,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 16),
                                  
                                  // Zone info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              zone.code,
                                              style: TextStyle(
                                                fontSize:  18,
                                                fontWeight:  FontWeight.bold,
                                                color: isSelected 
                                                    ? Colors. blue.shade700 
                                                    : Colors. black87,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration:  BoxDecoration(
                                                color: isAvailable 
                                                    ?  Colors.green.shade100 
                                                    : Colors.red.shade100,
                                                borderRadius: BorderRadius. circular(6),
                                              ),
                                              child: Text(
                                                isAvailable ? 'Available' :  'Full',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color:  isAvailable 
                                                      ? Colors.green.shade700 
                                                      : Colors.red.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          zone.name,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.car_rental,
                                              size: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${zone.availableSpots}/${zone.totalSpots} spots',
                                              style: TextStyle(
                                                fontSize:  12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(
                                              Icons.attach_money,
                                              size: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                            Text(
                                              '${_formatCurrency(zone. pricePerHour)}/h',
                                              style: TextStyle(
                                                fontSize:  12,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Selection indicator
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.blue.shade700,
                                      size: 28,
                                    )
                                  else if (isAvailable)
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey.shade400,
                                      size: 16,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      
      // Floating action button for confirmation
      floatingActionButton: _selectedZone != null
          ?  FloatingActionButton. extended(
              onPressed: _confirmSelection,
              backgroundColor: Colors.blue.shade700,
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Confirm Zone',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}

// Model class for Parking Zone
class ParkingZone {
  final String id;
  final String code;
  final String name;
  final LatLng position;
  final int availableSpots;
  final int totalSpots;
  final int pricePerHour;

  ParkingZone({
    required this.id,
    required this.code,
    required this.name,
    required this. position,
    required this.availableSpots,
    required this.totalSpots,
    required this.pricePerHour,
  });
}