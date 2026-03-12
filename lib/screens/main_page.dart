import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'home/home_page.dart';
import 'map/map_page.dart';
import 'setting/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super. key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  bool _hideBottomNav = false;

  void _setBottomNavVisibility(bool hide) {
    if (_hideBottomNav != hide) {
      setState(() {
        _hideBottomNav = hide;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomePage(),
          MapPage(onNavigationStateChanged:  _setBottomNavVisibility),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: _hideBottomNav 
          ? null
          : Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius:  8,
                    offset:  const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  backgroundColor:  Colors.transparent,
                  elevation: 0,
                  selectedItemColor: const Color(0xFF1A73E8),
                  unselectedItemColor: Colors.grey.shade500,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle:  const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                  ),
                  type: BottomNavigationBarType.fixed,
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.home_outlined),
                      activeIcon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A73E8).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.home),
                      ),
                      label: l10n?. home ?? 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.map_outlined),
                      activeIcon: Container(
                        padding:  const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A73E8).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.map),
                      ),
                      label: l10n?. map ?? 'Map',
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.settings_outlined),
                      activeIcon: Container(
                        padding:  const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A73E8).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.settings),
                      ),
                      label: l10n?. settings ?? 'Settings',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}