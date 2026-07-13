import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/features/auth/presentation/pages/login_page.dart';
import 'package:localizy/features/auth/presentation/providers/auth_provider.dart';
import 'package:localizy/features/transactions/presentation/pages/transaction_history_page.dart';
import 'package:localizy/features/verification/presentation/pages/address_verification_flow.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../pages/about_page.dart';
import '../pages/account_settings_page.dart';
import '../pages/change_password_page.dart';
import '../providers/language_provider.dart';

class SettingsSections extends ConsumerStatefulWidget {
  const SettingsSections({super.key});

  @override
  ConsumerState<SettingsSections> createState() => _SettingsSectionsState();
}

class _SettingsSectionsState extends ConsumerState<SettingsSections> {
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
          _appVersion = packageInfo.version;
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
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Account Section
          _buildSectionTitle(l10n.account),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            [
              _buildSettingItem(
                context,
                icon: Icons.history_rounded,
                title: l10n.transactionHistory,
                subtitle: l10n.viewPaymentHistory,
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
                title: l10n.verifiedAddresses,
                subtitle: l10n.manageVerifiedLocations,
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
                title: l10n.accountSettingsTitle,
                subtitle: l10n.updateProfileInfo,
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
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.lock_outline_rounded,
                title: l10n.changePassword,
                subtitle: l10n.changeLoginPassword,
                color: const Color(0xFF4285F4),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordPage(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Preferences Section
          _buildSectionTitle(l10n.preferences),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            [
              _buildLanguageSelector(context, l10n),
            ],
          ),

          const SizedBox(height: 24),

          // Support Section
          _buildSectionTitle(l10n.supportAndAbout),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context,
            [
              _buildSettingItem(
                context,
                icon: Icons.help_outline_rounded,
                title: l10n.helpAndSupport,
                subtitle: l10n.getHelpAndContact,
                color: const Color(0xFF4285F4),
                onTap: () {
                  _showSupportDialog(context, l10n);
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.privacy_tip_outlined,
                title: l10n.privacyPolicy,
                subtitle: l10n.readPrivacyPolicy,
                color: const Color(0xFF4285F4),
                onTap: () {
                  _showComingSoon(context, l10n, l10n.privacyPolicy);
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.info_outline_rounded,
                title: l10n.about,
                subtitle:
                    'Version $_appVersion${_buildNumber.isNotEmpty ? ' ($_buildNumber)' : ''}',
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

          // Logout Button
          _buildLogoutButton(context, l10n),

          const SizedBox(height: 32),
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
              child: Icon(icon, color: color, size: 24),
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

  Widget _buildLanguageSelector(BuildContext context, AppLocalizations l10n) {
    final locale = ref.watch(languageProvider);
    final currentLanguage =
        LanguageNotifier.supportedCodes.contains(locale.languageCode)
            ? locale.languageCode
            : 'fr';

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
            child: const Icon(Icons.language_rounded,
                color: Color(0xFF4285F4), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.language,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.changeAppLanguage,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9AA0B4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFF4285F4).withValues(alpha: 0.2)),
            ),
            child: DropdownButton<String>(
              value: currentLanguage,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4285F4)),
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
                  child: Text(
                    l10n.english,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  final notifier = ref.read(languageProvider.notifier);
                  notifier.changeLanguage(newValue);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                              'Language changed to ${notifier.getLanguageName(newValue)}'),
                        ],
                      ),
                      backgroundColor: const Color(0xFF4285F4),
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

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
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
                  child: Text(l10n.cancel,
                      style: TextStyle(color: Colors.grey.shade700)),
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
            await ref.read(authProvider.notifier).logout();
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
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
    );
  }

  void _showSupportDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.support_agent, color: Color(0xFF4285F4)),
            const SizedBox(width: 12),
            Text(l10n.helpAndSupport),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.howCanWeHelp,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
                Icons.email, l10n.emailUs, 'support@localizy.com'),
            const SizedBox(height: 12),
            _buildSupportOption(Icons.phone, l10n.callUs, '+84 123 456 789'),
            const SizedBox(height: 12),
            _buildSupportOption(Icons.chat, l10n.liveChat, l10n.available247),
            const SizedBox(height: 16),
            Text(
              l10n.respondWithin24h,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
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
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showComingSoon(
      BuildContext context, AppLocalizations l10n, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.featureComingSoon(feature))),
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
