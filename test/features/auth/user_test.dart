import 'package:flutter_test/flutter_test.dart';
import 'package:localizy/features/auth/domain/user.dart';

void main() {
  group('User.roleType', () {
    User withRole(String role) => User(
          token: 't',
          email: 'e',
          fullName: 'n',
          role: role,
          userId: '1',
        );

    test('validator → UserRole.validator (không phân biệt hoa thường)', () {
      expect(withRole('Validator').roleType, UserRole.validator);
      expect(withRole('VALIDATOR').roleType, UserRole.validator);
    });

    test('business → UserRole.business', () {
      expect(withRole('Business').roleType, UserRole.business);
    });

    test('subaccount cũng ánh xạ về business', () {
      expect(withRole('BusinessSubAccount').roleType, UserRole.business);
      expect(withRole('SubAccount').roleType, UserRole.business);
    });

    test('role khác/rỗng → UserRole.user', () {
      expect(withRole('Member').roleType, UserRole.user);
      expect(withRole('').roleType, UserRole.user);
    });
  });

  group('User.fromJson', () {
    test('đọc userId từ field id nếu không có userId', () {
      final u = User.fromJson({
        'token': 'abc',
        'email': 'a@b.com',
        'fullName': 'Alice',
        'role': 'Validator',
        'id': 'u-99',
      });
      expect(u.userId, 'u-99');
      expect(u.email, 'a@b.com');
      expect(u.roleType, UserRole.validator);
    });

    test('thiếu field → giá trị rỗng, không ném lỗi', () {
      final u = User.fromJson({});
      expect(u.token, '');
      expect(u.role, '');
      expect(u.roleType, UserRole.user);
    });

    test('toJson round-trip giữ nguyên field', () {
      final u = User.fromJson({
        'token': 't',
        'email': 'e',
        'fullName': 'f',
        'role': 'Business',
        'userId': '7',
      });
      expect(u.toJson(), {
        'token': 't',
        'email': 'e',
        'fullName': 'f',
        'role': 'Business',
        'userId': '7',
      });
    });
  });
}
