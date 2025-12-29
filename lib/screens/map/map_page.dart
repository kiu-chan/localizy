import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/services/directions_service.dart';
import 'package:localizy/screens/map/widgets/directions_panel.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(48.8566, 2.3522); // Paris mặc định
  bool _isLoading = true;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  
  // Biến cho chức năng chỉ đường
  DirectionsResult? _directionsResult;
  LatLng? _destinationPosition;
  bool _isSelectingDestination = false;
  TravelMode _selectedTravelMode = TravelMode.driving;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (! mounted) return;
    
    final l10n = AppLocalizations.of(context);
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission. denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n?. locationPermissionDenied ?? 'Location permission denied'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:  Text(l10n?.pleaseEnableLocationInSettings ?? 'Please enable location'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
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
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentPosition,
              zoom: 15.0,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n?.errorGettingLocation ??  'Error'}: $e'),
            backgroundColor: Colors. red,
          ),
        );
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // Hàm xử lý khi người dùng nhấn vào bản đồ để chọn điểm đến
  void _onMapTap(LatLng position) {
    if (_isSelectingDestination) {
      setState(() {
        _destinationPosition = position;
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position:  position,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: 'Điểm đến'),
          ),
        );
        _isSelectingDestination = false;
      });
      _getDirections();
    }
  }

  // Hàm lấy chỉ đường từ vị trí hiện tại đến điểm đến
  Future<void> _getDirections() async {
    if (_destinationPosition == null) return;

    setState(() {
      _isLoading = true;
    });

    final result = await DirectionsService.getDirections(
      origin: _currentPosition,
      destination: _destinationPosition!,
      mode: _selectedTravelMode,
    );

    if (result != null && mounted) {
      setState(() {
        _directionsResult = result;
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points:  result.polylinePoints,
            color: Colors.blue,
            width: 5,
          ),
        );
        _isLoading = false;
      });

      // Điều chỉnh camera để hiển thị toàn bộ tuyến đường
      _fitBounds();
    } else {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tìm thấy đường đi'),
            backgroundColor: Colors. red,
          ),
        );
      }
    }
  }

  // Điều chỉnh camera để hiển thị toàn bộ tuyến đường
  void _fitBounds() {
    if (_directionsResult == null || _mapController == null) return;

    final points = _directionsResult!.polylinePoints;
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100, // padding
      ),
    );
  }

  // Xóa tuyến đường
  void _clearRoute() {
    setState(() {
      _directionsResult = null;
      _destinationPosition = null;
      _polylines.clear();
      _markers.removeWhere((marker) => marker.markerId.value == 'destination');
    });
  }

  // Bắt đầu chọn điểm đến trên bản đồ
  void _startSelectingDestination() {
    setState(() {
      _isSelectingDestination = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nhấn vào bản đồ để chọn điểm đến'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations. of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.map ?? 'Map'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          // Nút chọn phương thức di chuyển
          if (_directionsResult != null)
            PopupMenuButton<TravelMode>(
              icon: const Icon(Icons.directions),
              onSelected: (mode) {
                setState(() {
                  _selectedTravelMode = mode;
                });
                _getDirections();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: TravelMode.driving,
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text('Lái xe'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value:  TravelMode.walking,
                  child: Row(
                    children: [
                      Icon(Icons.directions_walk, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text('Đi bộ'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: TravelMode. bicycling,
                  child:  Row(
                    children: [
                      Icon(Icons.directions_bike, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text('Đạp xe'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: TravelMode.transit,
                  child: Row(
                    children: [
                      Icon(Icons.directions_transit, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text('Phương tiện công cộng'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment:  MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(height: 16),
                      Text(l10n?.loadingMap ?? 'Loading map... '),
                    ],
                  ),
                )
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  onTap: _onMapTap,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 15.0,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  zoomControlsEnabled: true,
                  compassEnabled: true,
                  mapToolbarEnabled: true,
                ),
          // Panel hiển thị thông tin chỉ đường
          if (_directionsResult != null)
            DirectionsPanel(
              directionsResult: _directionsResult,
              onClose: _clearRoute,
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Nút chỉ đường
          FloatingActionButton(
            heroTag:  'directions',
            onPressed: _directionsResult == null
                ? _startSelectingDestination
                :  _clearRoute,
            backgroundColor: _directionsResult == null
                ?  Colors.blue
                : Colors.red,
            child: Icon(
              _directionsResult == null
                  ? Icons.directions
                  : Icons.clear,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'zoom_in',
            onPressed: () {
              _mapController?.animateCamera(CameraUpdate.zoomIn());
            },
            backgroundColor: Colors.white,
            child: Icon(Icons.add, color: Colors.green.shade700),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'zoom_out',
            onPressed: () {
              _mapController?.animateCamera(CameraUpdate.zoomOut());
            },
            backgroundColor: Colors.white,
            child: Icon(Icons.remove, color: Colors.green.shade700),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'my_location',
            onPressed:  _getCurrentLocation,
            backgroundColor: Colors. green.shade700,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }
}