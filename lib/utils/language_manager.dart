import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager extends ChangeNotifier {
  Locale _locale = const Locale('fr'); // Mặc định là tiếng Pháp

  Locale get locale => _locale;

  LanguageManager() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences. getInstance();
    final languageCode = prefs.getString('language_code') ?? 'fr';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences. getInstance();
    await prefs.setString('language_code', languageCode);
    notifyListeners();
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      default: 
        return 'Français';
    }
  }
}