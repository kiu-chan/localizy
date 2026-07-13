import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/features/auth/presentation/providers/auth_provider.dart';
import 'package:localizy/l10n/app_localizations.dart';

import 'business_dashboard_page.dart';
import 'business_map_page.dart';
import 'business_settings_page.dart';
import 'sub_account_management_page.dart';

class BusinessMainPage extends ConsumerStatefulWidget {
  const BusinessMainPage({super.key});

  @override
  ConsumerState<BusinessMainPage> createState() => _BusinessMainPageState();
}

class _BusinessMainPageState extends ConsumerState<BusinessMainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // SubAccount không có tab quản lý tài khoản con.
    final user = ref.watch(authProvider).value;
    final isSubAccount =
        (user?.role ?? '').toLowerCase().contains('subaccount');

    final pages = isSubAccount
        ? const <Widget>[
            BusinessDashboardPage(),
            BusinessMapPage(),
            BusinessSettingsPage(),
          ]
        : const <Widget>[
            BusinessDashboardPage(),
            SubAccountManagementPage(),
            BusinessMapPage(),
            BusinessSettingsPage(),
          ];

    final navItems = isSubAccount
        ? <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: l10n.dashboard,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map_outlined),
              activeIcon: const Icon(Icons.map),
              label: l10n.map,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: l10n.settings,
            ),
          ]
        : <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: l10n.dashboard,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_outline),
              activeIcon: const Icon(Icons.people),
              label: l10n.subAccounts,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map_outlined),
              activeIcon: const Icon(Icons.map),
              label: l10n.map,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: l10n.settings,
            ),
          ];

    final safeIndex = _currentIndex.clamp(0, pages.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue.shade700,
          unselectedItemColor: Colors.grey.shade500,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: navItems,
        ),
      ),
    );
  }
}
