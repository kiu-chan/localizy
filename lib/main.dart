import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/core/network/api_client.dart';
import 'package:localizy/core/services/notification_service.dart';
import 'package:localizy/core/theme/app_theme.dart';
import 'package:localizy/features/auth/presentation/session_expiry.dart';
import 'package:localizy/features/settings/presentation/providers/language_provider.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/splash_screen.dart';

import 'core/config/config_manager.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ConfigManager.initialize();
  await NotificationService.initialize();

  // Container tạo tường minh để handler 401 (ngoài cây widget) cũng
  // truy cập được authProvider.
  final container = ProviderContainer();
  ApiClient.onUnauthorized = makeSessionExpiryHandler(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);

    return MaterialApp(
      title: 'Citea',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      locale: locale,
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
  }
}
