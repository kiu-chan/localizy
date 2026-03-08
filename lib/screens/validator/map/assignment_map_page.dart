import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localizy/api/validator_api.dart';
import 'package:localizy/configs/map_config.dart';
import 'package:localizy/services/directions_service.dart';
import 'package:localizy/screens/map/widgets/directions_panel.dart';
import 'package:localizy/screens/map/widgets/map_type_selector.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentMapPage extends StatefulWidget {
  final ValidationAssignment assignment;

  const AssignmentMapPage({super.key, required this.assignment});

  @override
  State<AssignmentMapPage> createState() => _AssignmentMapPageState();
}

class _AssignmentMapPageState extends State<AssignmentMapPage> {
  GoogleMapController? _mapController;
  MapType _mapType = MapConfig.defaultMapType;

  LatLng? _currentPosition;
  bool _isLocating = false;

  DirectionsResult? _directionsResult;
  final Set<Polyline> _polylines = {};
  bool _isLoadingDirections = false;

  bool _isNavigating = false;
  int _currentStepIndex = 0;
  double? _distanceToNextStep;
  StreamSubscription<Position>? _positionStreamSubscription;

  LatLng get _target => LatLng(
        widget.assignment.address!.lat!,
        widget.assignment.address!.lng!,
      );

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _target,
              zoom: MapConfig.defaultZoom,
            ),
            mapType: _mapType,
            markers: _buildMarkers(),
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
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

          // Back button — top-left
          if (!_isNavigating && _directionsResult == null)
            Positioned(
              top: topPadding + 12,
              left: 12,
              child: _mapButton(Icons.arrow_back, () => Navigator.of(context).pop()),
            ),

          // Title chip — top-center
          if (!_isNavigating && _directionsResult == null)
            Positioned(
              top: topPadding + 12,
              left: 64,
              right: 64,
              child: Center(
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.assignment.requestId,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.green.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),

          // Map type selector — top-right (reuses MapTypeSelector bottom sheet)
          if (!_isNavigating && _directionsResult == null)
            MapTypeSelector(
              currentMapType: _mapType,
              onMapTypeChanged: (type) => setState(() => _mapType = type),
            ),

          // Right side controls
          if (!_isNavigating && _directionsResult == null)
          Positioned(
            right: 12,
            bottom: _directionsResult != null ? 240 : 120,
            child: Column(
              children: [
                _mapButton(Icons.add, () {
                  _mapController?.animateCamera(CameraUpdate.zoomIn());
                }),
                const SizedBox(height: 8),
                _mapButton(Icons.remove, () {
                  _mapController?.animateCamera(CameraUpdate.zoomOut());
                }),
                const SizedBox(height: 8),
                _mapButton(Icons.location_on, () {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(_target, MapConfig.defaultZoom),
                  );
                }, color: Colors.green.shade700),
                const SizedBox(height: 8),
                _isLocating
                    ? Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      )
                    : _mapButton(Icons.my_location, _goToMyLocation,
                        color: Colors.blue.shade700),
                if (!_isNavigating) ...[
                  const SizedBox(height: 8),
                  _directionsResult == null
                      ? _mapButton(Icons.directions, _getDirections,
                          color: Colors.blue.shade700,
                          tooltip: 'Chỉ đường')
                      : _mapButton(Icons.close, _clearRoute,
                          color: Colors.red.shade700,
                          tooltip: 'Xoá tuyến đường'),
                ],
              ],
            ),
          ),

          // Loading overlay for directions
          if (_isLoadingDirections)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 16),
                      Text(AppLocalizations.of(context)?.validatorMapFindingRoute ?? 'Finding route...'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Assignment marker
    markers.add(
      Marker(
        markerId: const MarkerId('assignment'),
        position: _target,
        onTap: _showAssignmentInfo,
        infoWindow: InfoWindow(
          title: widget.assignment.address!.code,
          snippet: widget.assignment.address!.cityCode,
        ),
      ),
    );

    return markers;
  }

  void _showAssignmentInfo() {
    final a = widget.assignment;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final sheetL10n = AppLocalizations.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green.shade700, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      a.address?.code ?? a.requestId,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _infoRow(Icons.tag, sheetL10n?.validatorMapRequestId ?? 'Request ID', a.requestId),
              _infoRow(Icons.location_city, sheetL10n?.validatorCityCode ?? 'City Code', a.address?.cityCode ?? '-'),
              _infoRow(Icons.gps_fixed, sheetL10n?.coordinates ?? 'Coordinates',
                  '${a.address?.lat?.toStringAsFixed(6) ?? '-'}, ${a.address?.lng?.toStringAsFixed(6) ?? '-'}'),
              _infoRow(Icons.info_outline, sheetL10n?.statusLabel ?? 'Status', a.status),
              _infoRow(Icons.flag, sheetL10n?.validatorPriority ?? 'Priority', a.priority),
              if (a.notes != null && a.notes!.isNotEmpty)
                _infoRow(Icons.notes, sheetL10n?.validatorNotes ?? 'Notes', a.notes!),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _sheetActionButton(
                      icon: Icons.directions,
                      label: sheetL10n?.validatorMapDirectionsHere ?? 'Get directions',
                      color: Colors.green.shade700,
                      onPressed: () {
                        Navigator.pop(context);
                        _getDirections();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _sheetActionButton(
                      icon: Icons.map,
                      label: sheetL10n?.validatorMapOpenInGoogleMaps ?? 'Google Maps',
                      color: Colors.blue.shade700,
                      onPressed: () {
                        Navigator.pop(context);
                        _openGoogleMaps();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openGoogleMaps() async {
    final lat = widget.assignment.address?.lat;
    final lng = widget.assignment.address?.lng;
    if (lat == null || lng == null) return;

    final uri = Uri.parse('https://maps.google.com/?q=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 2),
          ),
        ],
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    if (_isLocating) return;

    setState(() => _isLocating = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.locationPermissionDenied ?? 'Location permission denied'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (!mounted) return;

      final pos = LatLng(position.latitude, position.longitude);
      setState(() => _currentPosition = pos);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(pos, MapConfig.defaultZoom),
      );
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.validatorMapLocationError(e.toString()) ?? 'Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _getDirections() async {
    if (_isLoadingDirections) return;

    // Lấy vị trí hiện tại nếu chưa có
    if (_currentPosition == null) {
      await _goToMyLocation();
      if (_currentPosition == null) return;
    }

    if (!mounted) return;
    final locale = Localizations.localeOf(context);

    setState(() => _isLoadingDirections = true);

    try {
      final result = await DirectionsService.getDirections(
        origin: _currentPosition!,
        destination: _target,
        mode: TravelMode.driving,
        language: locale.languageCode,
      );

      if (!mounted) return;

      if (result != null && result.polylinePoints.isNotEmpty) {
        setState(() {
          _directionsResult = result;
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: result.polylinePoints,
              color: Colors.blue,
              width: 5,
            ),
          );
          _currentStepIndex = 0;
        });

        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) _fitBounds();
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.noRouteFound ?? 'Could not find a route'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.validatorMapDirectionsError(e.toString()) ?? 'Error finding route: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingDirections = false);
    }
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

  void _startNavigation() {
    if (!mounted || _directionsResult == null) return;

    setState(() {
      _isNavigating = true;
      _currentStepIndex = 0;
    });

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: MapConfig.distanceFilter.toInt(),
      ),
    ).listen((Position position) {
      if (!mounted || !_isNavigating) return;

      final currentPos = LatLng(position.latitude, position.longitude);
      setState(() => _currentPosition = currentPos);

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentPos,
            zoom: MapConfig.navigationZoom,
            bearing: MapConfig.navigationBearing,
            tilt: MapConfig.navigationTilt,
          ),
        ),
      );

      _updateNavigationStep(currentPos);
    });

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.navigationStarted ?? 'Navigation started'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _stopNavigation() {
    if (!mounted) return;

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    setState(() {
      _isNavigating = false;
      _currentStepIndex = 0;
      _distanceToNextStep = null;
    });
  }

  void _updateNavigationStep(LatLng currentPos) {
    if (_directionsResult == null ||
        _currentStepIndex >= _directionsResult!.steps.length) {
      return;
    }

    final currentStep = _directionsResult!.steps[_currentStepIndex];
    final distanceToEnd = _calculateDistance(currentPos, currentStep.endLocation);

    setState(() => _distanceToNextStep = distanceToEnd);

    if (distanceToEnd < MapConfig.stepCompletionDistance) {
      if (_currentStepIndex < _directionsResult!.steps.length - 1) {
        setState(() => _currentStepIndex++);
        final nextStep = _directionsResult!.steps[_currentStepIndex];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nextStep.instructions),
            backgroundColor: Colors.blue,
            duration: MapConfig.navigationSnackBarDuration,
          ),
        );
      } else {
        _stopNavigation();
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.validatorMapArrivedDestination ?? '🎉 You have arrived!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const double r = 6371000;
    final lat1 = p1.latitude * math.pi / 180;
    final lat2 = p2.latitude * math.pi / 180;
    final dLat = (p2.latitude - p1.latitude) * math.pi / 180;
    final dLng = (p2.longitude - p1.longitude) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  void _fitBounds() {
    if (_directionsResult == null || _mapController == null) return;

    final points = _directionsResult!.polylinePoints;
    if (points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        MapConfig.boundsPadding,
      ),
    );
  }

  Widget _sheetActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _mapButton(IconData icon, VoidCallback onPressed,
      {Color? color, String? tooltip}) {
    final widget = Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color ?? Colors.grey.shade700),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: widget);
    }
    return widget;
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
