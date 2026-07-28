import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/auth_emblem.dart';
import '../widgets/forgot_password_form.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
import '../widgets/wave_background.dart';

/// Các form dùng chung màn hình xác thực.
enum AuthView { login, register, forgotPassword }

/// Màn hình xác thực: đăng nhập, đăng ký và quên mật khẩu nằm chung một trang,
/// chuyển qua lại bằng hiệu ứng trượt + mờ (không push route mới).
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static const _duration = Duration(milliseconds: 350);

  AuthView _view = AuthView.login;

  /// Chiều trượt của form mới: đi sâu hơn thì vào từ phải, quay lại thì từ trái.
  bool _slideFromRight = true;

  /// Form quên mật khẩu đã gửi email xong → đổi hoạt ảnh ở đầu trang.
  bool _emailSent = false;

  AuthEmblemKind get _emblemKind {
    switch (_view) {
      case AuthView.register:
        return AuthEmblemKind.register;
      case AuthView.forgotPassword:
        return _emailSent
            ? AuthEmblemKind.emailSent
            : AuthEmblemKind.forgotPassword;
      case AuthView.login:
        return AuthEmblemKind.login;
    }
  }

  /// Đăng nhập là gốc; đăng ký và quên mật khẩu là một cấp sâu hơn.
  int _depth(AuthView view) => view == AuthView.login ? 0 : 1;

  void _switchTo(AuthView view) {
    if (view == _view) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _slideFromRight = _depth(view) > _depth(_view);
      _view = view;
      _emailSent = false;
    });
  }

  /// Form mới trượt vào, form cũ chạy cùng animation theo chiều ngược lại
  /// nên trượt ra phía đối diện.
  Widget _buildTransition(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(_slideFromRight ? 0.25 : -0.25, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }

  Widget _buildForm() {
    switch (_view) {
      case AuthView.register:
        return RegisterForm(
          key: const ValueKey(AuthView.register),
          onSwitchToLogin: () => _switchTo(AuthView.login),
        );
      case AuthView.forgotPassword:
        return ForgotPasswordForm(
          key: const ValueKey(AuthView.forgotPassword),
          onBackToLogin: () => _switchTo(AuthView.login),
          onEmailSentChanged: (sent) => setState(() => _emailSent = sent),
        );
      case AuthView.login:
        return LoginForm(
          key: const ValueKey(AuthView.login),
          onSwitchToRegister: () => _switchTo(AuthView.register),
          onSwitchToForgotPassword: () => _switchTo(AuthView.forgotPassword),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Quên mật khẩu không có nút đổi form nào khác nên giữ nút quay lại.
    final showBackButton = _view == AuthView.forgotPassword;

    return PopScope(
      // Đang ở form phụ thì back về đăng nhập thay vì thoát màn hình.
      canPop: _view == AuthView.login,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _switchTo(AuthView.login);
      },
      child: Scaffold(
        body: Stack(
          children: [
            const WaveBackground(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AuthEmblem(kind: _emblemKind),
                      // Hoạt ảnh đã có lề trắng sẵn trong khung vẽ nên gap nhỏ hơn.
                      const SizedBox(height: 24),
                      AnimatedSize(
                        duration: _duration,
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child: AnimatedSwitcher(
                          duration: _duration,
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: _buildTransition,
                          layoutBuilder: (currentChild, previousChildren) =>
                              Stack(
                            alignment: Alignment.topCenter,
                            children: [...previousChildren, ?currentChild],
                          ),
                          child: _buildForm(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: AnimatedOpacity(
                duration: _duration,
                opacity: showBackButton ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !showBackButton,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => _switchTo(AuthView.login),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
