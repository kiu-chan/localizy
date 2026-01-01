import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import '../main_page.dart';

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
    _emailFocusNode. dispose();
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
    _passwordController. addListener(() {
      setState(() {});
    });
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  void _handleLogin() async {
    if (_formKey.currentState! .validate()) {
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
            content:  Text(AppLocalizations.of(context)!.loginSuccess),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body:  Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin:  Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors. green.shade400,
              Colors.green.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment:  MainAxisAlignment.center,
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
                      child:  ClipOval(
                        child: Image.asset(
                          'assets/icon/logo. png',
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
                      l10n.welcomeBack,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight. bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.loginToContinue,
                      style: const TextStyle(
                        fontSize:  16,
                        color:  Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius. circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children:  [
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: l10n.email,
                              labelStyle: TextStyle(
                                color: (_emailFocusNode.hasFocus || _emailController.text.isNotEmpty)
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                              floatingLabelStyle: TextStyle(
                                color: (_emailFocusNode. hasFocus || _emailController. text.isNotEmpty)
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.green.shade700,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
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
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              labelStyle: TextStyle(
                                color: (_passwordFocusNode.hasFocus || _passwordController.text.isNotEmpty)
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                              floatingLabelStyle: TextStyle(
                                color: (_passwordFocusNode.hasFocus || _passwordController.text.isNotEmpty)
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outlined,
                                color: Colors. green.shade700,
                              ),
                              suffixIcon:  IconButton(
                                icon:  Icon(
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
                              if (value.length < 6) {
                                return l10n.passwordMinLength;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordPage(),
                                  ),
                                );
                              },
                              child: Text(
                                l10n.forgotPassword,
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight. w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed:  _isLoading ? null : _handleLogin,
                              style:  ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
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
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  :  Text(
                                      l10n.login,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
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
                          style: const TextStyle(color:  Colors.white70),
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
                          child:  Text(
                            l10n.register,
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
      ),
    );
  }
}