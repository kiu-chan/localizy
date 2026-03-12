import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localizy/configs/currency_config.dart';
import 'package:localizy/configs/map_config.dart';
import 'package:localizy/screens/map/widgets/directions_panel.dart';
import 'package:localizy/screens/map/widgets/map_type_selector.dart';
import 'package:localizy/services/directions_service.dart';

class ParkingZoneDetailMapPage extends StatefulWidget {
  final String zoneId;
  final String zoneCode;
  final String zoneName;
  final double latitude;
  final double longitude;
  final int availableSpots;
  final int totalSpots;
  final int pricePerHour;

  const ParkingZoneDetailMapPage({
    super.key,
    required this.zoneId,
    required this.zoneCode,
    required this.zoneName,
    required this.latitude,
    required this.longitude,
    this.availableSpots = 0,
    this.totalSpots = 0,
    this.pricePerHour = 0,
  });

  @override
  State<ParkingZoneDetailMapPage> createState() => _ParkingZoneDetailMapPageState();
}

class _ParkingZoneDetailMapPageState extends State<ParkingZoneDetailMapPage> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = MapConfig.defaultPosition;
  bool _isLoading = true;
  bool _isMapReady = false;

  MapType _currentMapType = MapConfig.defaultMapType;

  Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final Set<Polyline> _polylines = {};

  DirectionsResult? _directionsResult;
  bool _isNavigating = false;
  int _currentStepIndex = 0;
  double? _distanceToNextStep;
  StreamSubscription<Position>? _positionStreamSub;

  late final LatLng _zonePosition;

  @override
  void initState() {
    super.initState();
    _zonePosition = LatLng(widget.latitude, widget.longitude);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    _mapController = null;
    super.dispose();
  }

  // =================== Location ===================
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _isLoading = false);
        _buildMarkers();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      _animateToShowBoth();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
    _buildMarkers();
  }

  void _buildMarkers() {
    final isAvailable = widget.availableSpots > 0 || widget.totalSpots == 0;
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('parking_zone'),
          position: _zonePosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isAvailable ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
          ),
          onTap: _showZoneInfoDialog,
        ),
      };
      _circles.clear();
      _circles.add(Circle(
        circleId: const CircleId('parking_zone_circle'),
        center: _zonePosition,
        radius: 60,
        fillColor: (isAvailable ? Colors.green : Colors.red).withValues(alpha: 0.15),
        strokeColor: isAvailable ? Colors.green : Colors.red,
        strokeWidth: 2,
      ));
    });
  }

  // =================== Camera ===================
  Future<void> _animateToPosition(LatLng position, {double zoom = 16.0}) async {
    if (!_isMapReady || _mapController == null) return;
    try {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target: position,
          zoom: zoom,
          bearing: _isNavigating ? MapConfig.navigationBearing : 0,
          tilt: _isNavigating ? MapConfig.navigationTilt : MapConfig.normalTilt,
        )),
      );
    } catch (_) {}
  }

  Future<void> _animateToShowBoth() async {
    if (!_isMapReady || _mapController == null) return;
    try {
      final minLat = math.min(_currentPosition.latitude, _zonePosition.latitude);
      final maxLat = math.max(_currentPosition.latitude, _zonePosition.latitude);
      final minLng = math.min(_currentPosition.longitude, _zonePosition.longitude);
      final maxLng = math.max(_currentPosition.longitude, _zonePosition.longitude);

      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          80,
        ),
      );
    } catch (_) {
      _animateToPosition(_zonePosition);
    }
  }

  Future<void> _animateZoom(bool zoomIn) async {
    if (!_isMapReady || _mapController == null) return;
    try {
      await _mapController!.animateCamera(
        zoomIn ? CameraUpdate.zoomIn() : CameraUpdate.zoomOut(),
      );
    } catch (_) {}
  }

  // =================== Directions ===================
  Future<void> _getDirections() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final result = await DirectionsService.getDirections(
        origin: _currentPosition,
        destination: _zonePosition,
        mode: TravelMode.driving,
      );

      if (!mounted) return;

      if (result != null && result.polylinePoints.isNotEmpty) {
        setState(() {
          _directionsResult = result;
          _polylines
            ..clear()
            ..add(Polyline(
              polylineId: const PolylineId('route'),
              points: result.polylinePoints,
              color: Colors.blue,
              width: 5,
            ));
          _currentStepIndex = 0;
          _isLoading = false;
        });

        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted && !_isNavigating) _fitRoute();
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Could not find a route'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error finding route: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _fitRoute() {
    if (_directionsResult == null || _mapController == null) return;
    final points = _directionsResult!.polylinePoints;
    if (points.isEmpty) return;

    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      ),
      60,
    ));
  }

  void _clearRoute() {
    if (_isNavigating) _stopNavigation();
    setState(() {
      _directionsResult = null;
      _polylines.clear();
      _currentStepIndex = 0;
      _distanceToNextStep = null;
    });
  }

  // =================== Navigation ===================
  void _startNavigation() {
    if (_directionsResult == null) return;
    setState(() {
      _isNavigating = true;
      _currentStepIndex = 0;
    });

    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: MapConfig.distanceFilter.toInt(),
      ),
    ).listen((position) {
      if (!mounted || !_isNavigating) return;
      final current = LatLng(position.latitude, position.longitude);
      setState(() => _currentPosition = current);
      _animateToPosition(current, zoom: MapConfig.navigationZoom);
      _updateNavigationStep(current);
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Navigation started'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));
  }

  void _stopNavigation() {
    setState(() {
      _isNavigating = false;
      _currentStepIndex = 0;
      _distanceToNextStep = null;
    });
    _positionStreamSub?.cancel();
    _positionStreamSub = null;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Navigation stopped'),
      duration: Duration(seconds: 2),
    ));
  }

  void _updateNavigationStep(LatLng current) {
    if (_directionsResult == null ||
        _currentStepIndex >= _directionsResult!.steps.length) {
      return;
    }

    final step = _directionsResult!.steps[_currentStepIndex];
    final dist = _haversine(current, step.endLocation);
    setState(() => _distanceToNextStep = dist);

    if (dist < MapConfig.stepCompletionDistance) {
      if (_currentStepIndex < _directionsResult!.steps.length - 1) {
        setState(() => _currentStepIndex++);
      } else {
        _stopNavigation();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('🎉 You have arrived at the parking zone!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ));
      }
    }
  }

  double _haversine(LatLng a, LatLng b) {
    const r = 6371000.0;
    final lat1 = a.latitude * math.pi / 180;
    final lat2 = b.latitude * math.pi / 180;
    final dLat = (b.latitude - a.latitude) * math.pi / 180;
    final dLng = (b.longitude - a.longitude) * math.pi / 180;
    final x = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(x), math.sqrt(1 - x));
  }

  // =================== Map Callbacks ===================
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() => _isMapReady = true);
    _animateToPosition(_zonePosition);
  }

  void _onMapTypeChanged(MapType type) => setState(() => _currentMapType = type);

  // =================== Build ===================
  String _formatCurrency(int amount) => CurrencyConfig.format(amount.toDouble());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.zoneCode,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _zonePosition,
              zoom: 16,
            ),
            markers: _markers,
            circles: _circles,
            polylines: _polylines,
            mapType: _currentMapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: MapConfig.showCompass,
            mapToolbarEnabled: false,
            minMaxZoomPreference: MinMaxZoomPreference(MapConfig.minZoom, MapConfig.maxZoom),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Map type selector
          if (!_isNavigating)
            MapTypeSelector(
              currentMapType: _currentMapType,
              onMapTypeChanged: _onMapTypeChanged,
            ),

          // Directions panel
          if (_directionsResult != null)
            DirectionsPanel(
              directionsResult: _directionsResult,
              onClose: _clearRoute,
              currentStepIndex: _currentStepIndex,
              distanceToNextStep: _distanceToNextStep,
              isNavigating: _isNavigating,
              onStartNavigation: _startNavigation,
              onStopNavigation: _stopNavigation,
            ),
        ],
      ),
      floatingActionButton: !_isNavigating
          ? Padding(
              padding: EdgeInsets.only(
                bottom: _directionsResult != null ? 190 : 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Directions / Clear route button
                  FloatingActionButton(
                    heroTag: 'directions',
                    onPressed: _directionsResult == null ? _getDirections : _clearRoute,
                    backgroundColor: _directionsResult == null ? Colors.blue : Colors.red,
                    child: Icon(
                      _directionsResult == null ? Icons.directions : Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Zoom controls
                  FloatingActionButton(
                    heroTag: 'zoom_in',
                    onPressed: () => _animateZoom(true),
                    backgroundColor: Colors.white,
                    child: Icon(Icons.add, color: Colors.green.shade700),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: 'zoom_out',
                    onPressed: () => _animateZoom(false),
                    backgroundColor: Colors.white,
                    child: Icon(Icons.remove, color: Colors.green.shade700),
                  ),
                  const SizedBox(height: 10),
                  // My location
                  FloatingActionButton(
                    heroTag: 'my_location',
                    onPressed: _getCurrentLocation,
                    backgroundColor: Colors.green.shade700,
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  // Go to parking zone
                  if (_directionsResult == null)
                    FloatingActionButton(
                      heroTag: 'parking_info',
                      onPressed: () => _animateToPosition(_zonePosition),
                      backgroundColor: Colors.green.shade700,
                      child: const Icon(Icons.local_parking, color: Colors.white),
                    ),
                ],
              ),
            )
          : null,
    );
  }

  void _showZoneInfoDialog() {
    final isAvailable = widget.availableSpots > 0 || widget.totalSpots == 0;
    final statusColor = isAvailable ? Colors.green.shade700 : Colors.red.shade700;
    final statusText = isAvailable ? 'Available' : 'Full';

    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.local_parking, color: statusColor, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.zoneCode,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.zoneName,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: Icon(Icons.close, color: Colors.grey.shade500),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Status badge
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 18),

              // Stats row
              Row(
                children: [
                  _buildStat(
                    Icons.car_rental,
                    widget.totalSpots > 0 ? '${widget.availableSpots}/${widget.totalSpots}' : '—',
                    'Available',
                    Colors.blue,
                  ),
                  const SizedBox(width: 10),
                  _buildStat(
                    Icons.attach_money,
                    widget.pricePerHour > 0 ? _formatCurrency(widget.pricePerHour) : '—',
                    'Per Hour',
                    Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  _buildStat(
                    Icons.location_on,
                    '${widget.latitude.toStringAsFixed(4)},\n${widget.longitude.toStringAsFixed(4)}',
                    'Coordinates',
                    Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Get directions button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _getDirections();
                  },
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text(
                    'Get Directions',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
