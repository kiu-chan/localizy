import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/home/transaction_history_page.dart';
import 'package:localizy/utils/language_manager.dart';

class SettingsSections extends StatelessWidget {
  final LanguageManager languageManager;
  final String currentLanguage;
  final AppLocalizations l10n;

  const SettingsSections({
    Key? key,
    required this.languageManager,
    required this.currentLanguage,
    required this.l10n,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Account Section
          _buildSectionTitle('Account'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            [
              _buildSettingItem(
                context,
                icon: Icons.history,
                title: 'Transaction History',
                subtitle: 'View your payment history',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:  (context) => const TransactionHistoryPage(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.verified,
                title: 'Verified Addresses',
                subtitle: 'Manage verified locations',
                color: Colors.purple,
                onTap: () {
                  _showComingSoon(context, 'Verified Addresses');
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.person_outline,
                title: 'Account Settings',
                subtitle: 'Update your profile information',
                color:  Colors.orange,
                onTap: () {
                  _showAccountSettings(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Preferences Section
          _buildSectionTitle('Preferences'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            [
              _buildLanguageSelector(context),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon:  Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage app notifications',
                color:  Colors.teal,
                trailing: Switch(
                  value:  true,
                  onChanged: (value) {
                    // TODO: Toggle notifications
                  },
                  activeColor: Colors.green. shade700,
                ),
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Change app theme',
                color: Colors.indigo,
                trailing: Switch(
                  value:  false,
                  onChanged:  (value) {
                    // TODO: Toggle dark mode
                  },
                  activeColor: Colors.green.shade700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Support Section
          _buildSectionTitle('Support & About'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            [
              _buildSettingItem(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help and contact us',
                color: Colors.indigo,
                onTap:  () {
                  _showSupportDialog(context);
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                color:  Colors.cyan,
                onTap: () {
                  _showComingSoon(context, 'Privacy Policy');
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon:  Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                color: Colors. amber,
                onTap: () {
                  _showComingSoon(context, 'Terms of Service');
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons. info_outline,
                title: 'About App',
                subtitle:  'Version 1.0.0',
                color: Colors.pink,
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Logout Button
          _buildLogoutButton(context),

          const SizedBox(height:  32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child:  Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize:  16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style:  TextStyle(
                      fontSize:  13,
                      color: Colors. grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.language, color: Colors.green.shade700, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.language,
                  style: const TextStyle(
                    fontSize:  16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Change app language',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: DropdownButton<String>(
              value: currentLanguage,
              underline: const SizedBox(),
              icon:  Icon(Icons.arrow_drop_down, color: Colors.green.shade700),
              isDense: true,
              items: [
                DropdownMenuItem(
                  value: 'fr',
                  child: Text(
                    l10n.french,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child:  Text(
                    l10n.english,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
              onChanged:  (String? newValue) {
                if (newValue != null) {
                  languageManager.changeLanguage(newValue);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text('Language changed to ${languageManager.getLanguageName(newValue)}'),
                        ],
                      ),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 72,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:  BorderRadius.circular(20),
              ),
              title:  Row(
                children: [
                  Icon(Icons.logout, color: Colors.red. shade700),
                  const SizedBox(width: 12),
                  Text(l10n.logout),
                ],
              ),
              content: Text(
                l10n.logout == 'Logout'
                    ? 'Are you sure you want to logout?'
                    : l10n.logout == 'Se déconnecter'
                        ? 'Êtes-vous sûr de vouloir vous déconnecter? '
                        : 'Bạn có chắc chắn muốn đăng xuất?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    l10n.logout == 'Logout'
                        ? 'Cancel'
                        : l10n.logout == 'Se déconnecter'
                            ? 'Annuler'
                            : 'Hủy',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors. red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(l10n.logout),
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout, size: 20),
          const SizedBox(width: 8),
          Text(
            l10n.logout,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountSettings(BuildContext context) {
    showModalBottomSheet(
      context:  context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings, color: Colors.green.shade700, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Account Settings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildAccountSettingItem(
                      icon: Icons.person_outline,
                      title: 'Full Name',
                      value: 'John Doe',
                      showArrow: true,
                    ),
                    const SizedBox(height: 16),
                    _buildAccountSettingItem(
                      icon:  Icons.email_outlined,
                      title: 'Email',
                      value: 'john. doe@example.com',
                      showArrow: true,
                    ),
                    const SizedBox(height: 16),
                    _buildAccountSettingItem(
                      icon: Icons.phone_outlined,
                      title: 'Phone',
                      value: '+84 123 456 789',
                      showArrow: true,
                    ),
                    const SizedBox(height: 16),
                    _buildAccountSettingItem(
                      icon:  Icons.cake_outlined,
                      title:  'Date of Birth',
                      value:  'January 1, 1990',
                      showArrow:  true,
                    ),
                    const SizedBox(height:  16),
                    _buildAccountSettingItem(
                      icon: Icons.location_on_outlined,
                      title: 'Address',
                      value:  'Ho Chi Minh City, Vietnam',
                      showArrow: true,
                    ),
                    const SizedBox(height: 16),
                    _buildAccountSettingItem(
                      icon: Icons.lock_outline,
                      title: 'Password',
                      value: '••••••••',
                      showArrow: true,
                    ),
                    const SizedBox(height: 16),
                    _buildAccountSettingItem(
                      icon: Icons.security,
                      title: 'Two-Factor Authentication',
                      value: 'Enabled',
                      showArrow: true,
                    ),

                    const SizedBox(height: 24),

                    // Delete Account Button
                    OutlinedButton. icon(
                      onPressed:  () {
                        Navigator.pop(context);
                        _showDeleteAccountDialog(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete Account'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettingItem({
    required IconData icon,
    required String title,
    required String value,
    bool showArrow = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors. grey.shade600, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors. grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize:  16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (showArrow)
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors. grey.shade400),
      ],
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.support_agent, color: Colors.green.shade700),
            const SizedBox(width: 12),
            const Text('Help & Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How can we help you? ',
              style: TextStyle(fontSize: 16, fontWeight:  FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildSupportOption(Icons.email, 'Email Us', 'support@localizy.com'),
            const SizedBox(height: 12),
            _buildSupportOption(Icons.phone, 'Call Us', '+84 123 456 789'),
            const SizedBox(height:  12),
            _buildSupportOption(Icons.chat, 'Live Chat', 'Available 24/7'),
            const SizedBox(height: 16),
            const Text(
              'We typically respond within 24 hours',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors. grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Localizy',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.location_on, color: Colors.white, size: 32),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Localizy is your smart solution for parking management and location verification.',
        ),
        const SizedBox(height: 12),
        const Text(
          'Features:\n'
          '• Smart parking payment\n'
          '• License plate scanning\n'
          '• Address verification\n'
          '• Real-time navigation\n'
          '• Transaction history\n'
          '• Multi-language support',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 12),
        const Text(
          '© 2024 Localizy. All rights reserved.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:  (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius:  BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
            const SizedBox(width: 12),
            const Text('Delete Account'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed:  () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed:  () {
              Navigator.pop(context);
              // TODO: Delete account
            },
            style:  ElevatedButton.styleFrom(
              backgroundColor: Colors.red. shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('$feature - Coming soon')),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior. floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}