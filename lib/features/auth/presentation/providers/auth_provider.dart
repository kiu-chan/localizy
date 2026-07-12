import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/core/services/notification_service.dart';

import '../../data/auth_repository.dart';
import '../../domain/user.dart';

/// Nguồn sự thật duy nhất về phiên đăng nhập.
///
/// - `AsyncData(user)` — đã đăng nhập
/// - `AsyncData(null)` — chưa đăng nhập
/// - `AsyncLoading` — đang đọc phiên đã lưu (lúc mở app)
final authProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() =>
      ref.watch(authRepositoryProvider).getStoredUser();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<User> login({required String email, required String password}) async {
    final user = await _repo.login(email: email, password: password);
    _onSignedIn(user);
    return user;
  }

  Future<User> register({
    required String email,
    required String fullName,
    required String password,
  }) async {
    final user = await _repo.register(
        email: email, fullName: fullName, password: password);
    _onSignedIn(user);
    return user;
  }

  Future<User> googleLogin() async {
    final user = await _repo.googleLogin();
    _onSignedIn(user);
    return user;
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncData(null);
  }

  void _onSignedIn(User user) {
    state = AsyncData(user);
    // Đăng ký FCM token lên server — non-blocking, lỗi không chặn đăng nhập.
    unawaited(NotificationService.getAndRegisterToken());
  }
}
