import 'package:flutter/material.dart';
import 'package:localizy/screens/account/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../utils/config_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoAnimation;
  final String appName = 'Citea';
  final List<bool> _visibleLetters = [];

  @override
  void initState() {
    super.initState();
    
    // Khởi tạo danh sách hiển thị chữ cái
    _visibleLetters.addAll(List.generate(appName.length, (_) => false));
    
    // Khởi tạo animation cho logo
    _animationController = AnimationController(
      vsync: this,
      duration:  const Duration(milliseconds: 1000),
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    // Bắt đầu animation logo
    _animationController.forward();
    
    // Đợi logo xuất hiện xong
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Animation từng chữ cái
    for (int i = 0; i < appName.length; i++) {
      if (mounted) {
        setState(() {
          _visibleLetters[i] = true;
        });
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    
    // Đợi thêm một chút trước khi chuyển màn hình
    await Future. delayed(const Duration(milliseconds:  800));
    
    // Khởi tạo ứng dụng và chuyển màn hình
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Load các cấu hình cần thiết
      await ConfigManager.initialize();
      
      // Kiểm tra trạng thái đăng nhập
      await SharedPreferences.getInstance();
      
      if (mounted) {
        // Chuyển đến màn hình phù hợp
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
      // Vẫn chuyển màn hình ngay cả khi có lỗi
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin:  Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[700]!,
              Colors.green[500]!,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo với animation
              ScaleTransition(
                scale:  _logoAnimation,
                child:  FadeTransition(
                  opacity: _logoAnimation,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius:  25,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius. circular(35),
                      child: Image.asset(
                        'assets/icon/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback nếu không tìm thấy icon
                          return Icon(
                            Icons.location_on,
                            size:  90,
                            color: Colors. green[700],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Tên ứng dụng với hiệu ứng xuất hiện từng chữ
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(appName.length, (index) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0.0,
                      end: _visibleLetters[index] ?  1.0 : 0.0,
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value. clamp(0.0, 1.0), // Đảm bảo opacity luôn trong khoảng 0.0-1.0
                        child: Transform.translate(
                          offset: Offset(0, -20 * (1 - value)),
                          child: Text(
                            appName[index],
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors. black26,
                                  offset:  Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}