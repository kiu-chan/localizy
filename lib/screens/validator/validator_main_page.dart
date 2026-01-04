import 'package:flutter/material.dart';
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
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors. black.withOpacity(0.1),
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon:  Icon(Icons.list_alt),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons. settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}