import 'package:flutter/material.dart';
import '../../screens/account/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _autoApproval = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            fontWeight: FontWeight. bold,
            color: Colors. white,
          ),
        ),
        backgroundColor: Colors.green. shade700,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.green.shade700,
                    Colors.green.shade500,
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors. green.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Validator Admin',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'admin@gmail.com',
                    style: TextStyle(
                      fontSize:  14,
                      color:  Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton. icon(
                    onPressed:  () {
                      _showEditProfileDialog();
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Chỉnh sửa hồ sơ'),
                    style: ElevatedButton. styleFrom(
                      backgroundColor:  Colors.white,
                      foregroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Account Settings
            _buildSectionTitle('Tài khoản'),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons.person_outline,
                title: 'Thông tin cá nhân',
                subtitle:  'Cập nhật thông tin cá nhân',
                onTap: () {
                  _showPersonalInfoDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons. lock_outline,
                title: 'Đổi mật khẩu',
                subtitle:  'Thay đổi mật khẩu đăng nhập',
                onTap: () {
                  _showChangePasswordDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: 'admin@gmail.com',
                onTap: () {},
              ),
            ]),

            // Notification Settings
            _buildSectionTitle('Thông báo'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Thông báo đẩy',
                subtitle: 'Nhận thông báo về yêu cầu mới',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons. email_outlined,
                title:  'Thông báo Email',
                subtitle: 'Nhận email về hoạt động quan trọng',
                value:  _emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
              ),
            ]),

            // Work Settings
            _buildSectionTitle('Cài đặt công việc'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.auto_awesome,
                title: 'Tự động duyệt',
                subtitle:  'Tự động duyệt yêu cầu đơn giản',
                value: _autoApproval,
                onChanged: (value) {
                  setState(() {
                    _autoApproval = value;
                  });
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon:  Icons.access_time,
                title: 'Giờ làm việc',
                subtitle: '08:00 - 17:00',
                onTap: () {
                  _showWorkingHoursDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.bar_chart,
                title: 'Thống kê',
                subtitle:  'Xem thống kê công việc',
                onTap: () {
                  _showStatisticsDialog();
                },
              ),
            ]),

            // App Settings
            _buildSectionTitle('Ứng dụng'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: 'Chế độ tối',
                subtitle: 'Bật chế độ giao diện tối',
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
              ),
              const Divider(height:  1),
              _buildSettingsTile(
                icon:  Icons.language,
                title: 'Ngôn ngữ',
                subtitle: 'Tiếng Việt',
                onTap: () {
                  _showLanguageDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'Về ứng dụng',
                subtitle: 'Phiên bản 1.0.0',
                onTap: () {
                  _showAboutDialog();
                },
              ),
            ]),

            // Support
            _buildSectionTitle('Hỗ trợ'),
            _buildSettingsCard([
              _buildSettingsTile(
                icon:  Icons.help_outline,
                title: 'Trợ giúp',
                subtitle: 'Câu hỏi thường gặp và hướng dẫn',
                onTap: () {
                  _showHelpDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons. feedback_outlined,
                title: 'Phản hồi',
                subtitle: 'Gửi phản hồi cho chúng tôi',
                onTap: () {
                  _showFeedbackDialog();
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Chính sách bảo mật',
                subtitle: 'Xem chính sách bảo mật',
                onTap: () {
                  _showPrivacyPolicyDialog();
                },
              ),
            ]),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showLogoutDialog();
                  },
                  icon:  const Icon(Icons.logout),
                  label: const Text(
                    'Đăng xuất',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
      padding:  const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child:  Align(
        alignment: Alignment.centerLeft,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow:  [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
          color: Colors.green.shade50,
          borderRadius: BorderRadius. circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.green.shade700,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight. w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color:  Colors.grey.shade400,
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
          color: Colors. green.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.green.shade700,
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
          color: Colors.grey. shade600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors. green.shade700,
      ),
    );
  }

  // Dialog Functions
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa hồ sơ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text:  'Validator Admin'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: '0123456789'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã cập nhật hồ sơ'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showPersonalInfoDialog() {
    showDialog(
      context:  context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin cá nhân'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Họ và tên:', 'Validator Admin'),
            _buildInfoRow('Email:', 'admin@gmail.com'),
            _buildInfoRow('Số điện thoại:', '0123456789'),
            _buildInfoRow('Vai trò:', 'Validator'),
            _buildInfoRow('Ngày tham gia:', '01/01/2026'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
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

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText:  'Mật khẩu hiện tại',
                border:  OutlineInputBorder(),
                prefixIcon: Icon(Icons. lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger. of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã đổi mật khẩu thành công'),
                  backgroundColor:  Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: const Text('Đổi mật khẩu'),
          ),
        ],
      ),
    );
  }

  void _showWorkingHoursDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Giờ làm việc'),
        content: Column(
          mainAxisSize: MainAxisSize. min,
          children: [
            ListTile(
              title: const Text('Giờ bắt đầu'),
              subtitle: const Text('08:00'),
              trailing: const Icon(Icons.access_time),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Giờ kết thúc'),
              subtitle: const Text('17:00'),
              trailing: const Icon(Icons.access_time),
              onTap:  () {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showStatisticsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thống kê công việc'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Tổng yêu cầu xử lý:', '60'),
            _buildStatRow('Đã hoàn thành:', '45'),
            _buildStatRow('Đang xử lý:', '12'),
            _buildStatRow('Từ chối:', '3'),
            const Divider(),
            _buildStatRow('Tỷ lệ hoàn thành:', '75%'),
            _buildStatRow('Thời gian trung bình:', '2. 5 giờ'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:  [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Tiếng Việt'),
              value: 'vi',
              groupValue: 'vi',
              onChanged:  (value) {},
            ),
            RadioListTile(
              title: const Text('English'),
              value: 'en',
              groupValue: 'vi',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Về ứng dụng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco,
              size: 64,
              color: Colors.green.shade700,
            ),
            const SizedBox(height:  16),
            const Text(
              'Localizy Validator',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight. bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Phiên bản 1.0.0'),
            const SizedBox(height: 16),
            Text(
              'Ứng dụng dành cho Validator quản lý và xác thực địa điểm trên hệ thống Localizy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color:  Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trợ giúp'),
        content: SingleChildScrollView(
          child:  Column(
            mainAxisSize:  MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment. start,
            children: [
              const Text(
                'Câu hỏi thường gặp:',
                style:  TextStyle(
                  fontSize:  16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height:  12),
              _buildHelpItem(
                'Làm thế nào để duyệt yêu cầu? ',
                'Vào mục "Yêu cầu", chọn yêu cầu cần xử lý, sau đó nhấn nút "Duyệt" hoặc "Từ chối".',
              ),
              _buildHelpItem(
                'Làm thế nào để thêm lịch làm việc?',
                'Vào mục "Lịch làm việc", chọn ngày, sau đó nhấn nút "+" để thêm lịch mới.',
              ),
              _buildHelpItem(
                'Làm thế nào để xem thống kê?',
                'Vào mục "Dashboard" để xem tổng quan hoặc "Cài đặt" > "Thống kê" để xem chi tiết.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
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
          const SizedBox(height: 4),
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

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gửi phản hồi'),
        content: Column(
          mainAxisSize: MainAxisSize. min,
          children: const [
            TextField(
              decoration: InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nội dung phản hồi',
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
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator. pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã gửi phản hồi thành công'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton. styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chính sách bảo mật'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Localizy cam kết bảo vệ thông tin cá nhân của bạn. '
                'Chúng tôi thu thập và sử dụng thông tin của bạn một cách có trách nhiệm.\n\n'
                '1. Thu thập thông tin\n'
                'Chúng tôi thu thập thông tin cần thiết để cung cấp dịch vụ tốt nhất.\n\n'
                '2. Sử dụng thông tin\n'
                'Thông tin được sử dụng để cải thiện trải nghiệm người dùng.\n\n'
                '3. Bảo mật\n'
                'Chúng tôi áp dụng các biện pháp bảo mật tiên tiến.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey. shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất? '),
        actions: [
          TextButton(
            onPressed:  () => Navigator.pop(context),
            child: const Text('Hủy'),
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
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}