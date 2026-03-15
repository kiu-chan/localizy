import 'package:flutter/material.dart';
import 'package:localizy/api/auth_api.dart';
import 'package:localizy/api/main_api.dart';
import 'package:localizy/api/user_profile_service.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/setting/about_page.dart';
import 'package:localizy/screens/setting/account_settings_page.dart';
import 'package:localizy/screens/setting/change_password_page.dart';
import 'package:localizy/screens/account/login_page.dart';
import 'package:localizy/utils/language_manager.dart';
import 'package:localizy/services/logout_service.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final stored = await AuthService.getStoredUser();
    if (stored != null && mounted) {
      setState(() {
        _profile = {
          'name': stored.fullName,
          'email': stored.email,
          'role': stored.role,
        };
      });
    }

    try {
      final fetched = await UserProfileService.fetchCurrentUserProfile();
      if (mounted) {
        setState(() {
          _profile = fetched;
        });
      }
    } catch (_) {
      // keep stored values
    }
  }

  String? _avatarUrl(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) return null;
    if (avatarPath.toLowerCase().startsWith('http')) return avatarPath;
    final base = MainApi.instance.baseUrl.endsWith('/')
        ? MainApi.instance.baseUrl.substring(0, MainApi.instance.baseUrl.length - 1)
        : MainApi.instance.baseUrl;
    return '$base$avatarPath';
  }

  void _goToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AccountSettingsPage()),
    ).then((_) => _loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageManager = Provider.of<LanguageManager>(context);
    final validLanguages = ['fr', 'en'];
    final currentLanguage = validLanguages.contains(languageManager.locale.languageCode)
        ? languageManager.locale.languageCode
        : 'fr';

    final name = (_profile?['name'] ?? _profile?['fullName']) as String? ?? l10n.yourName;
    final email = _profile?['email'] as String? ?? '';
    final phone = _profile?['phone'] as String?;
    final avatarPath = _profile?['avatarUrl'] as String?;
    final avatarUrl = _avatarUrl(avatarPath);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(
              name: name,
              email: email,
              phone: phone,
              avatarUrl: avatarUrl,
              l10n: l10n,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Account
                  _buildSectionTitle(l10n.accountInfo),
                  const SizedBox(height: 12),
                  _buildCard([
                    _buildTile(
                      icon: Icons.manage_accounts_outlined,
                      title: l10n.accountSettingsTitle,
                      subtitle: email.isNotEmpty ? email : l10n.accountInfo,
                      onTap: _goToEditProfile,
                    ),
                    Divider(height: 1, indent: 72, color: Colors.grey.shade200),
                    _buildTile(
                      icon: Icons.lock_outline,
                      title: l10n.changePassword,
                      subtitle: l10n.changeLoginPassword,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Preferences
                  _buildSectionTitle(l10n.preferences),
                  const SizedBox(height: 12),
                  _buildCard([
                    _buildLanguageSelector(context, languageManager, currentLanguage, l10n),
                  ]),

                  const SizedBox(height: 24),

                  // Support & About
                  _buildSectionTitle(l10n.supportAndAbout),
                  const SizedBox(height: 12),
                  _buildCard([
                    _buildTile(
                      icon: Icons.info_outline,
                      title: l10n.about,
                      subtitle: l10n.appTitle,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AboutPage()),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  _buildLogoutButton(context, l10n),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader({
    required String name,
    required String email,
    String? phone,
    String? avatarUrl,
    required AppLocalizations l10n,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green.shade700, Colors.green.shade500],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Icon(Icons.verified_user, size: 50, color: Colors.green.shade700)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9)),
            ),
          ],
          if (phone != null && phone.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              phone,
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _goToEditProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, size: 14, color: Colors.green.shade700),
                  const SizedBox(width: 6),
                  Text(
                    l10n.edit,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.green.shade700, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    LanguageManager languageManager,
    String currentLanguage,
    AppLocalizations l10n,
  ) {
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
            child: Icon(Icons.language, color: Colors.green.shade700, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.language,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(l10n.selectLanguage,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
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
              icon: Icon(Icons.arrow_drop_down, color: Colors.green.shade700),
              isDense: true,
              items: [
                DropdownMenuItem(
                  value: 'fr',
                  child: Text(l10n.french, style: const TextStyle(fontSize: 14)),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text(l10n.english, style: const TextStyle(fontSize: 14)),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  languageManager.changeLanguage(newValue);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(l10n.languageChangedTo(
                              languageManager.getLanguageName(newValue))),
                        ],
                      ),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
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

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                        borderRadius: BorderRadius.circular(10)),
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }
}
