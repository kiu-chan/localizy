import 'package:flutter/material.dart';

import '../widgets/profile_header_section.dart';
import '../widgets/settings_sections.dart';

/// Trang Cài đặt của role user thường (tab trong MainPage).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // Profile Header Section
          SliverToBoxAdapter(
            child: ProfileHeaderSection(),
          ),

          // Settings Content
          SliverToBoxAdapter(
            child: SettingsSections(),
          ),
        ],
      ),
    );
  }
}
