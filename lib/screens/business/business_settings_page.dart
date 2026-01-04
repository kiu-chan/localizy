import 'package:flutter/material.dart';
import '../../screens/account/login_page.dart';

class BusinessSettingsPage extends StatefulWidget {
  const BusinessSettingsPage({super.key});

  @override
  State<BusinessSettingsPage> createState() => _BusinessSettingsPageState();
}

class _BusinessSettingsPageState extends State<BusinessSettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _marketingEmails = false;
  bool _locationUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight. bold,
            color: Colors. white,
          ),
        ),
        backgroundColor: Colors.blue. shade700,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child:  Column(
          children: [
            // Business Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end:  Alignment.bottomCenter,
                  colors: [
                    Colors. blue.shade700,
                    Colors.blue.shade500,
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.business,
                      size: 50,
                      color:  Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Business Account',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'business@gmail.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showEditProfileDialog();
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors. white,
                      foregroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius. circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Business Settings
            _buildSectionTitle('Business Information'),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons.business,
                title: 'Company Details',
                subtitle: 'Business name, type, description',
                onTap: () {
                  _showCompanyDetailsDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.verified,
                title: 'Verification',
                subtitle: 'Verify your business',
                onTap: () {
                  _showVerificationDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.receipt_long,
                title: 'Subscription',
                subtitle: 'Manage your subscription plan',
                onTap: () {
                  _showSubscriptionDialog();
                },
              ),
            ]),

            // Account Settings
            _buildSectionTitle('Account Settings'),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons. lock_outline,
                title:  'Change Password',
                subtitle: 'Update your password',
                onTap: () {
                  _showChangePasswordDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.security,
                title: 'Security',
                subtitle: 'Two-factor authentication',
                onTap: () {
                  _showSecurityDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.payment,
                title: 'Payment Methods',
                subtitle: 'Manage payment options',
                onTap:  () {
                  _showPaymentMethodsDialog();
                },
              ),
            ]),

            // Notifications
            _buildSectionTitle('Notifications'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive push notifications',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon:  Icons.email_outlined,
                title: 'Email Notifications',
                subtitle: 'Receive email updates',
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
              ),
              const Divider(height:  1),
              _buildSwitchTile(
                icon: Icons.campaign,
                title: 'Marketing Emails',
                subtitle: 'Receive promotional content',
                value: _marketingEmails,
                onChanged: (value) {
                  setState(() {
                    _marketingEmails = value;
                  });
                },
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon:  Icons.location_on,
                title: 'Location Updates',
                subtitle: 'Notify about location changes',
                value: _locationUpdates,
                onChanged:  (value) {
                  setState(() {
                    _locationUpdates = value;
                  });
                },
              ),
            ]),

            // Business Features
            _buildSectionTitle('Business Features'),
            _buildSettingsCard([
              _buildSettingsTile(
                icon:  Icons.analytics,
                title: 'Analytics',
                subtitle: 'View detailed analytics',
                onTap: () {
                  _showAnalyticsDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.inventory,
                title: 'Inventory Management',
                subtitle: 'Manage your inventory',
                onTap: () {
                  _showInventoryDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.qr_code,
                title:  'QR Code',
                subtitle: 'Generate business QR code',
                onTap: () {
                  _showQRCodeDialog();
                },
              ),
            ]),

            // Support
            _buildSectionTitle('Support'),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle:  'FAQs and guides',
                onTap: () {
                  _showHelpCenterDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.support_agent,
                title: 'Contact Support',
                subtitle: 'Get help from our team',
                onTap: () {
                  _showContactSupportDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons. feedback_outlined,
                title: 'Send Feedback',
                subtitle: 'Share your thoughts',
                onTap: () {
                  _showFeedbackDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.policy,
                title: 'Terms & Privacy',
                subtitle: 'Legal information',
                onTap: () {
                  _showTermsPrivacyDialog();
                },
              ),
            ]),

            // App Settings
            _buildSectionTitle('Application'),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
                onTap: () {
                  _showLanguageDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Version 1.0.0',
                onTap: () {
                  _showAboutDialog();
                },
              ),
            ]),

            // Logout
            Padding(
              padding:  const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton. icon(
                  onPressed:  () {
                    _showLogoutDialog();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:  FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets. symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Align(
        alignment:  Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical:  4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius. circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.blue.shade700,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize:  14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size:  16,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors. blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.blue.shade700,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue.shade700,
      ),
    );
  }

  // Dialog Functions
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Business Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Business Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons. business),
              ),
              controller: TextEditingController(text:  'Business Account'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Contact Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              controller: TextEditingController(text: 'business@gmail.com'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              controller: TextEditingController(text: '+84 123 456 789'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCompanyDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Company Details'),
        content: SingleChildScrollView(
          child:  Column(
            mainAxisSize:  MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Company Name:', 'Business Account Ltd.'),
              _buildInfoRow('Business Type:', 'Retail & Service'),
              _buildInfoRow('Tax ID:', '0123456789'),
              _buildInfoRow('Registration:', '01/01/2020'),
              _buildInfoRow('Address:', '123 Business Street, City'),
              const SizedBox(height: 16),
              const Text(
                'Description:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A leading business providing quality services and products to customers across multiple locations.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors. grey.shade700,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator. pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
            ),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:  const TextStyle(
                fontSize:  14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Business Verification'),
        content: Column(
          mainAxisSize:  MainAxisSize.min,
          children: [
            Icon(
              Icons.verified,
              size: 64,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height:  16),
            const Text(
              'Verify Your Business',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Get a verified badge to increase trust and visibility.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors. blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Required Documents:',
                    style:  TextStyle(
                      fontSize:  14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRequirementItem('Business Registration Certificate'),
                  _buildRequirementItem('Tax Identification Number'),
                  _buildRequirementItem('Proof of Address'),
                  _buildRequirementItem('Owner ID Document'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed:  () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
            ),
            child: const Text('Start Verification'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color:  Colors.blue.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Plans'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSubscriptionPlan(
                'Free',
                '\$0',
                'per month',
                [
                  'Up to 5 locations',
                  'Basic analytics',
                  '2 sub accounts',
                  'Email support',
                ],
                Colors.grey,
                true,
              ),
              const SizedBox(height: 12),
              _buildSubscriptionPlan(
                'Professional',
                '\$29',
                'per month',
                [
                  'Up to 25 locations',
                  'Advanced analytics',
                  '10 sub accounts',
                  'Priority support',
                  'Custom branding',
                ],
                Colors.blue,
                false,
              ),
              const SizedBox(height: 12),
              _buildSubscriptionPlan(
                'Enterprise',
                '\$99',
                'per month',
                [
                  'Unlimited locations',
                  'Full analytics suite',
                  'Unlimited sub accounts',
                  '24/7 support',
                  'API access',
                  'Dedicated account manager',
                ],
                Colors.purple,
                false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed:  () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlan(
    String name,
    String price,
    String period,
    List<String> features,
    Color color,
    bool isCurrent,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCurrent ? color : Colors.grey.shade300,
          width: isCurrent ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:  FontWeight.bold,
                  color: color,
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical:  4),
                  decoration:  BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child:  Text(
                  period,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey. shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      size: 16,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
          if (! isCurrent) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                ),
                child: const Text('Upgrade'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons. lock_outline),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration:  InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator. pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password changed successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style:  ElevatedButton.styleFrom(
              backgroundColor: Colors.blue. shade700,
            ),
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Settings'),
        content: Column(
          mainAxisSize:  MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Two-Factor Authentication'),
              subtitle: const Text('Add an extra layer of security'),
              value: false,
              onChanged: (value) {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.devices),
              title: const Text('Active Sessions'),
              subtitle: const Text('3 devices'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons. history),
              title: const Text('Login History'),
              subtitle: const Text('View recent login activity'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
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

  void _showPaymentMethodsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Methods'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPaymentMethodItem(
              Icons.credit_card,
              'Visa ending in 1234',
              'Expires 12/25',
              true,
            ),
            _buildPaymentMethodItem(
              Icons.account_balance,
              'Bank Account',
              'Account ending in 5678',
              false,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton. icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add Payment Method'),
              ),
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

  Widget _buildPaymentMethodItem(
    IconData icon,
    String title,
    String subtitle,
    bool isPrimary,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isPrimary)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical:  4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child:  Text(
                'Primary',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors. blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAnalyticsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analytics Overview'),
        content: SingleChildScrollView(
          child:  Column(
            mainAxisSize:  MainAxisSize.min,
            children: [
              _buildAnalyticItem('Total Views', '12,345', Icons.visibility, Colors.blue),
              _buildAnalyticItem('Total Clicks', '2,456', Icons.touch_app, Colors.green),
              _buildAnalyticItem('Search Appearances', '45,678', Icons.search, Colors. orange),
              _buildAnalyticItem('Customer Calls', '234', Icons.phone, Colors.purple),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons. bar_chart),
                  label:  const Text('View Detailed Analytics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed:  () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticItem(String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors. grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInventoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inventory Management'),
        content: const Text(
          'Inventory management feature allows you to track and manage your products across all locations.\n\nThis feature is available for Professional and Enterprise plans.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
            ),
            child: const Text('Learn More'),
          ),
        ],
      ),
    );
  }

  void _showQRCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Business QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_2,
                    size: 150,
                    color: Colors. blue.shade700,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scan to view business profile',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors. grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('Download QR Code'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed:  () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help Center'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Frequently Asked Questions: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight. bold,
                ),
              ),
              const SizedBox(height:  12),
              _buildHelpItem(
                'How to add a new location?',
                'Go to Map tab, tap the "+" button, and fill in location details.',
              ),
              _buildHelpItem(
                'How to manage sub accounts?',
                'Navigate to Sub Accounts tab, tap "+" to add new accounts with specific roles.',
              ),
              _buildHelpItem(
                'How to upgrade subscription?',
                'Go to Settings > Subscription and select your desired plan.',
              ),
              _buildHelpItem(
                'How to view analytics?',
                'Access Dashboard for overview or Settings > Analytics for detailed reports.',
              ),
            ],
          ),
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

  Widget _buildHelpItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height:  4),
          Text(
            answer,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.email, color: Colors.blue.shade700),
              title: const Text('Email'),
              subtitle: const Text('support@localizy.com'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.blue.shade700),
              title: const Text('Phone'),
              subtitle: const Text('+84 123 456 789'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons. chat, color: Colors.blue.shade700),
              title: const Text('Live Chat'),
              subtitle:  const Text('Available 24/7'),
              onTap: () {},
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

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration:  InputDecoration(
                labelText: 'Your Feedback',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed:  () {
              Navigator.pop(context);
              ScaffoldMessenger. of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feedback sent successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showTermsPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Privacy'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.article),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.cookie),
                title: const Text('Cookie Policy'),
                trailing: const Icon(Icons. arrow_forward_ios, size:  16),
                onTap: () {},
              ),
            ],
          ),
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

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('English'),
              value: 'en',
              groupValue: 'en',
              onChanged:  (value) {},
            ),
            RadioListTile(
              title: const Text('Tiếng Việt'),
              value: 'vi',
              groupValue: 'en',
              onChanged: (value) {},
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco,
              size: 64,
              color: Colors.blue. shade700,
            ),
            const SizedBox(height: 16),
            const Text(
              'Localizy Business',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Version 1.0.0'),
            const SizedBox(height: 16),
            Text(
              'Business management platform for managing multiple locations, sub accounts, and analytics.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}