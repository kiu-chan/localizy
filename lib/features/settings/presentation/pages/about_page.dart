import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../providers/website_config_provider.dart';
import 'privacy_policy_page.dart';
import 'terms_of_service_page.dart';

class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  PackageInfo? _packageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _packageInfo = info;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.copiedToClipboard(label))),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey. shade50,
      appBar: AppBar(
        title: Text(
          l10n.aboutLocalizy,
          style:  const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // App Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors. green.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // App Icon
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius:  20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child:  Icon(
                            Icons.location_on,
                            color: Colors.green.shade700,
                            size: 64,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // App Name
                        Text(
                          _packageInfo?.appName ?? 'Citea',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors. white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Version
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white. withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.versionDisplay(_packageInfo?.version ?? '0.1.0') +
                                (_packageInfo?.buildNumber.isNotEmpty == true ? ' (${_packageInfo!.buildNumber})' : ''),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors. white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          l10n.appDescription,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Features Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment. start,
                      children: [
                        _buildSectionTitle(l10n.keyFeatures),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          Icons. local_parking,
                          l10n.parkingPayment,
                          l10n.smartParkingPaymentDesc,
                          Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          Icons.qr_code_scanner,
                          l10n.licensePlateScanning,
                          l10n.licensePlateScanningDesc,
                          Colors.red,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          Icons. verified,
                          l10n.addressVerification,
                          l10n.addressVerificationDesc,
                          Colors.purple,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          Icons.navigation,
                          l10n.realTimeNavigation,
                          l10n.realTimeNavigationDesc,
                          Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          Icons.history,
                          l10n.transactionHistory,
                          l10n.transactionHistoryDesc,
                          Colors.teal,
                        ),
                        const SizedBox(height:  12),
                        _buildFeatureCard(
                          Icons.language,
                          l10n.multiLanguageSupport,
                          l10n.multiLanguageSupportDesc,
                          Colors.indigo,
                        ),

                        const SizedBox(height: 24),

                        // App Information
                        _buildSectionTitle(l10n.appInformation),
                        const SizedBox(height: 12),
                        _buildInfoCard(l10n),

                        const SizedBox(height: 24),

                        // Contact & Links
                        _buildSectionTitle(l10n.contactInformation),
                        const SizedBox(height: 12),
                        _buildContactCard(l10n),

                        const SizedBox(height:  24),

                        // Legal
                        _buildSectionTitle(l10n.legalSection),
                        const SizedBox(height: 12),
                        _buildLegalCard(l10n),

                        const SizedBox(height: 24),

                        // Developer Info
                        _buildSectionTitle(l10n.developmentTeam),
                        const SizedBox(height: 12),
                        _buildDeveloperCard(),

                        const SizedBox(height: 24),

                        // Copyright
                        Center(
                          child: Column(
                            children: [
                              Text(
                                l10n.copyright,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.allRightsReserved,
                                style:  TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.codedWithLove,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:  Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors. white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color. withValues(alpha: 0.1),
              borderRadius: BorderRadius. circular(12),
            ),
            child:  Icon(icon, color: color, size: 28),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors. grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets. all(20),
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
      child: Column(
        children: [
          _buildInfoRow(l10n.appNameLabel, _packageInfo?. appName ?? 'Citea'),
          const SizedBox(height: 12),
          _buildInfoRow(l10n.packageNameLabel, _packageInfo?.packageName ?? '-'),
          const SizedBox(height: 12),
          _buildInfoRow(l10n.versionLabel, _packageInfo?.version ?? '0.1.0'),
          if (_packageInfo?.buildNumber.isNotEmpty == true) ...[
            const SizedBox(height:  12),
            _buildInfoRow(l10n.buildNumberLabel, _packageInfo!.buildNumber),
          ],
          const SizedBox(height: 12),
          _buildInfoRow(l10n.platformLabel, 'Android & iOS'),
          const SizedBox(height: 12),
          _buildInfoRow(l10n.releaseDateLabel, 'January 2024'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:  [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(AppLocalizations l10n) {
    // Ưu tiên thông tin liên hệ từ API; fallback về giá trị mặc định.
    final contact = ref.watch(websiteConfigProvider).value?.contact;
    final email = (contact != null && contact.email.isNotEmpty)
        ? contact.email
        : 'support@citea.fr';
    final phone = (contact != null && contact.phone.isNotEmpty)
        ? contact.phone
        : '+33 1 23 45 67 89';
    final address = (contact != null && contact.address.isNotEmpty)
        ? contact.address
        : 'Paris, France';

    return Container(
      padding: const EdgeInsets. all(20),
      decoration: BoxDecoration(
        color:  Colors.white,
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
        children:  [
          _buildContactItem(
            Icons.email,
            l10n.email,
            email,
            () => _copyToClipboard(email, l10n.email),
          ),
          const Divider(height: 24),
          _buildContactItem(
            Icons.phone,
            l10n.phone,
            phone,
            () => _copyToClipboard(phone, l10n.phone),
          ),
          const Divider(height: 24),
          _buildContactItem(
            Icons.language,
            l10n.website,
            'www.citea.fr',
            () => _copyToClipboard('www.citea.fr', l10n.website),
          ),
          const Divider(height: 24),
          _buildContactItem(
            Icons. location_city,
            l10n.address,
            address,
            () => _copyToClipboard(address, l10n.address),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: Colors.green.shade700, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors. grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style:  const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.copy,
              size: 18,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors. white,
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
        children: [
          _buildLegalItem(
            Icons.privacy_tip_outlined,
            l10n.privacyPolicy,
            l10n.readPrivacyPolicy,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage(),
                ),
              );
            },
          ),
          const Divider(height: 24),
          _buildLegalItem(
            Icons.description_outlined,
            l10n.termsOfService,
            l10n.termsAndConditions,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsOfServicePage(),
                ),
              );
            },
          ),
          const Divider(height: 24),
          _buildLegalItem(
            Icons. policy_outlined,
            l10n.openSourceLicenses,
            l10n.thirdPartyLicenses,
            () {
              showLicensePage(
                context: context,
                applicationName: _packageInfo?.appName ?? 'Citea',
                applicationVersion: _packageInfo?.version ??  '0.1.0',
                applicationIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color:  Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius. circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: Colors. grey.shade700, size: 24),
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

  Widget _buildDeveloperCard() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors. white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:  Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child:  Icon(
              Icons.code,
              color: Colors. blue.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.developedBy,
                  style:  const TextStyle(
                    fontSize:  12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.devTeamName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:  FontWeight.bold,
                    color: Colors. grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}