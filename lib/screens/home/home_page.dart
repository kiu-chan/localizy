import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/home/verification/address_verification_flow.dart';
import 'package:localizy/screens/home/parking_payment_page.dart';
import 'package:localizy/screens/home/payment_check_page.dart';
import 'package:localizy/screens/home/address_search_page.dart';
import 'package:localizy/screens/ocr/license_plate_scanner_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
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
                    Colors.green. shade700,
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
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius:  20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.local_parking,
                      size: 60,
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
                    l10n.smartParkingManagement,
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
                    l10n. mainFeatures,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:  FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Main Features Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.0,
                    children: [
                      _buildFeatureCard(
                        context:  context,
                        icon: Icons.verified_outlined,
                        title: l10n.addressVerification,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:  (context) => const AddressVerificationFlow(),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context: context,
                        icon:  Icons.payment,
                        title: l10n.parkingPayment,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ParkingPaymentPage(),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context:  context,
                        icon: Icons.receipt_long,
                        title: l10n.paymentCheck,
                        color: Colors.orange,
                        onTap:  () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentCheckPage(),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context: context,
                        icon: Icons.search,
                        title: l10n.addressSearch,
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddressSearchPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    l10n. quickActions,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Quick Actions
                  _buildActionCard(
                    context: context,
                    icon: Icons.map_outlined,
                    title: l10n.viewMap,
                    description: l10n.findAndViewParkingLots,
                    color: Colors.teal,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.openMap)),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildActionCard(
                    context: context,
                    icon:  Icons.history,
                    title: l10n.transactionHistory,
                    description:  l10n.viewParkingPaymentHistory,
                    color: Colors.indigo,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content:  Text(l10n.viewTransactionHistory)),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildActionCard(
                    context: context,
                    icon: Icons. camera_alt_outlined,
                    title: l10n.licensePlateScannerOCR,
                    description: l10n.automaticLicensePlateRecognition,
                    color:  Colors.red,
                    onTap: () async {
                      // Navigate to OCR screen
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:  (context) => const LicensePlateScannerScreen(),
                        ),
                      );
                      
                      if (result != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content:  Text('${l10n.licensePlateScanned}:  $result')),
                        );
                      }
                    },
                  ),
                  
                  const SizedBox(height:  24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color. withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
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

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation:  3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:  BorderRadius.circular(16),
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
                      style:  TextStyle(
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