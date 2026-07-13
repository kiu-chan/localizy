import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localizy/features/settings/presentation/providers/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  test('mặc định là tiếng Pháp khi chưa lưu lựa chọn', () async {
    SharedPreferences.setMockInitialValues({});
    final container = makeContainer();

    expect(container.read(languageProvider).languageCode, 'fr');
  });

  test('đọc ngôn ngữ đã lưu từ SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({'language_code': 'en'});
    final container = makeContainer();

    // build() trả 'fr' trước, _loadSaved() cập nhật bất đồng bộ.
    expect(container.read(languageProvider).languageCode, 'fr');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(container.read(languageProvider).languageCode, 'en');
  });

  test('changeLanguage cập nhật state và lưu vào prefs', () async {
    SharedPreferences.setMockInitialValues({});
    final container = makeContainer();

    await container.read(languageProvider.notifier).changeLanguage('en');

    expect(container.read(languageProvider).languageCode, 'en');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('language_code'), 'en');
  });

  test('changeLanguage bỏ qua nếu trùng ngôn ngữ hiện tại', () async {
    SharedPreferences.setMockInitialValues({});
    final container = makeContainer();

    await container.read(languageProvider.notifier).changeLanguage('fr');
    expect(container.read(languageProvider).languageCode, 'fr');
  });

  test('getLanguageName trả tên hiển thị đúng', () {
    SharedPreferences.setMockInitialValues({});
    final container = makeContainer();
    final notifier = container.read(languageProvider.notifier);

    expect(notifier.getLanguageName('en'), 'English');
    expect(notifier.getLanguageName('fr'), 'Français');
    expect(notifier.getLanguageName('xx'), 'Français');
  });
}
