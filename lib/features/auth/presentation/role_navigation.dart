import 'package:flutter/material.dart';
import 'package:localizy/features/business/presentation/pages/business_main_page.dart';
import 'package:localizy/features/home/presentation/pages/main_page.dart';
import 'package:localizy/features/validator/presentation/pages/validator_main_page.dart';

import '../domain/user.dart';

/// Màn hình chính tương ứng với role của user.
Widget homePageForRole(User user) => switch (user.roleType) {
      UserRole.validator => const ValidatorMainPage(),
      UserRole.business => const BusinessMainPage(),
      UserRole.user => const MainPage(),
    };

/// Điều hướng về màn hình chính theo role sau khi đăng nhập/đăng ký.
void navigateToRoleHome(BuildContext context, User user,
    {bool clearStack = false}) {
  final route = MaterialPageRoute(builder: (_) => homePageForRole(user));
  if (clearStack) {
    Navigator.pushAndRemoveUntil(context, route, (r) => false);
  } else {
    Navigator.pushReplacement(context, route);
  }
}
