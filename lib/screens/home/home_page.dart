import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
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

  // Slides loaded from API or cache
  List<HomeSlide> _apiSlides = [];

  // Loading / empty state flags
  bool _isLoading = true;
  bool _noSlides = false;

  @override
  void initState() {
    super.initState();
    _loadSlidesWithCache();
    _startAutoSlide();
  }

  Future<void> _loadSlidesWithCache() async {
    // 1. Hiển thị cache ngay lập tức (nếu có)
    final cached = await SlideService.getCachedSlides();
    if (mounted && cached.isNotEmpty) {
      setState(() {
        _apiSlides = cached;
        _isLoading = false;
        _noSlides = false;
      });
    }

    // 2. Fetch dữ liệu mới ở nền, replace khi xong
    await _fetchSlides();
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
      if (mounted && _apiSlides.isEmpty) {
        setState(() {
          _isLoading = false;
          _noSlides = true;
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
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Slider
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              child: SizedBox(
              height: 290,
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
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Colors.white70,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Đang cập nhật slide',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
            ),

            // Main Features Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Features Title
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A73E8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.mainFeatures,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Main Features Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.0,
                    children: [
                      _buildFeatureCard(
                        context: context,
                        icon: Icons.verified_outlined,
                        title: l10n.addressVerification,
                        color: const Color(0xFF4285F4),
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
                        icon: Icons.payment_outlined,
                        title: l10n.parkingPayment,
                        color: const Color(0xFF00BFA5),
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
                        icon: Icons.receipt_long_outlined,
                        title: l10n.paymentCheck,
                        color: const Color(0xFF7C4DFF),
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
                        icon: Icons.search_rounded,
                        title: l10n.addressSearch,
                        color: const Color(0xFF00B0FF),
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
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A73E8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.quickActions,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildActionCard(
                    context: context,
                    icon: Icons.history,
                    title: l10n.transactionHistory,
                    description: l10n.viewParkingPaymentHistory,
                    color: const Color(0xFF4285F4),
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
                    color: const Color(0xFF4285F4),
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: slide.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade300),
              errorWidget: (context, url, error) => Container(color: Colors.grey.shade300),
            ),
            Container(
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
          ],
        ),
      );
    }

    // Fallback: gradient + icon + text (used when slide has no image)
    const gradient = [Color(0xFF1565C0), Color(0xFF42A5F5)];

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
              child: const Icon(
                Icons.local_parking_rounded,
                size: 60,
                color: Color(0xFF1A73E8),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withValues(alpha: 0.08),
        highlightColor: color.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 26, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3142),
                  height: 1.3,
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withValues(alpha: 0.08),
        highlightColor: color.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9AA0B4),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey[350]),
            ],
          ),
        ),
      ),
    );
  }
}