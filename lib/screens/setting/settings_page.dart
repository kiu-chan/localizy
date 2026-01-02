import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../utils/language_manager.dart';
import 'widgets/profile_header_section.dart';
import 'widgets/settings_sections.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageManager = Provider.of<LanguageManager>(context);

    // Đảm bảo language code hợp lệ (chỉ 'fr' hoặc 'en')
    final validLanguages = ['fr', 'en'];
    final currentLanguage = validLanguages.contains(languageManager.locale.languageCode)
        ? languageManager.locale.languageCode
        : 'fr'; // Mặc định là 'fr' nếu không hợp lệ

    return Scaffold(
      backgroundColor: Colors.grey. shade50,
      body: CustomScrollView(
        slivers: [
          // Profile Header Section
          const SliverToBoxAdapter(
            child: ProfileHeaderSection(),
          ),

          // Settings Content
          SliverToBoxAdapter(
            child: SettingsSections(
              languageManager: languageManager,
              currentLanguage: currentLanguage,
              l10n: l10n,
            ),
          ),
        ],
      ),
    );
  }
}