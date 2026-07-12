// Tương thích ngược: logic auth đã chuyển về features/auth/.
// File này chỉ là facade ủy quyền cho AuthRepository và sẽ bị xóa ở
// Giai đoạn 6 của lộ trình migrate (docs/ARCHITECTURE_MIGRATION.md).
// Code mới dùng authProvider / authRepositoryProvider thay vì AuthService.
import 'package:localizy/features/auth/data/auth_repository.dart';
import 'package:localizy/features/auth/domain/user.dart';

export 'package:localizy/features/auth/domain/auth_exception.dart';
export 'package:localizy/features/auth/domain/user.dart';

typedef AuthUser = User;

class AuthService {
  static AuthRepository get _repo => AuthRepository.instance;

  static Future<User> login({
    required String email,
    required String password,
  }) =>
      _repo.login(email: email, password: password);

  static Future<User> register({
    required String email,
    required String fullName,
    required String password,
  }) =>
      _repo.register(email: email, fullName: fullName, password: password);

  static Future<User> googleLogin() => _repo.googleLogin();

  static Future<void> forgotPassword({required String email}) =>
      _repo.forgotPassword(email: email);

  static Future<void> registerFcmToken(String fcmToken) =>
      _repo.registerFcmToken(fcmToken);

  static Future<void> logout() => _repo.logout();

  static Future<String?> getToken() => _repo.getToken();

  static Future<User?> getStoredUser() => _repo.getStoredUser();

  static Future<String?> getStoredUserId() => _repo.getStoredUserId();

  static Future<void> updateStoredUserPayload(
          Map<String, dynamic> newPayload) =>
      _repo.updateStoredUserPayload(newPayload);
}
