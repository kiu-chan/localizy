import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressSearchPage extends StatefulWidget {
  const AddressSearchPage({super.key});

  @override
  State<AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends State<AddressSearchPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedAddress;
  GoogleMapController? _mapController;
  
  // Mock data - thay thế bằng API thực tế
  final List<Map<String, dynamic>> _mockAddresses = [
    {
      'id': '1',
      'address': '123 Nguyễn Huệ, Quận 1, TP. HCM',
      'district': 'Quận 1',
      'city': 'TP.  Hồ Chí Minh',
      'lat': 10.7769,
      'lng': 106.7009,
      'verified': true,
      'parkingAvailable': true,
      'parkingSpots': 15,
    },
    {
      'id': '2',
      'address': '456 Lê Lợi, Quận 1, TP.HCM',
      'district': 'Quận 1',
      'city': 'TP.  Hồ Chí Minh',
      'lat': 10.7740,
      'lng': 106.6990,
      'verified': true,
      'parkingAvailable':  true,
      'parkingSpots': 8,
    },
    {
      'id': '3',
      'address': '789 Trần Hưng Đạo, Quận 5, TP.HCM',
      'district': 'Quận 5',
      'city': 'TP.  Hồ Chí Minh',
      'lat': 10.7550,
      'lng': 106.6770,
      'verified': false,
      'parkingAvailable': false,
      'parkingSpots': 0,
    },
    {
      'id': '4',
      'address': '234 Võ Văn Tần, Quận 3, TP.HCM',
      'district': 'Quận 3',
      'city':  'TP. Hồ Chí Minh',
      'lat': 10.7830,
      'lng': 106.6920,
      'verified': true,
      'parkingAvailable': true,
      'parkingSpots': 20,
    },
    {
      'id': '5',
      'address': '567 Hai Bà Trưng, Quận 3, TP.HCM',
      'district': 'Quận 3',
      'city': 'TP.  Hồ Chí Minh',
      'lat': 10.7880,
      'lng': 106.6950,
      'verified': true,
      'parkingAvailable': false,
      'parkingSpots': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _selectedAddress = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter mock data
    final results = _mockAddresses.where((address) {
      final searchLower = query.toLowerCase();
      return address['address']. toString().toLowerCase().contains(searchLower) ||
             address['district'].toString().toLowerCase().contains(searchLower) ||
             address['city']. toString().toLowerCase().contains(searchLower);
    }).toList();

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _selectAddress(Map<String, dynamic> address) {
    setState(() {
      _selectedAddress = address;
    });

    // Animate camera to selected location
    if (_mapController != null) {
      _mapController! .animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(address['lat'], address['lng']),
            zoom: 17,
          ),
        ),
      );
    }

    // Hide keyboard
    FocusScope. of(context).unfocus();
  }

  void _copyAddress(String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Đã sao chép địa chỉ'),
          ],
        ),
        backgroundColor:  Colors.green. shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openInMap(Map<String, dynamic> address) {
    // TODO: Open in Google Maps or navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mở bản đồ.. .')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey. shade50,
      appBar:  AppBar(
        title: const Text(
          'Tìm kiếm địa chỉ',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search input
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Nhập địa chỉ, quận, thành phố...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: _searchFocusNode.hasFocus
                          ? Colors.purple.shade700
                          : Colors.grey,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isSearching)
                                Padding(
                                  padding:  const EdgeInsets.only(right: 8),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:  CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.purple.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _performSearch('');
                                },
                              ),
                            ],
                          )
                        : null,
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
                        color: Colors.purple. shade700,
                        width:  2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: _performSearch,
                  textInputAction: TextInputAction.search,
                ),
                
                // Quick filters
                if (_searchResults.isEmpty && _searchController.text.isEmpty) ...[
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickFilter('Quận 1', Icons.location_city),
                        _buildQuickFilter('Quận 3', Icons.location_city),
                        _buildQuickFilter('Quận 5', Icons.location_city),
                        _buildQuickFilter('Đã xác minh', Icons.verified),
                        _buildQuickFilter('Có bãi đỗ', Icons.local_parking),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: _selectedAddress != null
                ? _buildDetailView()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilter(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          if (selected) {
            _searchController.text = label;
            _performSearch(label);
          }
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.purple.shade100,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                size: 64,
                color: Colors.purple.shade300,
              ),
            ),
            const SizedBox(height:  24),
            const Text(
              'Tìm kiếm địa chỉ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhập địa chỉ để bắt đầu tìm kiếm',
              style:  TextStyle(
                fontSize: 14,
                color: Colors. grey. shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade700),
            ),
            const SizedBox(height: 16),
            const Text('Đang tìm kiếm... '),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child:  Column(
          mainAxisAlignment:  MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey. shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy kết quả',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height:  8),
            Text(
              'Thử tìm kiếm với từ khóa khác',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey. shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final address = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAddressCard(address),
        );
      },
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    final isVerified = address['verified'] as bool;
    final hasParkingAvailable = address['parkingAvailable'] as bool;
    
    return Card(
      elevation:  2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _selectAddress(address),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:  CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.purple.shade700,
                      size: 24,
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
                                address['address'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical:  4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors. green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      size: 14,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Xác minh',
                                      style:  TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_city,
                              size: 16,
                              color: Colors. grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${address['district']} • ${address['city']}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors. grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        if (hasParkingAvailable) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_parking,
                                  size: 14,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${address['parkingSpots']} chỗ đỗ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors. blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailView() {
    final address = _selectedAddress!;
    final isVerified = address['verified'] as bool;
    final hasParkingAvailable = address['parkingAvailable'] as bool;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Map preview
          SizedBox(
            height: 250,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(address['lat'], address['lng']),
                zoom: 17,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: {
                Marker(
                  markerId: MarkerId(address['id']),
                  position: LatLng(address['lat'], address['lng']),
                  infoWindow: InfoWindow(title: address['address']),
                ),
              },
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
            ),
          ),
          
          // Address details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color:  Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                TextButton. icon(
                  onPressed:  () {
                    setState(() {
                      _selectedAddress = null;
                    });
                  },
                  icon:  const Icon(Icons.arrow_back, size: 20),
                  label: const Text('Quay lại kết quả'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.purple.shade700,
                    padding: EdgeInsets.zero,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Address title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.purple.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address['address'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight. bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (isVerified) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors. green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified,
                                        size: 16,
                                        color: Colors.green.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Đã xác minh',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight:  FontWeight.w600,
                                          color: Colors.green. shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              if (hasParkingAvailable)
                                Container(
                                  padding: const EdgeInsets. symmetric(
                                    horizontal:  10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.local_parking,
                                        size: 16,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Có bãi đỗ',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height:  24),
                
                // Details grid
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        Icons.location_city,
                        'Quận/Huyện',
                        address['district'],
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        Icons.business,
                        'Thành phố',
                        address['city'],
                      ),
                      const Divider(height:  20),
                      _buildDetailRow(
                        Icons. map,
                        'Tọa độ',
                        '${address['lat']. toStringAsFixed(6)}, ${address['lng'].toStringAsFixed(6)}',
                      ),
                      if (hasParkingAvailable) ...[
                        const Divider(height: 20),
                        _buildDetailRow(
                          Icons.local_parking,
                          'Số chỗ đỗ',
                          '${address['parkingSpots']} chỗ',
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _copyAddress(address['address']),
                        icon: const Icon(Icons.copy, size: 20),
                        label: const Text('Sao chép'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openInMap(address),
                        icon: const Icon(Icons.directions, size: 20),
                        label: const Text('Chỉ đường'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.purple.shade700,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (hasParkingAvailable) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to parking payment
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chuyển đến trang thanh toán... '),
                          ),
                        );
                      },
                      icon: const Icon(Icons.payment, size: 20),
                      label: const Text('Thanh toán đỗ xe'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets. symmetric(vertical: 14),
                        backgroundColor: Colors.green. shade700,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width:  12),
        Expanded(
          child: Text(
            label,
            style:  TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}