import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/home/history/tabs/all_transactions_tab.dart';
import 'package:localizy/screens/home/history/tabs/parking_transactions_tab.dart';
import 'package:localizy/screens/home/history/tabs/verification_transactions_tab.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          AllTransactionsTab(),
          ParkingTransactionsTab(),
          VerificationTransactionsTab(),
        ],
      ),
    );
  }
}