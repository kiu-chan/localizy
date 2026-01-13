import 'package:flutter/material.dart';
import 'package:localizy/api/auth_api.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import '../main_page.dart';
import '../validator/validator_main_page.dart';
import '../business/business_main_page.dart';
import 'dart:math' as math;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự thay đổi để rebuild UI
    _emailController.addListener(() {
      setState(() {});
    });
    _passwordController.addListener(() {
      setState(() {});
    });
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final user = await AuthService.login(email: email, password: password);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loginSuccess),
          backgroundColor: Colors.green,
        ),
      );

      // Điều hướng dựa trên role trả về từ API (so sánh chữ thường để an toàn)
      final role = user.role.toLowerCase();
      if (role.contains('validator')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ValidatorMainPage(),
          ),
        );
      } else if (role.contains('business')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BusinessMainPage(),
          ),
        );
      } else {
        // default -> user thường / admin / ...
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loginFailed),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations. of(context)!;
    
    return Scaffold(
      body: Stack(
        children: [
          // Wave Background
          const WaveBackground(),
          
          // Login Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black. withOpacity(0.2),
                              blurRadius:  20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child:  ClipOval(
                          child: Image.asset(
                            'assets/icon/logo.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.eco,
                                size: 60,
                                color: Colors. green.shade700,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        l10n. welcomeBack,
                        style:  const TextStyle(
                          fontSize:  32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.loginToContinue,
                        style:  const TextStyle(
                          fontSize:  16,
                          color:  Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child:  Column(
                          children: [
                            TextFormField(
                              controller:  _emailController,
                              focusNode: _emailFocusNode,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: l10n.email,
                                labelStyle: TextStyle(
                                  color:  (_emailFocusNode.hasFocus || _emailController.text. isNotEmpty)
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                                floatingLabelStyle: TextStyle(
                                  color: (_emailFocusNode.hasFocus || _emailController.text. isNotEmpty)
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                                prefixIcon:  Icon(
                                  Icons.email_outlined,
                                  color:  Colors.green.shade700,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.green.shade700,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.pleaseEnterEmail;
                                }
                                if (!value.contains('@')) {
                                  return l10n.invalidEmail;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              focusNode:  _passwordFocusNode,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: l10n.password,
                                labelStyle: TextStyle(
                                  color:  (_passwordFocusNode.hasFocus || _passwordController.text.isNotEmpty)
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                                floatingLabelStyle: TextStyle(
                                  color: (_passwordFocusNode.hasFocus || _passwordController.text.isNotEmpty)
                                      ? Colors. black
                                      : Colors. grey,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outlined,
                                  color: Colors.green.shade700,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.green.shade700,
                                  ),
                                  onPressed:  () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:  BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:  BorderSide(
                                    color: Colors.green.shade700,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.pleaseEnterPassword;
                                }
                                if (value. length < 6) {
                                  return l10n.passwordMinLength;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment:  Alignment.centerRight,
                              child: TextButton(
                                onPressed:  () {
                                  Navigator. push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  l10n. forgotPassword,
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width:  double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green. shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child:  CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        l10n.login,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight:  FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.noAccount,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              l10n.register,
                              style: const TextStyle(
                                color:  Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget hiệu ứng gợn sóng
class WaveBackground extends StatefulWidget {
  const WaveBackground({super.key});

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();
    
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds:  5),
    )..repeat();

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _controller3 = AnimationController(
      vsync:  this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.shade400,
            Colors.green.shade700,
          ],
        ),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller1,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePainter(
                  animationValue: _controller1.value,
                  color: Colors.white. withOpacity(0.08),
                  amplitude: 30,
                  frequency: 1.5,
                  offset: 0,
                ),
                size: Size. infinite,
              );
            },
          ),
          AnimatedBuilder(
            animation: _controller2,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePainter(
                  animationValue: _controller2.value,
                  color: Colors. white.withOpacity(0.06),
                  amplitude: 40,
                  frequency: 1.2,
                  offset: 100,
                ),
                size:  Size.infinite,
              );
            },
          ),
          AnimatedBuilder(
            animation: _controller3,
            builder: (context, child) {
              return CustomPaint(
                painter:  WavePainter(
                  animationValue: _controller3.value,
                  color: Colors.white.withOpacity(0.04),
                  amplitude: 50,
                  frequency: 1.0,
                  offset: 200,
                ),
                size: Size.infinite,
              );
            },
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double amplitude;
  final double frequency;
  final double offset;

  WavePainter({
    required this. animationValue,
    required this.color,
    required this. amplitude,
    required this.frequency,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    
    for (double y = 0; y <= size.height; y += 1) {
      final waveValue = math.sin(
        (y / size.height * 2 * math.pi * frequency) + 
        (animationValue * 2 * math.pi) + 
        (offset / 100)
      ) * amplitude;
      
      path.lineTo(waveValue + size.width / 2, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}