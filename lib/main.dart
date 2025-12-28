import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'screens/login_page.dart';
import 'utils/language_manager.dart';
import 'utils/config_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await ConfigManager.initialize();
  
  // Initialize Google Maps cho iOS
  if (Platform.isIOS) {
    await _initializeGoogleMapsIOS();
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageManager(),
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeGoogleMapsIOS() async {
  const platform = MethodChannel('com.cameroon.localizy/config');
  try {
    final result = await platform.invokeMethod('setGoogleMapsApiKey', {
      'apiKey': ConfigManager.googleMapsApiKeyIOS,
    });
    debugPrint('Google Maps iOS initialized:  $result');
  } catch (e) {
    debugPrint('Failed to initialize Google Maps for iOS: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageManager>(
      builder: (context, languageManager, child) {
        return MaterialApp(
          title: 'Localizy',
          debugShowCheckedModeBanner: false,
          locale: languageManager.locale,
          supportedLocales: const [
            Locale('fr'), // Français
            Locale('en'), // English
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            primarySwatch: Colors. green,
            visualDensity: VisualDensity. adaptivePlatformDensity,
          ),
          home: const LoginPage(),
        );
      },
    );
  }
}