import 'package:flutter/material.dart';
import 'package:localizy/api/address_api.dart';

class AddressSearchBar extends StatefulWidget {
  final Function(AddressResult) onAddressSelected;

  const AddressSearchBar({
    super.key,
    required this.onAddressSelected,
  });

  @override
  State<AddressSearchBar> createState() => _AddressSearchBarState();
}

class _AddressSearchBarState extends State<AddressSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<AddressCoordinate> _apiAddresses = [];
  List<AddressCoordinate> _searchResults = [];
  bool _isSearching = false;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _fetchApiAddresses();
    _searchFocusNode.addListener(() {
      setState(() {
        _showResults = _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchApiAddresses() async {
    try {
      final coords = await AddressApi.fetchCoordinates();
      setState(() {
        _apiAddresses = coords;
      });
    } catch (e) {
      debugPrint('Failed to fetch addresses for search: $e');
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showResults = false;
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _showResults = true;
    });

    // Lọc theo id (hoặc mở rộng sang các trường khác nếu muốn)
    final searchLower = query.toLowerCase();
    final results = _apiAddresses.where((a) =>
      a.id.toLowerCase().contains(searchLower) ||
      a.lat.toString().contains(searchLower) ||
      a.lng.toString().contains(searchLower)
    ).toList();

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _selectAddress(AddressCoordinate address) {
    widget.onAddressSelected(
      AddressResult(
        id: address.id,
        code: address.id,
        address: '',
        district: '',
        city: '',
        country: '',
        lat: address.lat,
        lng: address.lng,
        verified: true,
      ),
    );
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Column(
        children: [
          // Search bar
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _performSearch,
                decoration: InputDecoration(
                  hintText: 'Search by address id or coordinate',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.green.shade700,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                              _showResults = false;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          // Search results
          if (_showResults)
            Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isSearching
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _searchResults.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Address not found',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey.shade200,
                          ),
                          itemBuilder: (context, index) {
                            final address = _searchResults[index];
                            return ListTile(
                              onTap: () => _selectAddress(address),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                address.id,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("Lat: ${address.lat}, Lng: ${address.lng}",
                                  style: const TextStyle(fontSize: 13)),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                            );
                          },
                        ),
            ),
        ],
      ),
    );
  }
}

class AddressResult {
  final String id;
  final String code;
  final String address;
  final String district;
  final String city;
  final String country;
  final double lat;
  final double lng;
  final bool verified;

  AddressResult({
    required this.id,
    required this.code,
    required this.address,
    required this.district,
    required this.city,
    required this.country,
    required this.lat,
    required this.lng,
    required this.verified,
  });
}

// AddressCoordinate class được lấy từ lib/api/address_api.dart
// class AddressCoordinate {
//   final String id;
//   final double lat;
//   final double lng;
//   AddressCoordinate({
//     required this.id,
//     required this.lat,
//     required this.lng,
//   });
// }