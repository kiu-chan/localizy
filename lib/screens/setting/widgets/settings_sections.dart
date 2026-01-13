import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/home/transaction_history_page.dart';
import 'package:localizy/screens/home/verification/address_verification_flow.dart';
import 'package:localizy/screens/setting/about_page.dart';
import 'package:localizy/screens/setting/account_settings_page.dart';
import 'package:localizy/screens/account/login_page.dart';
import 'package:localizy/utils/language_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:localizy/services/logout_service.dart';

class SettingsSections extends StatefulWidget {
  final LanguageManager languageManager;
  final String currentLanguage;
  final AppLocalizations l10n;

  const SettingsSections({
    super.key,
    required this. languageManager,
    required this.currentLanguage,
    required this.l10n,
  });

  @override
  State<SettingsSections> createState() => _SettingsSectionsState();
}

class _SettingsSectionsState extends State<SettingsSections> {
  String _appVersion = 'Loading...';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo. version;
          _buildNumber = packageInfo.buildNumber;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _appVersion = '0.1.0';
          _buildNumber = '';
        });
      }
    }
  }

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
                      builder: (context) => const TransactionHistoryPage(),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddressVerificationFlow(),
                    ),
                  );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountSettingsPage(),
                    ),
                  );
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
            ],
          ),

          const SizedBox(height:  24),

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
                icon: Icons.info_outline,
                title: 'About App',
                subtitle: 'Version $_appVersion${_buildNumber. isNotEmpty ? ' ($_buildNumber)' : ''}',
                color: Colors.pink,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutPage(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Logout Button (reusable logic in LogoutService)
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
            color:  Colors.black.withValues(alpha: 0.05),
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
                color: color.withValues(alpha: 0.1),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style:  TextStyle(
                      fontSize:  13,
                      color:  Colors.grey.shade600,
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
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.language, color: Colors.green. shade700, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.l10n.language,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:  FontWeight.w600,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical:  8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child:  DropdownButton<String>(
              value: widget.currentLanguage,
              underline: const SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: Colors.green.shade700),
              isDense: true,
              items: [
                DropdownMenuItem(
                  value: 'fr',
                  child: Text(
                    widget.l10n. french,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text(
                    widget.l10n. english,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  widget.languageManager.changeLanguage(newValue);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text('Language changed to ${widget.languageManager.getLanguageName(newValue)}'),
                        ],
                      ),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius. circular(10),
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
    // Full-width logout button that reuses LogoutService for the logout logic.
    final l10n = widget.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Text(l10n.logout),
                  ],
                ),
                content: Text(l10n.confirmLogout),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(l10n.cancel, style: TextStyle(color: Colors.grey.shade700)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(l10n.ok),
                  ),
                ],
              ),
            );

            if (confirm == true && context.mounted) {
              await LogoutService.logoutAndRedirect(
                context,
                loginPage: const LoginPage(),
              );
            }
          },
          icon: const Icon(Icons.logout, size: 20),
          label: Text(
            l10n.logout,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:  (context) => AlertDialog(
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
            const SizedBox(height: 12),
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
        Icon(icon, color: Colors. green.shade700, size: 20),
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}