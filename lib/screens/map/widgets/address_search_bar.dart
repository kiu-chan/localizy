import 'package:flutter/material.dart';

class AddressSearchBar extends StatefulWidget {
  final Function(AddressResult) onAddressSelected;

  const AddressSearchBar({
    super.key,
    required this. onAddressSelected,
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

  // Mock data - Địa chỉ đã được đánh dấu (Việt Nam và Pháp)
  final List<AddressResult> _savedAddresses = [
    // Địa chỉ Việt Nam
    AddressResult(
      id: '1',
      code: 'VN-001',
      address: '123 Nguyễn Huệ, Quận 1, TP. HCM',
      district: 'Quận 1',
      city: 'TP.  Hồ Chí Minh',
      country: 'Việt Nam',
      lat: 10.7769,
      lng: 106.7009,
      verified: true,
    ),
    AddressResult(
      id: '2',
      code: 'VN-002',
      address: '456 Lê Lợi, Quận 1, TP. HCM',
      district:  'Quận 1',
      city: 'TP. Hồ Chí Minh',
      country:  'Việt Nam',
      lat: 10.7740,
      lng: 106.6990,
      verified: true,
    ),
    AddressResult(
      id: '3',
      code: 'VN-003',
      address: '789 Trần Hưng Đạo, Quận 5, TP. HCM',
      district:  'Quận 5',
      city: 'TP. Hồ Chí Minh',
      country:  'Việt Nam',
      lat: 10.7550,
      lng: 106.6770,
      verified: false,
    ),
    AddressResult(
      id: '4',
      code: 'VN-004',
      address:  '234 Võ Văn Tần, Quận 3, TP.HCM',
      district: 'Quận 3',
      city:  'TP. Hồ Chí Minh',
      country: 'Việt Nam',
      lat: 10.7830,
      lng: 106.6920,
      verified: true,
    ),
    AddressResult(
      id: '5',
      code: 'VN-005',
      address: '567 Hai Bà Trưng, Quận 3, TP.HCM',
      district: 'Quận 3',
      city:  'TP. Hồ Chí Minh',
      country: 'Việt Nam',
      lat: 10.7880,
      lng: 106.6950,
      verified: true,
    ),
    
    // Địa chỉ Pháp
    AddressResult(
      id: '6',
      code: 'FR-001',
      address:  'Tour Eiffel, Champ de Mars, 5 Avenue Anatole',
      district: '7e arrondissement',
      city:  'Paris',
      country:  'France',
      lat:  48.8584,
      lng: 2.2945,
      verified: true,
    ),
    AddressResult(
      id: '7',
      code: 'FR-002',
      address: 'Musée du Louvre, Rue de Rivoli',
      district: '1er arrondissement',
      city:  'Paris',
      country:  'France',
      lat:  48.8606,
      lng: 2.3376,
      verified: true,
    ),
    AddressResult(
      id: '8',
      code: 'FR-003',
      address: 'Arc de Triomphe, Place Charles de Gaulle',
      district: '8e arrondissement',
      city: 'Paris',
      country: 'France',
      lat: 48.8738,
      lng: 2.2950,
      verified: true,
    ),
    AddressResult(
      id: '9',
      code: 'FR-004',
      address: 'Cathédrale Notre-Dame, Parvis Notre-Dame',
      district: '4e arrondissement',
      city: 'Paris',
      country: 'France',
      lat: 48.8530,
      lng: 2.3499,
      verified: false,
    ),
    AddressResult(
      id: '10',
      code: 'FR-005',
      address: 'Basilique du Sacré-Cœur, 35 Rue du Chevalier de la Barre',
      district:  '18e arrondissement',
      city: 'Paris',
      country: 'France',
      lat: 48.8867,
      lng: 2.3431,
      verified: true,
    ),
    AddressResult(
      id: '11',
      code: 'FR-006',
      address: 'Château de Versailles, Place d\'Armes',
      district: 'Versailles',
      city: 'Île-de-France',
      country: 'France',
      lat: 48.8049,
      lng: 2.1204,
      verified: true,
    ),
    AddressResult(
      id: '12',
      code: 'FR-007',
      address: 'La Promenade des Anglais',
      district: 'Centre',
      city: 'Nice',
      country: 'France',
      lat: 43.6951,
      lng: 7.2654,
      verified: true,
    ),
    AddressResult(
      id: '13',
      code: 'FR-008',
      address: 'Vieux-Port de Marseille, Quai des Belges',
      district: '1er arrondissement',
      city:  'Marseille',
      country: 'France',
      lat: 43.2955,
      lng: 5.3745,
      verified: true,
    ),
    AddressResult(
      id: '14',
      code: 'FR-009',
      address: 'Place Bellecour',
      district: '2e arrondissement',
      city: 'Lyon',
      country: 'France',
      lat: 45.7578,
      lng: 4.8320,
      verified: true,
    ),
    AddressResult(
      id: '15',
      code: 'FR-010',
      address: 'Place de la Bourse, Miroir d\'Eau',
      district:  'Centre',
      city: 'Bordeaux',
      country: 'France',
      lat: 44.8412,
      lng: -0.5698,
      verified: false,
    ),
    AddressResult(
      id: '16',
      code: 'FR-011',
      address: 'Palais des Papes, Place du Palais',
      district: 'Centre',
      city: 'Avignon',
      country: 'France',
      lat: 43.9509,
      lng: 4.8075,
      verified: true,
    ),
    AddressResult(
      id: '17',
      code: 'FR-012',
      address: 'Mont Saint-Michel',
      district: 'Le Mont-Saint-Michel',
      city: 'Normandie',
      country: 'France',
      lat: 48.6361,
      lng: -1.5115,
      verified: true,
    ),
    AddressResult(
      id: '18',
      code: 'FR-013',
      address: 'Musée d\'Orsay, 1 Rue de la Légion d\'Honneur',
      district: '7e arrondissement',
      city: 'Paris',
      country: 'France',
      lat: 48.8600,
      lng: 2.3266,
      verified: true,
    ),
    AddressResult(
      id: '19',
      code: 'FR-014',
      address: 'Champs-Élysées',
      district: '8e arrondissement',
      city: 'Paris',
      country: 'France',
      lat: 48.8698,
      lng: 2.3078,
      verified: true,
    ),
    AddressResult(
      id: '20',
      code: 'FR-015',
      address: 'Palais Longchamp, Boulevard Jardin Zoologique',
      district: '4e arrondissement',
      city: 'Marseille',
      country: 'France',
      lat: 43.3050,
      lng: 5.3950,
      verified: false,
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
    _searchController. dispose();
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
    await Future.delayed(const Duration(milliseconds: 300));

    // Tìm kiếm theo mã địa chỉ, địa chỉ, quận, thành phố, hoặc quốc gia
    final searchLower = query.toLowerCase();
    final results = _savedAddresses.where((address) {
      return address.code.toLowerCase().contains(searchLower) ||
          address. address.toLowerCase().contains(searchLower) ||
          address.district.toLowerCase().contains(searchLower) ||
          address.city. toLowerCase().contains(searchLower) ||
          address.country.toLowerCase().contains(searchLower);
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
      top: 50,
      left: 16,
      right: 16,
      child: Column(
        children: [
          // Search bar
          Material(
            elevation: 4,
            borderRadius: BorderRadius. circular(12),
            child:  Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _performSearch,
                decoration: InputDecoration(
                  hintText: 'Search by address code, address',
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
              decoration:  BoxDecoration(
                color:  Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius:  10,
                    offset: const Offset(0, 4),
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
                  :  _searchResults.isEmpty
                      ?  Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size:  48,
                                color: Colors. grey.shade400,
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
                              leading:  Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: address.verified
                                      ? Colors.green.shade50
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: address.verified
                                      ? Colors.green. shade700
                                      : Colors.grey.shade600,
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
                                        fontWeight:  FontWeight.bold,
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    address.address,
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${address.city}, ${address. country}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
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
    required this. country,
    required this.lat,
    required this.lng,
    required this.verified,
  });
}