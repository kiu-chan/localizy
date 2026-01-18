import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/home/verification/address_verification_flow.dart';
import 'package:localizy/screens/home/parking_payment_page.dart';
import 'package:localizy/screens/home/payment_check_page.dart';
import 'package:localizy/screens/home/address_search_page.dart';
import 'package:localizy/screens/home/history/transaction_history_page.dart';
import 'package:localizy/screens/ocr/license_plate_scanner_screen.dart';
import 'package:localizy/api/slide_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  // Slides loaded from API
  List<HomeSlide> _apiSlides = [];

  // Loading / empty state flags
  bool _isLoading = true;
  bool _noSlides = false;

  @override
  void initState() {
    super.initState();
    _fetchSlides();
    _startAutoSlide();
  }

  Future<void> _fetchSlides() async {
    try {
      final slides = await SlideService.getActiveSlides();
      if (mounted) {
        setState(() {
          _apiSlides = slides;
          _isLoading = false;
          _noSlides = slides.isEmpty;
          if (_apiSlides.isNotEmpty) {
            _currentPage = 0;
            if (_pageController.hasClients) {
              _pageController.jumpToPage(0);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching slides: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _noSlides = true;
          _apiSlides = [];
        });
      }
    }
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final slides = _apiSlides;
      if (slides.isEmpty) return;

      if (_currentPage < slides.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slides = _apiSlides;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Slider
            SizedBox(
              height: 280,
              child: Stack(
                children: [
                  // Three states:
                  // 1) Loading -> show progress indicator
                  // 2) No slides -> show "Đang cập nhật slide"
                  // 3) Has slides -> PageView
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (_noSlides)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      color: Colors.grey.shade200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Đang cập nhật slide',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: slides.length,
                      itemBuilder: (context, index) {
                        final slide = slides[index];
                        return _buildHeaderSlide(
                          l10n: l10n,
                          slide: slide,
                        );
                      },
                    ),

                  // Page Indicator (only when there are slides)
                  if (!_isLoading && !_noSlides)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          slides.length,
                          (index) => _buildPageIndicator(index == _currentPage),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Main Features Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Features Title
                  Text(
                    l10n.mainFeatures,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
                        context: context,
                        icon: Icons.verified_outlined,
                        title: l10n.addressVerification,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddressVerificationFlow(),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context: context,
                        icon: Icons.payment,
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
                        context: context,
                        icon: Icons.receipt_long,
                        title: l10n.paymentCheck,
                        color: Colors.orange,
                        onTap: () {
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

                  // Quick Actions Title
                  Text(
                    l10n.quickActions,
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
                    icon: Icons.history,
                    title: l10n.transactionHistory,
                    description: l10n.viewParkingPaymentHistory,
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionHistoryPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildActionCard(
                    context: context,
                    icon: Icons.camera_alt_outlined,
                    title: l10n.licensePlateScannerOCR,
                    description: l10n.automaticLicensePlateRecognition,
                    color: Colors.red,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LicensePlateScannerScreen(),
                        ),
                      );

                      if (result != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${l10n.licensePlateScanned}:  $result')),
                        );
                      }
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

  Widget _buildHeaderSlide({
    required AppLocalizations l10n,
    required HomeSlide slide,
  }) {
    // If the slide contains an imageUrl, show it as background with an overlay and content text.
    if (slide.imageUrl != null && slide.imageUrl!.isNotEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(slide.imageUrl!),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // dark overlay to ensure text is readable
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.black.withValues(alpha: 0.15),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slide.content.isNotEmpty ? slide.content : l10n.welcomeToLocalizy,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Fallback: gradient + icon + text (used when slide has no image)
    final gradient = [Colors.blue.shade400, Colors.blue.shade700];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(slide.id),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.local_parking,
                size: 60,
                color: Colors.blueAccent,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            slide.content.isNotEmpty ? slide.content : l10n.welcomeToLocalizy,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
        shape: BoxShape.circle,
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
                  color: color.withValues(alpha: 0.1),
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
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