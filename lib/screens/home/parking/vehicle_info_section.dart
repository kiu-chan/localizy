import 'package:flutter/material.dart';
import 'package:localizy/screens/ocr/license_plate_scanner_screen.dart';
import 'package:localizy/screens/home/parking/parking_zone_map_selector.dart';

class VehicleInfoSection extends StatefulWidget {
  final TextEditingController licensePlateController;
  final TextEditingController parkingZoneController;
  final void Function(String id, String code, int pricePerHour)? onZoneSelected;

  const VehicleInfoSection({
    super.key,
    required this.licensePlateController,
    required this.parkingZoneController,
    this.onZoneSelected,
  });

  @override
  State<VehicleInfoSection> createState() => _VehicleInfoSectionState();
}

class _VehicleInfoSectionState extends State<VehicleInfoSection> {
  final _licensePlateFocusNode = FocusNode();
  final _parkingZoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _licensePlateFocusNode.addListener(() => setState(() {}));
    widget.licensePlateController.addListener(() => setState(() {}));
    widget.parkingZoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _licensePlateFocusNode.dispose();
    _parkingZoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openLicensePlateScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder:  (context) => const LicensePlateScannerScreen(),
      ),
    );
    
    if (result != null && result. isNotEmpty) {
      setState(() {
        widget.licensePlateController.text = result;
      });
    }
  }

  Future<void> _openMapSelector() async {
    final result = await Navigator.push<ParkingZone>(
      context,
      MaterialPageRoute(
        builder: (context) => const ParkingZoneMapSelector(),
      ),
    );

    if (result != null) {
      setState(() {
        widget.parkingZoneController.text = result.code;
      });
      widget.onZoneSelected?.call(result.id, result.code, result.pricePerHour);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.directions_car, size: 24, color: Colors.green.shade700),
            const SizedBox(width: 8),
            const Text(
              'Vehicle Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height:  12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow:  [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // License Plate field with scanner button
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: widget.licensePlateController,
                      focusNode: _licensePlateFocusNode,
                      decoration: InputDecoration(
                        labelText: 'License Plate',
                        labelStyle: TextStyle(
                          color: (_licensePlateFocusNode. hasFocus || 
                                  widget.licensePlateController.text.isNotEmpty)
                              ? Colors.green.shade700
                              : Colors.grey,
                        ),
                        hintText: 'e.g.:  30A-12345',
                        prefixIcon: Icon(
                          Icons.directions_car,
                          color:  _licensePlateFocusNode. hasFocus
                              ? Colors.green.shade700
                              : Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:  BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey. shade300),
                        ),
                        focusedBorder:  OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.green.shade700,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      textCapitalization: TextCapitalization. characters,
                      validator: (value) {
                        if (value == null || value. isEmpty) {
                          return 'Please enter license plate';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Scan button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.qr_code_scanner,
                        color: Colors.red.shade700,
                        size: 28,
                      ),
                      onPressed: _openLicensePlateScanner,
                      tooltip: 'Scan License Plate',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height:  16),
              
              // Parking Zone field — read-only, chỉ chọn từ bản đồ
              Row(
                children:  [
                  Expanded(
                    child: TextFormField(
                      controller: widget.parkingZoneController,
                      focusNode: _parkingZoneFocusNode,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Parking Zone',
                        labelStyle: TextStyle(
                          color: widget.parkingZoneController.text.isNotEmpty
                              ? Colors.green.shade700
                              : Colors.grey,
                        ),
                        hintText: 'Select on map →',
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: widget.parkingZoneController.text.isNotEmpty
                              ? Colors.green.shade700
                              : Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blue.shade700,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a parking zone on the map';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Map selector button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue. shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.map,
                        color: Colors.blue.shade700,
                        size: 28,
                      ),
                      onPressed: _openMapSelector,
                      tooltip: 'Select on Map',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}