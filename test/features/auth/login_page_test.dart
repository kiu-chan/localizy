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
