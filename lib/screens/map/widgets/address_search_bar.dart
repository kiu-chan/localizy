import 'dart:async';
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
  List<AddressSearchResult> _searchResults = [];
  bool _isSearching = false;
  bool _showResults = false;
  String? _errorMessage;
  
  // Debounce timer để tránh gọi API quá nhiều
  Timer? _debounceTimer;

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
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel timer cũ nếu có
    _debounceTimer?.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showResults = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _showResults = true;
      _isSearching = true;
      _errorMessage = null;
    });

    // Debounce 500ms trước khi gọi API
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    try {
      final results = await AddressApi.search(query);
      
      if (!mounted) return;
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _errorMessage = 'Search failed. Please try again.';
      });
      debugPrint('Search error: $e');
    }
  }

  void _selectAddress(AddressSearchResult address) {
    widget.onAddressSelected(
      AddressResult(
        id: address.id,
        name: address.name,
        address: address.address,
        type: address.type,
        lat: address.lat,
        lng: address.lng,
      ),
    );
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _showResults = false;
      _searchResults = [];
    });
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'landmark':
        return Icons.account_balance;
      case 'restaurant':
        return Icons.restaurant;
      case 'hotel':
        return Icons.hotel;
      case 'hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'shop':
        return Icons.shopping_cart;
      case 'park':
        return Icons.park;
      case 'station':
        return Icons.train;
      case 'airport':
        return Icons.flight;
      case 'cafe':
        return Icons.local_cafe;
      case 'bank':
        return Icons.account_balance_wallet;
      case 'atm':
        return Icons.atm;
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'gas_station':
        return Icons.local_gas_station;
      case 'parking':
        return Icons.local_parking;
      case 'gym':
        return Icons.fitness_center;
      case 'cinema':
        return Icons.movie;
      case 'museum':
        return Icons.museum;
      case 'library':
        return Icons.local_library;
      case 'church':
        return Icons.church;
      case 'mosque':
        return Icons.mosque;
      case 'temple':
        return Icons.temple_buddhist;
      default:
        return Icons.location_on;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'landmark':
        return Colors.purple;
      case 'restaurant':
        return Colors.orange;
      case 'hotel':
        return Colors.blue;
      case 'hospital':
        return Colors.red;
      case 'school':
        return Colors.amber;
      case 'shop':
        return Colors.teal;
      case 'park':
        return Colors.green;
      case 'station':
        return Colors.indigo;
      case 'airport':
        return Colors.cyan;
      default:
        return Colors.green.shade700;
    }
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
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search for places, addresses...',
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
                            _debounceTimer?.cancel();
                            setState(() {
                              _searchResults = [];
                              _showResults = false;
                              _errorMessage = null;
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
              constraints: const BoxConstraints(maxHeight: 350),
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
              child: _buildSearchResults(),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    // Loading state
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _performSearch(_searchController.text),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (_searchResults.isEmpty) {
      return Padding(
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
              'No results found',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try different keywords',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    // Results list
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        final typeColor = _getTypeColor(result.type);
        
        return ListTile(
          onTap: () => _selectAddress(result),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getTypeIcon(result.type),
              color: typeColor,
              size: 22,
            ),
          ),
          title: Text(
            result.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                result.address,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  result.type,
                  style: TextStyle(
                    fontSize: 10,
                    color: typeColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey.shade400,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        );
      },
    );
  }
}

/// Model kết quả địa chỉ được chọn
class AddressResult {
  final String id;
  final String name;
  final String address;
  final String type;
  final double lat;
  final double lng;

  AddressResult({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.lat,
    required this.lng,
  });

  // Getters để tương thích với code cũ
  String get code => id;
  bool get verified => true;
}