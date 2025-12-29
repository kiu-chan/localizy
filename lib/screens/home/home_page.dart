import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
        backgroundColor: Colors.green. shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child:  Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.shade400,
                    Colors.green.shade700,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black. withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child:  Icon(
                      Icons.local_parking,
                      size:  60,
                      color: Colors. green.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.welcomeToLocalizy,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize:  28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quản lý đỗ xe thông minh',
                    style: const TextStyle(
                      fontSize:  16,
                      color:  Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Features Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  
                  Text(
                    'Chức năng chính',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:  FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Main Features Grid
                  GridView. count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.0, // Changed from 1.1 to 1.0
                    children: [
                      _buildFeatureCard(
                        context:  context,
                        icon: Icons.verified_outlined,
                        title: 'Xác minh địa chỉ',
                        color: Colors.blue,
                        onTap: () {
                          // Navigate to address verification screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chức năng xác minh địa chỉ')),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context: context,
                        icon: Icons.payment,
                        title: 'Thanh toán đỗ xe',
                        color: Colors.green,
                        onTap: () {
                          // Navigate to parking payment screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chức năng thanh toán đỗ xe')),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context: context,
                        icon: Icons.receipt_long,
                        title: 'Kiểm tra thanh toán',
                        color: Colors. orange,
                        onTap: () {
                          // Navigate to payment check screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kiểm tra thanh toán đỗ xe')),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context:  context,
                        icon: Icons.search,
                        title: 'Tìm kiếm địa chỉ',
                        color: Colors.purple,
                        onTap: () {
                          // Navigate to address search screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chức năng tìm kiếm địa chỉ')),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Thao tác nhanh',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors. grey[800],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Quick Actions
                  _buildActionCard(
                    context: context,
                    icon: Icons. map_outlined,
                    title: 'Xem bản đồ',
                    description: 'Tìm kiếm và xem vị trí bãi đỗ xe',
                    color: Colors.teal,
                    onTap: () {
                      // Navigate to map screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content:  Text('Mở bản đồ')),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildActionCard(
                    context: context,
                    icon:  Icons.history,
                    title: 'Lịch sử giao dịch',
                    description:  'Xem lịch sử thanh toán đỗ xe',
                    color: Colors.indigo,
                    onTap: () {
                      // Navigate to transaction history screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Xem lịch sử giao dịch')),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildActionCard(
                    context: context,
                    icon: Icons.camera_alt_outlined,
                    title: 'Quét biển số xe (OCR)',
                    description: 'Nhận diện biển số xe tự động',
                    color:  Colors.red,
                    onTap:  () {
                      // Navigate to OCR screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mở camera quét biển số')),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Feature card for grid view (main features)
  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), // Reduced padding
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Added to prevent overflow
            children: [
              Container(
                padding: const EdgeInsets.all(14), // Reduced from 16
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32, // Reduced from 36
                  color: color,
                ),
              ),
              const SizedBox(height: 10), // Reduced from 12
              Flexible( // Added Flexible to prevent text overflow
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2, // Added max lines
                  overflow: TextOverflow. ellipsis, // Added overflow handling
                  style: const TextStyle(
                    fontSize: 13, // Reduced from 14
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Action card for list view (quick actions)
  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color. withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:  Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:  FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors. grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}