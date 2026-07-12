import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localizy/l10n/app_localizations.dart';

class MapTypeSelector extends StatelessWidget {
  final MapType currentMapType;
  final ValueChanged<MapType> onMapTypeChanged;

  const MapTypeSelector({
    super.key,
    required this.currentMapType,
    required this.onMapTypeChanged,
  });

  void _showMapTypeBottomSheet(BuildContext context) {
    final l10n = AppLocalizations. of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius. circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors. grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.layers,
                      color: Colors.green.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n?.selectMapType ??  'Select Map Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors. green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Map type options
              _buildMapTypeOption(
                context,
                MapType.normal,
                l10n?.normal ?? 'Normal',
                Icons.map_outlined,
                'Standard road map view',
              ),
              _buildMapTypeOption(
                context,
                MapType.satellite,
                l10n?.satellite ?? 'Satellite',
                Icons. satellite_alt_outlined,
                'Aerial satellite imagery',
              ),
              _buildMapTypeOption(
                context,
                MapType.terrain,
                l10n?.terrain ?? 'Terrain',
                Icons. terrain_outlined,
                'Topographic terrain view',
              ),
              _buildMapTypeOption(
                context,
                MapType.hybrid,
                l10n?.hybrid ?? 'Hybrid',
                Icons. layers_outlined,
                'Satellite with labels',
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapTypeOption(
    BuildContext context,
    MapType mapType,
    String label,
    IconData icon,
    String description,
  ) {
    final isSelected = currentMapType == mapType;
    
    return InkWell(
      onTap:  () {
        onMapTypeChanged(mapType);
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? Colors.green. shade700 : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.green.shade700
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child:  Icon(
                icon,
                size: 24,
                color: isSelected ?  Colors.white : Colors.grey. shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ?  FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.green.shade700 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style:  TextStyle(
                      fontSize:  12,
                      color: Colors. grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons. check_circle,
                color: Colors.green.shade700,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getMapTypeIcon(MapType mapType) {
    switch (mapType) {
      case MapType.normal:
        return Icons.map_outlined;
      case MapType.satellite:
        return Icons.satellite_alt_outlined;
      case MapType.terrain:
        return Icons.terrain_outlined;
      case MapType. hybrid:
        return Icons.layers_outlined;
      default: 
        return Icons.map_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 110,
      right: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius. circular(10),
        child: InkWell(
          onTap: () => _showMapTypeBottomSheet(context),
          borderRadius:  BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Icon(
              _getMapTypeIcon(currentMapType),
              color: Colors.green.shade700,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}