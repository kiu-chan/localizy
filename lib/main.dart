import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/splash_screen.dart';
import 'package:provider/provider.dart';
import 'utils/language_manager.dart';
import 'utils/config_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ConfigManager.initialize();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageManager>(
      builder: (context, languageManager, child) {
        return MaterialApp(
          title: 'Citizen',
          debugShowCheckedModeBanner: false,
          locale: languageManager.locale,
          supportedLocales: const [
            Locale('fr'), // Français
            Locale('en'), // English
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations. delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme:  ThemeData(
            primarySwatch: Colors.green,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}