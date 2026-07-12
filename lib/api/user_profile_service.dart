// Tương thích ngược: logic profile đã gộp vào AuthRepository (features/auth/).
// Facade này sẽ bị xóa ở Giai đoạn 6 của lộ trình migrate.
import 'dart:io';

import 'package:localizy/features/auth/data/auth_repository.dart';

class UserProfileService {
  static AuthRepository get _repo => AuthRepository.instance;

  static Future<Map<String, dynamic>> fetchCurrentUserProfile() =>
      _repo.fetchCurrentUserProfile();

  static Future<Map<String, dynamic>> updateProfile({
    String? userId,
    String? name,
    String? dateOfBirth,
    String? phone,
    String? email,
  }) =>
      _repo.updateProfile(
        userId: userId,
        name: name,
        dateOfBirth: dateOfBirth,
        phone: phone,
        email: email,
      );

  static Future<Map<String, dynamic>> uploadAvatar({
    String? userId,
    required File avatarFile,
  }) =>
      _repo.uploadAvatar(userId: userId, avatarFile: avatarFile);
}
