import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'dart:math' as math;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    final l10n = AppLocalizations.of(context)!;

    if (! _agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n. pleaseAgreeToTerms),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:  Text(l10n.registerSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Wave Background
          const WaveBackground(),
          
          // Register Content
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:  const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons. arrow_back, color: Colors. white),
                        onPressed:  () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding:  const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child:  Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors. white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black. withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/icon/logo.png',
                                  width: 80,
                                  height: 80,
                                  fit:  BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.eco,
                                      size: 60,
                                      color: Colors.green.shade700,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              l10n.createAccount,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.register,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Container(
                              padding: const EdgeInsets. all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Name Field
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: l10n.fullName,
                                      prefixIcon:  Icon(
                                        Icons.person_outlined,
                                        color: Colors.green.shade700,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:  BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.green. shade700,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.pleaseEnterName;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Email Field
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration:  InputDecoration(
                                      labelText: l10n.email,
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: Colors.green.shade700,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder:  OutlineInputBorder(
                                        borderRadius: BorderRadius. circular(12),
                                        borderSide: BorderSide(
                                          color: Colors. green.shade700,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.pleaseEnterEmail;
                                      }
                                      if (! value.contains('@')) {
                                        return l10n.invalidEmail;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Password Field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: !_isPasswordVisible,
                                    decoration: InputDecoration(
                                      labelText: l10n.password,
                                      prefixIcon:  Icon(
                                        Icons. lock_outlined,
                                        color: Colors.green.shade700,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.green.shade700,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible = !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color:  Colors.green.shade700,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.pleaseEnterPassword;
                                      }
                                      if (value.length < 6) {
                                        return l10n.passwordMinLength;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height:  16),
                                  
                                  // Confirm Password Field
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: !_isConfirmPasswordVisible,
                                    decoration: InputDecoration(
                                      labelText: l10n. confirmPassword,
                                      prefixIcon: Icon(
                                        Icons.lock_outlined,
                                        color: Colors.green.shade700,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isConfirmPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.green.shade700,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder:  OutlineInputBorder(
                                        borderRadius: BorderRadius. circular(12),
                                        borderSide: BorderSide(
                                          color: Colors. green.shade700,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.pleaseConfirmPassword;
                                      }
                                      if (value != _passwordController.text) {
                                        return l10n. passwordsDoNotMatch;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Terms Checkbox
                                  Row(
                                    children:  [
                                      Checkbox(
                                        value: _agreeToTerms,
                                        onChanged: (value) {
                                          setState(() {
                                            _agreeToTerms = value ??  false;
                                          });
                                        },
                                        activeColor: Colors.green.shade700,
                                      ),
                                      Expanded(
                                        child:  Text(
                                          l10n.agreeToTerms,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Register Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null :  _handleRegister,
                                      style: ElevatedButton. styleFrom(
                                        backgroundColor: Colors.green.shade700,
                                        foregroundColor:  Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 24,
                                              width:  24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth:  2,
                                              ),
                                            )
                                          : Text(
                                              l10n.register,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.alreadyHaveAccount,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                TextButton(
                                  onPressed:  () {
                                    Navigator. pop(context);
                                  },
                                  child: Text(
                                    l10n.login,
                                    style: const TextStyle(
                                      color: Colors.white,
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
    
    // Tạo 3 animation controller với tốc độ khác nhau
    _controller1 = AnimationController(
      vsync: this,
      duration:  const Duration(seconds: 5),
    )..repeat();

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();

    _controller3 = AnimationController(
      vsync: this,
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.shade400,
            Colors.green.shade700,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Sóng thứ nhất
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
          // Sóng thứ hai
          AnimatedBuilder(
            animation: _controller2,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePainter(
                  animationValue:  _controller2.value,
                  color: Colors.white.withOpacity(0.06),
                  amplitude: 40,
                  frequency: 1.2,
                  offset: 100,
                ),
                size:  Size.infinite,
              );
            },
          ),
          // Sóng thứ ba
          AnimatedBuilder(
            animation: _controller3,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePainter(
                  animationValue:  _controller3.value,
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

// Custom Painter để vẽ sóng
class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double amplitude;
  final double frequency;
  final double offset;

  WavePainter({
    required this.animationValue,
    required this.color,
    required this.amplitude,
    required this. frequency,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Bắt đầu từ góc trên bên trái
    path.moveTo(0, 0);
    
    // Vẽ từ trên xuống với nhiều sóng
    for (double y = 0; y <= size.height; y += 1) {
      // Tính toán giá trị x với hiệu ứng sóng
      final waveValue = math.sin(
        (y / size.height * 2 * math.pi * frequency) +
            (animationValue * 2 * math.pi) +
            (offset / 100)
      ) * amplitude;

      path.lineTo(waveValue + size.width / 2, y);
    }

    // Hoàn thành path
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