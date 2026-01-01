import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'home/home_page.dart';
import 'map/map_page.dart';
import 'setting/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // Tạo danh sách pages một lần duy nhất, không tạo lại mỗi lần build
  final List<Widget> _pages = const [
    HomePage(),
    MapPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      // Sử dụng IndexedStack thay vì _pages[_currentIndex]
      // IndexedStack giữ state của tất cả các pages
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.green. shade700,
        unselectedItemColor: Colors.grey,
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
            icon: const Icon(Icons. settings),
            label: l10n?.settings ?? 'Settings',
          ),
        ],
      ),
    );
  }
}