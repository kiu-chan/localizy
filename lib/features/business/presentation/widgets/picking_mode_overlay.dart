import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localizy/l10n/app_localizations.dart';

/// Overlay full-screen khi người dùng đang chọn tọa độ trên bản đồ.
class PickingModeOverlay extends StatefulWidget {
  final LatLng? selectedLatLng;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final ValueChanged<LatLng> onSelectLocation;

  const PickingModeOverlay({
    super.key,
    required this.selectedLatLng,
    required this.onCancel,
    required this.onConfirm,
    required this.onSelectLocation,
  });

  @override
  State<PickingModeOverlay> createState() => _PickingModeOverlayState();
}

class _PickingModeOverlayState extends State<PickingModeOverlay> {
  bool _locating = false;

  Future<void> _useMyLocation() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _locating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError(l10n.mapLocationServiceDisabled);
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _showError(l10n.locationPermissionDenied);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (mounted) {
        widget.onSelectLocation(LatLng(pos.latitude, pos.longitude));
      }
    } catch (e) {
      _showError(l10n.mapGetLocationError(e.toString()));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final hasLocation = widget.selectedLatLng != null;

    return Stack(
      children: [
        // ── Top header (full-width) ───────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, topPadding + 14, 16, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade800,
                  Colors.blue.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.touch_app,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.mapSelectLocationTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        l10n.mapTapMapToPin,
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // X close
                GestureDetector(
                  onTap: widget.onCancel,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),


        // ── Bottom panel (full-width, solid) ─────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Coordinates display
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: hasLocation
                      ? _CoordCard(latlng: widget.selectedLatLng!)
                      : _EmptyCoordHint(),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    // My location — icon only
                    _MyLocationIconButton(
                      loading: _locating,
                      onPressed: _useMyLocation,
                    ),
                    const SizedBox(width: 12),

                    // Confirm button — full width
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: hasLocation ? widget.onConfirm : null,
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(
                          l10n.mapConfirm,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          disabledBackgroundColor: Colors.grey.shade200,
                          disabledForegroundColor: Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _CoordCard extends StatelessWidget {
  final LatLng latlng;
  const _CoordCard({required this.latlng});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.gps_fixed, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.selectedLocation,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _CoordChip(
                        label: l10n.mapLatitude,
                        value: latlng.latitude.toStringAsFixed(6)),
                    const SizedBox(width: 8),
                    _CoordChip(
                        label: l10n.mapLongitude,
                        value: latlng.longitude.toStringAsFixed(6)),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.blue.shade600, size: 20),
        ],
      ),
    );
  }
}

class _CoordChip extends StatelessWidget {
  final String label;
  final String value;
  const _CoordChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.blue.shade400)),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _EmptyCoordHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app, color: Colors.grey.shade400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.mapNoCoordinates,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyLocationIconButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;
  const _MyLocationIconButton(
      {required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Tooltip(
      message: l10n.mapMyLocation,
      child: SizedBox(
        width: 52,
        height: 52,
        child: OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green.shade700,
            side: BorderSide(color: Colors.green.shade400),
            backgroundColor: Colors.green.shade50,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: loading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.green.shade700),
                )
              : Icon(Icons.my_location,
                  size: 22, color: Colors.green.shade700),
        ),
      ),
    );
  }
}
