import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:localizy/l10n/app_localizations.dart';

import '../../domain/website_config.dart';
import '../providers/website_config_provider.dart';

class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  static const _primary = Color(0xFF4285F4);
  static const _defaultEmail = 'support@citea.fr';
  static const _defaultAddress = 'Paris, France';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final configAsync = ref.watch(websiteConfigProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l10n.privacyPolicy,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        // API lỗi (vd: offline) → hiển thị nội dung tĩnh thay vì màn hình lỗi.
        error: (_, _) => _buildBody(context, l10n, null),
        data: (config) => _buildBody(context, l10n, config),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, AppLocalizations l10n, WebsiteConfig? config) {
    final apiContent = config?.legal.privacyPolicy.trim() ?? '';
    final contact = config?.contact;
    final email =
        (contact != null && contact.email.isNotEmpty) ? contact.email : _defaultEmail;
    final address = (contact != null && contact.address.isNotEmpty)
        ? contact.address
        : _defaultAddress;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(l10n),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (apiContent.isNotEmpty)
                  _buildContentCard(apiContent)
                else
                  ..._buildStaticSections(l10n),
                _buildContactSection(l10n, email, address),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.privacy_tip_outlined,
                color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.privacyPolicySubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Nội dung đầy đủ do backend cung cấp (PUT /api/settings/site-info),
  /// trả về dưới dạng HTML.
  Widget _buildContentCard(String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: HtmlWidget(
        content,
        textStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFF5B6478),
          height: 1.6,
        ),
      ),
    );
  }

  /// Nội dung tĩnh dùng khi backend chưa có dữ liệu hoặc không kết nối được.
  List<Widget> _buildStaticSections(AppLocalizations l10n) {
    return [
      _buildSection(
        icon: Icons.info_outline_rounded,
        title: l10n.privacyIntroTitle,
        body: l10n.privacyIntroBody,
      ),
      _buildSection(
        icon: Icons.folder_open_rounded,
        title: l10n.privacyCollectTitle,
        body: l10n.privacyCollectBody,
      ),
      _buildSection(
        icon: Icons.settings_suggest_outlined,
        title: l10n.privacyUseTitle,
        body: l10n.privacyUseBody,
      ),
      _buildSection(
        icon: Icons.share_outlined,
        title: l10n.privacyShareTitle,
        body: l10n.privacyShareBody,
      ),
      _buildSection(
        icon: Icons.lock_outline_rounded,
        title: l10n.privacySecurityTitle,
        body: l10n.privacySecurityBody,
      ),
      _buildSection(
        icon: Icons.schedule_rounded,
        title: l10n.privacyRetentionTitle,
        body: l10n.privacyRetentionBody,
      ),
      _buildSection(
        icon: Icons.verified_user_outlined,
        title: l10n.privacyRightsTitle,
        body: l10n.privacyRightsBody,
      ),
    ];
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF5B6478),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(
      AppLocalizations l10n, String email, String address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.mail_outline_rounded,
                    color: _primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.privacyContactTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.privacyContactBody,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF5B6478),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            '$email\n$address',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _primary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
