import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../pages/privacy_policy_page.dart';
import '../pages/terms_of_service_page.dart';
import '../providers/website_config_provider.dart';
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
    // Nạp sẵn cấu hình website (liên hệ + pháp lý) cho sheet support
    // và các trang Privacy/Terms.
    ref.watch(websiteConfigProvider);

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyPage(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                context,
                icon: Icons.description_outlined,
                title: l10n.termsOfService,
                subtitle: l10n.termsAndConditions,
                color: const Color(0xFF4285F4),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsOfServicePage(),
                    ),
                  );
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
    const primary = Color(0xFF4285F4);

    // Ưu tiên thông tin liên hệ từ API; fallback về giá trị mặc định
    // khi chưa tải được (offline / backend chưa cấu hình).
    final contact = ref.read(websiteConfigProvider).value?.contact;
    final email = (contact != null && contact.email.isNotEmpty)
        ? contact.email
        : 'support@citea.fr';
    final phone = (contact != null && contact.phone.isNotEmpty)
        ? contact.phone
        : '+33 1 23 45 67 89';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.hardEdge,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 12, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4285F4), Color(0xFF6BA4F8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.support_agent,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.helpAndSupport,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.howCanWeHelp,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Contact options
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSupportOption(
                      context,
                      l10n,
                      icon: Icons.email_outlined,
                      title: l10n.emailUs,
                      value: email,
                      copyable: true,
                    ),
                    const SizedBox(height: 12),
                    _buildSupportOption(
                      context,
                      l10n,
                      icon: Icons.phone_outlined,
                      title: l10n.callUs,
                      value: phone,
                      copyable: true,
                    ),
                    const SizedBox(height: 12),
                    _buildSupportOption(
                      context,
                      l10n,
                      icon: Icons.chat_bubble_outline_rounded,
                      title: l10n.liveChat,
                      value: l10n.available247,
                      copyable: false,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule_rounded,
                              size: 16, color: primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.respondWithin24h,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF5B6478),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportOption(
    BuildContext context,
    AppLocalizations l10n, {
    required IconData icon,
    required String title,
    required String value,
    required bool copyable,
  }) {
    const primary = Color(0xFF4285F4);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5B6478),
                  ),
                ),
              ],
            ),
          ),
          if (copyable)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _copyToClipboard(context, l10n, title, value),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(Icons.copy_rounded,
                      size: 18, color: primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _copyToClipboard(
    BuildContext context,
    AppLocalizations l10n,
    String label,
    String value,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.copiedToClipboard(label))),
            ],
          ),
          backgroundColor: const Color(0xFF4285F4),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
