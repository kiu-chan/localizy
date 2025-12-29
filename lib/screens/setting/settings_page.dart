import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../utils/language_manager.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations. of(context)!;
    final languageManager = Provider.of<LanguageManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          const Center(
            child: CircleAvatar(
              radius:  50,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height:  20),
          Center(
            child: Text(
              l10n.user,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Language Dropdown
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius:  5,
                  offset:  const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.language, color: Colors.green. shade700),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n. language,
                    style: const TextStyle(
                      fontSize:  16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green.shade700),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: languageManager.locale.languageCode,
                    underline: const SizedBox(),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.green.shade700),
                    items: [
                      DropdownMenuItem(
                        value: 'fr',
                        child: Row(
                          children: [
                            const Text('🇫🇷', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(l10n.french),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child:  Row(
                          children: [
                            const Text('🇬🇧', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(l10n.english),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        languageManager.changeLanguage(newValue);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              languageManager.getLanguageName(newValue),
                            ),
                            backgroundColor:  Colors.green,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height:  20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child:  Divider(),
          ),
          const SizedBox(height: 10),
          
          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title:  Text(l10n.logout),
                      content: Text(
                        l10n.logout == 'Logout' 
                          ? 'Are you sure you want to logout? '
                          : l10n.logout == 'Se déconnecter'
                          ?  'Êtes-vous sûr de vouloir vous déconnecter? '
                          : 'Bạn có chắc chắn muốn đăng xuất?',
                      ),
                      actions: [
                        TextButton(
                          onPressed:  () => Navigator.pop(context),
                          child: Text(
                            l10n.logout == 'Logout'
                              ? 'Cancel'
                              : l10n.logout == 'Se déconnecter'
                              ? 'Annuler'
                              : 'Hủy',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors. red,
                          ),
                          child: Text(l10n.logout),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors. red,
                foregroundColor:  Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.logout,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight. bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}