import 'package:flutter/material.dart';
import 'package:localizy/api/city_api.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localizy/screens/home/verification/map_picker_page.dart';

class MapConfirmationPage extends StatefulWidget {
  final Map<String, double>? initialLocation;
  final String? initialLocationName;
  final String? initialCityId;
  final String? initialCityName;
  final String? initialFullAddress;
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback onPrevious;

  const MapConfirmationPage({
    super.key,
    this.initialLocation,
    this.initialLocationName,
    this.initialCityId,
    this.initialCityName,
    this.initialFullAddress,
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
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _fullAddressController = TextEditingController();

  List<CityItem> _cities = [];
  String? _selectedCityId;
  String? _selectedCityName;
  bool _isLoadingCities = true;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    if (_selectedLocation != null) {
      _address =
          'Lat: ${_selectedLocation!['lat']!.toStringAsFixed(6)}, Lng: ${_selectedLocation!['lng']!.toStringAsFixed(6)}';
    }
    _locationNameController.text = widget.initialLocationName ?? '';
    _fullAddressController.text = widget.initialFullAddress ?? '';
    _selectedCityId = widget.initialCityId;
    _selectedCityName = widget.initialCityName;
    _loadCities();
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    _fullAddressController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    try {
      final cities = await CityApi.getActiveCities();
      if (mounted) {
        setState(() {
          _cities = cities;
          _isLoadingCities = false;
          if (_selectedCityId != null) {
            final match = cities.where((c) => c.id == _selectedCityId).toList();
            if (match.isEmpty) {
              _selectedCityId = null;
              _selectedCityName = null;
            }
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCities = false);
      }
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
          'lng': result['lng'] as double,
        };
        _address = result['address'] as String;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(_selectedLocation!['lat']!, _selectedLocation!['lng']!),
          ),
        );
      }
    }
  }

  bool _canProceed() {
    return _selectedLocation != null &&
        _selectedCityId != null &&
        _fullAddressController.text.trim().isNotEmpty;
  }

  void _confirmLocation() {
    if (!_canProceed()) return;
    widget.onNext({
      'lat': _selectedLocation!['lat']!,
      'lng': _selectedLocation!['lng']!,
      'locationName': _locationNameController.text.trim(),
      'cityId': _selectedCityId,
      'cityName': _selectedCityName,
      'fullAddress': _fullAddressController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
                        const Icon(Icons.info_outline,
                            color: Color(0xFF4285F4), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            localizations.mapConfirmIntro,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Map preview
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.grey.shade300, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _selectedLocation == null
                        ? _buildEmptyMapPlaceholder()
                        : _buildMapPreview(),
                  ),
                ),

                const SizedBox(height: 16),

                // Select location button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openMapPicker,
                    icon: Icon(
                      _selectedLocation == null
                          ? Icons.add_location
                          : Icons.edit_location,
                    ),
                    label: Text(
                      _selectedLocation == null
                          ? localizations.selectLocationOnMap
                          : localizations.changeLocation,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                          color: Color(0xFF4285F4), width: 2),
                      foregroundColor: const Color(0xFF4285F4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                if (_selectedLocation != null) ...[
                  const SizedBox(height: 16),

                  // Coordinates card
                  Card(
                    elevation: 2,
                    color: const Color(0xFFEBF3FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                          color: Color(0xFF4285F4), width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildLocationRow(
                        Icons.location_on,
                        localizations.coordinates,
                        _address,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // ── City dropdown ──
                Text(
                  localizations.selectCity,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 8),

                if (_isLoadingCities)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _selectedCityId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.location_city),
                      hintText: localizations.selectCityHint,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    items: _cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city.id,
                        child: Text(city.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCityId = value;
                        _selectedCityName =
                            _cities.firstWhere((c) => c.id == value).name;
                      });
                    },
                  ),

                const SizedBox(height: 20),

                // ── Full address ──
                Text(
                  localizations.fullAddressLabel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _fullAddressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.home_outlined),
                    ),
                    hintText: localizations.fullAddressHint,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 20),

                // Location name
                TextFormField(
                  controller: _locationNameController,
                  decoration: InputDecoration(
                    labelText: localizations.mapLocationNameLabel,
                    hintText: localizations.mapLocationNameHint,
                    prefixIcon: const Icon(Icons.label_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

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
                            Icon(Icons.warning_amber,
                                color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Text(
                              localizations.importantNotes,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildNoteItem(localizations.notePleaseMarkExactly),
                        _buildNoteItem(localizations.noteCheckCoordinates),
                        _buildNoteItem(localizations.noteLocationWillBeUsed),
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
    final localizations = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            localizations.noLocationSelected,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    return GoogleMap(
      key: ValueKey(
          'map_${_selectedLocation!['lat']}_${_selectedLocation!['lng']}'),
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
        Icon(icon, size: 20, color: const Color(0xFF4285F4)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500),
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
              child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
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
            onPressed: _canProceed() ? _confirmLocation : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  localizations.confirmAndContinue,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
