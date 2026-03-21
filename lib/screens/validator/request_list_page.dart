import 'package:flutter/material.dart';
import 'package:localizy/api/validator_api.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/validator/request_list/assignment_card.dart';
import 'package:localizy/screens/validator/request_list/detail_sheet.dart';

class RequestListPage extends StatefulWidget {
  const RequestListPage({super.key});

  @override
  State<RequestListPage> createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  String _selectedFilter = 'All';
  List<ValidationAssignment> _assignments = [];
  bool _isLoading = true;
  String? _error;

  static const _filters = ['All', 'Assigned', 'Scheduled', 'Verified', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ValidatorApi.getMyAssignments();
      setState(() {
        _assignments = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ValidationAssignment> get _filtered {
    if (_selectedFilter == 'All') return _assignments;
    return _assignments.where((a) => a.status == _selectedFilter).toList();
  }

  String _filterLabel(String filter, AppLocalizations l10n) => switch (filter) {
        'All' => l10n.validatorFilterAll,
        'Assigned' => l10n.validatorStatusAssigned,
        'Scheduled' => l10n.validatorScheduledStat,
        'Verified' => l10n.validatorVerifiedStat,
        'Rejected' => l10n.validatorRejectedStat,
        _ => filter,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          l10n.validatorRequestList,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAssignments,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 56,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: _filters
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(f, _filterLabel(f, l10n)),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError(l10n)
                    : _filtered.isEmpty
                        ? _buildEmpty(l10n)
                        : RefreshIndicator(
                            onRefresh: _loadAssignments,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => AssignmentCard(
                                assignment: _filtered[i],
                                onTap: () => _showDetail(_filtered[i]),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDetail(ValidationAssignment assignment) async {
    final shouldReload = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DetailSheet(assignment: assignment),
    );
    if (shouldReload == true && mounted) {
      _loadAssignments();
    }
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = value),
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.green.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.green.shade700 : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Colors.green.shade700,
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(l10n.validatorFailedToLoadAssignments,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _loadAssignments,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(l10n.validatorNoAssignmentsFound,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
