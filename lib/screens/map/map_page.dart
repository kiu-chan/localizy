import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/services/directions_service.dart';
import 'package:localizy/screens/map/widgets/directions_panel.dart';
import 'package:localizy/screens/map/widgets/map_type_selector.dart';
import 'package:localizy/screens/map/widgets/address_search_bar.dart';
import 'package:localizy/screens/map/widgets/address_cluster_manager.dart';
import 'package:localizy/screens/map/widgets/address_detail_bottom_sheet.dart';
import 'package:localizy/configs/map_config.dart';
import 'package:localizy/api/address_api.dart';

class MapPage extends StatefulWidget {
  final Function(bool)? onNavigationStateChanged;

  const MapPage({
    super.key,
    this.onNavigationStateChanged,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  GoogleMapController? _mapController;
  LatLng _currentPosition = MapConfig.defaultPosition;
  bool _isLoading = true;
  bool _hasLoadedOnce = false;
  Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isMapReady = false;

  DirectionsResult? _directionsResult;
  LatLng? _destinationPosition;
  bool _isSelectingDestination = false;
  final TravelMode _selectedTravelMode = TravelMode.driving;

  // Navigation tracking
  bool _isNavigating = false;
  int _currentStepIndex = 0;
  double? _distanceToNextStep;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _navigationTimer;

  // Map type selection
  MapType _currentMapType = MapConfig.defaultMapType;

  // Cluster Manager
  late AddressClusterManager _addressClusterManager;

  // Marker không thuộc cluster (destination, searched, etc.)
  final Set<Marker> _nonClusterMarkers = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initClusterManager();
  }

  void _initClusterManager() {
    _addressClusterManager = AddressClusterManager(
      onMarkersUpdated: _onClusterMarkersUpdated,
      onAddressTapped: _onAddressTapped,
      onClusterTapped: _onClusterTapped,
      initialZoom: MapConfig.defaultZoom,
    );
  }

  void _onClusterMarkersUpdated(Set<Marker> clusterMarkers) {
    if (!mounted) return;
    setState(() {
      _markers = clusterMarkers.union(_nonClusterMarkers);
    });
  }

  void _onAddressTapped(AddressCoordinate address) {
    final position = LatLng(address.lat, address.lng);
    _animateToPosition(position, zoom: 17.0);

    AddressDetailBottomSheet.show(
      context,
      address: address,
      onGetDirections: _setDestinationAndGetDirections,
    );
  }

  void _onClusterTapped(LatLng position, double currentZoom) {
    _animateToPosition(position, zoom: currentZoom + 2);
  }

  void _setDestinationAndGetDirections(AddressCoordinate address) {
    final position = LatLng(address.lat, address.lng);

    setState(() {
      _destinationPosition = position;
      _nonClusterMarkers.removeWhere((marker) => marker.markerId.value == 'destination');
      _nonClusterMarkers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: address.code.isNotEmpty ? address.code : address.id),
        ),
      );
    });

    _addressClusterManager.updateMap();
    _getDirections();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading && !_hasLoadedOnce) {
      _getCurrentLocation();
      _fetchApiAddresses();
    }
  }

  String _getLanguageCode() {
    final locale = Localizations.localeOf(context);
    return locale.languageCode;
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n?.locationPermissionDenied ?? 'Location permission denied'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasLoadedOnce = true;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.pleaseEnableLocationInSettings ?? 'Please enable location'),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasLoadedOnce = true;
          });
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
        _hasLoadedOnce = true;
      });

      _animateToPosition(_currentPosition, zoom: MapConfig.defaultZoom);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasLoadedOnce = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n?.errorGettingLocation ?? 'Error'}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchApiAddresses() async {
    try {
      final list = await AddressApi.fetchCoordinates();
      _addressClusterManager.setAddresses(list);
    } catch (e) {
      debugPrint('Failed to fetch API addresses: $e');
    }
  }

  // =================== Navigation Methods ===================
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000;

    final lat1 = point1.latitude * math.pi / 180;
    final lat2 = point2.latitude * math.pi / 180;
    final dLat = (point2.latitude - point1.latitude) * math.pi / 180;
    final dLng = (point2.longitude - point1.longitude) * math.pi / 180;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
            math.sin(dLng / 2) * math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  void _startNavigation() {
    if (!mounted || _directionsResult == null) return;

    final l10n = AppLocalizations.of(context);

    setState(() {
      _isNavigating = true;
      _currentStepIndex = 0;
    });

    widget.onNavigationStateChanged?.call(true);

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: MapConfig.distanceFilter.toInt(),
      ),
    ).listen((Position position) {
      if (!mounted || !_isNavigating) return;

      final currentPos = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = currentPos;
      });

      _animateToPosition(currentPos, zoom: MapConfig.navigationZoom);
      _updateNavigationStep(currentPos);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.navigationStarted ?? 'Navigation started'),
        backgroundColor: Colors.green,
        duration: MapConfig.snackBarDuration,
      ),
    );
  }

  void _stopNavigation() {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);

    setState(() {
      _isNavigating = false;
      _currentStepIndex = 0;
      _distanceToNextStep = null;
    });

    widget.onNavigationStateChanged?.call(false);

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _navigationTimer?.cancel();
    _navigationTimer = null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.navigationStopped ?? 'Navigation stopped'),
        duration: MapConfig.snackBarDuration,
      ),
    );
  }

  void _updateNavigationStep(LatLng currentPos) {
    if (_directionsResult == null || _currentStepIndex >= _directionsResult!.steps.length) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final currentStep = _directionsResult!.steps[_currentStepIndex];
    final distanceToEnd = _calculateDistance(currentPos, currentStep.endLocation);

    setState(() {
      _distanceToNextStep = distanceToEnd;
    });

    if (distanceToEnd < MapConfig.stepCompletionDistance) {
      if (_currentStepIndex < _directionsResult!.steps.length - 1) {
        setState(() {
          _currentStepIndex++;
        });

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.arrivedAtDestination ?? '🎉 You have arrived at your destination!'),
            backgroundColor: Colors.green,
            duration: MapConfig.navigationSnackBarDuration,
          ),
        );
      }
    }
  }

  // =================== Camera Methods ===================
  Future<void> _animateToPosition(LatLng position, {double? zoom}) async {
    if (!mounted || !_isMapReady || _mapController == null) return;

    try {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: zoom ?? MapConfig.defaultZoom,
            bearing: _isNavigating ? MapConfig.navigationBearing : 0,
            tilt: _isNavigating ? MapConfig.navigationTilt : MapConfig.normalTilt,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error animating camera: $e');
    }
  }

  Future<void> _animateToBounds(LatLngBounds bounds, {double? padding}) async {
    if (!mounted || !_isMapReady || _mapController == null) return;

    try {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, padding ?? MapConfig.boundsPadding),
      );
    } catch (e) {
      debugPrint('Error animating camera to bounds: $e');
    }
  }

  Future<void> _animateZoom(bool zoomIn) async {
    if (!mounted || !_isMapReady || _mapController == null) return;

    try {
      await _mapController!.animateCamera(
        zoomIn ? CameraUpdate.zoomIn() : CameraUpdate.zoomOut(),
      );
    } catch (e) {
      debugPrint('Error zooming: $e');
    }
  }

  // =================== Map Callbacks ===================
  void _onMapCreated(GoogleMapController controller) {
    if (!mounted) return;

    _mapController = controller;
    _addressClusterManager.setMapId(controller.mapId);

    setState(() {
      _isMapReady = true;
    });

    if (_currentPosition != MapConfig.defaultPosition) {
      _animateToPosition(_currentPosition);
    }
  }

  void _onCameraMove(CameraPosition position) {
    _addressClusterManager.onCameraMove(position);
  }

  void _onCameraIdle() {
    _addressClusterManager.updateMap();
  }

  void _onMapTap(LatLng position) {
    if (!mounted || !_isSelectingDestination) return;

    final l10n = AppLocalizations.of(context);

    setState(() {
      _destinationPosition = position;
      _nonClusterMarkers.removeWhere((marker) => marker.markerId.value == 'destination');
      _nonClusterMarkers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: l10n?.destination ?? 'Destination'),
        ),
      );
      _isSelectingDestination = false;
    });

    _addressClusterManager.updateMap();
    _getDirections();
  }

  // =================== Directions Methods ===================
  Future<void> _getDirections() async {
    if (!mounted || _destinationPosition == null) return;

    final l10n = AppLocalizations.of(context);
    final languageCode = _getLanguageCode();

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await DirectionsService.getDirections(
        origin: _currentPosition,
        destination: _destinationPosition!,
        mode: _selectedTravelMode,
        language: languageCode,
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
          _isLoading = false;
          _currentStepIndex = 0;
        });

        await Future.delayed(const Duration(milliseconds: 100));

        if (mounted && !_isNavigating) {
          _fitBounds();
        }
      } else {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
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
    if (!mounted || !_isMapReady || _directionsResult == null || _mapController == null) {
      return;
    }

    try {
      final points = _directionsResult!.polylinePoints;

      if (points.isEmpty) return;

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

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      _animateToBounds(bounds);
    } catch (e) {
      debugPrint('Error fitting bounds: $e');
    }
  }

  void _clearRoute() {
    if (!mounted) return;

    if (_isNavigating) {
      _stopNavigation();
    }

    setState(() {
      _directionsResult = null;
      _destinationPosition = null;
      _polylines.clear();
      _nonClusterMarkers.removeWhere((marker) =>
          marker.markerId.value == 'destination' ||
          marker.markerId.value == 'searched');
      _isSelectingDestination = false;
      _currentStepIndex = 0;
      _distanceToNextStep = null;
    });

    _addressClusterManager.updateMap();
    widget.onNavigationStateChanged?.call(false);
  }

  void _startSelectingDestination() {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);

    setState(() {
      _isSelectingDestination = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.tapToSelectDestination ?? 'Tap on the map to select destination'),
        duration: MapConfig.snackBarDuration,
      ),
    );
  }

  void _onMapTypeChanged(MapType newMapType) {
    setState(() {
      _currentMapType = newMapType;
    });
  }

  void _onAddressSelected(AddressResult address) {
    final position = LatLng(address.lat, address.lng);

    setState(() {
      _nonClusterMarkers.removeWhere((marker) => marker.markerId.value == 'searched');
      _nonClusterMarkers.add(
        Marker(
          markerId: const MarkerId('searched'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: address.code,
            snippet: address.address,
          ),
        ),
      );
    });

    _addressClusterManager.updateMap();
    _animateToPosition(position, zoom: 17.0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              address.verified ? Icons.verified : Icons.location_on,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${address.code} - ${address.address}',
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: address.verified ? Colors.green.shade700 : Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Directions',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _destinationPosition = position;
              _nonClusterMarkers.removeWhere((marker) => marker.markerId.value == 'destination');
              _nonClusterMarkers.add(
                Marker(
                  markerId: const MarkerId('destination'),
                  position: position,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  infoWindow: InfoWindow(title: address.address),
                ),
              );
            });
            _addressClusterManager.updateMap();
            _getDirections();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isMapReady = false;
    _positionStreamSubscription?.cancel();
    _navigationTimer?.cancel();
    widget.onNavigationStateChanged?.call(false);
    _mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          _isLoading && !_hasLoadedOnce
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(height: 16),
                      Text(l10n?.loadingMap ?? 'Loading map...'),
                    ],
                  ),
                )
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  onTap: _onMapTap,
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: MapConfig.defaultZoom,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: MapConfig.showMyLocationButton,
                  mapType: _currentMapType,
                  zoomControlsEnabled: MapConfig.showZoomControls,
                  compassEnabled: MapConfig.showCompass,
                  mapToolbarEnabled: MapConfig.showMapToolbar,
                  minMaxZoomPreference: MinMaxZoomPreference(
                    MapConfig.minZoom,
                    MapConfig.maxZoom,
                  ),
                ),
          if (!_isLoading && !_isNavigating)
            MapTypeSelector(
              currentMapType: _currentMapType,
              onMapTypeChanged: _onMapTypeChanged,
            ),
          if (!_isLoading && !_isNavigating)
            AddressSearchBar(
              onAddressSelected: _onAddressSelected,
            ),
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
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'directions',
                  onPressed: _directionsResult == null
                      ? _startSelectingDestination
                      : _clearRoute,
                  backgroundColor: _directionsResult == null
                      ? Colors.blue
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