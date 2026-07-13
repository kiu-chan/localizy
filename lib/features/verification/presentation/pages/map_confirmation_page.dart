import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/core/theme/app_colors.dart';
import 'package:localizy/features/map/data/city_repository.dart';
import 'package:localizy/features/map/domain/city.dart';
import 'package:localizy/features/verification/presentation/widgets/verification_ui.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localizy/features/verification/presentation/pages/map_picker_page.dart';

class MapConfirmationPage extends ConsumerStatefulWidget {
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
  ConsumerState<MapConfirmationPage> createState() =>
      _MapConfirmationPageState();
}

class _MapConfirmationPageState extends ConsumerState<MapConfirmationPage> {
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
      final cities = await ref.read(cityRepositoryProvider).getActiveCities();
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

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    String? label,
    EdgeInsetsGeometry? iconPadding,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.disabled, fontSize: 14),
      filled: true,
      fillColor: AppColors.surface,
      prefixIcon: Padding(
        padding: iconPadding ?? EdgeInsets.zero,
        child: Icon(icon, color: AppColors.muted, size: 20),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VerificationInfoBanner(text: localizations.mapConfirmIntro),
                const SizedBox(height: 20),

                // Map preview
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppShadows.cardList,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _selectedLocation == null
                      ? _buildEmptyMapPlaceholder(localizations)
                      : _buildMapPreview(),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openMapPicker,
                    icon: Icon(
                      _selectedLocation == null
                          ? Icons.add_location_alt_outlined
                          : Icons.edit_location_alt_outlined,
                      size: 20,
                    ),
                    label: Text(
                      _selectedLocation == null
                          ? localizations.selectLocationOnMap
                          : localizations.changeLocation,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                if (_selectedLocation != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: verificationCardDecoration(
                      borderColor: AppColors.primary.withValues(alpha: 0.4),
                    ).copyWith(color: AppColors.primarySurface),
                    child: _buildLocationRow(
                      Icons.location_on,
                      localizations.coordinates,
                      _address,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ── City dropdown ──
                _buildFieldLabel(localizations.selectCity),
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
                    initialValue: _selectedCityId,
                    decoration: _fieldDecoration(
                      hint: localizations.selectCityHint,
                      icon: Icons.location_city,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.muted),
                    borderRadius: BorderRadius.circular(14),
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
                _buildFieldLabel(localizations.fullAddressLabel),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullAddressController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14, color: AppColors.ink),
                  decoration: _fieldDecoration(
                    hint: localizations.fullAddressHint,
                    icon: Icons.home_outlined,
                    iconPadding: const EdgeInsets.only(bottom: 40),
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 20),

                // ── Location name (optional) ──
                _buildFieldLabel(localizations.mapLocationNameLabel),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _locationNameController,
                  style: const TextStyle(fontSize: 14, color: AppColors.ink),
                  decoration: _fieldDecoration(
                    hint: localizations.mapLocationNameHint,
                    icon: Icons.label_outline,
                  ),
                ),

                const SizedBox(height: 24),

                VerificationNotesCard(
                  title: localizations.importantNotes,
                  notes: [
                    localizations.notePleaseMarkExactly,
                    localizations.noteCheckCoordinates,
                    localizations.noteLocationWillBeUsed,
                  ],
                ),
              ],
            ),
          ),
        ),
        VerificationBottomBar(
          child: SizedBox(
            width: double.infinity,
            child: VerificationPrimaryButton(
              label: localizations.confirmAndContinue,
              icon: Icons.arrow_forward,
              onPressed: _canProceed() ? _confirmLocation : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    );
  }

  Widget _buildEmptyMapPlaceholder(AppLocalizations localizations) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.fill,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, size: 56, color: AppColors.disabled),
          const SizedBox(height: 12),
          Text(
            localizations.noLocationSelected,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
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
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
