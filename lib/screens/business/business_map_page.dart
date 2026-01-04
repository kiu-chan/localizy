import 'package:flutter/material.dart';

class BusinessMapPage extends StatefulWidget {
  const BusinessMapPage({super.key});

  @override
  State<BusinessMapPage> createState() => _BusinessMapPageState();
}

class _BusinessMapPageState extends State<BusinessMapPage> {
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
        actions:  [
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
          // Map Placeholder
          Container(
            color: Colors.grey.shade300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 100,
                    color: Colors. grey.shade500,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Map View',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your business locations will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating location list button
          Positioned(
            bottom: 80,
            right: 16,
            child:  FloatingActionButton(
              onPressed: () {
                _showLocationsList();
              },
              backgroundColor:  Colors.blue.shade700,
              child: const Icon(Icons. list),
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
              icon: const Icon(Icons. add_location),
              label: const Text('Add Location'),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context:  context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Locations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Active Locations'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title:  const Text('Pending Review'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Inactive'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
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
      context:  context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
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
                      borderRadius: BorderRadius. circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Locations',
                    style:  TextStyle(
                      fontSize:  20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return _buildLocationItem(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem(int index) {
    final locations = [
      {
        'name': 'Coffee Shop - District 1',
        'address':  '123 Main Street, District 1',
        'status':  'Active',
      },
      {
        'name': 'Restaurant - District 3',
        'address': '456 Food Street, District 3',
        'status': 'Active',
      },
      {
        'name': 'Retail Store - District 5',
        'address': '789 Shopping Ave, District 5',
        'status': 'Pending',
      },
    ];

    if (index >= locations.length) return const SizedBox();

    final location = locations[index];
    final statusColor = location['status'] == 'Active' ? Colors.green :  Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors. white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child:  Icon(
              Icons.location_on,
              color: Colors.blue.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:  Column(
              crossAxisAlignment:  CrossAxisAlignment.start,
              children: [
                Text(
                  location['name']!,
                  style: const TextStyle(
                    fontSize:  14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location['address']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor. withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:  Text(
              location['status']!,
              style: TextStyle(
                fontSize: 11,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
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
        content: const SingleChildScrollView(
          child:  Column(
            mainAxisSize:  MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Location Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons. business),
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
              backgroundColor: Colors.blue.shade700,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}