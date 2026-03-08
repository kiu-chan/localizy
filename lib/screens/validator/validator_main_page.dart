import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'dashboard_page.dart';
import 'request_list_page.dart';
import 'schedule_page.dart';
import 'settings_page.dart';

class ValidatorMainPage extends StatefulWidget {
  const ValidatorMainPage({super.key});

  @override
  State<ValidatorMainPage> createState() => _ValidatorMainPageState();
}

class _ValidatorMainPageState extends State<ValidatorMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const RequestListPage(),
    const SchedulePage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Container(
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
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.green.shade700,
              unselectedItemColor: Colors.grey,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.dashboard),
                  label: l10n.dashboard,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.list_alt),
                  label: l10n.requests,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.calendar_today),
                  label: l10n.validatorScheduleTitle,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings),
                  label: l10n.settings,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}