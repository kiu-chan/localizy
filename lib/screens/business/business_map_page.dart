import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class BusinessMapPage extends StatefulWidget {
  const BusinessMapPage({super.key});

  @override
  State<BusinessMapPage> createState() => _BusinessMapPageState();
}

class _BusinessMapPageState extends State<BusinessMapPage> {
  late GoogleMapController _mapController;
  final Completer<GoogleMapController> _controller = Completer();
  MapType _currentMapType = MapType.normal;

  // Vị trí trung tâm tại Paris, France
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(48.8566, 2.3522), // Paris, France
    zoom: 12,
  );

  // Danh sách markers cho các địa điểm kinh doanh tại Pháp
  final Set<Marker> _markers = {};
  
  final List<Map<String, dynamic>> _locations = [
    {
      'id': '1',
      'name': 'Café de Flore',
      'address': '172 Boulevard Saint-Germain, 75006 Paris',
      'lat': 48.8542,
      'lng': 2.3320,
      'status': 'Active',
      'type': 'Café',
    },
    {
      'id': '2',
      'name': 'Le Marais Restaurant',
      'address': '15 Rue des Archives, 75004 Paris',
      'lat':  48.8584,
      'lng': 2.3558,
      'status': 'Active',
      'type': 'Restaurant',
    },
    {
      'id': '3',
      'name': 'Boutique Champs-Élysées',
      'address': '50 Avenue des Champs-Élysées, 75008 Paris',
      'lat': 48.8698,
      'lng': 2.3078,
      'status': 'Active',
      'type': 'Retail',
    },
    {
      'id': '4',
      'name': 'Montmartre Gallery',
      'address': '22 Rue des Abbesses, 75018 Paris',
      'lat': 48.8846,
      'lng': 2.3387,
      'status': 'Pending',
      'type': 'Gallery',
    },
    {
      'id': '5',
      'name': 'Latin Quarter Bistro',
      'address': '8 Rue de la Huchette, 75005 Paris',
      'lat':  48.8527,
      'lng': 2.3456,
      'status': 'Active',
      'type': 'Restaurant',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  void _loadMarkers() {
    for (var location in _locations) {
      _markers.add(
        Marker(
          markerId: MarkerId(location['id']),
          position: LatLng(location['lat'], location['lng']),
          infoWindow: InfoWindow(
            title: location['name'],
            snippet: location['address'],
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            location['status'] == 'Active' 
              ? BitmapDescriptor.hueBlue 
              : BitmapDescriptor.hueOrange,
          ),
          onTap: () {
            _showLocationDetail(location);
          },
        ),
      );
    }
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Business Map',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: () {
              _goToInitialPosition();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: _initialPosition,
            onMapCreated: _onMapCreated,
            markers: _markers,
            myLocationEnabled: false,
            myLocationButtonEnabled:  false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Location count badge
          Positioned(
            top: 16,
            left: 16,
            child:  Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow:  [
                  BoxShadow(
                    color: Colors. black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_locations.length} Locations',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors. blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Map type selector
          Positioned(
            top: 16,
            right:  16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow:  [
                  BoxShadow(
                    color: Colors. black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child:  Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.layers),
                    onPressed: () {
                      _showMapTypeDialog();
                    },
                    color: Colors.blue.shade700,
                  ),
                ],
              ),
            ),
          ),

          // Floating location list button
          Positioned(
            bottom: 100,
            right: 16,
            child:  FloatingActionButton(
              onPressed: () {
                _showLocationsList();
              },
              backgroundColor: Colors.white,
              heroTag: 'list',
              child: Icon(Icons.list, color: Colors.blue.shade700),
            ),
          ),

          // Add location button
          Positioned(
            bottom: 16,
            right: 16,
            child:  FloatingActionButton. extended(
              onPressed: () {
                _showAddLocationDialog();
              },
              backgroundColor:  Colors.blue.shade700,
              icon: const Icon(Icons.add_location),
              label: const Text('Add Location'),
              heroTag: 'add',
            ),
          ),
        ],
      ),
    );
  }

  void _goToInitialPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_initialPosition));
  }

  void _showMapTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Map Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Normal'),
              onTap: () {
                setState(() {
                  _currentMapType = MapType.normal;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.satellite),
              title: const Text('Satellite'),
              onTap: () {
                setState(() {
                  _currentMapType = MapType.satellite;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.terrain),
              title: const Text('Terrain'),
              onTap:  () {
                setState(() {
                  _currentMapType = MapType.terrain;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Locations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Active Locations'),
              value: true,
              onChanged: (value) {},
              activeColor: Colors.blue.shade700,
            ),
            CheckboxListTile(
              title:  const Text('Pending Review'),
              value: true,
              onChanged: (value) {},
              activeColor: Colors.blue.shade700,
            ),
            CheckboxListTile(
              title: const Text('Inactive'),
              value: false,
              onChanged: (value) {},
              activeColor: Colors.blue. shade700,
            ),
            const Divider(),
            const Text(
              'Location Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight. bold,
              ),
            ),
            CheckboxListTile(
              title: const Text('Café'),
              value: true,
              onChanged: (value) {},
              activeColor: Colors.blue.shade700,
            ),
            CheckboxListTile(
              title: const Text('Restaurant'),
              value: true,
              onChanged: (value) {},
              activeColor: Colors. blue.shade700,
            ),
            CheckboxListTile(
              title: const Text('Retail'),
              value: true,
              onChanged: (value) {},
              activeColor: Colors. blue.shade700,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filters applied'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showLocationsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize:  0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color:  Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Locations',
                          style:  TextStyle(
                            fontSize:  20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_locations.length} total',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors. blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _locations.length,
                  itemBuilder: (context, index) {
                    return _buildLocationItem(_locations[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationItem(Map<String, dynamic> location) {
    final statusColor = location['status'] == 'Active' 
      ? Colors.green 
      : Colors.orange;

    IconData typeIcon;
    Color typeColor;
    
    switch (location['type']) {
      case 'Café':
        typeIcon = Icons.local_cafe;
        typeColor = Colors.brown;
        break;
      case 'Restaurant':
        typeIcon = Icons.restaurant;
        typeColor = Colors.red;
        break;
      case 'Retail':
        typeIcon = Icons.shopping_bag;
        typeColor = Colors.purple;
        break;
      case 'Gallery':
        typeIcon = Icons. palette;
        typeColor = Colors. pink;
        break;
      default:
        typeIcon = Icons. business;
        typeColor = Colors. blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            Navigator.pop(context);
            final GoogleMapController controller = await _controller.future;
            controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(location['lat'], location['lng']),
                  zoom:  15,
                ),
              ),
            );
          },
          child:  Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:  typeColor. withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    typeIcon,
                    color: typeColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              location['name'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor. withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              location['status'],
                              style: TextStyle(
                                fontSize: 11,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors. grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location['address'],
                              style:  TextStyle(
                                fontSize:  12,
                                color: Colors. grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius:  BorderRadius.circular(4),
                        ),
                        child: Text(
                          location['type'],
                          style:  TextStyle(
                            fontSize:  11,
                            color: typeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLocationDetail(Map<String, dynamic> location) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors. white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.blue.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width:  12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location['type'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors. grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.place, 'Address', location['address']),
            _buildDetailRow(Icons.info, 'Status', location['status']),
            _buildDetailRow(
              Icons.location_on,
              'Coordinates',
              '${location['lat']}, ${location['lng']}',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton. icon(
                    onPressed:  () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      side: BorderSide(color: Colors.blue.shade700),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width:  12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmDialog(location);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:  const TextStyle(
                fontSize:  14,
                fontWeight:  FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:  const Text('Delete Location'),
        content: Text('Are you sure you want to delete "${location['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _markers.removeWhere((m) => m.markerId. value == location['id']);
                _locations.removeWhere((l) => l['id'] == location['id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Location'),
        content: SingleChildScrollView(
          child:  Column(
            mainAxisSize:  MainAxisSize.min,
            children: const [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Location Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration:  InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon:  Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons. phone),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Type (Café, Restaurant, etc.)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location added successfully'),
                  backgroundColor: Colors. green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue. shade700,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController. dispose();
    super.dispose();
  }
}