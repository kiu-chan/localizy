import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localizy/api/address_api.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AddressSearchPage extends StatefulWidget {
  const AddressSearchPage({super.key});

  @override
  State<AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends State<AddressSearchPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  bool _isSearching = false;
  bool _isLoadingAll = false;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allAddresses = [];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
    _searchController.addListener(() => setState(() {}));
    _loadAllAddresses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadAllAddresses() async {
    setState(() => _isLoadingAll = true);
    try {
      final items = await AddressApi.fetchAll();
      setState(() {
        _allAddresses = items.map((a) => _addressItemToMap(a)).toList();
        _isLoadingAll = false;
      });
    } catch (e) {
      setState(() => _isLoadingAll = false);
    }
  }

  Map<String, dynamic> _addressItemToMap(dynamic a) {
    return {
      'id': a.id,
      'code': a.code,
      'name': a.name,
      'address': a.fullAddress,
      'cityName': a.cityName,
      'lat': a.latitude,
      'lng': a.longitude,
      'verified': a.isVerified,
      'parkingAvailable': a.parkingAvailable,
      'parkingSpots': a.parkingSpots,
    };
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final items = await AddressApi.searchItems(query);
      setState(() {
        _searchResults = items.map((a) => _addressItemToMap(a)).toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _openDetail(Map<String, dynamic> address) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressDetailSheet(addressId: address['id'], basicInfo: address),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l10n.addressSearch,
          style: const TextStyle(fontWeight: FontWeight.w600),
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
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: l10n.searchAddressHint,
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
                              padding: const EdgeInsets.only(right: 8),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
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
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple.shade700, width: 2),
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
          ),

          // Results
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final l10n = AppLocalizations.of(context)!;

    if (_searchController.text.isEmpty) {
      if (_isLoadingAll) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade700),
          ),
        );
      }
      if (_allAddresses.isEmpty) {
        return Center(
          child: Text(
            l10n.noAddressesFound,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allAddresses.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAddressCard(_allAddresses[index]),
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
            Text(l10n.searching),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              l10n.mapNoSearchResults,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.searchTryDifferentKeywords,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildAddressCard(_searchResults[index]),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    final isVerified = address['verified'] as bool;
    final hasParkingAvailable = address['parkingAvailable'] as bool;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _openDetail(address),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.location_on, color: Colors.purple.shade700, size: 24),
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
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.verified, size: 16, color: Colors.green.shade600),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_city, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address['cityName'] ?? '',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasParkingAvailable) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.local_parking, size: 14, color: Colors.blue.shade600),
                          const SizedBox(width: 2),
                          Text(
                            '${address['parkingSpots']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressDetailSheet extends StatefulWidget {
  final String addressId;
  final Map<String, dynamic> basicInfo;

  const _AddressDetailSheet({required this.addressId, required this.basicInfo});

  @override
  State<_AddressDetailSheet> createState() => _AddressDetailSheetState();
}

class _AddressDetailSheetState extends State<_AddressDetailSheet> {
  AddressDetail? _detail;
  bool _isLoading = true;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await AddressApi.getDetail(widget.addressId);
      if (mounted) setState(() { _detail = detail; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openInGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = widget.basicInfo['lat'] as double;
    final lng = widget.basicInfo['lng'] as double;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Map
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, lng),
                    zoom: 16,
                  ),
                  onMapCreated: (c) => _mapController = c,
                  markers: {
                    Marker(
                      markerId: MarkerId(widget.addressId),
                      position: LatLng(lat, lng),
                      infoWindow: InfoWindow(title: widget.basicInfo['address']),
                    ),
                  },
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade700),
                      ),
                    )
                  : _buildContent(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ScrollController controller) {
    final l10n = AppLocalizations.of(context)!;
    final d = _detail;
    final basic = widget.basicInfo;

    final fullAddress = d?.fullAddress ?? basic['address'] ?? '';
    final name = d?.name ?? basic['name'] ?? '';
    final cityName = d?.cityName ?? basic['cityName'] ?? '';
    final code = d?.code ?? basic['code'] ?? '';
    final isVerified = d?.isVerified ?? basic['verified'] ?? false;
    final parkingAvailable = d?.parkingAvailable ?? basic['parkingAvailable'] ?? false;
    final totalSpots = d?.totalParkingSpots ?? 0;
    final availableSpots = d?.availableSpots ?? basic['parkingSpots'] ?? 0;
    final pricePerHour = d?.pricePerHour ?? 0;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // Name & badges
        if (name.isNotEmpty)
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        if (name.isNotEmpty) const SizedBox(height: 4),
        Text(
          fullAddress,
          style: TextStyle(
            fontSize: name.isEmpty ? 18 : 14,
            fontWeight: name.isEmpty ? FontWeight.bold : FontWeight.normal,
            color: name.isEmpty ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 10),

        // Badges
        Wrap(
          spacing: 8,
          children: [
            if (code.isNotEmpty)
              _badge(code, Icons.qr_code, Colors.purple),
            if (isVerified)
              _badge(l10n.verifiedStatus, Icons.verified, Colors.green),
            if (parkingAvailable)
              _badge(l10n.parkingAvailableBadge, Icons.local_parking, Colors.blue),
          ],
        ),

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),

        // Info rows
        _infoRow(Icons.location_city, l10n.cityLabel, cityName),
        if (d?.userName != null && d!.userName.isNotEmpty) ...[
          const SizedBox(height: 12),
          _infoRow(Icons.person, l10n.mapAddedBy, d.userName),
        ],
        if (d?.validatorName != null && d!.validatorName!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _infoRow(Icons.how_to_reg, l10n.verifiedBy, d.validatorName!),
        ],
        const SizedBox(height: 12),
        _infoRow(
          Icons.map,
          l10n.coordinates,
          '${widget.basicInfo['lat'].toStringAsFixed(6)}, ${widget.basicInfo['lng'].toStringAsFixed(6)}',
        ),
        if (d?.formattedCreatedAt != null) ...[
          const SizedBox(height: 12),
          _infoRow(Icons.calendar_today, l10n.createdAt, d!.formattedCreatedAt!),
        ],

        // Parking info
        if (parkingAvailable) ...[
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _infoRow(Icons.local_parking, l10n.totalParkingSpots, '$totalSpots'),
          const SizedBox(height: 12),
          _infoRow(Icons.check_circle_outline, l10n.availableParkingSpots, '$availableSpots'),
          if (pricePerHour > 0) ...[
            const SizedBox(height: 12),
            _infoRow(Icons.payments_outlined, l10n.pricePerHour, d?.formattedPricePerHour ?? ''),
          ],
        ],

        if (d?.comments != null && d!.comments!.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _infoRow(Icons.comment_outlined, l10n.notes, d.comments!),
        ],

        const SizedBox(height: 24),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openInGoogleMaps(
                  widget.basicInfo['lat'] as double,
                  widget.basicInfo['lng'] as double,
                ),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: Text(l10n.viewOnMaps),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (parkingAvailable) ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.navigatingToPayment)),
                    );
                  },
                  icon: const Icon(Icons.payment, size: 18),
                  label: Text(l10n.bookParking),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.green.shade700,
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
      ],
    );
  }

  Widget _badge(String label, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
