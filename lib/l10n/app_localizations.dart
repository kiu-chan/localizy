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
  /// **'Citea'**
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

  /// No description provided for @signInWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter avec Google'**
  String get signInWithGoogle;

  /// No description provided for @orContinueWith.
  ///
  /// In fr, this message translates to:
  /// **'Ou continuer avec'**
  String get orContinueWith;

  /// No description provided for @googleLoginFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la connexion Google'**
  String get googleLoginFailed;

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
  /// **'Traitement en cours...'**
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

  /// No description provided for @mapConfirmIntro.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez l\'emplacement exact de l\'adresse à vérifier sur la carte'**
  String get mapConfirmIntro;

  /// No description provided for @selectLocationOnMap.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner l\'emplacement sur la carte'**
  String get selectLocationOnMap;

  /// No description provided for @changeLocation.
  ///
  /// In fr, this message translates to:
  /// **'Changer l\'emplacement'**
  String get changeLocation;

  /// No description provided for @selectedLocation.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement sélectionné'**
  String get selectedLocation;

  /// No description provided for @coordinates.
  ///
  /// In fr, this message translates to:
  /// **'Coordonnées'**
  String get coordinates;

  /// No description provided for @importantNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes importantes'**
  String get importantNotes;

  /// No description provided for @notePleaseMarkExactly.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez marquer l\'emplacement exact à vérifier'**
  String get notePleaseMarkExactly;

  /// No description provided for @noteCheckCoordinates.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez attentivement les coordonnées et l\'adresse affichée'**
  String get noteCheckCoordinates;

  /// No description provided for @noteLocationWillBeUsed.
  ///
  /// In fr, this message translates to:
  /// **'Cet emplacement sera utilisé pour la vérification'**
  String get noteLocationWillBeUsed;

  /// No description provided for @confirmAndContinue.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer et continuer'**
  String get confirmAndContinue;

  /// No description provided for @noLocationSelected.
  ///
  /// In fr, this message translates to:
  /// **'Aucun emplacement sélectionné'**
  String get noLocationSelected;

  /// No description provided for @uploadDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger des documents'**
  String get uploadDocuments;

  /// No description provided for @confirmLocation.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer l\'emplacement'**
  String get confirmLocation;

  /// No description provided for @payment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get payment;

  /// No description provided for @selectAppointment.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner un rendez-vous'**
  String get selectAppointment;

  /// No description provided for @complete.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get complete;

  /// No description provided for @stepProgress.
  ///
  /// In fr, this message translates to:
  /// **'Étape {currentStep}/{totalSteps}: {stepTitle}'**
  String stepProgress(Object currentStep, Object stepTitle, Object totalSteps);

  /// No description provided for @percentComplete.
  ///
  /// In fr, this message translates to:
  /// **'{percent}% terminé'**
  String percentComplete(Object percent);

  /// No description provided for @appointmentIntro.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez une date et une heure convenables pour que le personnel vienne vérifier'**
  String get appointmentIntro;

  /// No description provided for @selectDate.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner la date'**
  String get selectDate;

  /// No description provided for @tapToChange.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour modifier'**
  String get tapToChange;

  /// No description provided for @selectDateSuitable.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez une date qui vous convient'**
  String get selectDateSuitable;

  /// No description provided for @selectTimeSlot.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner le créneau horaire'**
  String get selectTimeSlot;

  /// No description provided for @fullyBooked.
  ///
  /// In fr, this message translates to:
  /// **'Complet'**
  String get fullyBooked;

  /// No description provided for @yourAppointment.
  ///
  /// In fr, this message translates to:
  /// **'Votre rendez-vous'**
  String get yourAppointment;

  /// No description provided for @date.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @timeSlot.
  ///
  /// In fr, this message translates to:
  /// **'Créneau horaire'**
  String get timeSlot;

  /// No description provided for @noteStaffWillArrive.
  ///
  /// In fr, this message translates to:
  /// **'Le personnel arrivera pendant le créneau horaire sélectionné'**
  String get noteStaffWillArrive;

  /// No description provided for @notePleaseBePresent.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez être présent à l\'adresse à l\'heure du rendez-vous'**
  String get notePleaseBePresent;

  /// No description provided for @notePrepareOriginalDocs.
  ///
  /// In fr, this message translates to:
  /// **'Préparez les documents originaux pour vérification'**
  String get notePrepareOriginalDocs;

  /// No description provided for @confirmAppointment.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le rendez-vous'**
  String get confirmAppointment;

  /// No description provided for @requestSubmitted.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée! '**
  String get requestSubmitted;

  /// No description provided for @thankYouForCompleting.
  ///
  /// In fr, this message translates to:
  /// **'Merci d\'avoir terminé le processus de vérification'**
  String get thankYouForCompleting;

  /// No description provided for @yourAddressCode.
  ///
  /// In fr, this message translates to:
  /// **'VOTRE CODE D\'ADRESSE'**
  String get yourAddressCode;

  /// No description provided for @copyCode.
  ///
  /// In fr, this message translates to:
  /// **'Copier le code'**
  String get copyCode;

  /// No description provided for @addressCodeCopied.
  ///
  /// In fr, this message translates to:
  /// **'Code d\'adresse copié'**
  String get addressCodeCopied;

  /// No description provided for @requestSummary.
  ///
  /// In fr, this message translates to:
  /// **'Résumé de la demande'**
  String get requestSummary;

  /// No description provided for @identityDocument.
  ///
  /// In fr, this message translates to:
  /// **'Document d\'identité'**
  String get identityDocument;

  /// No description provided for @uploaded.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargé'**
  String get uploaded;

  /// No description provided for @addressProofDoc.
  ///
  /// In fr, this message translates to:
  /// **'Preuve d\'adresse'**
  String get addressProofDoc;

  /// No description provided for @location.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement'**
  String get location;

  /// No description provided for @confirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmé'**
  String get confirmed;

  /// No description provided for @completed.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get completed;

  /// No description provided for @appointmentDate.
  ///
  /// In fr, this message translates to:
  /// **'Date du rendez-vous'**
  String get appointmentDate;

  /// No description provided for @paymentMomo.
  ///
  /// In fr, this message translates to:
  /// **'Portefeuille MoMo'**
  String get paymentMomo;

  /// No description provided for @paymentZaloPay.
  ///
  /// In fr, this message translates to:
  /// **'ZaloPay'**
  String get paymentZaloPay;

  /// No description provided for @paymentBankTransfer.
  ///
  /// In fr, this message translates to:
  /// **'Virement bancaire'**
  String get paymentBankTransfer;

  /// No description provided for @paymentCard.
  ///
  /// In fr, this message translates to:
  /// **'Carte de crédit/débit'**
  String get paymentCard;

  /// No description provided for @paymentUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get paymentUnknown;

  /// No description provided for @nextSteps.
  ///
  /// In fr, this message translates to:
  /// **'Prochaines étapes'**
  String get nextSteps;

  /// No description provided for @step1ReceiveEmail.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir un email de confirmation dans les 5 minutes'**
  String get step1ReceiveEmail;

  /// No description provided for @step2StaffContact.
  ///
  /// In fr, this message translates to:
  /// **'Le personnel vous contactera 1 jour à l\'avance'**
  String get step2StaffContact;

  /// No description provided for @step3VerifyAddress.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier l\'adresse à l\'heure prévue'**
  String get step3VerifyAddress;

  /// No description provided for @step4ReceiveResult.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir le résultat de vérification après 24 heures'**
  String get step4ReceiveResult;

  /// No description provided for @importantNotesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notes importantes'**
  String get importantNotesTitle;

  /// No description provided for @noteSaveAddressCode.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez enregistrer le code d\'adresse pour consultation'**
  String get noteSaveAddressCode;

  /// No description provided for @noteBePresentOnTime.
  ///
  /// In fr, this message translates to:
  /// **'Soyez présent à l\'heure à l\'adresse enregistrée'**
  String get noteBePresentOnTime;

  /// No description provided for @noteContactHotline.
  ///
  /// In fr, this message translates to:
  /// **'Contactez la hotline 1900xxxx si besoin d\'aide'**
  String get noteContactHotline;

  /// No description provided for @share.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get share;

  /// No description provided for @backToHome.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'accueil'**
  String get backToHome;

  /// No description provided for @documentUploadIntro.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez télécharger les documents nécessaires pour vérifier votre adresse'**
  String get documentUploadIntro;

  /// No description provided for @idDocumentSection.
  ///
  /// In fr, this message translates to:
  /// **'1. Document d\'identité'**
  String get idDocumentSection;

  /// No description provided for @documentType.
  ///
  /// In fr, this message translates to:
  /// **'Type de document:'**
  String get documentType;

  /// No description provided for @idCardCCCD.
  ///
  /// In fr, this message translates to:
  /// **'Carte d\'identité'**
  String get idCardCCCD;

  /// No description provided for @passport.
  ///
  /// In fr, this message translates to:
  /// **'Passeport'**
  String get passport;

  /// No description provided for @idDocumentDescription.
  ///
  /// In fr, this message translates to:
  /// **'Prenez des photos claires des deux côtés du document'**
  String get idDocumentDescription;

  /// No description provided for @addressProofSection.
  ///
  /// In fr, this message translates to:
  /// **'2. Document de preuve d\'adresse'**
  String get addressProofSection;

  /// No description provided for @addressProofTitle.
  ///
  /// In fr, this message translates to:
  /// **'Document de preuve d\'adresse'**
  String get addressProofTitle;

  /// No description provided for @addressProofDescription.
  ///
  /// In fr, this message translates to:
  /// **'Factures de services publics, contrat de location, enregistrement de résidence temporaire, etc.'**
  String get addressProofDescription;

  /// No description provided for @noteImageMustBeClear.
  ///
  /// In fr, this message translates to:
  /// **'Les images doivent être claires, non floues ou masquées'**
  String get noteImageMustBeClear;

  /// No description provided for @noteDocumentMustBeValid.
  ///
  /// In fr, this message translates to:
  /// **'Les informations sur les documents doivent être valides'**
  String get noteDocumentMustBeValid;

  /// No description provided for @noteAddressMustMatch.
  ///
  /// In fr, this message translates to:
  /// **'L\'adresse sur le document doit correspondre au lieu de vérification'**
  String get noteAddressMustMatch;

  /// No description provided for @noteSupportedFormats.
  ///
  /// In fr, this message translates to:
  /// **'Formats pris en charge: JPG, PNG'**
  String get noteSupportedFormats;

  /// No description provided for @uploadDocument.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger le document'**
  String get uploadDocument;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @chooseFromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans la galerie'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get takePhoto;

  /// No description provided for @errorSelectingImage.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la sélection de l\'image'**
  String get errorSelectingImage;

  /// No description provided for @continueButton.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueButton;

  /// No description provided for @selectLocation.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner l\'emplacement'**
  String get selectLocation;

  /// No description provided for @mapPickerInstruction.
  ///
  /// In fr, this message translates to:
  /// **'Déplacez la carte - l\'épingle de l\'icône pointe vers les coordonnées exactes'**
  String get mapPickerInstruction;

  /// No description provided for @paymentIntro.
  ///
  /// In fr, this message translates to:
  /// **'Payez les frais de vérification pour continuer le processus'**
  String get paymentIntro;

  /// No description provided for @totalPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement total'**
  String get totalPayment;

  /// No description provided for @currencyVND.
  ///
  /// In fr, this message translates to:
  /// **'VND'**
  String get currencyVND;

  /// No description provided for @addressVerificationFee.
  ///
  /// In fr, this message translates to:
  /// **'Frais de vérification d\'adresse'**
  String get addressVerificationFee;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner le mode de paiement'**
  String get selectPaymentMethod;

  /// No description provided for @paymentMomoDescription.
  ///
  /// In fr, this message translates to:
  /// **'Payer via portefeuille électronique MoMo'**
  String get paymentMomoDescription;

  /// No description provided for @paymentZaloPayDescription.
  ///
  /// In fr, this message translates to:
  /// **'Payer via portefeuille électronique ZaloPay'**
  String get paymentZaloPayDescription;

  /// No description provided for @paymentBankTransferDescription.
  ///
  /// In fr, this message translates to:
  /// **'Virement bancaire direct'**
  String get paymentBankTransferDescription;

  /// No description provided for @paymentCardDescription.
  ///
  /// In fr, this message translates to:
  /// **'Payer avec Visa, MasterCard'**
  String get paymentCardDescription;

  /// No description provided for @feeDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails des frais'**
  String get feeDetails;

  /// No description provided for @basicVerificationFee.
  ///
  /// In fr, this message translates to:
  /// **'Frais de vérification de base'**
  String get basicVerificationFee;

  /// No description provided for @travelFee.
  ///
  /// In fr, this message translates to:
  /// **'Frais de déplacement'**
  String get travelFee;

  /// No description provided for @total.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @noteFeeNonRefundable.
  ///
  /// In fr, this message translates to:
  /// **'Les frais ne sont pas remboursables après paiement'**
  String get noteFeeNonRefundable;

  /// No description provided for @noteReceiveInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Vous recevrez une facture par email'**
  String get noteReceiveInvoice;

  /// No description provided for @noteVerificationStartsAfterPayment.
  ///
  /// In fr, this message translates to:
  /// **'Le processus de vérification commencera après un paiement réussi'**
  String get noteVerificationStartsAfterPayment;

  /// No description provided for @payButton.
  ///
  /// In fr, this message translates to:
  /// **'Payer'**
  String get payButton;

  /// No description provided for @securedBySSL.
  ///
  /// In fr, this message translates to:
  /// **'Paiement sécurisé par SSL'**
  String get securedBySSL;

  /// No description provided for @pleaseWaitAMoment.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez patienter un moment'**
  String get pleaseWaitAMoment;

  /// No description provided for @selectMapType.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner le type de carte'**
  String get selectMapType;

  /// No description provided for @normal.
  ///
  /// In fr, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @satellite.
  ///
  /// In fr, this message translates to:
  /// **'Satellite'**
  String get satellite;

  /// No description provided for @terrain.
  ///
  /// In fr, this message translates to:
  /// **'Terrain'**
  String get terrain;

  /// No description provided for @hybrid.
  ///
  /// In fr, this message translates to:
  /// **'Hybride'**
  String get hybrid;

  /// No description provided for @loginFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la connexion'**
  String get loginFailed;

  /// No description provided for @confirmLogout.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir vous déconnecter ?'**
  String get confirmLogout;

  /// No description provided for @ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @registerFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de l\'inscription'**
  String get registerFailed;

  /// No description provided for @pleaseSelectLocation.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner un emplacement'**
  String get pleaseSelectLocation;

  /// No description provided for @getDirections.
  ///
  /// In fr, this message translates to:
  /// **'Obtenir l\'itinéraire'**
  String get getDirections;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @description.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @phone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get phone;

  /// No description provided for @website.
  ///
  /// In fr, this message translates to:
  /// **'Site internet'**
  String get website;

  /// No description provided for @openingHours.
  ///
  /// In fr, this message translates to:
  /// **'Horaires d\'ouverture'**
  String get openingHours;

  /// No description provided for @createdAt.
  ///
  /// In fr, this message translates to:
  /// **'Créé le'**
  String get createdAt;

  /// No description provided for @address.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get address;

  /// No description provided for @retake.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get retake;

  /// No description provided for @scannerHelpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment utiliser'**
  String get scannerHelpTitle;

  /// No description provided for @scannerHelpTip1.
  ///
  /// In fr, this message translates to:
  /// **'Pointez la caméra sur la plaque, puis appuyez sur le bouton de capture'**
  String get scannerHelpTip1;

  /// No description provided for @scannerHelpTip2.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez aussi choisir une photo depuis la galerie'**
  String get scannerHelpTip2;

  /// No description provided for @scannerHelpTip3.
  ///
  /// In fr, this message translates to:
  /// **'Après la détection, vous pouvez modifier le numéro si nécessaire'**
  String get scannerHelpTip3;

  /// No description provided for @dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// No description provided for @subAccounts.
  ///
  /// In fr, this message translates to:
  /// **'Sous-comptes'**
  String get subAccounts;

  /// No description provided for @preferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get preferences;

  /// No description provided for @supportAndAbout.
  ///
  /// In fr, this message translates to:
  /// **'Support & À propos'**
  String get supportAndAbout;

  /// No description provided for @businessAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte entreprise'**
  String get businessAccount;

  /// No description provided for @languageChangedTo.
  ///
  /// In fr, this message translates to:
  /// **'Langue changée en {language}'**
  String languageChangedTo(Object language);

  /// No description provided for @subAccountManagement.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des sous-comptes'**
  String get subAccountManagement;

  /// No description provided for @addAccount.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un compte'**
  String get addAccount;

  /// No description provided for @addNewSubAccount.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un nouveau sous-compte'**
  String get addNewSubAccount;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer le nom complet'**
  String get pleaseEnterFullName;

  /// No description provided for @phoneOptional.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone (optionnel)'**
  String get phoneOptional;

  /// No description provided for @locationOptional.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement (optionnel)'**
  String get locationOptional;

  /// No description provided for @create.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get create;

  /// No description provided for @subAccountCreatedSuccessfully.
  ///
  /// In fr, this message translates to:
  /// **'Sous-compte créé avec succès'**
  String get subAccountCreatedSuccessfully;

  /// No description provided for @errorCreatingSubAccount.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la création du sous-compte: {error}'**
  String errorCreatingSubAccount(Object error);

  /// No description provided for @accountId.
  ///
  /// In fr, this message translates to:
  /// **'ID du compte'**
  String get accountId;

  /// No description provided for @statusLabel.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get statusLabel;

  /// No description provided for @active.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In fr, this message translates to:
  /// **'Inactif'**
  String get inactive;

  /// No description provided for @managedLocations.
  ///
  /// In fr, this message translates to:
  /// **'Emplacements gérés'**
  String get managedLocations;

  /// No description provided for @createdDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de création'**
  String get createdDate;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @editSubAccount.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le sous-compte'**
  String get editSubAccount;

  /// No description provided for @subAccountUpdatedSuccessfully.
  ///
  /// In fr, this message translates to:
  /// **'Sous-compte mis à jour avec succès'**
  String get subAccountUpdatedSuccessfully;

  /// No description provided for @errorUpdatingSubAccount.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la mise à jour: {error}'**
  String errorUpdatingSubAccount(Object error);

  /// No description provided for @deleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte'**
  String get deleteAccount;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer {name}?'**
  String confirmDeleteAccount(Object name);

  /// No description provided for @accountDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Compte supprimé'**
  String get accountDeleted;

  /// No description provided for @noLocation.
  ///
  /// In fr, this message translates to:
  /// **'Aucun emplacement'**
  String get noLocation;

  /// No description provided for @noSubAccountsFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun sous-compte trouvé'**
  String get noSubAccountsFound;

  /// No description provided for @mapSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher des lieux...'**
  String get mapSearchHint;

  /// No description provided for @mapNoSearchResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat trouvé'**
  String get mapNoSearchResults;

  /// No description provided for @mapSelectLocationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner l\'emplacement sur la carte'**
  String get mapSelectLocationTitle;

  /// No description provided for @mapTapMapToPin.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur la carte pour épingler un emplacement'**
  String get mapTapMapToPin;

  /// No description provided for @mapLocationServiceDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Le service de localisation n\'est pas activé.'**
  String get mapLocationServiceDisabled;

  /// No description provided for @mapGetLocationError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'obtenir la position : {error}'**
  String mapGetLocationError(String error);

  /// No description provided for @mapNoCoordinates.
  ///
  /// In fr, this message translates to:
  /// **'Pas de coordonnées — appuyez sur la carte ou utilisez le GPS'**
  String get mapNoCoordinates;

  /// No description provided for @mapMyLocation.
  ///
  /// In fr, this message translates to:
  /// **'Ma position'**
  String get mapMyLocation;

  /// No description provided for @mapConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get mapConfirm;

  /// No description provided for @mapCityCode.
  ///
  /// In fr, this message translates to:
  /// **'Code de ville'**
  String get mapCityCode;

  /// No description provided for @mapCoordinates.
  ///
  /// In fr, this message translates to:
  /// **'Coordonnées'**
  String get mapCoordinates;

  /// No description provided for @mapAddedBy.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté par'**
  String get mapAddedBy;

  /// No description provided for @mapCreated.
  ///
  /// In fr, this message translates to:
  /// **'Créé'**
  String get mapCreated;

  /// No description provided for @mapYourLocations.
  ///
  /// In fr, this message translates to:
  /// **'Vos emplacements'**
  String get mapYourLocations;

  /// No description provided for @mapLocationCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} emplacements'**
  String mapLocationCount(int count);

  /// No description provided for @mapNoLocationsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun emplacement ajouté'**
  String get mapNoLocationsYet;

  /// No description provided for @mapAddLocation.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un emplacement'**
  String get mapAddLocation;

  /// No description provided for @mapAddLocationSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Remplissez les détails du nouvel emplacement'**
  String get mapAddLocationSubtitle;

  /// No description provided for @mapLocationNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'emplacement'**
  String get mapLocationNameLabel;

  /// No description provided for @mapLocationNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex. Restaurant Pho Bac'**
  String get mapLocationNameHint;

  /// No description provided for @mapLocationNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un nom'**
  String get mapLocationNameRequired;

  /// No description provided for @mapFullAddressLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse complète'**
  String get mapFullAddressLabel;

  /// No description provided for @mapFullAddressHint.
  ///
  /// In fr, this message translates to:
  /// **'ex. 123 Nguyen Trai, Thanh Xuan, Hanoi'**
  String get mapFullAddressHint;

  /// No description provided for @mapFullAddressRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer l\'adresse'**
  String get mapFullAddressRequired;

  /// No description provided for @mapAddressCode.
  ///
  /// In fr, this message translates to:
  /// **'Code d\'adresse'**
  String get mapAddressCode;

  /// No description provided for @mapFieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Requis'**
  String get mapFieldRequired;

  /// No description provided for @mapFieldInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Invalide'**
  String get mapFieldInvalid;

  /// No description provided for @mapPickFromMap.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get mapPickFromMap;

  /// No description provided for @mapSourceFromMap.
  ///
  /// In fr, this message translates to:
  /// **'Depuis la carte'**
  String get mapSourceFromMap;

  /// No description provided for @mapSourceMyLocation.
  ///
  /// In fr, this message translates to:
  /// **'Ma position'**
  String get mapSourceMyLocation;

  /// No description provided for @mapSourceManual.
  ///
  /// In fr, this message translates to:
  /// **'Saisie manuelle'**
  String get mapSourceManual;

  /// No description provided for @mapLatitude.
  ///
  /// In fr, this message translates to:
  /// **'Latitude'**
  String get mapLatitude;

  /// No description provided for @mapLongitude.
  ///
  /// In fr, this message translates to:
  /// **'Longitude'**
  String get mapLongitude;

  /// No description provided for @mapAddLocationSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement ajouté avec succès'**
  String get mapAddLocationSuccess;

  /// No description provided for @mapAllAddresses.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get mapAllAddresses;

  /// No description provided for @mapMineOnly.
  ///
  /// In fr, this message translates to:
  /// **'Les miens'**
  String get mapMineOnly;

  /// No description provided for @mapErrorMessage.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String mapErrorMessage(String error);

  /// No description provided for @requests.
  ///
  /// In fr, this message translates to:
  /// **'Demandes'**
  String get requests;

  /// No description provided for @validatorFailedToLoadDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Échec du chargement du tableau de bord'**
  String get validatorFailedToLoadDashboard;

  /// No description provided for @validatorHello.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, {name}!'**
  String validatorHello(String name);

  /// No description provided for @validatorPendingAndScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez {pending} tâches en attente et {scheduled} planifiées'**
  String validatorPendingAndScheduled(int pending, int scheduled);

  /// No description provided for @validatorAppointmentsToday.
  ///
  /// In fr, this message translates to:
  /// **'{count} rendez-vous aujourd\'hui'**
  String validatorAppointmentsToday(int count);

  /// No description provided for @validatorStatistics.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get validatorStatistics;

  /// No description provided for @validatorTotalAssigned.
  ///
  /// In fr, this message translates to:
  /// **'Total attribué'**
  String get validatorTotalAssigned;

  /// No description provided for @validatorAwaitingConfirm.
  ///
  /// In fr, this message translates to:
  /// **'En attente de confirmation'**
  String get validatorAwaitingConfirm;

  /// No description provided for @validatorScheduledStat.
  ///
  /// In fr, this message translates to:
  /// **'Planifié'**
  String get validatorScheduledStat;

  /// No description provided for @validatorVerifiedStat.
  ///
  /// In fr, this message translates to:
  /// **'Vérifié'**
  String get validatorVerifiedStat;

  /// No description provided for @validatorRejectedStat.
  ///
  /// In fr, this message translates to:
  /// **'Rejeté'**
  String get validatorRejectedStat;

  /// No description provided for @validatorToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get validatorToday;

  /// No description provided for @validatorRecentAssignments.
  ///
  /// In fr, this message translates to:
  /// **'Affectations récentes'**
  String get validatorRecentAssignments;

  /// No description provided for @validatorNoRecentAssignments.
  ///
  /// In fr, this message translates to:
  /// **'Aucune affectation récente'**
  String get validatorNoRecentAssignments;

  /// No description provided for @validatorRequestList.
  ///
  /// In fr, this message translates to:
  /// **'Liste des demandes'**
  String get validatorRequestList;

  /// No description provided for @validatorScheduleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Planning'**
  String get validatorScheduleTitle;

  /// No description provided for @validatorFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get validatorFilterAll;

  /// No description provided for @validatorStatusAssigned.
  ///
  /// In fr, this message translates to:
  /// **'Attribué'**
  String get validatorStatusAssigned;

  /// No description provided for @validatorFailedToLoadAssignments.
  ///
  /// In fr, this message translates to:
  /// **'Échec du chargement des affectations'**
  String get validatorFailedToLoadAssignments;

  /// No description provided for @validatorNoAssignmentsFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucune affectation trouvée'**
  String get validatorNoAssignmentsFound;

  /// No description provided for @validatorNoAddress.
  ///
  /// In fr, this message translates to:
  /// **'Pas d\'adresse'**
  String get validatorNoAddress;

  /// No description provided for @validatorSelectDayToView.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un jour pour voir le planning'**
  String get validatorSelectDayToView;

  /// No description provided for @validatorNoAssignmentsForDay.
  ///
  /// In fr, this message translates to:
  /// **'Aucune affectation pour ce jour'**
  String get validatorNoAssignmentsForDay;

  /// No description provided for @validatorGeneralInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations générales'**
  String get validatorGeneralInfo;

  /// No description provided for @validatorPriority.
  ///
  /// In fr, this message translates to:
  /// **'Priorité'**
  String get validatorPriority;

  /// No description provided for @validatorSubmitted.
  ///
  /// In fr, this message translates to:
  /// **'Soumis le'**
  String get validatorSubmitted;

  /// No description provided for @validatorAssignedDate.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'attribution'**
  String get validatorAssignedDate;

  /// No description provided for @validatorNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get validatorNotes;

  /// No description provided for @validatorCode.
  ///
  /// In fr, this message translates to:
  /// **'Code'**
  String get validatorCode;

  /// No description provided for @validatorCityCode.
  ///
  /// In fr, this message translates to:
  /// **'Code de ville'**
  String get validatorCityCode;

  /// No description provided for @validatorViewOnMap.
  ///
  /// In fr, this message translates to:
  /// **'Voir sur la carte'**
  String get validatorViewOnMap;

  /// No description provided for @validatorRequester.
  ///
  /// In fr, this message translates to:
  /// **'Demandeur'**
  String get validatorRequester;

  /// No description provided for @validatorNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get validatorNameLabel;

  /// No description provided for @validatorVerificationData.
  ///
  /// In fr, this message translates to:
  /// **'Données de vérification'**
  String get validatorVerificationData;

  /// No description provided for @validatorPhotosProvided.
  ///
  /// In fr, this message translates to:
  /// **'Photos fournies'**
  String get validatorPhotosProvided;

  /// No description provided for @validatorDocumentsProvided.
  ///
  /// In fr, this message translates to:
  /// **'Documents fournis'**
  String get validatorDocumentsProvided;

  /// No description provided for @validatorLocationVerified.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement vérifié'**
  String get validatorLocationVerified;

  /// No description provided for @validatorAttachments.
  ///
  /// In fr, this message translates to:
  /// **'Pièces jointes'**
  String get validatorAttachments;

  /// No description provided for @validatorFileCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} fichier(s)'**
  String validatorFileCount(int count);

  /// No description provided for @validatorAssignedValidatorLabel.
  ///
  /// In fr, this message translates to:
  /// **'Validateur attribué'**
  String get validatorAssignedValidatorLabel;

  /// No description provided for @validatorProcessingInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations de traitement'**
  String get validatorProcessingInfo;

  /// No description provided for @validatorProcessedBy.
  ///
  /// In fr, this message translates to:
  /// **'Traité par'**
  String get validatorProcessedBy;

  /// No description provided for @validatorProcessedDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de traitement'**
  String get validatorProcessedDate;

  /// No description provided for @validatorProcessingNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes de traitement'**
  String get validatorProcessingNotes;

  /// No description provided for @validatorRejectionReason.
  ///
  /// In fr, this message translates to:
  /// **'Raison du rejet'**
  String get validatorRejectionReason;

  /// No description provided for @validatorVerify.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get validatorVerify;

  /// No description provided for @validatorReject.
  ///
  /// In fr, this message translates to:
  /// **'Rejeter'**
  String get validatorReject;

  /// No description provided for @validatorVerifyAddress.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier l\'adresse'**
  String get validatorVerifyAddress;

  /// No description provided for @validatorConfirmAppointmentDesc.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez confirmer que vous avez reçu et allez procéder à cette mission de validation.'**
  String get validatorConfirmAppointmentDesc;

  /// No description provided for @validatorVerifyAddressDesc.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez que l\'adresse a été vérifiée sur place.'**
  String get validatorVerifyAddressDesc;

  /// No description provided for @validatorNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'ex. Adresse vérifiée sur place, l\'emplacement est exact'**
  String get validatorNotesHint;

  /// No description provided for @validatorRejectAddress.
  ///
  /// In fr, this message translates to:
  /// **'Rejeter l\'adresse'**
  String get validatorRejectAddress;

  /// No description provided for @validatorRejectAddressDesc.
  ///
  /// In fr, this message translates to:
  /// **'Fournissez une raison pour rejeter cette adresse.'**
  String get validatorRejectAddressDesc;

  /// No description provided for @validatorReasonLabel.
  ///
  /// In fr, this message translates to:
  /// **'Raison *'**
  String get validatorReasonLabel;

  /// No description provided for @validatorReasonHint.
  ///
  /// In fr, this message translates to:
  /// **'ex. Les coordonnées ne correspondent pas à l\'emplacement réel'**
  String get validatorReasonHint;

  /// No description provided for @validatorReasonRequired.
  ///
  /// In fr, this message translates to:
  /// **'La raison est requise'**
  String get validatorReasonRequired;

  /// No description provided for @validatorAppointmentConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous confirmé avec succès'**
  String get validatorAppointmentConfirmed;

  /// No description provided for @validatorAddressVerified.
  ///
  /// In fr, this message translates to:
  /// **'Adresse vérifiée avec succès'**
  String get validatorAddressVerified;

  /// No description provided for @validatorAddressRejected.
  ///
  /// In fr, this message translates to:
  /// **'Adresse rejetée'**
  String get validatorAddressRejected;

  /// No description provided for @validatorCannotLoadImage.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger l\'image'**
  String get validatorCannotLoadImage;

  /// No description provided for @validatorPersonalInformation.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get validatorPersonalInformation;

  /// No description provided for @validatorViewPersonalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Voir les informations personnelles'**
  String get validatorViewPersonalInfo;

  /// No description provided for @validatorChangePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get validatorChangePassword;

  /// No description provided for @validatorChangeLoginPassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe de connexion'**
  String get validatorChangeLoginPassword;

  /// No description provided for @validatorPushNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications push'**
  String get validatorPushNotifications;

  /// No description provided for @validatorPushNotificationsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir des notifications sur les nouvelles demandes'**
  String get validatorPushNotificationsDesc;

  /// No description provided for @validatorEmailNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications par e-mail'**
  String get validatorEmailNotifications;

  /// No description provided for @validatorEmailNotificationsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir des e-mails sur les activités importantes'**
  String get validatorEmailNotificationsDesc;

  /// No description provided for @validatorRole.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get validatorRole;

  /// No description provided for @validatorRoleValue.
  ///
  /// In fr, this message translates to:
  /// **'Validateur'**
  String get validatorRoleValue;

  /// No description provided for @validatorCurrentPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get validatorCurrentPassword;

  /// No description provided for @validatorNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get validatorNewPassword;

  /// No description provided for @validatorConfirmNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le nouveau mot de passe'**
  String get validatorConfirmNewPassword;

  /// No description provided for @validatorMapRequestId.
  ///
  /// In fr, this message translates to:
  /// **'ID de demande'**
  String get validatorMapRequestId;

  /// No description provided for @validatorMapDirectionsHere.
  ///
  /// In fr, this message translates to:
  /// **'Obtenir l\'itinéraire vers ici'**
  String get validatorMapDirectionsHere;

  /// No description provided for @validatorMapFindingRoute.
  ///
  /// In fr, this message translates to:
  /// **'Recherche d\'itinéraire...'**
  String get validatorMapFindingRoute;

  /// No description provided for @validatorMapLocationError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de localisation : {error}'**
  String validatorMapLocationError(String error);

  /// No description provided for @validatorMapDirectionsError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur d\'itinéraire : {error}'**
  String validatorMapDirectionsError(String error);

  /// No description provided for @validatorMapArrivedDestination.
  ///
  /// In fr, this message translates to:
  /// **'🎉 Vous êtes arrivé !'**
  String get validatorMapArrivedDestination;

  /// No description provided for @validatorMapOpenInGoogleMaps.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir dans Google Maps'**
  String get validatorMapOpenInGoogleMaps;

  /// No description provided for @addressInfoIntro.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez la ville et saisissez l\'adresse complète à vérifier'**
  String get addressInfoIntro;

  /// No description provided for @selectCity.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get selectCity;

  /// No description provided for @selectCityHint.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une ville'**
  String get selectCityHint;

  /// No description provided for @selectCityRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner une ville'**
  String get selectCityRequired;

  /// No description provided for @fullAddressLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse complète'**
  String get fullAddressLabel;

  /// No description provided for @fullAddressHint.
  ///
  /// In fr, this message translates to:
  /// **'ex. 123 rue Nguyen Trai, Quartier Thuong Dinh, District Thanh Xuan'**
  String get fullAddressHint;

  /// No description provided for @fullAddressRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir l\'adresse complète'**
  String get fullAddressRequired;

  /// No description provided for @fullAddressTip.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez l\'adresse exacte avec le numéro, la rue, le quartier et l\'arrondissement'**
  String get fullAddressTip;

  /// No description provided for @addressInfoStep.
  ///
  /// In fr, this message translates to:
  /// **'Détails de l\'adresse'**
  String get addressInfoStep;

  /// No description provided for @cityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get cityLabel;

  /// No description provided for @fullAddressSummary.
  ///
  /// In fr, this message translates to:
  /// **'Adresse complète'**
  String get fullAddressSummary;

  /// No description provided for @cityNameSummary.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get cityNameSummary;

  /// No description provided for @submitVerificationRequest.
  ///
  /// In fr, this message translates to:
  /// **'Soumettre la demande de vérification'**
  String get submitVerificationRequest;

  /// No description provided for @account.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get account;

  /// No description provided for @viewPaymentHistory.
  ///
  /// In fr, this message translates to:
  /// **'Voir votre historique de paiements'**
  String get viewPaymentHistory;

  /// No description provided for @verifiedAddresses.
  ///
  /// In fr, this message translates to:
  /// **'Adresses vérifiées'**
  String get verifiedAddresses;

  /// No description provided for @manageVerifiedLocations.
  ///
  /// In fr, this message translates to:
  /// **'Gérer vos adresses vérifiées'**
  String get manageVerifiedLocations;

  /// No description provided for @accountSettingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le compte'**
  String get accountSettingsTitle;

  /// No description provided for @updateProfileInfo.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour vos informations'**
  String get updateProfileInfo;

  /// No description provided for @changeAppLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Changer la langue de l\'application'**
  String get changeAppLanguage;

  /// No description provided for @helpAndSupport.
  ///
  /// In fr, this message translates to:
  /// **'Aide & Support'**
  String get helpAndSupport;

  /// No description provided for @getHelpAndContact.
  ///
  /// In fr, this message translates to:
  /// **'Obtenir de l\'aide et nous contacter'**
  String get getHelpAndContact;

  /// No description provided for @privacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get privacyPolicy;

  /// No description provided for @readPrivacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Lire notre politique de confidentialité'**
  String get readPrivacyPolicy;

  /// No description provided for @featureComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'{feature} - Bientôt disponible'**
  String featureComingSoon(String feature);

  /// No description provided for @howCanWeHelp.
  ///
  /// In fr, this message translates to:
  /// **'Comment pouvons-nous vous aider ?'**
  String get howCanWeHelp;

  /// No description provided for @emailUs.
  ///
  /// In fr, this message translates to:
  /// **'Nous écrire'**
  String get emailUs;

  /// No description provided for @callUs.
  ///
  /// In fr, this message translates to:
  /// **'Nous appeler'**
  String get callUs;

  /// No description provided for @liveChat.
  ///
  /// In fr, this message translates to:
  /// **'Chat en direct'**
  String get liveChat;

  /// No description provided for @available247.
  ///
  /// In fr, this message translates to:
  /// **'Disponible 24h/24, 7j/7'**
  String get available247;

  /// No description provided for @respondWithin24h.
  ///
  /// In fr, this message translates to:
  /// **'Nous répondons généralement sous 24 heures'**
  String get respondWithin24h;

  /// No description provided for @saveChanges.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get saveChanges;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour avec succès'**
  String get profileUpdateSuccess;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour échouée : {error}'**
  String profileUpdateFailed(Object error);

  /// No description provided for @profileLoadFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le profil : {error}'**
  String profileLoadFailed(Object error);

  /// No description provided for @avatarUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Photo de profil mise à jour'**
  String get avatarUpdated;

  /// No description provided for @avatarUpdateFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de mettre à jour la photo : {error}'**
  String avatarUpdateFailed(Object error);

  /// No description provided for @cannotPickImage.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de choisir une image : {error}'**
  String cannotPickImage(Object error);

  /// No description provided for @yourName.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom'**
  String get yourName;

  /// No description provided for @enterFullNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre nom complet'**
  String get enterFullNameHint;

  /// No description provided for @enterEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre e-mail'**
  String get enterEmailHint;

  /// No description provided for @enterPhoneHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre numéro de téléphone'**
  String get enterPhoneHint;

  /// No description provided for @roleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get roleAdmin;

  /// No description provided for @roleValidator.
  ///
  /// In fr, this message translates to:
  /// **'Validateur'**
  String get roleValidator;

  /// No description provided for @roleBusiness.
  ///
  /// In fr, this message translates to:
  /// **'Entreprise'**
  String get roleBusiness;

  /// No description provided for @roleSubAccount.
  ///
  /// In fr, this message translates to:
  /// **'Sous-compte'**
  String get roleSubAccount;

  /// No description provided for @roleMember.
  ///
  /// In fr, this message translates to:
  /// **'Membre'**
  String get roleMember;

  /// No description provided for @changePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePassword;

  /// No description provided for @changeLoginPassword.
  ///
  /// In fr, this message translates to:
  /// **'Modifier votre mot de passe de connexion'**
  String get changeLoginPassword;

  /// No description provided for @currentPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le nouveau mot de passe'**
  String get confirmNewPassword;

  /// No description provided for @enterCurrentPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez le mot de passe actuel'**
  String get enterCurrentPasswordHint;

  /// No description provided for @enterNewPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez le nouveau mot de passe'**
  String get enterNewPasswordHint;

  /// No description provided for @passwordChangeSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié avec succès'**
  String get passwordChangeSuccess;

  /// No description provided for @passwordChangeFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de modifier le mot de passe : {error}'**
  String passwordChangeFailed(Object error);

  /// No description provided for @createdBy.
  ///
  /// In fr, this message translates to:
  /// **'Créé par'**
  String get createdBy;

  /// No description provided for @verifiedBy.
  ///
  /// In fr, this message translates to:
  /// **'Vérifié par'**
  String get verifiedBy;

  /// No description provided for @notes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @parkingAvailableSlots.
  ///
  /// In fr, this message translates to:
  /// **'Disponible / Total'**
  String get parkingAvailableSlots;

  /// No description provided for @parkingPriceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prix de stationnement'**
  String get parkingPriceLabel;

  /// No description provided for @parkingInfoSection.
  ///
  /// In fr, this message translates to:
  /// **'Informations de stationnement'**
  String get parkingInfoSection;

  /// No description provided for @verifiedStatus.
  ///
  /// In fr, this message translates to:
  /// **'Vérifié'**
  String get verifiedStatus;

  /// No description provided for @failedToLoadDetails.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les détails'**
  String get failedToLoadDetails;

  /// No description provided for @searchAddressHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez une adresse, district, ville...'**
  String get searchAddressHint;

  /// No description provided for @searching.
  ///
  /// In fr, this message translates to:
  /// **'Recherche...'**
  String get searching;

  /// No description provided for @noAddressesFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucune adresse trouvée'**
  String get noAddressesFound;

  /// No description provided for @searchTryDifferentKeywords.
  ///
  /// In fr, this message translates to:
  /// **'Essayez de rechercher avec d\'autres mots-clés'**
  String get searchTryDifferentKeywords;

  /// No description provided for @parkingAvailableBadge.
  ///
  /// In fr, this message translates to:
  /// **'Parking disponible'**
  String get parkingAvailableBadge;

  /// No description provided for @totalParkingSpots.
  ///
  /// In fr, this message translates to:
  /// **'Places totales'**
  String get totalParkingSpots;

  /// No description provided for @availableParkingSpots.
  ///
  /// In fr, this message translates to:
  /// **'Places disponibles'**
  String get availableParkingSpots;

  /// No description provided for @pricePerHour.
  ///
  /// In fr, this message translates to:
  /// **'Prix/heure'**
  String get pricePerHour;

  /// No description provided for @viewOnMaps.
  ///
  /// In fr, this message translates to:
  /// **'Voir sur Maps'**
  String get viewOnMaps;

  /// No description provided for @bookParking.
  ///
  /// In fr, this message translates to:
  /// **'Réserver un parking'**
  String get bookParking;

  /// No description provided for @navigatingToPayment.
  ///
  /// In fr, this message translates to:
  /// **'Navigation vers le paiement...'**
  String get navigatingToPayment;

  /// No description provided for @aboutLocalizy.
  ///
  /// In fr, this message translates to:
  /// **'À propos de Localizy'**
  String get aboutLocalizy;

  /// No description provided for @appDescription.
  ///
  /// In fr, this message translates to:
  /// **'Votre solution intelligente pour la gestion\ndu stationnement et la vérification d\'adresses'**
  String get appDescription;

  /// No description provided for @keyFeatures.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalités clés'**
  String get keyFeatures;

  /// No description provided for @smartParkingPaymentDesc.
  ///
  /// In fr, this message translates to:
  /// **'Payez le stationnement facilement et en toute sécurité'**
  String get smartParkingPaymentDesc;

  /// No description provided for @licensePlateScanning.
  ///
  /// In fr, this message translates to:
  /// **'Lecture de plaques d\'immatriculation'**
  String get licensePlateScanning;

  /// No description provided for @licensePlateScanningDesc.
  ///
  /// In fr, this message translates to:
  /// **'Reconnaissance OCR automatique pour une saisie rapide'**
  String get licensePlateScanningDesc;

  /// No description provided for @addressVerificationDesc.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez et gérez vos adresses'**
  String get addressVerificationDesc;

  /// No description provided for @realTimeNavigation.
  ///
  /// In fr, this message translates to:
  /// **'Navigation en temps réel'**
  String get realTimeNavigation;

  /// No description provided for @realTimeNavigationDesc.
  ///
  /// In fr, this message translates to:
  /// **'Obtenez un itinéraire vers les parkings'**
  String get realTimeNavigationDesc;

  /// No description provided for @transactionHistoryDesc.
  ///
  /// In fr, this message translates to:
  /// **'Suivez tous vos paiements de stationnement'**
  String get transactionHistoryDesc;

  /// No description provided for @multiLanguageSupport.
  ///
  /// In fr, this message translates to:
  /// **'Support multilingue'**
  String get multiLanguageSupport;

  /// No description provided for @multiLanguageSupportDesc.
  ///
  /// In fr, this message translates to:
  /// **'Disponible en plusieurs langues'**
  String get multiLanguageSupportDesc;

  /// No description provided for @appInformation.
  ///
  /// In fr, this message translates to:
  /// **'Informations sur l\'application'**
  String get appInformation;

  /// No description provided for @appNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'application'**
  String get appNameLabel;

  /// No description provided for @packageNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du package'**
  String get packageNameLabel;

  /// No description provided for @versionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @buildNumberLabel.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de build'**
  String get buildNumberLabel;

  /// No description provided for @platformLabel.
  ///
  /// In fr, this message translates to:
  /// **'Plateforme'**
  String get platformLabel;

  /// No description provided for @releaseDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de sortie'**
  String get releaseDateLabel;

  /// No description provided for @contactInformation.
  ///
  /// In fr, this message translates to:
  /// **'Informations de contact'**
  String get contactInformation;

  /// No description provided for @copiedToClipboard.
  ///
  /// In fr, this message translates to:
  /// **'{label} copié dans le presse-papier'**
  String copiedToClipboard(String label);

  /// No description provided for @legalSection.
  ///
  /// In fr, this message translates to:
  /// **'Mentions légales'**
  String get legalSection;

  /// No description provided for @termsOfService.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get termsOfService;

  /// No description provided for @termsAndConditions.
  ///
  /// In fr, this message translates to:
  /// **'Termes et conditions'**
  String get termsAndConditions;

  /// No description provided for @openSourceLicenses.
  ///
  /// In fr, this message translates to:
  /// **'Licences open source'**
  String get openSourceLicenses;

  /// No description provided for @thirdPartyLicenses.
  ///
  /// In fr, this message translates to:
  /// **'Licences tierces'**
  String get thirdPartyLicenses;

  /// No description provided for @developmentTeam.
  ///
  /// In fr, this message translates to:
  /// **'Équipe de développement'**
  String get developmentTeam;

  /// No description provided for @developedBy.
  ///
  /// In fr, this message translates to:
  /// **'Développé par'**
  String get developedBy;

  /// No description provided for @devTeamName.
  ///
  /// In fr, this message translates to:
  /// **'L\'équipe de développement Localizy'**
  String get devTeamName;

  /// No description provided for @copyright.
  ///
  /// In fr, this message translates to:
  /// **'© 2024 Localizy'**
  String get copyright;

  /// No description provided for @allRightsReserved.
  ///
  /// In fr, this message translates to:
  /// **'Tous droits réservés'**
  String get allRightsReserved;

  /// No description provided for @madeWithLoveInVietnam.
  ///
  /// In fr, this message translates to:
  /// **'Fait avec ❤️ au Vietnam'**
  String get madeWithLoveInVietnam;

  /// No description provided for @versionDisplay.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String versionDisplay(String version);

  /// No description provided for @businessDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord professionnel'**
  String get businessDashboard;

  /// No description provided for @overview.
  ///
  /// In fr, this message translates to:
  /// **'Vue d\'ensemble'**
  String get overview;

  /// No description provided for @totalLocations.
  ///
  /// In fr, this message translates to:
  /// **'Emplacements totaux'**
  String get totalLocations;

  /// No description provided for @recentActivities.
  ///
  /// In fr, this message translates to:
  /// **'Activités récentes'**
  String get recentActivities;

  /// No description provided for @failedToLoadData.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les données'**
  String get failedToLoadData;

  /// No description provided for @noActivitiesYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité pour le moment'**
  String get noActivitiesYet;

  /// No description provided for @minutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count}min'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count}h'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count}j'**
  String daysAgo(int count);

  /// No description provided for @idCopied.
  ///
  /// In fr, this message translates to:
  /// **'ID copié'**
  String get idCopied;
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
