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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Localizy'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue'**
  String get loginToContinue;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?  '**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms of use'**
  String get agreeToTerms;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registerSuccess;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @pleaseAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the terms of use'**
  String get pleaseAgreeToTerms;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you instructions to reset your password'**
  String get resetPasswordDescription;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @checkEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email! '**
  String get checkEmail;

  /// No description provided for @checkEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'We have sent password reset instructions to'**
  String get checkEmailDescription;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @sendAgain.
  ///
  /// In en, this message translates to:
  /// **'Send again'**
  String get sendAgain;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @welcomeToLocalizy.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Localizy'**
  String get welcomeToLocalizy;

  /// No description provided for @homePage.
  ///
  /// In en, this message translates to:
  /// **'Home page'**
  String get homePage;

  /// No description provided for @viewAndExploreMap.
  ///
  /// In en, this message translates to:
  /// **'View and explore map'**
  String get viewAndExploreMap;

  /// No description provided for @mapFeatureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Map feature is under development'**
  String get mapFeatureInDevelopment;

  /// No description provided for @openMap.
  ///
  /// In en, this message translates to:
  /// **'Open map'**
  String get openMap;

  /// No description provided for @loadingMap.
  ///
  /// In en, this message translates to:
  /// **'Loading map...'**
  String get loadingMap;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @pleaseEnableLocationInSettings.
  ///
  /// In en, this message translates to:
  /// **'Please enable location permission in settings'**
  String get pleaseEnableLocationInSettings;

  /// No description provided for @errorGettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Error getting location'**
  String get errorGettingLocation;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get yourLocation;

  /// No description provided for @youAreHere.
  ///
  /// In en, this message translates to:
  /// **'You are here'**
  String get youAreHere;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account information'**
  String get accountInfo;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About app'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language settings'**
  String get languageSettings;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your language'**
  String get selectLanguage;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @smartParkingManagement.
  ///
  /// In en, this message translates to:
  /// **'Smart parking management'**
  String get smartParkingManagement;

  /// No description provided for @mainFeatures.
  ///
  /// In en, this message translates to:
  /// **'Main Features'**
  String get mainFeatures;

  /// No description provided for @addressVerification.
  ///
  /// In en, this message translates to:
  /// **'Address verification'**
  String get addressVerification;

  /// No description provided for @parkingPayment.
  ///
  /// In en, this message translates to:
  /// **'Parking payment'**
  String get parkingPayment;

  /// No description provided for @paymentCheck.
  ///
  /// In en, this message translates to:
  /// **'Payment check'**
  String get paymentCheck;

  /// No description provided for @addressSearch.
  ///
  /// In en, this message translates to:
  /// **'Address search'**
  String get addressSearch;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @viewMap.
  ///
  /// In en, this message translates to:
  /// **'View map'**
  String get viewMap;

  /// No description provided for @findAndViewParkingLots.
  ///
  /// In en, this message translates to:
  /// **'Find and view parking lot locations'**
  String get findAndViewParkingLots;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction history'**
  String get transactionHistory;

  /// No description provided for @viewParkingPaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'View parking payment history'**
  String get viewParkingPaymentHistory;

  /// No description provided for @licensePlateScannerOCR.
  ///
  /// In en, this message translates to:
  /// **'License plate scanner (OCR)'**
  String get licensePlateScannerOCR;

  /// No description provided for @automaticLicensePlateRecognition.
  ///
  /// In en, this message translates to:
  /// **'Automatic license plate recognition'**
  String get automaticLicensePlateRecognition;

  /// No description provided for @addressVerificationFunction.
  ///
  /// In en, this message translates to:
  /// **'Address verification function'**
  String get addressVerificationFunction;

  /// No description provided for @parkingPaymentFunction.
  ///
  /// In en, this message translates to:
  /// **'Parking payment function'**
  String get parkingPaymentFunction;

  /// No description provided for @checkParkingPayment.
  ///
  /// In en, this message translates to:
  /// **'Check parking payment'**
  String get checkParkingPayment;

  /// No description provided for @addressSearchFunction.
  ///
  /// In en, this message translates to:
  /// **'Address search function'**
  String get addressSearchFunction;

  /// No description provided for @viewTransactionHistory.
  ///
  /// In en, this message translates to:
  /// **'View transaction history'**
  String get viewTransactionHistory;

  /// No description provided for @licensePlateScanned.
  ///
  /// In en, this message translates to:
  /// **'License plate scanned'**
  String get licensePlateScanned;

  /// No description provided for @licensePlateScanner.
  ///
  /// In en, this message translates to:
  /// **'License Plate Scanner'**
  String get licensePlateScanner;

  /// No description provided for @noCameraFound.
  ///
  /// In en, this message translates to:
  /// **'No camera found on device.'**
  String get noCameraFound;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera Error'**
  String get cameraError;

  /// No description provided for @errorInitializingCamera.
  ///
  /// In en, this message translates to:
  /// **'Error initializing camera'**
  String get errorInitializingCamera;

  /// No description provided for @recognizing.
  ///
  /// In en, this message translates to:
  /// **'Recognizing...'**
  String get recognizing;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @noLicensePlateDetected.
  ///
  /// In en, this message translates to:
  /// **'No license plate detected'**
  String get noLicensePlateDetected;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @cannotDeleteFile.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete file'**
  String get cannotDeleteFile;

  /// No description provided for @confirmLicensePlate.
  ///
  /// In en, this message translates to:
  /// **'Confirm License Plate'**
  String get confirmLicensePlate;

  /// No description provided for @detectedLicensePlate.
  ///
  /// In en, this message translates to:
  /// **'Detected license plate:'**
  String get detectedLicensePlate;

  /// No description provided for @enterLicensePlate.
  ///
  /// In en, this message translates to:
  /// **'Enter license plate'**
  String get enterLicensePlate;

  /// No description provided for @supportedCountries.
  ///
  /// In en, this message translates to:
  /// **'Supported:  Vietnam 🇻🇳, France 🇫🇷, Cameroon 🇨🇲'**
  String get supportedCountries;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @pleaseEnterLicensePlate.
  ///
  /// In en, this message translates to:
  /// **'Please enter license plate'**
  String get pleaseEnterLicensePlate;

  /// No description provided for @placeLicensePlateInFrame.
  ///
  /// In en, this message translates to:
  /// **'Place license plate in frame'**
  String get placeLicensePlateInFrame;

  /// No description provided for @autoRecognition.
  ///
  /// In en, this message translates to:
  /// **'Auto recognition:  Vietnam 🇻🇳, France 🇫🇷, Cameroon 🇨🇲'**
  String get autoRecognition;

  /// No description provided for @errorInitializingCameraDetails.
  ///
  /// In en, this message translates to:
  /// **'Error initializing camera:  {error}'**
  String errorInitializingCameraDetails(Object error);

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @navigationStarted.
  ///
  /// In en, this message translates to:
  /// **'Navigation started'**
  String get navigationStarted;

  /// No description provided for @navigationStopped.
  ///
  /// In en, this message translates to:
  /// **'Navigation stopped'**
  String get navigationStopped;

  /// No description provided for @arrivedAtDestination.
  ///
  /// In en, this message translates to:
  /// **'🎉 You have arrived at your destination!'**
  String get arrivedAtDestination;

  /// No description provided for @noRouteFound.
  ///
  /// In en, this message translates to:
  /// **'Could not find a route'**
  String get noRouteFound;

  /// No description provided for @errorFindingRoute.
  ///
  /// In en, this message translates to:
  /// **'Error finding route'**
  String get errorFindingRoute;

  /// No description provided for @tapToSelectDestination.
  ///
  /// In en, this message translates to:
  /// **'Tap on the map to select destination'**
  String get tapToSelectDestination;

  /// No description provided for @travelModeDriving.
  ///
  /// In en, this message translates to:
  /// **'Driving'**
  String get travelModeDriving;

  /// No description provided for @travelModeWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get travelModeWalking;

  /// No description provided for @travelModeBicycling.
  ///
  /// In en, this message translates to:
  /// **'Bicycling'**
  String get travelModeBicycling;

  /// No description provided for @travelModeTransit.
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get travelModeTransit;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// No description provided for @fastestRoute.
  ///
  /// In en, this message translates to:
  /// **'Fastest route'**
  String get fastestRoute;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
