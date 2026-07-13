import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ngôn ngữ hiện tại của app (thay LanguageManager ChangeNotifier cũ).
///
/// State là [Locale]; mặc định tiếng Pháp, đọc lựa chọn đã lưu từ
/// SharedPreferences khi khởi tạo.
final languageProvider =
    NotifierProvider<LanguageNotifier, Locale>(LanguageNotifier.new);

class LanguageNotifier extends Notifier<Locale> {
  static const _prefsKey = 'language_code';
  static const supportedCodes = ['fr', 'en'];

  @override
  Locale build() {
    _loadSaved();
    return const Locale('fr');
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey) ?? 'fr';
    if (code != state.languageCode) state = Locale(code);
  }

  Future<void> changeLanguage(String languageCode) async {
    if (state.languageCode == languageCode) return;
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, languageCode);
  }

  String getLanguageName(String code) => switch (code) {
        'en' => 'English',
        _ => 'Français',
      };
}
