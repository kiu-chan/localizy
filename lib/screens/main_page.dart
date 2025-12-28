import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MapPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations. of(context);
    
    return Scaffold(
      body:  _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor:  Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n?.home ??  'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: l10n?.map ?? 'Map',
          ),
          BottomNavigationBarItem(
            icon:  const Icon(Icons.settings),
            label: l10n?.settings ?? 'Settings',
          ),
        ],
      ),
    );
  }
}