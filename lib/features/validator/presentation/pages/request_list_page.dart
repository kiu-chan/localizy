import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/l10n/app_localizations.dart';

import '../../../../core/widgets/skeleton_loader.dart';
import '../../domain/validation_assignment.dart';
import '../providers/validator_providers.dart';
import '../widgets/assignment_card.dart';
import '../widgets/assignment_card_skeleton.dart';
import '../widgets/assignment_detail_sheet.dart';

class RequestListPage extends ConsumerStatefulWidget {
  const RequestListPage({super.key});

  @override
  ConsumerState<RequestListPage> createState() => _RequestListPageState();
}

class _RequestListPageState extends ConsumerState<RequestListPage> {
  String _selectedFilter = 'All';

  static const _filters = [
    'All',
    'Assigned',
    'Scheduled',
    'Verified',
    'Rejected'
  ];

  List<ValidationAssignment> _filtered(List<ValidationAssignment> all) {
    if (_selectedFilter == 'All') return all;
    return all.where((a) => a.status == _selectedFilter).toList();
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
    final assignmentsAsync = ref.watch(myAssignmentsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          l10n.validatorRequestList,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.invalidate(myAssignmentsProvider),
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
            child: assignmentsAsync.when(
              loading: () => ShimmerLoader(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 6,
                  itemBuilder: (_, _) => const AssignmentCardSkeleton(),
                ),
              ),
              error: (_, _) => _buildError(l10n),
              data: (assignments) {
                final filtered = _filtered(assignments);
                if (filtered.isEmpty) return _buildEmpty(l10n);
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(myAssignmentsProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => AssignmentCard(
                      assignment: filtered[i],
                      onTap: () => _showDetail(filtered[i]),
                    ),
                  ),
                );
              },
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
      builder: (_) => AssignmentDetailSheet(assignment: assignment),
    );
    if (shouldReload == true && mounted) {
      ref.invalidate(myAssignmentsProvider);
      // Trạng thái mới cũng ảnh hưởng thống kê trên Dashboard.
      ref.invalidate(validatorDashboardProvider);
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
            onPressed: () => ref.invalidate(myAssignmentsProvider),
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
