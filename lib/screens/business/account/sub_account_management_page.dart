import 'package:flutter/material.dart';
import 'package:localizy/api/sub_account_api.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/business/account/widgets/sub_account_card.dart';
import 'package:localizy/screens/business/account/widgets/sub_account_detail_sheet.dart';
import 'package:localizy/screens/business/account/widgets/sub_account_form_dialog.dart';

class SubAccountManagementPage extends StatefulWidget {
  const SubAccountManagementPage({super.key});

  @override
  State<SubAccountManagementPage> createState() =>
      _SubAccountManagementPageState();
}

class _SubAccountManagementPageState extends State<SubAccountManagementPage> {
  List<SubAccount> _accounts = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ─── Data ──────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await SubAccountApi.getMySubAccounts();
      if (mounted) setState(() => _accounts = list);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Create ────────────────────────────────────────────────────────────────

  Future<void> _create() async {
    final created = await showCreateSubAccountDialog(context);
    if (created != null && mounted) {
      setState(() => _accounts.insert(0, created));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.subAccountCreatedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ─── Detail + Edit ─────────────────────────────────────────────────────────

  Future<void> _openDetail(SubAccount account) async {
    final doEdit = await showSubAccountDetailSheet(context, account);
    if (!doEdit || !mounted) return;

    final updated = await showEditSubAccountDialog(context, account);
    if (updated != null && mounted) {
      setState(() {
        final idx = _accounts.indexWhere((a) => a.id == account.id);
        if (idx != -1) _accounts[idx] = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.subAccountUpdatedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          l10n.subAccountManagement,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_outlined),
        label: Text(l10n.addAccount),
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                color: Colors.grey.shade400, size: 56),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_accounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline,
                size: 64, color: Colors.grey.shade300),
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

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: _accounts.length,
      itemBuilder: (_, i) => SubAccountCard(
        account: _accounts[i],
        onTap: () => _openDetail(_accounts[i]),
      ),
    );
  }
}
