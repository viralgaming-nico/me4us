import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('es'),
  ];

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'a little more me, a little more us'**
  String get tagline;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

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

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get haveAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @authNeedEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and a password of at least 6 characters.'**
  String get authNeedEmailPassword;

  /// No description provided for @authCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email to confirm your account, then sign in.'**
  String get authCheckEmail;

  /// No description provided for @authCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the account. Try a different email.'**
  String get authCreateFailed;

  /// No description provided for @authSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in. Check your email and password.'**
  String get authSignInFailed;

  /// No description provided for @authGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in with Google. Please try again.'**
  String get authGoogleFailed;

  /// No description provided for @loadAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your account.'**
  String get loadAccountFailed;

  /// No description provided for @loadUnionFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your union.'**
  String get loadUnionFailed;

  /// No description provided for @linkUp.
  ///
  /// In en, this message translates to:
  /// **'Link up'**
  String get linkUp;

  /// No description provided for @unionExplainer.
  ///
  /// In en, this message translates to:
  /// **'A union is 2 or 3 people on their own phones.'**
  String get unionExplainer;

  /// No description provided for @startUnion.
  ///
  /// In en, this message translates to:
  /// **'Start a union'**
  String get startUnion;

  /// No description provided for @haveCode.
  ///
  /// In en, this message translates to:
  /// **'Have a code?'**
  String get haveCode;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCode;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @unionReady.
  ///
  /// In en, this message translates to:
  /// **'Your union is ready'**
  String get unionReady;

  /// No description provided for @shareCode.
  ///
  /// In en, this message translates to:
  /// **'Share this code with the other person. It works for 7 days.'**
  String get shareCode;

  /// No description provided for @errAlreadyInUnion.
  ///
  /// In en, this message translates to:
  /// **'You are already in a union.'**
  String get errAlreadyInUnion;

  /// No description provided for @errTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again in an hour.'**
  String get errTooManyAttempts;

  /// No description provided for @errInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'That code isn\'t valid. Check it and try again.'**
  String get errInvalidCode;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'That did not work. Please try again.'**
  String get errGeneric;

  /// No description provided for @errConnection.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Check your connection and try again.'**
  String get errConnection;

  /// No description provided for @yourDoors.
  ///
  /// In en, this message translates to:
  /// **'Your doors'**
  String get yourDoors;

  /// No description provided for @doorsExplainer.
  ///
  /// In en, this message translates to:
  /// **'Choose what you are open to. Nothing is shown unless everyone in your union opens that door, and nobody sees your individual choices. You can change this any time.'**
  String get doorsExplainer;

  /// No description provided for @doorKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get doorKids;

  /// No description provided for @doorKidsDesc.
  ///
  /// In en, this message translates to:
  /// **'Calendars and tasks for children in your union.'**
  String get doorKidsDesc;

  /// No description provided for @doorThirdPerson.
  ///
  /// In en, this message translates to:
  /// **'A third person'**
  String get doorThirdPerson;

  /// No description provided for @doorThirdPersonDesc.
  ///
  /// In en, this message translates to:
  /// **'Include a third member in shared things.'**
  String get doorThirdPersonDesc;

  /// No description provided for @doorAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get doorAlcohol;

  /// No description provided for @doorAlcoholDesc.
  ///
  /// In en, this message translates to:
  /// **'Content that mentions drinking.'**
  String get doorAlcoholDesc;

  /// No description provided for @doorLite.
  ///
  /// In en, this message translates to:
  /// **'Lite fun'**
  String get doorLite;

  /// No description provided for @doorLiteDesc.
  ///
  /// In en, this message translates to:
  /// **'Mild, PG-13 playful content.'**
  String get doorLiteDesc;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Check your connection and try again.'**
  String get saveFailed;

  /// No description provided for @yourUnion.
  ///
  /// In en, this message translates to:
  /// **'Your union'**
  String get yourUnion;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @memberN.
  ///
  /// In en, this message translates to:
  /// **'Member {n}'**
  String memberN(int n);

  /// No description provided for @startedUnion.
  ///
  /// In en, this message translates to:
  /// **'Started this union'**
  String get startedUnion;

  /// No description provided for @inviteSomeone.
  ///
  /// In en, this message translates to:
  /// **'Invite someone'**
  String get inviteSomeone;

  /// No description provided for @inviteThird.
  ///
  /// In en, this message translates to:
  /// **'Invite a third person'**
  String get inviteThird;

  /// No description provided for @unionFull.
  ///
  /// In en, this message translates to:
  /// **'Your union is full.'**
  String get unionFull;

  /// No description provided for @inviteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t make a code. Please try again.'**
  String get inviteFailed;

  /// No description provided for @inviteFailedConnection.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t make a code. Check your connection.'**
  String get inviteFailedConnection;

  /// No description provided for @openForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Open for everyone'**
  String get openForEveryone;

  /// No description provided for @doorOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get doorOpen;

  /// No description provided for @doorClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get doorClosed;

  /// No description provided for @changeDoors.
  ///
  /// In en, this message translates to:
  /// **'Change my doors'**
  String get changeDoors;

  /// No description provided for @tabMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get tabMe;

  /// No description provided for @tabUs.
  ///
  /// In en, this message translates to:
  /// **'Us'**
  String get tabUs;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @nudges.
  ///
  /// In en, this message translates to:
  /// **'Nudges'**
  String get nudges;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
