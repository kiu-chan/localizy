import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/l10n/app_localizations.dart';

import '../../data/business_repository.dart';
import '../../domain/sub_account.dart';
import '../providers/business_providers.dart';
import '../widgets/sub_account_card.dart';
import '../widgets/sub_account_detail_sheet.dart';
import '../widgets/sub_account_form_dialog.dart';

class SubAccountManagementPage extends ConsumerWidget {
  const SubAccountManagementPage({super.key});

  // ─── Actions ───────────────────────────────────────────────────────────────

  /// Danh sách + dashboard (subAccountCount) cùng cần làm mới sau thay đổi.
  void _reload(WidgetRef ref) {
    ref.invalidate(subAccountsProvider);
    ref.invalidate(businessDashboardProvider);
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final created = await showCreateSubAccountDialog(
        context, ref.read(businessRepositoryProvider));
    if (created != null && context.mounted) {
      _reload(ref);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.subAccountCreatedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _openDetail(
      BuildContext context, WidgetRef ref, SubAccount account) async {
    final doEdit = await showSubAccountDetailSheet(context, account);
    if (!doEdit || !context.mounted) return;

    final updated = await showEditSubAccountDialog(
        context, ref.read(businessRepositoryProvider), account);
    if (updated != null && context.mounted) {
      _reload(ref);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.subAccountUpdatedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final accountsAsync = ref.watch(subAccountsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          l10n.subAccountManagement,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.invalidate(subAccountsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_outlined),
        label: Text(l10n.addAccount),
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildError(context, ref, l10n, e),
        data: (accounts) => _buildList(context, ref, l10n, accounts),
      ),
    );
  }

  Widget _buildError(
      BuildContext context, WidgetRef ref, AppLocalizations l10n, Object e) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.grey.shade400, size: 56),
          const SizedBox(height: 16),
          Text(
            e.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => ref.invalidate(subAccountsProvider),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, AppLocalizations l10n,
      List<SubAccount> accounts) {
    if (accounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              l10n.noSubAccountsFound,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addAccount,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(subAccountsProvider.future),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: accounts.length,
        itemBuilder: (_, i) => SubAccountCard(
          account: accounts[i],
          onTap: () => _openDetail(context, ref, accounts[i]),
        ),
      ),
    );
  }
}
