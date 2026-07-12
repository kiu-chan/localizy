import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localizy/core/services/notification_service.dart';
import 'package:localizy/core/theme/app_theme.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/splash_screen.dart';
import 'package:provider/provider.dart';
import 'core/config/config_manager.dart';
import 'utils/language_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ConfigManager.initialize();
  await NotificationService.initialize();

  runApp(
    // ProviderScope (Riverpod) chạy song song với Provider trong quá trình
    // migrate — xem docs/ARCHITECTURE_MIGRATION.md. Provider sẽ gỡ ở Giai đoạn 6.
    ProviderScope(
      child: ChangeNotifierProvider(
        create: (_) => LanguageManager(),
        child: const MyApp(),
      ),
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
          title: 'Citea',
          navigatorKey: navigatorKey,
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
          theme: AppTheme.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
