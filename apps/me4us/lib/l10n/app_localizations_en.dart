// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tagline => 'a little more me, a little more us';

  @override
  String get signOut => 'Sign out';

  @override
  String get tryAgain => 'Try again';

  @override
  String get copyCode => 'Copy code';

  @override
  String get continueButton => 'Continue';

  @override
  String get save => 'Save';

  @override
  String get yourName => 'Your name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get haveAccount => 'I already have an account';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get or => 'or';

  @override
  String get authNeedEmailPassword =>
      'Enter your email and a password of at least 6 characters.';

  @override
  String get authCheckEmail =>
      'Check your email to confirm your account, then sign in.';

  @override
  String get authCreateFailed =>
      'Couldn\'t create the account. Try a different email.';

  @override
  String get authSignInFailed =>
      'Couldn\'t sign in. Check your email and password.';

  @override
  String get authGoogleFailed =>
      'Couldn\'t sign in with Google. Please try again.';

  @override
  String get loadAccountFailed => 'Couldn\'t load your account.';

  @override
  String get loadUnionFailed => 'Couldn\'t load your union.';

  @override
  String get linkUp => 'Link up';

  @override
  String get unionExplainer => 'A union is 2 or 3 people on their own phones.';

  @override
  String get startUnion => 'Start a union';

  @override
  String get haveCode => 'Have a code?';

  @override
  String get inviteCode => 'Invite code';

  @override
  String get join => 'Join';

  @override
  String get unionReady => 'Your union is ready';

  @override
  String get shareCode =>
      'Share this code with the other person. It works for 7 days.';

  @override
  String get errAlreadyInUnion => 'You are already in a union.';

  @override
  String get errTooManyAttempts =>
      'Too many attempts. Please try again in an hour.';

  @override
  String get errInvalidCode =>
      'That code isn\'t valid. Check it and try again.';

  @override
  String get errGeneric => 'That did not work. Please try again.';

  @override
  String get errConnection =>
      'Something went wrong. Check your connection and try again.';

  @override
  String get yourDoors => 'Your doors';

  @override
  String get doorsExplainer =>
      'Choose what you are open to. Nothing is shown unless everyone in your union opens that door, and nobody sees your individual choices. You can change this any time.';

  @override
  String get doorKids => 'Kids';

  @override
  String get doorKidsDesc => 'Calendars and tasks for children in your union.';

  @override
  String get doorThirdPerson => 'A third person';

  @override
  String get doorThirdPersonDesc => 'Include a third member in shared things.';

  @override
  String get doorAlcohol => 'Alcohol';

  @override
  String get doorAlcoholDesc => 'Content that mentions drinking.';

  @override
  String get doorLite => 'Lite fun';

  @override
  String get doorLiteDesc => 'Mild, PG-13 playful content.';

  @override
  String get saveFailed =>
      'Couldn\'t save. Check your connection and try again.';

  @override
  String get yourUnion => 'Your union';

  @override
  String get you => 'You';

  @override
  String memberN(int n) {
    return 'Member $n';
  }

  @override
  String get startedUnion => 'Started this union';

  @override
  String get inviteSomeone => 'Invite someone';

  @override
  String get inviteThird => 'Invite a third person';

  @override
  String get unionFull => 'Your union is full.';

  @override
  String get inviteFailed => 'Couldn\'t make a code. Please try again.';

  @override
  String get inviteFailedConnection =>
      'Couldn\'t make a code. Check your connection.';

  @override
  String get openForEveryone => 'Open for everyone';

  @override
  String get doorOpen => 'Open';

  @override
  String get doorClosed => 'Closed';

  @override
  String get changeDoors => 'Change my doors';

  @override
  String get tabMe => 'Me';

  @override
  String get tabUs => 'Us';

  @override
  String get calendar => 'Calendar';

  @override
  String get nudges => 'Nudges';

  @override
  String get reminderInHour => 'Starts in 1 hour';

  @override
  String get reminderInDay => 'Starts in 1 day';

  @override
  String reminderInMinutes(int n) {
    return 'Starts in $n min';
  }
}
