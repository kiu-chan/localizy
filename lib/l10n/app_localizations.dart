import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Localizy'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour! '**
  String get welcomeBack;

  /// No description provided for @loginToContinue.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour continuer'**
  String get loginToContinue;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get login;

  /// No description provided for @loginSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie!'**
  String get loginSuccess;

  /// No description provided for @noAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas de compte?  '**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get register;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre e-mail'**
  String get pleaseEnterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail invalide'**
  String get invalidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre mot de passe'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 6 caractères'**
  String get passwordMinLength;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @agreeToTerms.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte les conditions d\'utilisation'**
  String get agreeToTerms;

  /// No description provided for @registerSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Inscription réussie! '**
  String get registerSuccess;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà un compte?  '**
  String get alreadyHaveAccount;

  /// No description provided for @pleaseEnterName.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre nom'**
  String get pleaseEnterName;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez confirmer votre mot de passe'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get passwordsDoNotMatch;

  /// No description provided for @pleaseAgreeToTerms.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez accepter les conditions d\'utilisation'**
  String get pleaseAgreeToTerms;

  /// No description provided for @resetPassword.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get resetPassword;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre adresse e-mail et nous vous enverrons des instructions pour réinitialiser votre mot de passe'**
  String get resetPasswordDescription;

  /// No description provided for @sendRequest.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la demande'**
  String get sendRequest;

  /// No description provided for @checkEmail.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre e-mail! '**
  String get checkEmail;

  /// No description provided for @checkEmailDescription.
  ///
  /// In fr, this message translates to:
  /// **'Nous avons envoyé des instructions de réinitialisation de mot de passe à'**
  String get checkEmailDescription;

  /// No description provided for @backToLogin.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la connexion'**
  String get backToLogin;

  /// No description provided for @sendAgain.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer'**
  String get sendAgain;

  /// No description provided for @home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get home;

  /// No description provided for @map.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get map;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @welcomeToLocalizy.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Localizy'**
  String get welcomeToLocalizy;

  /// No description provided for @homePage.
  ///
  /// In fr, this message translates to:
  /// **'Page d\'accueil'**
  String get homePage;

  /// No description provided for @viewAndExploreMap.
  ///
  /// In fr, this message translates to:
  /// **'Voir et explorer la carte'**
  String get viewAndExploreMap;

  /// No description provided for @mapFeatureInDevelopment.
  ///
  /// In fr, this message translates to:
  /// **'La fonction carte est en cours de développement'**
  String get mapFeatureInDevelopment;

  /// No description provided for @openMap.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la carte'**
  String get openMap;

  /// No description provided for @loadingMap.
  ///
  /// In fr, this message translates to:
  /// **'Chargement de la carte.. .'**
  String get loadingMap;

  /// No description provided for @currentLocation.
  ///
  /// In fr, this message translates to:
  /// **'Position actuelle'**
  String get currentLocation;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Autorisation de localisation refusée'**
  String get locationPermissionDenied;

  /// No description provided for @pleaseEnableLocationInSettings.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez activer l\'autorisation de localisation dans les paramètres'**
  String get pleaseEnableLocationInSettings;

  /// No description provided for @errorGettingLocation.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'obtention de la position'**
  String get errorGettingLocation;

  /// No description provided for @yourLocation.
  ///
  /// In fr, this message translates to:
  /// **'Votre position'**
  String get yourLocation;

  /// No description provided for @youAreHere.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes ici'**
  String get youAreHere;

  /// No description provided for @user.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get user;

  /// No description provided for @accountInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations du compte'**
  String get accountInfo;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @privacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get privacy;

  /// No description provided for @help.
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get help;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'À propos de l\'application'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logout;

  /// No description provided for @languageSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de langue'**
  String get languageSettings;

  /// No description provided for @selectLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez votre langue'**
  String get selectLanguage;

  /// No description provided for @vietnamese.
  ///
  /// In fr, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @smartParkingManagement.
  ///
  /// In fr, this message translates to:
  /// **'Gestion intelligente du stationnement'**
  String get smartParkingManagement;

  /// No description provided for @mainFeatures.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalités principales'**
  String get mainFeatures;

  /// No description provided for @addressVerification.
  ///
  /// In fr, this message translates to:
  /// **'Vérification d\'adresse'**
  String get addressVerification;

  /// No description provided for @parkingPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement du stationnement'**
  String get parkingPayment;

  /// No description provided for @paymentCheck.
  ///
  /// In fr, this message translates to:
  /// **'Vérification du paiement'**
  String get paymentCheck;

  /// No description provided for @addressSearch.
  ///
  /// In fr, this message translates to:
  /// **'Recherche d\'adresse'**
  String get addressSearch;

  /// No description provided for @quickActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions rapides'**
  String get quickActions;

  /// No description provided for @viewMap.
  ///
  /// In fr, this message translates to:
  /// **'Voir la carte'**
  String get viewMap;

  /// No description provided for @findAndViewParkingLots.
  ///
  /// In fr, this message translates to:
  /// **'Trouver et voir les emplacements de stationnement'**
  String get findAndViewParkingLots;

  /// No description provided for @transactionHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique des transactions'**
  String get transactionHistory;

  /// No description provided for @viewParkingPaymentHistory.
  ///
  /// In fr, this message translates to:
  /// **'Voir l\'historique des paiements de stationnement'**
  String get viewParkingPaymentHistory;

  /// No description provided for @licensePlateScannerOCR.
  ///
  /// In fr, this message translates to:
  /// **'Scanner de plaque d\'immatriculation (OCR)'**
  String get licensePlateScannerOCR;

  /// No description provided for @automaticLicensePlateRecognition.
  ///
  /// In fr, this message translates to:
  /// **'Reconnaissance automatique de plaque d\'immatriculation'**
  String get automaticLicensePlateRecognition;

  /// No description provided for @addressVerificationFunction.
  ///
  /// In fr, this message translates to:
  /// **'Fonction de vérification d\'adresse'**
  String get addressVerificationFunction;

  /// No description provided for @parkingPaymentFunction.
  ///
  /// In fr, this message translates to:
  /// **'Fonction de paiement du stationnement'**
  String get parkingPaymentFunction;

  /// No description provided for @checkParkingPayment.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier le paiement du stationnement'**
  String get checkParkingPayment;

  /// No description provided for @addressSearchFunction.
  ///
  /// In fr, this message translates to:
  /// **'Fonction de recherche d\'adresse'**
  String get addressSearchFunction;

  /// No description provided for @viewTransactionHistory.
  ///
  /// In fr, this message translates to:
  /// **'Voir l\'historique des transactions'**
  String get viewTransactionHistory;

  /// No description provided for @licensePlateScanned.
  ///
  /// In fr, this message translates to:
  /// **'Plaque d\'immatriculation scannée'**
  String get licensePlateScanned;

  /// No description provided for @licensePlateScanner.
  ///
  /// In fr, this message translates to:
  /// **'Scanner de plaque d\'immatriculation'**
  String get licensePlateScanner;

  /// No description provided for @noCameraFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucune caméra trouvée sur l\'appareil.'**
  String get noCameraFound;

  /// No description provided for @cameraError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de caméra'**
  String get cameraError;

  /// No description provided for @errorInitializingCamera.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'initialisation de la caméra'**
  String get errorInitializingCamera;

  /// No description provided for @recognizing.
  ///
  /// In fr, this message translates to:
  /// **'Reconnaissance en cours...'**
  String get recognizing;

  /// No description provided for @processing.
  ///
  /// In fr, this message translates to:
  /// **'Traitement.. .'**
  String get processing;

  /// No description provided for @noLicensePlateDetected.
  ///
  /// In fr, this message translates to:
  /// **'Aucune plaque d\'immatriculation détectée'**
  String get noLicensePlateDetected;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @cannotDeleteFile.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de supprimer le fichier'**
  String get cannotDeleteFile;

  /// No description provided for @confirmLicensePlate.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la plaque d\'immatriculation'**
  String get confirmLicensePlate;

  /// No description provided for @detectedLicensePlate.
  ///
  /// In fr, this message translates to:
  /// **'Plaque d\'immatriculation détectée:'**
  String get detectedLicensePlate;

  /// No description provided for @enterLicensePlate.
  ///
  /// In fr, this message translates to:
  /// **'Entrer la plaque d\'immatriculation'**
  String get enterLicensePlate;

  /// No description provided for @supportedCountries.
  ///
  /// In fr, this message translates to:
  /// **'Pris en charge:  Vietnam 🇻🇳, France 🇫🇷, Cameroun 🇨🇲'**
  String get supportedCountries;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @pleaseEnterLicensePlate.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer la plaque d\'immatriculation'**
  String get pleaseEnterLicensePlate;

  /// No description provided for @placeLicensePlateInFrame.
  ///
  /// In fr, this message translates to:
  /// **'Placez la plaque d\'immatriculation dans le cadre'**
  String get placeLicensePlateInFrame;

  /// No description provided for @autoRecognition.
  ///
  /// In fr, this message translates to:
  /// **'Reconnaissance automatique:  Vietnam 🇻🇳, France 🇫🇷, Cameroun 🇨🇲'**
  String get autoRecognition;

  /// No description provided for @errorInitializingCameraDetails.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'initialisation de la caméra: {error}'**
  String errorInitializingCameraDetails(Object error);

  /// No description provided for @destination.
  ///
  /// In fr, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @navigationStarted.
  ///
  /// In fr, this message translates to:
  /// **'Navigation démarrée'**
  String get navigationStarted;

  /// No description provided for @navigationStopped.
  ///
  /// In fr, this message translates to:
  /// **'Navigation arrêtée'**
  String get navigationStopped;

  /// No description provided for @arrivedAtDestination.
  ///
  /// In fr, this message translates to:
  /// **'🎉 Vous êtes arrivé à destination! '**
  String get arrivedAtDestination;

  /// No description provided for @noRouteFound.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de trouver un itinéraire'**
  String get noRouteFound;

  /// No description provided for @errorFindingRoute.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la recherche d\'itinéraire'**
  String get errorFindingRoute;

  /// No description provided for @tapToSelectDestination.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur la carte pour sélectionner la destination'**
  String get tapToSelectDestination;

  /// No description provided for @travelModeDriving.
  ///
  /// In fr, this message translates to:
  /// **'En voiture'**
  String get travelModeDriving;

  /// No description provided for @travelModeWalking.
  ///
  /// In fr, this message translates to:
  /// **'À pied'**
  String get travelModeWalking;

  /// No description provided for @travelModeBicycling.
  ///
  /// In fr, this message translates to:
  /// **'À vélo'**
  String get travelModeBicycling;

  /// No description provided for @travelModeTransit.
  ///
  /// In fr, this message translates to:
  /// **'Transports en commun'**
  String get travelModeTransit;

  /// No description provided for @step.
  ///
  /// In fr, this message translates to:
  /// **'Étape'**
  String get step;

  /// No description provided for @fastestRoute.
  ///
  /// In fr, this message translates to:
  /// **'Itinéraire le plus rapide'**
  String get fastestRoute;

  /// No description provided for @start.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get stop;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
