import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:localizy/l10n/app_localizations.dart';

import '../providers/website_config_provider.dart';
import '../widgets/legal_document_skeleton.dart';

class TermsOfServicePage extends ConsumerWidget {
  const TermsOfServicePage({super.key});

  static const _primary = Color(0xFF4285F4);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final configAsync = ref.watch(websiteConfigProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l10n.termsOfService,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: configAsync.when(
        loading: () => const LegalDocumentSkeleton(),
        error: (_, _) => _buildError(context, ref, l10n),
        data: (config) {
          final content = config.legal.termsOfUse.trim();
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(l10n),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: content.isNotEmpty
                      ? _buildContentCard(content)
                      : _buildEmptyState(l10n),
                ),
              ],
            ),
          );
        },
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
            child: const Icon(Icons.description_outlined,
                color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.termsAndConditions,
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

  /// Nội dung backend trả về dưới dạng HTML.
  Widget _buildContentCard(String content) {
    return Container(
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

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.hourglass_empty_rounded,
              size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            l10n.contentBeingUpdated,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            l10n.failedToLoadData,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(websiteConfigProvider),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
