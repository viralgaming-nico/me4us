import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'me_localizations_en.dart';
import 'me_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of MeLocalizations
/// returned by `MeLocalizations.of(context)`.
///
/// Applications need to include `MeLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/me_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: MeLocalizations.localizationsDelegates,
///   supportedLocales: MeLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the MeLocalizations.supportedLocales
/// property.
abstract class MeLocalizations {
  MeLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static MeLocalizations of(BuildContext context) {
    return Localizations.of<MeLocalizations>(context, MeLocalizations)!;
  }

  static const LocalizationsDelegate<MeLocalizations> delegate =
      _MeLocalizationsDelegate();

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

  /// No description provided for @meTitle.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get meTitle;

  /// No description provided for @pointsToday.
  ///
  /// In en, this message translates to:
  /// **'{n} today'**
  String pointsToday(int n);

  /// No description provided for @pointsWeek.
  ///
  /// In en, this message translates to:
  /// **'{n} this week'**
  String pointsWeek(int n);

  /// No description provided for @pointsTotal.
  ///
  /// In en, this message translates to:
  /// **'{n} points'**
  String pointsTotal(int n);

  /// No description provided for @pointsPlus.
  ///
  /// In en, this message translates to:
  /// **'+{n}'**
  String pointsPlus(int n);

  /// No description provided for @todayList.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayList;

  /// No description provided for @allDoneToday.
  ///
  /// In en, this message translates to:
  /// **'All done for today.'**
  String get allDoneToday;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your self-care list is empty'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In en, this message translates to:
  /// **'Start with a few basics, or add your own.'**
  String get emptyBody;

  /// No description provided for @useStarter.
  ///
  /// In en, this message translates to:
  /// **'Use the starter list'**
  String get useStarter;

  /// No description provided for @addOwn.
  ///
  /// In en, this message translates to:
  /// **'Add my own'**
  String get addOwn;

  /// No description provided for @manageItems.
  ///
  /// In en, this message translates to:
  /// **'Edit my list'**
  String get manageItems;

  /// No description provided for @checkinTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in'**
  String get checkinTitle;

  /// No description provided for @checkinPrompt.
  ///
  /// In en, this message translates to:
  /// **'How are you today?'**
  String get checkinPrompt;

  /// No description provided for @checkinStart.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get checkinStart;

  /// No description provided for @checkinDone.
  ///
  /// In en, this message translates to:
  /// **'Checked in today'**
  String get checkinDone;

  /// No description provided for @checkinEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get checkinEdit;

  /// No description provided for @checkinNote.
  ///
  /// In en, this message translates to:
  /// **'Anything else? (optional)'**
  String get checkinNote;

  /// No description provided for @checkinSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get checkinSave;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load. Check your connection.'**
  String get loadFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Check your connection and try again.'**
  String get saveFailed;

  /// No description provided for @itemsTitle.
  ///
  /// In en, this message translates to:
  /// **'My list'**
  String get itemsTitle;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItem;

  /// No description provided for @itemTitle.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get itemTitle;

  /// No description provided for @itemCategory.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get itemCategory;

  /// No description provided for @itemCadence.
  ///
  /// In en, this message translates to:
  /// **'How often'**
  String get itemCadence;

  /// No description provided for @itemPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get itemPoints;

  /// No description provided for @itemActive.
  ///
  /// In en, this message translates to:
  /// **'Show on my list'**
  String get itemActive;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @catBasic.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get catBasic;

  /// No description provided for @catPeriodic.
  ///
  /// In en, this message translates to:
  /// **'Every so often'**
  String get catPeriodic;

  /// No description provided for @catMeds.
  ///
  /// In en, this message translates to:
  /// **'Meds'**
  String get catMeds;

  /// No description provided for @catNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get catNutrition;

  /// No description provided for @cadDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get cadDaily;

  /// No description provided for @cadWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get cadWeekly;

  /// No description provided for @cadMonthly.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get cadMonthly;

  /// No description provided for @phItemTeeth.
  ///
  /// In en, this message translates to:
  /// **'Brush teeth'**
  String get phItemTeeth;

  /// No description provided for @phItemShower.
  ///
  /// In en, this message translates to:
  /// **'Shower'**
  String get phItemShower;

  /// No description provided for @phItemMeds.
  ///
  /// In en, this message translates to:
  /// **'Take meds'**
  String get phItemMeds;

  /// No description provided for @phItemVitamins.
  ///
  /// In en, this message translates to:
  /// **'Vitamins'**
  String get phItemVitamins;

  /// No description provided for @phItemMeal.
  ///
  /// In en, this message translates to:
  /// **'Eat a proper meal'**
  String get phItemMeal;

  /// No description provided for @phItemHaircut.
  ///
  /// In en, this message translates to:
  /// **'Haircut'**
  String get phItemHaircut;

  /// No description provided for @phQMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get phQMood;

  /// No description provided for @phQEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get phQEnergy;

  /// No description provided for @phQStress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get phQStress;

  /// No description provided for @phQSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get phQSleep;

  /// No description provided for @phQNeed.
  ///
  /// In en, this message translates to:
  /// **'What I need today'**
  String get phQNeed;

  /// No description provided for @phMoodGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get phMoodGood;

  /// No description provided for @phMoodOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get phMoodOkay;

  /// No description provided for @phMoodLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get phMoodLow;

  /// No description provided for @phEnergyHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get phEnergyHigh;

  /// No description provided for @phEnergyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get phEnergyMedium;

  /// No description provided for @phEnergyLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get phEnergyLow;

  /// No description provided for @phStressCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get phStressCalm;

  /// No description provided for @phStressSome.
  ///
  /// In en, this message translates to:
  /// **'A bit'**
  String get phStressSome;

  /// No description provided for @phStressHigh.
  ///
  /// In en, this message translates to:
  /// **'A lot'**
  String get phStressHigh;

  /// No description provided for @phSleepGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get phSleepGood;

  /// No description provided for @phSleepOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get phSleepOkay;

  /// No description provided for @phSleepPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get phSleepPoor;

  /// No description provided for @phNeedSpace.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get phNeedSpace;

  /// No description provided for @phNeedCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get phNeedCompany;

  /// No description provided for @phNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'A hand'**
  String get phNeedHelp;

  /// No description provided for @phNeedRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get phNeedRest;
}

class _MeLocalizationsDelegate extends LocalizationsDelegate<MeLocalizations> {
  const _MeLocalizationsDelegate();

  @override
  Future<MeLocalizations> load(Locale locale) {
    return SynchronousFuture<MeLocalizations>(lookupMeLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_MeLocalizationsDelegate old) => false;
}

MeLocalizations lookupMeLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return MeLocalizationsEn();
    case 'es':
      return MeLocalizationsEs();
  }

  throw FlutterError(
    'MeLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
