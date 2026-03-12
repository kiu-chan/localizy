import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/home/history/transaction_history_page.dart';
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
                icon: Icons.history_rounded,
                title: 'Transaction History',
                subtitle: 'View your payment history',
                color: const Color(0xFF4285F4),
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
                icon: Icons.verified_outlined,
                title: 'Verified Addresses',
                subtitle: 'Manage verified locations',
                color: const Color(0xFF4285F4),
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
                icon: Icons.person_outline_rounded,
                title: 'Account Settings',
                subtitle: 'Update your profile information',
                color: const Color(0xFF4285F4),
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
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: 'Get help and contact us',
                color: const Color(0xFF4285F4),
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
                color: const Color(0xFF4285F4),
                onTap: () {
                  _showComingSoon(context, 'Privacy Policy');
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.info_outline_rounded,
                title: 'About App',
                subtitle: 'Version $_appVersion${_buildNumber.isNotEmpty ? ' ($_buildNumber)' : ''}',
                color: const Color(0xFF4285F4),
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
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF4285F4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9AA0B4),
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Colors.grey[350],
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
              color: const Color(0xFF4285F4).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.language_rounded, color: Color(0xFF4285F4), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.l10n.language,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Change app language',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9AA0B4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical:  8),
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF4285F4).withValues(alpha: 0.2)),
            ),
            child: DropdownButton<String>(
              value: widget.currentLanguage,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4285F4)),
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
                      backgroundColor: const Color(0xFF4285F4),
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
            const Icon(Icons.support_agent, color: Color(0xFF4285F4)),
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
        Icon(icon, color: const Color(0xFF4285F4), size: 20),
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
        backgroundColor: const Color(0xFF4285F4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}