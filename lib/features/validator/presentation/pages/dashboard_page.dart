import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/features/auth/presentation/providers/auth_provider.dart';
import 'package:localizy/l10n/app_localizations.dart';

import '../../domain/validation_assignment.dart';
import '../providers/validator_providers.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/validation_badges.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dashboardAsync = ref.watch(validatorDashboardProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          l10n.dashboard,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.invalidate(validatorDashboardProvider),
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const DashboardSkeleton(),
        error: (_, _) => _buildError(l10n, ref),
        data: (dashboard) => RefreshIndicator(
          onRefresh: () => ref.refresh(validatorDashboardProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(dashboard, l10n, ref),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsGrid(dashboard.taskStats, l10n),
                      const SizedBox(height: 24),
                      _buildRecentSection(dashboard.recentAssignments, l10n),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(l10n.validatorFailedToLoadDashboard,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(validatorDashboardProvider),
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

  Widget _buildHeader(
      ValidatorDashboard dashboard, AppLocalizations l10n, WidgetRef ref) {
    final stats = dashboard.taskStats;
    final user = ref.watch(authProvider).value;
    final validatorName = (user != null && user.fullName.isNotEmpty)
        ? user.fullName
        : 'Validator';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green.shade700, Colors.green.shade500],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.validatorHello(validatorName),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.validatorPendingAndScheduled(
                stats.assignedCount, stats.scheduledCount),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          if (stats.todayAppointments > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.today, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    l10n.validatorAppointmentsToday(stats.todayAppointments),
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ValidatorTaskStats s, AppLocalizations l10n) {
    final cards = [
      _StatItem(Icons.assignment_ind, l10n.validatorTotalAssigned,
          s.totalAssigned, Colors.purple),
      _StatItem(Icons.pending_actions, l10n.validatorAwaitingConfirm,
          s.assignedCount, Colors.orange),
      _StatItem(Icons.event_available, l10n.validatorScheduledStat,
          s.scheduledCount, Colors.blue),
      _StatItem(Icons.verified, l10n.validatorVerifiedStat, s.verifiedCount,
          Colors.green),
      _StatItem(Icons.cancel, l10n.validatorRejectedStat, s.rejectedCount,
          Colors.red),
      _StatItem(
          Icons.today, l10n.validatorToday, s.todayAppointments, Colors.teal),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.validatorStatistics,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: cards.map(_buildStatCard).toList(),
        ),
      ],
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            item.value.toString(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            item.label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSection(
      List<ValidationAssignment> recent, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.validatorRecentAssignments,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (recent.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(l10n.validatorNoRecentAssignments,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
            ),
          )
        else
          ...recent.map(_buildAssignmentItem),
      ],
    );
  }

  Widget _buildAssignmentItem(ValidationAssignment a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(Icons.location_on, color: Colors.green.shade700, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.address?.code ?? a.requestId,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  a.assignedDate != null
                      ? formatValidationDate(a.assignedDate!)
                      : a.requestType,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          ValidationStatusBadge(status: a.status),
        ],
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  _StatItem(this.icon, this.label, this.value, this.color);
}
