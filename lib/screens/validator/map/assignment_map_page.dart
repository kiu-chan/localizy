import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localizy/api/validator_api.dart';
import 'package:localizy/configs/map_config.dart';

class AssignmentMapPage extends StatefulWidget {
  final ValidationAssignment assignment;

  const AssignmentMapPage({super.key, required this.assignment});

  @override
  State<AssignmentMapPage> createState() => _AssignmentMapPageState();
}

class _AssignmentMapPageState extends State<AssignmentMapPage> {
  GoogleMapController? _mapController;
  MapType _mapType = MapConfig.defaultMapType;

  LatLng get _target => LatLng(
        widget.assignment.address!.lat!,
        widget.assignment.address!.lng!,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.assignment.requestId,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            tooltip: 'Toggle map type',
            onPressed: _toggleMapType,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _target,
              zoom: MapConfig.defaultZoom,
            ),
            mapType: _mapType,
            markers: {
              Marker(
                markerId: const MarkerId('assignment'),
                position: _target,
                infoWindow: InfoWindow(
                  title: widget.assignment.address!.code,
                  snippet: widget.assignment.address!.cityCode,
                ),
              ),
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

          // Zoom controls
          Positioned(
            right: 12,
            bottom: 120,
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
                _mapButton(Icons.my_location, () {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(_target, MapConfig.defaultZoom),
                  );
                }),
              ],
            ),
          ),

          // Info card at bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _buildInfoCard(),
          ),
        ],
      ),
    );
  }

  void _toggleMapType() {
    setState(() {
      _mapType = _mapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  Widget _mapButton(IconData icon, VoidCallback onPressed) {
    return Material(
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
          child: Icon(icon, size: 20, color: Colors.grey.shade700),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final a = widget.assignment;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  a.address!.code,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _cardRow('City', a.address!.cityCode),
          _cardRow(
            'Coordinates',
            '${a.address!.lat!.toStringAsFixed(6)}, ${a.address!.lng!.toStringAsFixed(6)}',
          ),
          if (a.submittedBy != null) _cardRow('Requester', a.submittedBy!.name),
        ],
      ),
    );
  }

  Widget _cardRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
