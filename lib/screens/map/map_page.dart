import 'dart:async';
import 'dart:math' as math;
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
  LatLng _currentPosition = const LatLng(48.8566, 2.3522);
  bool _isLoading = true;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isMapReady = false;
  
  DirectionsResult? _directionsResult;
  LatLng? _destinationPosition;
  bool _isSelectingDestination = false;
  TravelMode _selectedTravelMode = TravelMode.driving;
  
  // Navigation tracking
  bool _isNavigating = false;
  int _currentStepIndex = 0;
  double?  _distanceToNextStep;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _navigationTimer;

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

  // Helper method để lấy language code từ locale hiện tại
  String _getLanguageCode() {
    final locale = Localizations.localeOf(context);
    return locale.languageCode; // 'vi', 'en', 'fr', etc.
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
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
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
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (! mounted) return;

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      _animateToPosition(_currentPosition, zoom: 15.0);
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

  // Tính khoảng cách giữa 2 điểm (Haversine formula)
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // meters
    
    final lat1 = point1.latitude * math.pi / 180;
    final lat2 = point2.latitude * math.pi / 180;
    final dLat = (point2.latitude - point1.latitude) * math.pi / 180;
    final dLng = (point2.longitude - point1.longitude) * math.pi / 180;
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final c = 2 * math.atan2(math. sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  // Bắt đầu navigation
  void _startNavigation() {
    if (! mounted || _directionsResult == null) return;

    final l10n = AppLocalizations. of(context);

    setState(() {
      _isNavigating = true;
      _currentStepIndex = 0;
    });

    // Theo dõi vị trí liên tục
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Cập nhật mỗi 5 mét
      ),
    ).listen((Position position) {
      if (!mounted || ! _isNavigating) return;

      final currentPos = LatLng(position. latitude, position.longitude);
      
      setState(() {
        _currentPosition = currentPos;
      });

      // Cập nhật camera để theo dõi vị trí hiện tại
      _animateToPosition(currentPos, zoom: 18.0);

      // Kiểm tra và cập nhật bước hiện tại
      _updateNavigationStep(currentPos);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.navigationStarted ?? 'Navigation started'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Dừng navigation
  void _stopNavigation() {
    if (!mounted) return;

    final l10n = AppLocalizations. of(context);

    setState(() {
      _isNavigating = false;
      _currentStepIndex = 0;
      _distanceToNextStep = null;
    });

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _navigationTimer?.cancel();
    _navigationTimer = null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.navigationStopped ?? 'Navigation stopped'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Cập nhật bước navigation dựa trên vị trí hiện tại
  void _updateNavigationStep(LatLng currentPos) {
    if (_directionsResult == null || _currentStepIndex >= _directionsResult!.steps.length) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final currentStep = _directionsResult!. steps[_currentStepIndex];
    final distanceToEnd = _calculateDistance(currentPos, currentStep.endLocation);

    setState(() {
      _distanceToNextStep = distanceToEnd;
    });

    // Nếu đã gần đến cuối bước hiện tại (< 20m), chuyển sang bước tiếp theo
    if (distanceToEnd < 20) {
      if (_currentStepIndex < _directionsResult!.steps. length - 1) {
        setState(() {
          _currentStepIndex++;
        });

        // Thông báo bước tiếp theo
        final nextStep = _directionsResult! .steps[_currentStepIndex];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nextStep.instructions),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Đã đến đích
        _stopNavigation();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.arrivedAtDestination ?? '🎉 You have arrived at your destination!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _animateToPosition(LatLng position, {double zoom = 15.0}) async {
    if (!mounted || ! _isMapReady || _mapController == null) return;
    
    try {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: zoom,
            bearing: _isNavigating ? 0 : 0,
            tilt: _isNavigating ? 45 : 0,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error animating camera: $e');
    }
  }

  Future<void> _animateToBounds(LatLngBounds bounds, {double padding = 100.0}) async {
    if (!mounted || !_isMapReady || _mapController == null) return;
    
    try {
      await _mapController!. animateCamera(
        CameraUpdate.newLatLngBounds(bounds, padding),
      );
    } catch (e) {
      debugPrint('Error animating camera to bounds:  $e');
    }
  }

  Future<void> _animateZoom(bool zoomIn) async {
    if (!mounted || !_isMapReady || _mapController == null) return;
    
    try {
      await _mapController!. animateCamera(
        zoomIn ? CameraUpdate.zoomIn() : CameraUpdate.zoomOut(),
      );
    } catch (e) {
      debugPrint('Error zooming: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (! mounted) return;
    
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });
    
    if (_currentPosition != const LatLng(48.8566, 2.3522)) {
      _animateToPosition(_currentPosition);
    }
  }

  void _onMapTap(LatLng position) {
    if (!mounted || !_isSelectingDestination) return;

    final l10n = AppLocalizations. of(context);
    
    setState(() {
      _destinationPosition = position;
      _markers.removeWhere((marker) => marker.markerId. value == 'destination');
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: position,
          icon:  BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: l10n?. destination ?? 'Destination'),
        ),
      );
      _isSelectingDestination = false;
    });
    
    _getDirections();
  }

  Future<void> _getDirections() async {
    if (!mounted || _destinationPosition == null) return;

    final l10n = AppLocalizations.of(context);
    final languageCode = _getLanguageCode(); // LẤY LANGUAGE CODE

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await DirectionsService.getDirections(
        origin: _currentPosition,
        destination: _destinationPosition!,
        mode: _selectedTravelMode,
        language: languageCode, // TRUYỀN LANGUAGE CODE VÀO API
      );

      if (!mounted) return;

      if (result != null && result.polylinePoints.isNotEmpty) {
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
          _currentStepIndex = 0;
        });

        await Future.delayed(const Duration(milliseconds: 100));
        
        if (mounted && ! _isNavigating) {
          _fitBounds();
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?. noRouteFound ?? 'Could not find a route'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n?.errorFindingRoute ?? 'Error finding route'}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _fitBounds() {
    if (!mounted || ! _isMapReady || _directionsResult == null || _mapController == null) {
      return;
    }

    try {
      final points = _directionsResult!.polylinePoints;
      
      if (points.isEmpty) return;
      
      double minLat = points.first.latitude;
      double maxLat = points.first.latitude;
      double minLng = points.first. longitude;
      double maxLng = points.first.longitude;

      for (final point in points) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      _animateToBounds(bounds, padding: 100.0);
    } catch (e) {
      debugPrint('Error fitting bounds: $e');
    }
  }

  void _clearRoute() {
    if (!mounted) return;
    
    // Dừng navigation nếu đang chạy
    if (_isNavigating) {
      _stopNavigation();
    }
    
    setState(() {
      _directionsResult = null;
      _destinationPosition = null;
      _polylines.clear();
      _markers.removeWhere((marker) => marker.markerId.value == 'destination');
      _isSelectingDestination = false;
      _currentStepIndex = 0;
      _distanceToNextStep = null;
    });
  }

  void _startSelectingDestination() {
    if (!mounted) return;

    final l10n = AppLocalizations. of(context);
    
    setState(() {
      _isSelectingDestination = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.tapToSelectDestination ?? 'Tap on the map to select destination'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getTravelModeText(TravelMode mode) {
    final l10n = AppLocalizations. of(context);
    switch (mode) {
      case TravelMode.driving:
        return l10n?.travelModeDriving ?? 'Driving';
      case TravelMode.walking:
        return l10n?. travelModeWalking ??  'Walking';
      case TravelMode.bicycling:
        return l10n?.travelModeBicycling ?? 'Bicycling';
      case TravelMode.transit:
        return l10n?.travelModeTransit ?? 'Transit';
    }
  }

  @override
  void dispose() {
    _isMapReady = false;
    _positionStreamSubscription?.cancel();
    _navigationTimer?.cancel();
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.map ?? 'Map'),
        backgroundColor: Colors.green. shade700,
        foregroundColor: Colors.white,
        actions: [
          if (_directionsResult != null && ! _isNavigating)
            PopupMenuButton<TravelMode>(
              icon: const Icon(Icons.directions),
              onSelected: (mode) {
                if (mounted) {
                  setState(() {
                    _selectedTravelMode = mode;
                  });
                  _getDirections();
                }
              },
              itemBuilder:  (context) => [
                PopupMenuItem(
                  value:  TravelMode.driving,
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.green. shade700),
                      const SizedBox(width: 8),
                      Text(_getTravelModeText(TravelMode.driving)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: TravelMode.walking,
                  child: Row(
                    children: [
                      Icon(Icons.directions_walk, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(_getTravelModeText(TravelMode. walking)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value:  TravelMode.bicycling,
                  child: Row(
                    children: [
                      Icon(Icons.directions_bike, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(_getTravelModeText(TravelMode.bicycling)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: TravelMode.transit,
                  child: Row(
                    children: [
                      Icon(Icons.directions_transit, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(_getTravelModeText(TravelMode. transit)),
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
                  zoomControlsEnabled: ! _isNavigating,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                  padding: EdgeInsets.only(
                    bottom: _directionsResult != null 
                        ? (_isNavigating ? 280 : 200) 
                        : 0,
                  ),
                ),
          // Panel hiển thị thông tin chỉ đường
          if (_directionsResult != null)
            DirectionsPanel(
              directionsResult:  _directionsResult,
              onClose: _clearRoute,
              currentStepIndex: _currentStepIndex,
              distanceToNextStep: _distanceToNextStep,
              isNavigating: _isNavigating,
              onStartNavigation: _startNavigation,
              onStopNavigation:  _stopNavigation,
            ),
        ],
      ),
      floatingActionButton: ! _isNavigating
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'directions',
                  onPressed: _directionsResult == null
                      ? _startSelectingDestination
                      : _clearRoute,
                  backgroundColor: _directionsResult == null
                      ?  Colors.blue
                      : Colors.red,
                  child: Icon(
                    _directionsResult == null
                        ?  Icons.directions
                        : Icons.clear,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  onPressed:  () => _animateZoom(true),
                  backgroundColor: Colors.white,
                  child: Icon(Icons.add, color: Colors.green.shade700),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  onPressed: () => _animateZoom(false),
                  backgroundColor:  Colors.white,
                  child: Icon(Icons.remove, color: Colors.green.shade700),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'my_location',
                  onPressed: _getCurrentLocation,
                  backgroundColor: Colors.green.shade700,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
                if (_directionsResult != null) const SizedBox(height: 200),
              ],
            )
          : null,
    );
  }
}