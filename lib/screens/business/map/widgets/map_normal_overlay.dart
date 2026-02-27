import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/api/address_api.dart';
import 'package:localizy/screens/business/map/map_form_snapshot.dart';

class MapNormalOverlay extends StatefulWidget {
  final List<MyAddress> addresses;
  final bool isLoading;
  final String? error;
  final bool showMineOnly;
  final VoidCallback onRefresh;
  final VoidCallback onDismissError;
  final VoidCallback onShowMapType;
  final VoidCallback onToggleMineOnly;
  final VoidCallback onShowList;
  final VoidCallback onAddLocation;
  final ValueChanged<MyAddress>? onSuggestionTap;

  const MapNormalOverlay({
    super.key,
    required this.addresses,
    required this.isLoading,
    this.error,
    this.showMineOnly = false,
    required this.onRefresh,
    required this.onDismissError,
    required this.onShowMapType,
    required this.onToggleMineOnly,
    required this.onShowList,
    required this.onAddLocation,
    this.onSuggestionTap,
  });

  @override
  State<MapNormalOverlay> createState() => _MapNormalOverlayState();
}

class _MapNormalOverlayState extends State<MapNormalOverlay> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  // Kept as ValueNotifier so suggestions update WITHOUT rebuilding the parent
  // widget that contains the TextField — preventing keyboard dismissal.
  final _suggestions = ValueNotifier<List<MyAddress>>([]);
  final _searching = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onTextChanged)
      ..dispose();
    _focusNode.dispose();
    _suggestions.dispose();
    _searching.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      _suggestions.value = [];
      _searching.value = false;
      return;
    }
    _searching.value = true;
    _suggestions.value = widget.addresses.where((a) {
      return a.name.toLowerCase().contains(q) ||
          a.code.toLowerCase().contains(q) ||
          a.fullAddress.toLowerCase().contains(q) ||
          a.cityCode.toLowerCase().contains(q);
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    _suggestions.value = [];
    _searching.value = false;
    _focusNode.unfocus();
  }

  void _selectSuggestion(MyAddress address) {
    _clearSearch();
    widget.onSuggestionTap?.call(address);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final top = MediaQuery.of(context).padding.top;
    // Search bar: top+12 offset, 48 height → bottom edge at top+60
    // Dropdown sits 6px below that → top+66
    const searchH = 48.0;
    const searchTop = 12.0;
    const mapBtnW = 48.0 + 10.0; // width + gap

    return Stack(
      children: [
        // ── Tap-outside dismisser (ALWAYS in tree, never inserted/removed) ──
        Positioned.fill(
          child: ValueListenableBuilder<bool>(
            valueListenable: _searching,
            builder: (_, active, _) => GestureDetector(
              // null onTap when not searching → no-op, doesn't steal focus
              onTap: active ? _clearSearch : null,
              behavior: HitTestBehavior.translucent,
            ),
          ),
        ),

        // ── Loading overlay ────────────────────────────────────────────────
        if (widget.isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x55FFFFFF),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),

        // ── Search bar + map-type button ───────────────────────────────────
        Positioned(
          top: top + searchTop,
          left: 16,
          right: 16,
          height: searchH,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    // onChanged is NOT used here; we listen via controller
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: l10n.mapSearchHint,
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.grey.shade400, size: 20),
                      suffixIcon: ValueListenableBuilder<bool>(
                        valueListenable: _searching,
                        builder: (_, active, _) => active
                            ? GestureDetector(
                                onTap: _clearSearch,
                                child: Icon(Icons.close,
                                    size: 18,
                                    color: Colors.grey.shade400),
                              )
                            : const SizedBox.shrink(),
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.layers_outlined),
                  onPressed: widget.onShowMapType,
                  color: Colors.blue.shade700,
                  iconSize: 22,
                ),
              ),
            ],
          ),
        ),

        // ── Suggestions dropdown (ALWAYS in tree via Offstage) ─────────────
        Positioned(
          top: top + searchTop + searchH + 6,
          left: 16,
          right: 16 + mapBtnW,
          child: ValueListenableBuilder<List<MyAddress>>(
            valueListenable: _suggestions,
            builder: (_, list, _) {
              final visible = _searching.value;
              return Offstage(
                offstage: !visible,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: list.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Icon(Icons.search_off,
                                  size: 18,
                                  color: Colors.grey.shade400),
                              const SizedBox(width: 10),
                              Text(
                                l10n.mapNoSearchResults,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets.symmetric(vertical: 6),
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount:
                              list.length > 6 ? 6 : list.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            indent: 52,
                            color: Colors.grey.shade100,
                          ),
                          itemBuilder: (_, i) {
                            final a = list[i];
                            final color = addressStatusColor(a.status);
                            final name =
                                a.name.isNotEmpty ? a.name : a.code;
                            final sub = a.fullAddress.isNotEmpty
                                ? a.fullAddress
                                : a.cityCode;
                            return InkWell(
                              onTap: () => _selectSuggestion(a),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: color.withValues(
                                            alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(
                                                10),
                                      ),
                                      child: Icon(Icons.location_on,
                                          color: color, size: 16),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(name,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow
                                                  .ellipsis),
                                          Text(sub,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey
                                                      .shade500),
                                              maxLines: 1,
                                              overflow: TextOverflow
                                                  .ellipsis),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.north_west,
                                        size: 14,
                                        color: Colors.grey.shade300),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              );
            },
          ),
        ),

        // ── Location count badge + filter toggle ───────────────────────────
        Positioned(
          top: top + searchTop + searchH + 12,
          left: 16,
          child: ValueListenableBuilder<bool>(
            valueListenable: _searching,
            builder: (_, active, _) => Offstage(
              offstage: active,
              child: Row(
                children: [
                  // Count badge
                  GestureDetector(
                    onTap: widget.onRefresh,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.blue.shade700, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.addresses.length}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Mine only toggle chip
                  GestureDetector(
                    onTap: widget.onToggleMineOnly,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: widget.showMineOnly
                            ? Colors.blue.shade700
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.showMineOnly
                                ? Icons.person
                                : Icons.group,
                            color: widget.showMineOnly
                                ? Colors.white
                                : Colors.grey.shade600,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.showMineOnly
                                ? l10n.mapMineOnly
                                : l10n.mapAllAddresses,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: widget.showMineOnly
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Error banner ───────────────────────────────────────────────────
        if (widget.error != null)
          Positioned(
            top: top + 128,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(widget.error!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.red.shade700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                  GestureDetector(
                    onTap: widget.onDismissError,
                    child: Icon(Icons.close,
                        size: 16, color: Colors.red.shade700),
                  ),
                ],
              ),
            ),
          ),

        // ── FABs ──────────────────────────────────────────────────────────
        Positioned(
          bottom: 88,
          right: 16,
          child: _MapFab(
            onPressed: widget.onShowList,
            heroTag: 'list',
            child: Icon(Icons.format_list_bulleted,
                color: Colors.blue.shade700, size: 22),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: _MapFab(
            onPressed: widget.onAddLocation,
            heroTag: 'add',
            color: Colors.blue.shade700,
            child: const Icon(Icons.add_location_alt,
                color: Colors.white, size: 26),
          ),
        ),
      ],
    );
  }
}

class _MapFab extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String heroTag;
  final Color? color;

  const _MapFab({
    required this.onPressed,
    required this.child,
    required this.heroTag,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(child: child),
        ),
      ),
    );
  }
}
