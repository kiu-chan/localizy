import 'package:flutter/material.dart';
import 'package:localizy/api/auth_api.dart';
import 'package:localizy/api/user_profile_service.dart';
import 'package:localizy/api/main_api.dart';

class ProfileHeaderSection extends StatefulWidget {
  const ProfileHeaderSection({super.key});

  @override
  State<ProfileHeaderSection> createState() => _ProfileHeaderSectionState();
}

class _ProfileHeaderSectionState extends State<ProfileHeaderSection> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
    });

    // First, try to read stored user (quick)
    final stored = await AuthService.getStoredUser();
    if (stored != null) {
      setState(() {
        _profile = {
          'fullName': stored.fullName,
          'email': stored.email,
        };
      });
    }

    // Then try to fetch fresh profile from API
    try {
      final fetched = await UserProfileService.fetchCurrentUserProfile();
      if (mounted) {
        setState(() {
          _profile = fetched;
        });
      }
    } catch (e) {
      // ignore - keep stored values
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    final name = _profile?['fullName'] as String? ?? 'John Doe';
    final email = _profile?['email'] as String? ?? 'john.doe@example.com';
    final phone = _profile?['phone'] as String? ?? '+84 123 456 789';
    final avatar = _profile?['avatar'] as String?;
    final avatarUrl = _avatarUrl(avatar);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            children: [
              // Avatar with Edit Button
              Stack(
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
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.green,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        // Optionally navigate to profile edit or trigger avatar change flow
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // User Name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 4),

              // User Email
              Text(
                email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),

              const SizedBox(height: 4),

              // Phone Number
              Text(
                phone,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),

              const SizedBox(height: 16),

              // Member Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Premium Member',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
}