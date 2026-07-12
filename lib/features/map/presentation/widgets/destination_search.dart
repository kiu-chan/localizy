import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DestinationSearch extends StatefulWidget {
  final Function(LatLng) onDestinationSelected;

  const DestinationSearch({
    super.key,
    required this.onDestinationSelected,
  });

  @override
  State<DestinationSearch> createState() => _DestinationSearchState();
}

class _DestinationSearchState extends State<DestinationSearch> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed:  () => Navigator.pop(context),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a location...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  autofocus: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.location_on, color: Colors.green.shade700),
            title: const Text('Select on the map'),
            onTap: () {
              Navigator.pop(context);
              // Sẽ chuyển sang chế độ chọn điểm trên bản đồ
            },
          ),
        ],
      ),
    );
  }
}