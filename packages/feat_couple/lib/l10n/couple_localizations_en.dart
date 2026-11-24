// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'couple_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CoupleLocalizationsEn extends CoupleLocalizations {
  CoupleLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get calendarTitle => 'Our calendar';

  @override
  String get nudgesTitle => 'Nudges';

  @override
  String get paywallTitle => 'Me + You';

  @override
  String get paywallBody =>
      'The shared calendar and nudges are part of Me + You. Unlocking is coming soon.';

  @override
  String get paywallNote => 'Me stays free.';

  @override
  String get noEvents => 'Nothing planned yet.';

  @override
  String get addEvent => 'Add event';

  @override
  String get editEvent => 'Edit event';

  @override
  String get eventTitle => 'What';

  @override
  String get allDay => 'All day';

  @override
  String get starts => 'Starts';

  @override
  String get ends => 'Ends';

  @override
  String get noEnd => 'No end time';

  @override
  String get sharedEvent => 'Shared';

  @override
  String get sharedEventDesc => 'Anyone in your union can change it.';

  @override
  String get mineEvent => 'Mine';

  @override
  String get mineEventDesc => 'Everyone sees it; only you can change it.';

  @override
  String get reminders => 'Remind me';

  @override
  String remindMinutes(int n) {
    return '$n min before';
  }

  @override
  String get remindHour => '1 hour before';

  @override
  String get remindDay => '1 day before';

  @override
  String get remindersLater =>
      'Shared events alert everyone in your union; your own events alert only you.';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get loadFailed => 'Couldn\'t load. Check your connection.';

  @override
  String get saveFailed =>
      'Couldn\'t save. Check your connection and try again.';

  @override
  String get acceptNudges => 'Accept nudges';

  @override
  String get acceptNudgesDesc =>
      'Let the people in your union send you nudges.';

  @override
  String get sendTo => 'Send to';

  @override
  String get kindFlag => 'Nudge';

  @override
  String get kindPresence => 'Be present';

  @override
  String get presenceDesc => 'Sends only: \"go be present for a moment\".';

  @override
  String get nudgeText => 'Short message (optional)';

  @override
  String get send => 'Send';

  @override
  String get sent => 'Sent.';

  @override
  String get errNotAccepting => 'They haven\'t turned on nudges.';

  @override
  String get errRateLimited =>
      'You\'ve sent 3 nudges in the last 24 hours. Try again later.';

  @override
  String get errNotEntitled => 'Me + You isn\'t unlocked.';

  @override
  String get errGeneric => 'That didn\'t work. Please try again.';

  @override
  String get received => 'Received';

  @override
  String get sentList => 'Sent';

  @override
  String get noNudges => 'No nudges yet.';

  @override
  String get presenceMessage => 'Go be present for a moment.';

  @override
  String get nudgeFallback => 'Thinking of you.';

  @override
  String get markRead => 'Mark read';

  @override
  String get nobodyToNudge => 'Nobody else is in your union yet.';
}
