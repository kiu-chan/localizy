import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/l10n/app_localizations.dart';

import '../../domain/history_entry.dart';
import '../../domain/validation_entry.dart';
import '../providers/history_providers.dart';
import '../widgets/history_card.dart';
import '../widgets/history_detail_sheet.dart';
import '../widgets/history_list_view.dart';
import '../widgets/validation_card.dart';
import '../widgets/validation_detail_sheet.dart';

class TransactionHistoryPage extends ConsumerStatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  ConsumerState<TransactionHistoryPage> createState() =>
      _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends ConsumerState<TransactionHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Dữ liệu cache từ lần mở trước có thể đã cũ (ví dụ user vừa thanh toán
    // xong) — invalidate để mỗi lần mở trang đều tải mới.
    ref.invalidate(allHistoryProvider);
    ref.invalidate(parkingHistoryProvider);
    ref.invalidate(validationHistoryProvider);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionHistory),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Parking'),
            Tab(text: 'Verification'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AllHistoryTab(),
          _ParkingHistoryTab(),
          _ValidationHistoryTab(),
        ],
      ),
    );
  }
}

class _AllHistoryTab extends ConsumerWidget {
  const _AllHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HistoryListView<HistoryEntry>(
      value: ref.watch(allHistoryProvider),
      onRefresh: () => ref.refresh(allHistoryProvider.future),
      onRetry: () => ref.invalidate(allHistoryProvider),
      emptyIcon: Icons.receipt_long,
      emptyTitle: 'No Transactions',
      emptySubtitle: 'Your transaction history will appear here',
      itemBuilder: (context, entry) => HistoryCard(
        entry: entry,
        onTap: () => showHistoryDetailSheet(context, entry),
      ),
    );
  }
}

class _ParkingHistoryTab extends ConsumerWidget {
  const _ParkingHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HistoryListView<HistoryEntry>(
      value: ref.watch(parkingHistoryProvider),
      onRefresh: () => ref.refresh(parkingHistoryProvider.future),
      onRetry: () => ref.invalidate(parkingHistoryProvider),
      emptyIcon: Icons.local_parking,
      emptyTitle: 'No Parking Transactions',
      emptySubtitle: 'Your parking history will appear here',
      itemBuilder: (context, entry) => HistoryCard(
        entry: entry,
        showDuration: true,
        onTap: () => showHistoryDetailSheet(context, entry, parkingStyle: true),
      ),
    );
  }
}

class _ValidationHistoryTab extends ConsumerWidget {
  const _ValidationHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HistoryListView<ValidationEntry>(
      value: ref.watch(validationHistoryProvider),
      onRefresh: () => ref.refresh(validationHistoryProvider.future),
      onRetry: () => ref.invalidate(validationHistoryProvider),
      emptyIcon: Icons.verified_outlined,
      emptyTitle: 'No Verification Requests',
      emptySubtitle: 'Your verification history will appear here',
      itemBuilder: (context, entry) => ValidationCard(
        entry: entry,
        onTap: () => showValidationDetailSheet(context, entry),
      ),
    );
  }
}
