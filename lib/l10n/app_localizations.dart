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
  /// **'Carte d\'identité/CCCD'**
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
