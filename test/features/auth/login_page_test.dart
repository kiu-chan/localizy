import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localizy/features/auth/data/auth_repository.dart';
import 'package:localizy/features/auth/domain/auth_exception.dart';
import 'package:localizy/features/auth/presentation/pages/login_page.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepo;

  setUp(() {
    authRepo = MockAuthRepository();
    // AuthNotifier.build() đọc phiên đã lưu — trả null (chưa đăng nhập).
    when(() => authRepo.getStoredUser()).thenAnswer((_) async => null);
    // LoginPage điền sẵn email của lần đăng nhập trước — mặc định chưa có.
    when(() => authRepo.getLastLoginEmail()).thenAnswer((_) async => null);
    when(() => authRepo.clearLastLoginEmail()).thenAnswer((_) async {});
  });

  Future<void> pumpLoginPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginPage(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('hiển thị 2 ô nhập và nút đăng nhập', (tester) async {
    await pumpLoginPage(tester);

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('field rỗng → validation chặn, không gọi login', (tester) async {
    await pumpLoginPage(tester);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verifyNever(() => authRepo.login(
        email: any(named: 'email'), password: any(named: 'password')));
  });

  testWidgets('có email đã lưu → điền sẵn vào ô email', (tester) async {
    when(() => authRepo.getLastLoginEmail())
        .thenAnswer((_) async => 'last@user.com');

    await pumpLoginPage(tester);
    await tester.pump(); // hoàn tất _prefillLastEmail

    expect(find.text('last@user.com'), findsOneWidget);
  });

  testWidgets('nhấn nút X → xoá ô email và quên email đã lưu', (tester) async {
    when(() => authRepo.getLastLoginEmail())
        .thenAnswer((_) async => 'last@user.com');

    await pumpLoginPage(tester);
    await tester.pump();

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(find.text('last@user.com'), findsNothing);
    verify(() => authRepo.clearLastLoginEmail()).called(1);
  });

  testWidgets('nhấn "Register" → đổi sang form đăng ký ngay trong trang',
      (tester) async {
    await pumpLoginPage(tester);
    await tester.pump();

    final toRegister = find.widgetWithText(TextButton, 'Register');
    await tester.ensureVisible(toRegister);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(toRegister);
    await tester.pump();
    // WaveBackground chạy animation vô hạn nên không dùng pumpAndSettle được.
    await tester.pump(const Duration(milliseconds: 500));

    // Không push route mới: vẫn chỉ có một LoginPage trong cây widget.
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Welcome back!'), findsNothing);
    expect(find.byType(TextFormField), findsNWidgets(4));

    // Quay lại đăng nhập bằng nút "Login" ở cuối form đăng ký.
    final toLogin = find.widgetWithText(TextButton, 'Login');
    await tester.ensureVisible(toLogin);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(toLogin);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('nhấn "Forgot password?" → đổi form, còn nút quay lại',
      (tester) async {
    await pumpLoginPage(tester);
    await tester.pump();

    final toForgot = find.widgetWithText(TextButton, 'Forgot password?');
    await tester.ensureVisible(toForgot);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(toForgot);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Reset password'), findsOneWidget);
    expect(find.text('Welcome back!'), findsNothing);

    // Form này không có nút đổi trang nào khác nên giữ nút quay lại.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Welcome back!'), findsOneWidget);
  });

  testWidgets('đăng nhập lỗi → hiện SnackBar với message', (tester) async {
    when(() => authRepo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(AuthException('Sai thông tin đăng nhập'));

    await pumpLoginPage(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret1');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // chạy _handleLogin
    await tester.pump(); // hiện SnackBar

    verify(() => authRepo.login(email: 'a@b.com', password: 'secret1'))
        .called(1);
    expect(find.text('Sai thông tin đăng nhập'), findsOneWidget);
  });
}
