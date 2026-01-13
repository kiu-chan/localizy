import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('$label copied to clipboard')),
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
    return Scaffold(
      backgroundColor: Colors.grey. shade50,
      appBar: AppBar(
        title: const Text(
          'About Localizy',
          style:  TextStyle(fontWeight: FontWeight.w600),
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
                          _packageInfo?.appName ?? 'Localizy',
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
                            'Version ${_packageInfo?.version ?? '0.1.0'}${_packageInfo?.buildNumber. isNotEmpty == true ? ' (${_packageInfo! .buildNumber})' : ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors. white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Description
                        const Text(
                          'Your smart solution for parking\nmanagement and location verification',
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
                        _buildSectionTitle('Key Features'),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          Icons. local_parking,
                          'Smart Parking Payment',
                          'Pay for parking easily and securely',
                          Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          Icons.qr_code_scanner,
                          'License Plate Scanning',
                          'Automatic OCR recognition for quick entry',
                          Colors.red,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          Icons. verified,
                          'Address Verification',
                          'Verify and manage your locations',
                          Colors.purple,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          Icons.navigation,
                          'Real-time Navigation',
                          'Get directions to parking locations',
                          Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureCard(
                          Icons.history,
                          'Transaction History',
                          'Track all your parking payments',
                          Colors.teal,
                        ),
                        const SizedBox(height:  12),
                        _buildFeatureCard(
                          Icons.language,
                          'Multi-language Support',
                          'Available in multiple languages',
                          Colors.indigo,
                        ),

                        const SizedBox(height: 24),

                        // App Information
                        _buildSectionTitle('App Information'),
                        const SizedBox(height: 12),
                        _buildInfoCard(),

                        const SizedBox(height: 24),

                        // Contact & Links
                        _buildSectionTitle('Contact Information'),
                        const SizedBox(height: 12),
                        _buildContactCard(),

                        const SizedBox(height:  24),

                        // Legal
                        _buildSectionTitle('Legal'),
                        const SizedBox(height: 12),
                        _buildLegalCard(),

                        const SizedBox(height: 24),

                        // Developer Info
                        _buildSectionTitle('Development Team'),
                        const SizedBox(height: 12),
                        _buildDeveloperCard(),

                        const SizedBox(height: 24),

                        // Copyright
                        Center(
                          child: Column(
                            children: [
                              Text(
                                '© 2024 Localizy',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'All rights reserved',
                                style:  TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Made with ❤️ in Vietnam',
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

  Widget _buildInfoCard() {
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
          _buildInfoRow('App Name', _packageInfo?. appName ?? 'Localizy'),
          const SizedBox(height: 12),
          _buildInfoRow('Package Name', _packageInfo?.packageName ?? '-'),
          const SizedBox(height: 12),
          _buildInfoRow('Version', _packageInfo?.version ?? '0.1.0'),
          if (_packageInfo?.buildNumber.isNotEmpty == true) ...[
            const SizedBox(height:  12),
            _buildInfoRow('Build Number', _packageInfo!.buildNumber),
          ],
          const SizedBox(height: 12),
          _buildInfoRow('Platform', 'Android & iOS'),
          const SizedBox(height: 12),
          _buildInfoRow('Release Date', 'January 2024'),
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

  Widget _buildContactCard() {
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
            'Email',
            'support@localizy.com',
            () => _copyToClipboard('support@localizy.com', 'Email'),
          ),
          const Divider(height: 24),
          _buildContactItem(
            Icons.phone,
            'Phone',
            '+84 123 456 789',
            () => _copyToClipboard('+84123456789', 'Phone number'),
          ),
          const Divider(height: 24),
          _buildContactItem(
            Icons.language,
            'Website',
            'www.localizy.com',
            () => _copyToClipboard('www.localizy.com', 'Website'),
          ),
          const Divider(height: 24),
          _buildContactItem(
            Icons. location_city,
            'Address',
            'Ho Chi Minh City, Vietnam',
            () => _copyToClipboard('Ho Chi Minh City, Vietnam', 'Address'),
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

  Widget _buildLegalCard() {
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
            'Privacy Policy',
            'How we handle your data',
            () {
              _showComingSoon('Privacy Policy');
            },
          ),
          const Divider(height: 24),
          _buildLegalItem(
            Icons.description_outlined,
            'Terms of Service',
            'Terms and conditions',
            () {
              _showComingSoon('Terms of Service');
            },
          ),
          const Divider(height: 24),
          _buildLegalItem(
            Icons. policy_outlined,
            'Open Source Licenses',
            'Third-party licenses',
            () {
              showLicensePage(
                context: context,
                applicationName: _packageInfo?.appName ?? 'Localizy',
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
          Row(
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
                    const Text(
                      'Developed by',
                      style:  TextStyle(
                        fontSize:  12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Localizy Development Team',
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
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child:  Row(
              mainAxisAlignment:  MainAxisAlignment.spaceAround,
              children: [
                _buildTechBadge(Icons.phone_android, 'Flutter'),
                _buildTechBadge(Icons.cloud, 'Firebase'),
                _buildTechBadge(Icons. map, 'Google Maps'),
                _buildTechBadge(Icons.camera_alt, 'ML Kit'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechBadge(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize:  10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showComingSoon(String feature) {
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