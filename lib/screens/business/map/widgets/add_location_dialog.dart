import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localizy/api/city_api.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/business/map/map_form_snapshot.dart';

// ─── Result types ─────────────────────────────────────────────────────────────

sealed class AddLocationDialogResult {}

/// Người dùng nhấn "Lấy tọa độ từ bản đồ" → cần vào picking mode
class AddLocationPickResult extends AddLocationDialogResult {
  final FormSnapshot snapshot;
  AddLocationPickResult(this.snapshot);
}

/// Người dùng nhấn "Thêm" với form hợp lệ → gửi lên API
class AddLocationSubmitResult extends AddLocationDialogResult {
  final String name;
  final String fullAddress;
  final String cityCode;
  final double lat;
  final double lng;

  AddLocationSubmitResult({
    required this.name,
    required this.fullAddress,
    required this.cityCode,
    required this.lat,
    required this.lng,
  });
}

// ─── Dialog function ──────────────────────────────────────────────────────────

/// Hiển thị dialog thêm địa điểm mới.
///
/// - [snapshot]: dữ liệu form được khôi phục sau khi quay lại từ picking mode.
/// - [selectedLatLng]: tọa độ đã chọn trên bản đồ (pre-fill vĩ độ / kinh độ).
Future<AddLocationDialogResult?> showAddLocationDialog(
  BuildContext context, {
  FormSnapshot? snapshot,
  LatLng? selectedLatLng,
}) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: snapshot?.name ?? '');
  final fullAddressController =
      TextEditingController(text: snapshot?.fullAddress ?? '');
  final latController = TextEditingController(
    text: selectedLatLng?.latitude.toStringAsFixed(6) ?? '',
  );
  final lngController = TextEditingController(
    text: selectedLatLng?.longitude.toStringAsFixed(6) ?? '',
  );

  // Load danh sách thành phố trước khi hiển thị dialog
  List<CityItem> cities = [];
  try {
    cities = await CityApi.getActiveCities();
  } catch (_) {}

  String? selectedCityCode = snapshot?.cityCode.isNotEmpty == true
      ? snapshot!.cityCode
      : (cities.isNotEmpty ? cities.first.code : null);

  // 'submit' | 'pick' | 'cancel'
  String action = 'cancel';

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        final l10n = AppLocalizations.of(dialogContext)!;
        bool gpsLoading = false;
        bool gpsFilledFromDevice = latController.text.isNotEmpty &&
            selectedLatLng == null &&
            snapshot == null;

        Future<void> useMyLocation() async {
          setDialogState(() => gpsLoading = true);
          try {
            final serviceEnabled =
                await Geolocator.isLocationServiceEnabled();
            if (!serviceEnabled) {
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(l10n.mapLocationServiceDisabled)),
                );
              }
              return;
            }

            LocationPermission perm = await Geolocator.checkPermission();
            if (perm == LocationPermission.denied) {
              perm = await Geolocator.requestPermission();
            }
            if (perm == LocationPermission.denied ||
                perm == LocationPermission.deniedForever) {
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(l10n.locationPermissionDenied)),
                );
              }
              return;
            }

            final pos = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                timeLimit: Duration(seconds: 10),
              ),
            );

            latController.text = pos.latitude.toStringAsFixed(6);
            lngController.text = pos.longitude.toStringAsFixed(6);
            setDialogState(() => gpsFilledFromDevice = true);
          } catch (e) {
            if (dialogContext.mounted) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(content: Text(l10n.mapGetLocationError(e.toString()))),
              );
            }
          } finally {
            setDialogState(() => gpsLoading = false);
          }
        }

        final coordFilled =
            latController.text.isNotEmpty && lngController.text.isNotEmpty;

        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ───────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_location_alt,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.mapAddLocation,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n.mapAddLocationSubtitle,
                            style: TextStyle(
                                fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white70, size: 20),
                      onPressed: () {
                        action = 'cancel';
                        Navigator.pop(dialogContext);
                      },
                    ),
                  ],
                ),
              ),

              // ── Form ─────────────────────────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _FormField(
                          controller: nameController,
                          label: l10n.mapLocationNameLabel,
                          hint: l10n.mapLocationNameHint,
                          icon: Icons.storefront_outlined,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? l10n.mapLocationNameRequired
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        _FormField(
                          controller: fullAddressController,
                          label: l10n.mapFullAddressLabel,
                          hint: l10n.mapFullAddressHint,
                          icon: Icons.place_outlined,
                          maxLines: 2,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? l10n.mapFullAddressRequired
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedCityCode,
                          decoration: InputDecoration(
                            labelText: l10n.mapCityCode,
                            prefixIcon: const Icon(
                              Icons.location_city_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.blue.shade400, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            isDense: true,
                          ),
                          items: cities
                              .map((c) => DropdownMenuItem(
                                    value: c.code,
                                    child: Text('${c.name} (${c.code})'),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setDialogState(() => selectedCityCode = v),
                          validator: (_) => selectedCityCode == null
                              ? l10n.mapFieldRequired
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // ── Coordinates section ───────────────────────────
                        Row(
                          children: [
                            Icon(Icons.my_location_outlined,
                                size: 15, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              l10n.mapCoordinates,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const Spacer(),

                            // ── GPS personal location button ──────────────
                            _CoordSourceButton(
                              icon: Icons.my_location,
                              label: l10n.mapMyLocation,
                              color: Colors.green.shade700,
                              bgColor: Colors.green.shade50,
                              borderColor: Colors.green.shade300,
                              loading: gpsLoading,
                              onTap: useMyLocation,
                            ),
                            const SizedBox(width: 8),

                            // ── Pick from map button ──────────────────────
                            _CoordSourceButton(
                              icon: Icons.map_outlined,
                              label: l10n.mapPickFromMap,
                              color: Colors.cyan.shade700,
                              bgColor: Colors.cyan.shade50,
                              borderColor: Colors.cyan.shade300,
                              onTap: () {
                                action = 'pick';
                                Navigator.pop(dialogContext);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Indicator when coords are filled from some source
                        if (coordFilled)
                          _CoordSourceBadge(
                            fromMap: selectedLatLng != null,
                            fromGps: gpsFilledFromDevice,
                            lat: latController.text,
                            lng: lngController.text,
                          ),
                        if (coordFilled) const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: _FormField(
                                controller: latController,
                                label: l10n.mapLatitude,
                                hint: '21.0285',
                                icon: Icons.arrow_upward,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true, signed: true),
                                onChanged: (_) => setDialogState(() {}),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return l10n.mapFieldRequired;
                                  }
                                  if (double.tryParse(v.trim()) == null) {
                                    return l10n.mapFieldInvalid;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _FormField(
                                controller: lngController,
                                label: l10n.mapLongitude,
                                hint: '105.8542',
                                icon: Icons.arrow_forward,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true, signed: true),
                                onChanged: (_) => setDialogState(() {}),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return l10n.mapFieldRequired;
                                  }
                                  if (double.tryParse(v.trim()) == null) {
                                    return l10n.mapFieldInvalid;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Actions ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          action = 'cancel';
                          Navigator.pop(dialogContext);
                        },
                        style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            action = 'submit';
                            Navigator.pop(dialogContext);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_location_alt, size: 18),
                            const SizedBox(width: 6),
                            Text(l10n.mapAddLocation,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  if (action == 'pick') {
    return AddLocationPickResult(FormSnapshot(
      name: nameController.text,
      fullAddress: fullAddressController.text,
      cityCode: selectedCityCode ?? '',
    ));
  }

  if (action == 'submit') {
    return AddLocationSubmitResult(
      name: nameController.text.trim(),
      fullAddress: fullAddressController.text.trim(),
      cityCode: selectedCityCode ?? '',
      lat: double.parse(latController.text.trim()),
      lng: double.parse(lngController.text.trim()),
    );
  }

  return null; // cancelled
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────

/// Nút nhỏ chọn nguồn tọa độ (GPS hoặc bản đồ)
class _CoordSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final bool loading;
  final VoidCallback onTap;

  const _CoordSourceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    this.loading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                    strokeWidth: 1.5, color: color),
              )
            else
              Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge hiển thị nguồn tọa độ đã được điền
class _CoordSourceBadge extends StatelessWidget {
  final bool fromMap;
  final bool fromGps;
  final String lat;
  final String lng;

  const _CoordSourceBadge({
    required this.fromMap,
    required this.fromGps,
    required this.lat,
    required this.lng,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Color color;
    final IconData icon;
    final String sourceLabel;

    if (fromMap) {
      color = Colors.cyan.shade700;
      icon = Icons.map_outlined;
      sourceLabel = l10n.mapSourceFromMap;
    } else if (fromGps) {
      color = Colors.green.shade700;
      icon = Icons.my_location;
      sourceLabel = l10n.mapSourceMyLocation;
    } else {
      color = Colors.blue.shade600;
      icon = Icons.edit_outlined;
      sourceLabel = l10n.mapSourceManual;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            sourceLabel,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$lat,  $lng',
              style:
                  TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.check_circle, size: 14, color: color),
        ],
      ),
    );
  }
}

// ─── Reusable form field ──────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        isDense: true,
      ),
    );
  }
}
