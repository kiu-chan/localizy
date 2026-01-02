import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'dart:math' as math;

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    if (_formKey. currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Wave Background
          const WaveBackground(),
          
          // Forgot Password Content
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
                    child:  SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: _emailSent
                          ? _buildSuccessView()
                          : _buildFormView(),
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

  Widget _buildFormView() {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment. center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow:  [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child:  Icon(
              Icons.lock_reset,
              size: 60,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            l10n. resetPassword,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              l10n.resetPasswordDescription,
              textAlign:  TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color:  Colors.white70,
              ),
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
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius:  20,
                  offset:  const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                TextFormField(
                  controller:  _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors. green.shade700,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                    if (value == null || value. isEmpty) {
                      return l10n.pleaseEnterEmail;
                    }
                    if (!value.contains('@')) {
                      return l10n. invalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors. green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius. circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors. white,
                              strokeWidth:  2,
                            ),
                          )
                        : Text(
                            l10n. sendRequest,
                            style:  const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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

  Widget _buildSuccessView() {
    final l10n = AppLocalizations. of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
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
            Icons. mark_email_read,
            size: 60,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 40),
        Text(
          l10n.checkEmail,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets. symmetric(horizontal: 32),
          child: Text(
            '${l10n.checkEmailDescription} ${_emailController.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors. white70,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Container(
          padding:  const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:  Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors. green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius. circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    l10n.backToLogin,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight. bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _emailSent = false;
                  });
                },
                child: Text(
                  l10n.sendAgain,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
    path.lineTo(size.width, size. height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}