import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  List<AddressResult> _searchResults = [];
  bool _isSearching = false;
  bool _showResults = false;

  // Mock data - Địa chỉ đã được đánh dấu
  final List<AddressResult> _savedAddresses = [
    AddressResult(
      id: '1',
      code: 'ADDR-001',
      address:  '123 Nguyễn Huệ, Quận 1, TP. HCM',
      district:  'Quận 1',
      city: 'TP.  Hồ Chí Minh',
      lat: 10.7769,
      lng: 106.7009,
      verified: true,
    ),
    AddressResult(
      id: '2',
      code: 'ADDR-002',
      address: '456 Lê Lợi, Quận 1, TP.HCM',
      district: 'Quận 1',
      city:  'TP. Hồ Chí Minh',
      lat: 10.7740,
      lng: 106.6990,
      verified: true,
    ),
    AddressResult(
      id: '3',
      code: 'ADDR-003',
      address: '789 Trần Hưng Đạo, Quận 5, TP.HCM',
      district: 'Quận 5',
      city:  'TP. Hồ Chí Minh',
      lat: 10.7550,
      lng: 106.6770,
      verified: false,
    ),
    AddressResult(
      id:  '4',
      code: 'ADDR-004',
      address: '234 Võ Văn Tần, Quận 3, TP.HCM',
      district: 'Quận 3',
      city:  'TP. Hồ Chí Minh',
      lat: 10.7830,
      lng: 106.6920,
      verified: true,
    ),
    AddressResult(
      id: '5',
      code: 'ADDR-005',
      address: '567 Hai Bà Trưng, Quận 3, TP.HCM',
      district: 'Quận 3',
      city:  'TP. Hồ Chí Minh',
      lat: 10.7880,
      lng: 106.6950,
      verified: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
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

    // Simulate API call
    await Future. delayed(const Duration(milliseconds:  300));

    // Tìm kiếm theo mã địa chỉ hoặc địa chỉ
    final searchLower = query.toLowerCase();
    final results = _savedAddresses. where((address) {
      return address.code.toLowerCase().contains(searchLower) ||
          address.address.toLowerCase().contains(searchLower) ||
          address.district.toLowerCase().contains(searchLower) ||
          address.city.toLowerCase().contains(searchLower);
    }).toList();

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _selectAddress(AddressResult address) {
    widget.onAddressSelected(address);
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 30,
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
                  hintText: 'Tìm kiếm theo mã địa chỉ hoặc địa chỉ',
                  hintStyle: TextStyle(
                    color: Colors.grey. shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.green.shade700,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ?  IconButton(
                          icon:  const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController. clear();
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
                boxShadow:  [
                  BoxShadow(
                    color: Colors. black.withOpacity(0.1),
                    blurRadius:  10,
                    offset:  const Offset(0, 4),
                  ),
                ],
              ),
              child: _isSearching
                  ? const Center(
                      child:  Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _searchResults. isEmpty
                      ?  Padding(
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
                                'Không tìm thấy địa chỉ',
                                style: TextStyle(
                                  color: Colors. grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets. symmetric(vertical: 8),
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) => Divider(
                            height:  1,
                            color:  Colors.grey.shade200,
                          ),
                          itemBuilder: (context, index) {
                            final address = _searchResults[index];
                            return ListTile(
                              onTap: () => _selectAddress(address),
                              leading:  Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:  address.verified
                                      ? Colors.green. shade50
                                      : Colors.grey.shade100,
                                  borderRadius:  BorderRadius.circular(8),
                                ),
                                child:  Icon(
                                  Icons.location_on,
                                  color: address.verified
                                      ? Colors.green.shade700
                                      : Colors.grey. shade600,
                                  size: 20,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      address.code,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                  if (address.verified) ...[
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.verified,
                                      size: 14,
                                      color: Colors.green.shade700,
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Text(
                                address.address,
                                style: const TextStyle(fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
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
  final double lat;
  final double lng;
  final bool verified;

  AddressResult({
    required this. id,
    required this.code,
    required this.address,
    required this.district,
    required this.city,
    required this.lat,
    required this.lng,
    required this.verified,
  });
}