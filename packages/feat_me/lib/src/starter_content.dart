// PLACEHOLDER CONTENT. Nick and Heather approve all real content; replace the labels in
// lib/l10n/me_*.arb (keys starting with "ph") when they do.
// IDs below are permanent: never rename them (stored answers key on them).

import '../l10n/me_localizations.dart';
import 'models.dart';

/// A starter self-care item offered on an empty list.
class StarterItem {
  const StarterItem(this.id, this.category, this.cadence, this.points);
  final String id;
  final SelfcareCategory category;
  final Cadence cadence;
  final int points;
}

/// Examples named in CLAUDE.md (teeth, shower, meds, vitamins, meals, haircut).
const starterItems = [
  StarterItem('me.basic.teeth', SelfcareCategory.basic, Cadence.daily, 1),
  StarterItem('me.basic.shower', SelfcareCategory.basic, Cadence.daily, 1),
  StarterItem('me.meds.meds', SelfcareCategory.meds, Cadence.daily, 2),
  StarterItem('me.nutrition.vitamins', SelfcareCategory.nutrition, Cadence.daily, 1),
  StarterItem('me.nutrition.meal', SelfcareCategory.nutrition, Cadence.daily, 1),
  StarterItem('me.periodic.haircut', SelfcareCategory.periodic, Cadence.monthly, 3),
];

String starterTitle(MeLocalizations l, String id) => switch (id) {
      'me.basic.teeth' => l.phItemTeeth,
      'me.basic.shower' => l.phItemShower,
      'me.meds.meds' => l.phItemMeds,
      'me.nutrition.vitamins' => l.phItemVitamins,
      'me.nutrition.meal' => l.phItemMeal,
      'me.periodic.haircut' => l.phItemHaircut,
      _ => id,
    };

class CheckinQuestion {
  const CheckinQuestion(this.id, this.choices);
  final String id;
  final List<String> choices;
}

/// The daily check-in: mood, energy, stress, sleep, "what I need today".
const checkinQuestions = [
  CheckinQuestion('mood', ['good', 'okay', 'low']),
  CheckinQuestion('energy', ['high', 'medium', 'low']),
  CheckinQuestion('stress', ['calm', 'some', 'high']),
  CheckinQuestion('sleep', ['good', 'okay', 'poor']),
  CheckinQuestion('need', ['space', 'company', 'help', 'rest']),
];

String questionLabel(MeLocalizations l, String qId) => switch (qId) {
      'mood' => l.phQMood,
      'energy' => l.phQEnergy,
      'stress' => l.phQStress,
      'sleep' => l.phQSleep,
      'need' => l.phQNeed,
      _ => qId,
    };

String choiceLabel(MeLocalizations l, String qId, String choiceId) => switch ((qId, choiceId)) {
      ('mood', 'good') => l.phMoodGood,
      ('mood', 'okay') => l.phMoodOkay,
      ('mood', 'low') => l.phMoodLow,
      ('energy', 'high') => l.phEnergyHigh,
      ('energy', 'medium') => l.phEnergyMedium,
      ('energy', 'low') => l.phEnergyLow,
      ('stress', 'calm') => l.phStressCalm,
      ('stress', 'some') => l.phStressSome,
      ('stress', 'high') => l.phStressHigh,
      ('sleep', 'good') => l.phSleepGood,
      ('sleep', 'okay') => l.phSleepOkay,
      ('sleep', 'poor') => l.phSleepPoor,
      ('need', 'space') => l.phNeedSpace,
      ('need', 'company') => l.phNeedCompany,
      ('need', 'help') => l.phNeedHelp,
      ('need', 'rest') => l.phNeedRest,
      _ => choiceId,
    };
