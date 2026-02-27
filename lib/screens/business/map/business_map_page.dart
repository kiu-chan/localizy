import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localizy/api/address_api.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/business/map/map_form_snapshot.dart';
import 'package:localizy/screens/business/map/widgets/add_location_dialog.dart';
import 'package:localizy/screens/business/map/widgets/location_detail_sheet.dart';
import 'package:localizy/screens/business/map/widgets/location_list_sheet.dart';
import 'package:localizy/screens/business/map/widgets/map_normal_overlay.dart';
import 'package:localizy/screens/business/map/widgets/picking_mode_overlay.dart';

class BusinessMapPage extends StatefulWidget {
  const BusinessMapPage({super.key});

  @override
  State<BusinessMapPage> createState() => _BusinessMapPageState();
}

class _BusinessMapPageState extends State<BusinessMapPage> {
  late GoogleMapController _mapController;
  final Completer<GoogleMapController> _controller = Completer();
  MapType _currentMapType = MapType.normal;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(21.0285, 105.8542),
    zoom: 12,
  );

  final Set<Marker> _markers = {};
  List<MyAddress> _addresses = [];
  bool _isLoading = false;
  String? _error;
  bool _showMineOnly = false;

  // ── Picking mode ──────────────────────────────────────────────────────────
  bool _isPickingLocation = false;
  LatLng? _selectedLatLng;
  FormSnapshot? _formSnapshot;

  static const String _selectionMarkerId = '__selection__';

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  // ─── API ──────────────────────────────────────────────────────────────────

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = _showMineOnly
          ? await AddressApi.getBusinessMineAddresses()
          : await AddressApi.getBusinessAddresses();
      if (mounted) {
        setState(() => _addresses = list);
        _rebuildAddressMarkers();
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleMineOnly() {
    setState(() => _showMineOnly = !_showMineOnly);
    _loadAddresses();
  }


  // ─── Markers ──────────────────────────────────────────────────────────────

  void _rebuildAddressMarkers() {
    setState(() {
      _markers.removeWhere((m) => m.markerId.value != _selectionMarkerId);
      for (final address in _addresses) {
        _markers.add(
          Marker(
            markerId: MarkerId(address.id),
            position: LatLng(address.latitude, address.longitude),
            infoWindow: InfoWindow(
              title: address.name.isNotEmpty ? address.name : address.code,
              snippet: address.cityCode,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                _markerHue(address.status)),
            onTap: () {
              if (!_isPickingLocation) showLocationDetailSheet(context, address);
            },
          ),
        );
      }
    });
  }

  void _setSelectionMarker(LatLng latlng) {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _selectedLatLng = latlng;
      _markers.removeWhere((m) => m.markerId.value == _selectionMarkerId);
      _markers.add(
        Marker(
          markerId: const MarkerId(_selectionMarkerId),
          position: latlng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: InfoWindow(
            title: l10n.selectedLocation,
            snippet:
                '${latlng.latitude.toStringAsFixed(5)}, ${latlng.longitude.toStringAsFixed(5)}',
          ),
        ),
      );
    });
  }

  void _clearSelectionMarker() {
    setState(() {
      _selectedLatLng = null;
      _markers.removeWhere((m) => m.markerId.value == _selectionMarkerId);
    });
  }

  double _markerHue(String status) {
    switch (status) {
      case 'Reviewed':
        return BitmapDescriptor.hueBlue;
      case 'Rejected':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueOrange;
    }
  }

  // ─── Map callbacks ────────────────────────────────────────────────────────

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _mapController = controller;
    if (_addresses.isNotEmpty) {
      controller.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_addresses.first.latitude, _addresses.first.longitude),
        ),
      );
    }
  }

  /// Chỉ xử lý tap khi đang ở chế độ chọn tọa độ
  void _onMapTapped(LatLng latlng) {
    if (_isPickingLocation) _setSelectionMarker(latlng);
  }

  // ─── Picking mode ─────────────────────────────────────────────────────────

  void _enterPickingMode(FormSnapshot snapshot) {
    setState(() {
      _isPickingLocation = true;
      _formSnapshot = snapshot;
      _selectedLatLng = null;
      _markers.removeWhere((m) => m.markerId.value == _selectionMarkerId);
    });
  }

  void _confirmPicking() {
    if (_selectedLatLng == null) return;
    setState(() => _isPickingLocation = false);
    _openAddDialog(snapshot: _formSnapshot);
  }

  void _cancelPicking() {
    setState(() {
      _isPickingLocation = false;
      _formSnapshot = null;
    });
    _clearSelectionMarker();
  }

  // ─── Camera ───────────────────────────────────────────────────────────────

  Future<void> _flyTo(LatLng latlng) async {
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latlng, zoom: 15),
      ),
    );
  }

  // ─── Map type dialog ──────────────────────────────────────────────────────

  void _showMapTypeDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectMapType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map),
              title: Text(l10n.normal),
              onTap: () {
                setState(() => _currentMapType = MapType.normal);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.satellite),
              title: Text(l10n.satellite),
              onTap: () {
                setState(() => _currentMapType = MapType.satellite);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.terrain),
              title: Text(l10n.terrain),
              onTap: () {
                setState(() => _currentMapType = MapType.terrain);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Add location flow ────────────────────────────────────────────────────

  Future<void> _openAddDialog({FormSnapshot? snapshot}) async {
    final result = await showAddLocationDialog(
      context,
      snapshot: snapshot,
      selectedLatLng: _selectedLatLng,
    );

    if (!mounted) return;

    if (result is AddLocationPickResult) {
      _enterPickingMode(result.snapshot);
      return;
    }

    if (result is AddLocationSubmitResult) {
      await _submitNewAddress(result);
    }
  }

  Future<void> _submitNewAddress(AddLocationSubmitResult data) async {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final newAddress = await AddressApi.addAddress(
        code: data.code,
        name: data.name,
        fullAddress: data.fullAddress,
        latitude: data.lat,
        longitude: data.lng,
        cityCode: data.cityCode,
      );

      if (mounted) {
        Navigator.pop(context); // close loading
        _clearSelectionMarker();
        setState(() {
          _formSnapshot = null;
          _addresses.insert(0, newAddress);
        });
        _rebuildAddressMarkers();

        final messenger = ScaffoldMessenger.of(context);
        await _flyTo(LatLng(newAddress.latitude, newAddress.longitude));
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.mapAddLocationSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.mapErrorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: _initialPosition,
            onMapCreated: _onMapCreated,
            onTap: _onMapTapped,
            markers: _markers,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          if (_isPickingLocation)
            Positioned.fill(
              child: PickingModeOverlay(
                selectedLatLng: _selectedLatLng,
                onCancel: _cancelPicking,
                onConfirm: _confirmPicking,
                onSelectLocation: (latlng) {
                  _setSelectionMarker(latlng);
                  _flyTo(latlng);
                },
              ),
            ),

          if (!_isPickingLocation)
            Positioned.fill(
              child: MapNormalOverlay(
                addresses: _addresses,
                isLoading: _isLoading,
                error: _error,
                showMineOnly: _showMineOnly,
                onRefresh: _loadAddresses,
                onDismissError: () => setState(() => _error = null),
                onShowMapType: _showMapTypeDialog,
                onToggleMineOnly: _toggleMineOnly,
                onSuggestionTap: (address) =>
                    _flyTo(LatLng(address.latitude, address.longitude)),
                onShowList: () => showLocationListSheet(
                  context,
                  _addresses,
                  _flyTo,
                ),
                onAddLocation: () => _openAddDialog(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
