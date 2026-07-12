/// Nhóm role quyết định màn hình chính sau đăng nhập.
enum UserRole { user, validator, business }

/// Người dùng đã đăng nhập (payload từ API auth).
class User {
  const User({
    required this.token,
    required this.email,
    required this.fullName,
    required this.role,
    required this.userId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? '',
      userId: json['userId'] ?? json['id'] ?? '',
    );
  }

  final String token;
  final String email;
  final String fullName;

  /// Role thô từ backend (ví dụ "Validator", "BusinessSubAccount"...).
  final String role;
  final String userId;

  UserRole get roleType {
    final r = role.toLowerCase();
    if (r.contains('validator')) return UserRole.validator;
    if (r.contains('business') || r.contains('subaccount')) {
      return UserRole.business;
    }
    return UserRole.user;
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'email': email,
        'fullName': fullName,
        'role': role,
        'userId': userId,
      };
}
