import 'package:flutter/material.dart';
import 'package:localizy/api/auth_api.dart';
import 'package:localizy/api/user_profile_service.dart';
import 'package:localizy/api/main_api.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/setting/account_settings_page.dart';

class ProfileHeaderSection extends StatefulWidget {
  const ProfileHeaderSection({super.key});

  @override
  State<ProfileHeaderSection> createState() => _ProfileHeaderSectionState();
}

class _ProfileHeaderSectionState extends State<ProfileHeaderSection> {
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
    } catch (e) {
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

  String _roleLabel(String? role, AppLocalizations l10n) {
    switch (role) {
      case 'Admin':
        return l10n.roleAdmin;
      case 'Validator':
        return l10n.roleValidator;
      case 'Business':
        return l10n.roleBusiness;
      case 'SubAccount':
        return l10n.roleSubAccount;
      default:
        return l10n.roleMember;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = (_profile?['name'] ?? _profile?['fullName']) as String? ?? l10n.yourName;
    final email = _profile?['email'] as String? ?? '';
    final phone = _profile?['phone'] as String?;
    final role = _profile?['role'] as String?;
    final avatarPath = _profile?['avatarUrl'] as String?;
    final avatarUrl = _avatarUrl(avatarPath);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF4285F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            children: [
              // Avatar (chỉ hiển thị, không click)
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
                      ? const Icon(Icons.person, size: 50, color: Color(0xFF4285F4))
                      : null,
                ),
              ),

              const SizedBox(height: 16),

              // Tên
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              if (email.isNotEmpty)
                Text(
                  email,
                  style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9)),
                ),

              if (phone != null && phone.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],

              const SizedBox(height: 16),

              // Role Badge + nút chuyển đến trang cập nhật
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _roleLabel(role, l10n),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
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
                          const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF1565C0)),
                          const SizedBox(width: 6),
                          Text(
                            l10n.edit,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
