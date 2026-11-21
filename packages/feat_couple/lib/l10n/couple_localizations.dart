import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'couple_localizations_en.dart';
import 'couple_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CoupleLocalizations
/// returned by `CoupleLocalizations.of(context)`.
///
/// Applications need to include `CoupleLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/couple_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CoupleLocalizations.localizationsDelegates,
///   supportedLocales: CoupleLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the CoupleLocalizations.supportedLocales
/// property.
abstract class CoupleLocalizations {
  CoupleLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CoupleLocalizations of(BuildContext context) {
    return Localizations.of<CoupleLocalizations>(context, CoupleLocalizations)!;
  }

  static const LocalizationsDelegate<CoupleLocalizations> delegate =
      _CoupleLocalizationsDelegate();

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

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Our calendar'**
  String get calendarTitle;

  /// No description provided for @nudgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Nudges'**
  String get nudgesTitle;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Me + You'**
  String get paywallTitle;

  /// No description provided for @paywallBody.
  ///
  /// In en, this message translates to:
  /// **'The shared calendar and nudges are part of Me + You. Unlocking is coming soon.'**
  String get paywallBody;

  /// No description provided for @paywallNote.
  ///
  /// In en, this message translates to:
  /// **'Me stays free.'**
  String get paywallNote;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned yet.'**
  String get noEvents;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get addEvent;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get editEvent;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'What'**
  String get eventTitle;

  /// No description provided for @allDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDay;

  /// No description provided for @starts.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get starts;

  /// No description provided for @ends.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get ends;

  /// No description provided for @noEnd.
  ///
  /// In en, this message translates to:
  /// **'No end time'**
  String get noEnd;

  /// No description provided for @sharedEvent.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get sharedEvent;

  /// No description provided for @sharedEventDesc.
  ///
  /// In en, this message translates to:
  /// **'Anyone in your union can change it.'**
  String get sharedEventDesc;

  /// No description provided for @mineEvent.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get mineEvent;

  /// No description provided for @mineEventDesc.
  ///
  /// In en, this message translates to:
  /// **'Everyone sees it; only you can change it.'**
  String get mineEventDesc;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get reminders;

  /// No description provided for @remindMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min before'**
  String remindMinutes(int n);

  /// No description provided for @remindHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get remindHour;

  /// No description provided for @remindDay.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get remindDay;

  /// No description provided for @remindersLater.
  ///
  /// In en, this message translates to:
  /// **'Reminders are saved now; alerts on your phone come in a later update.'**
  String get remindersLater;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load. Check your connection.'**
  String get loadFailed;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Check your connection and try again.'**
  String get saveFailed;

  /// No description provided for @acceptNudges.
  ///
  /// In en, this message translates to:
  /// **'Accept nudges'**
  String get acceptNudges;

  /// No description provided for @acceptNudgesDesc.
  ///
  /// In en, this message translates to:
  /// **'Let the people in your union send you nudges.'**
  String get acceptNudgesDesc;

  /// No description provided for @sendTo.
  ///
  /// In en, this message translates to:
  /// **'Send to'**
  String get sendTo;

  /// No description provided for @kindFlag.
  ///
  /// In en, this message translates to:
  /// **'Nudge'**
  String get kindFlag;

  /// No description provided for @kindPresence.
  ///
  /// In en, this message translates to:
  /// **'Be present'**
  String get kindPresence;

  /// No description provided for @presenceDesc.
  ///
  /// In en, this message translates to:
  /// **'Sends only: \"go be present for a moment\".'**
  String get presenceDesc;

  /// No description provided for @nudgeText.
  ///
  /// In en, this message translates to:
  /// **'Short message (optional)'**
  String get nudgeText;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent.'**
  String get sent;

  /// No description provided for @errNotAccepting.
  ///
  /// In en, this message translates to:
  /// **'They haven\'t turned on nudges.'**
  String get errNotAccepting;

  /// No description provided for @errRateLimited.
  ///
  /// In en, this message translates to:
  /// **'You\'ve sent 3 nudges in the last 24 hours. Try again later.'**
  String get errRateLimited;

  /// No description provided for @errNotEntitled.
  ///
  /// In en, this message translates to:
  /// **'Me + You isn\'t unlocked.'**
  String get errNotEntitled;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'That didn\'t work. Please try again.'**
  String get errGeneric;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @sentList.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sentList;

  /// No description provided for @noNudges.
  ///
  /// In en, this message translates to:
  /// **'No nudges yet.'**
  String get noNudges;

  /// No description provided for @presenceMessage.
  ///
  /// In en, this message translates to:
  /// **'Go be present for a moment.'**
  String get presenceMessage;

  /// No description provided for @nudgeFallback.
  ///
  /// In en, this message translates to:
  /// **'Thinking of you.'**
  String get nudgeFallback;

  /// No description provided for @markRead.
  ///
  /// In en, this message translates to:
  /// **'Mark read'**
  String get markRead;

  /// No description provided for @nobodyToNudge.
  ///
  /// In en, this message translates to:
  /// **'Nobody else is in your union yet.'**
  String get nobodyToNudge;
}

class _CoupleLocalizationsDelegate
    extends LocalizationsDelegate<CoupleLocalizations> {
  const _CoupleLocalizationsDelegate();

  @override
  Future<CoupleLocalizations> load(Locale locale) {
    return SynchronousFuture<CoupleLocalizations>(
      lookupCoupleLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_CoupleLocalizationsDelegate old) => false;
}

CoupleLocalizations lookupCoupleLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return CoupleLocalizationsEn();
    case 'es':
      return CoupleLocalizationsEs();
  }

  throw FlutterError(
    'CoupleLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
