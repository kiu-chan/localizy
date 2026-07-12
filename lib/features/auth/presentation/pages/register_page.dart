import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/l10n/app_localizations.dart';

import '../../domain/auth_exception.dart';
import '../providers/auth_provider.dart';
import '../role_navigation.dart';
import '../widgets/wave_background.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
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

  Future<void> _handleRegister() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseAgreeToTerms),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await ref.read(authProvider.notifier).register(
            email: _emailController.text.trim(),
            fullName: _nameController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.registerSuccess),
          backgroundColor: Colors.green,
        ),
      );
      navigateToRoleHome(context, user, clearStack: true);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.registerFailed), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          const WaveBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
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
                                    color: Colors.black.withValues(alpha: 0.2),
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
                                  fit: BoxFit.cover,
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
                              padding: const EdgeInsets.all(24),
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
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: _fieldDecoration(
                                      labelText: l10n.fullName,
                                      prefixIcon: Icons.person_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.pleaseEnterName;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: _fieldDecoration(
                                      labelText: l10n.email,
                                      prefixIcon: Icons.email_outlined,
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
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: !_isPasswordVisible,
                                    decoration: _fieldDecoration(
                                      labelText: l10n.password,
                                      prefixIcon: Icons.lock_outlined,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.green.shade700,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          });
                                        },
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
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: !_isConfirmPasswordVisible,
                                    decoration: _fieldDecoration(
                                      labelText: l10n.confirmPassword,
                                      prefixIcon: Icons.lock_outlined,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isConfirmPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.green.shade700,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isConfirmPasswordVisible =
                                                !_isConfirmPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.pleaseConfirmPassword;
                                      }
                                      if (value != _passwordController.text) {
                                        return l10n.passwordsDoNotMatch;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _agreeToTerms,
                                        onChanged: (value) {
                                          setState(() {
                                            _agreeToTerms = value ?? false;
                                          });
                                        },
                                        activeColor: Colors.green.shade700,
                                      ),
                                      Expanded(
                                        child: Text(
                                          l10n.agreeToTerms,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _handleRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade700,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                          : Text(
                                              l10n.register,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.alreadyHaveAccount,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
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

  InputDecoration _fieldDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(prefixIcon, color: Colors.green.shade700),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green.shade700, width: 2),
      ),
    );
  }
}
