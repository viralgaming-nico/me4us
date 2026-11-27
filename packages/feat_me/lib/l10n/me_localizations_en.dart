// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'me_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class MeLocalizationsEn extends MeLocalizations {
  MeLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get meTitle => 'Me';

  @override
  String pointsToday(int n) {
    return '$n today';
  }

  @override
  String pointsWeek(int n) {
    return '$n this week';
  }

  @override
  String pointsTotal(int n) {
    return '$n points';
  }

  @override
  String pointsPlus(int n) {
    return '+$n';
  }

  @override
  String get todayList => 'Today';

  @override
  String get allDoneToday => 'All done for today.';

  @override
  String get emptyTitle => 'Your self-care list is empty';

  @override
  String get emptyBody => 'Start with a few basics, or add your own.';

  @override
  String get useStarter => 'Use the starter list';

  @override
  String get addOwn => 'Add my own';

  @override
  String get manageItems => 'Edit my list';

  @override
  String get checkinTitle => 'Daily check-in';

  @override
  String get checkinPrompt => 'How are you today?';

  @override
  String get checkinStart => 'Check in';

  @override
  String get checkinDone => 'Checked in today';

  @override
  String get checkinEdit => 'Edit';

  @override
  String get checkinNote => 'Anything else? (optional)';

  @override
  String get checkinSave => 'Save';

  @override
  String get loadFailed => 'Couldn\'t load. Check your connection.';

  @override
  String get retry => 'Try again';

  @override
  String get saveFailed =>
      'Couldn\'t save. Check your connection and try again.';

  @override
  String get itemsTitle => 'My list';

  @override
  String get addItem => 'Add item';

  @override
  String get editItem => 'Edit item';

  @override
  String get itemTitle => 'Name';

  @override
  String get itemCategory => 'Type';

  @override
  String get itemCadence => 'How often';

  @override
  String get itemPoints => 'Points';

  @override
  String get itemActive => 'Show on my list';

  @override
  String get save => 'Save';

  @override
  String get catBasic => 'Basics';

  @override
  String get catPeriodic => 'Every so often';

  @override
  String get catMeds => 'Meds';

  @override
  String get catNutrition => 'Nutrition';

  @override
  String get cadDaily => 'Every day';

  @override
  String get cadWeekly => 'Every week';

  @override
  String get cadMonthly => 'Every month';

  @override
  String get phItemTeeth => 'Brush teeth';

  @override
  String get phItemShower => 'Shower';

  @override
  String get phItemMeds => 'Take meds';

  @override
  String get phItemVitamins => 'Vitamins';

  @override
  String get phItemMeal => 'Eat a proper meal';

  @override
  String get phItemHaircut => 'Haircut';

  @override
  String get phQMood => 'Mood';

  @override
  String get phQEnergy => 'Energy';

  @override
  String get phQStress => 'Stress';

  @override
  String get phQSleep => 'Sleep';

  @override
  String get phQNeed => 'What I need today';

  @override
  String get phMoodGood => 'Good';

  @override
  String get phMoodOkay => 'Okay';

  @override
  String get phMoodLow => 'Low';

  @override
  String get phEnergyHigh => 'High';

  @override
  String get phEnergyMedium => 'Medium';

  @override
  String get phEnergyLow => 'Low';

  @override
  String get phStressCalm => 'Calm';

  @override
  String get phStressSome => 'A bit';

  @override
  String get phStressHigh => 'A lot';

  @override
  String get phSleepGood => 'Good';

  @override
  String get phSleepOkay => 'Okay';

  @override
  String get phSleepPoor => 'Poor';

  @override
  String get phNeedSpace => 'Space';

  @override
  String get phNeedCompany => 'Company';

  @override
  String get phNeedHelp => 'A hand';

  @override
  String get phNeedRest => 'Rest';
}
