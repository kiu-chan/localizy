/// Tài khoản con thuộc một tài khoản Business.
class SubAccount {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String role;
  final bool isActive;
  final String parentBusinessId;
  final String createdAt;

  SubAccount({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.parentBusinessId,
    required this.createdAt,
  });

  factory SubAccount.fromJson(Map<String, dynamic> json) {
    return SubAccount(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      // API trả về field 'name'
      fullName: json['name'] ?? json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'SubAccount',
      isActive: json['isActive'] == null ? true : (json['isActive'] == true),
      parentBusinessId: json['parentBusinessId']?.toString() ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  SubAccount copyWith({
    String? fullName,
    String? email,
    String? phone,
  }) {
    return SubAccount(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role,
      isActive: isActive,
      parentBusinessId: parentBusinessId,
      createdAt: createdAt,
    );
  }
}
