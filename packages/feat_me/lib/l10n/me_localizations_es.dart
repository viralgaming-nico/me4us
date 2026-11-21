// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'me_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class MeLocalizationsEs extends MeLocalizations {
  MeLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get meTitle => 'Yo';

  @override
  String pointsToday(int n) {
    return '$n hoy';
  }

  @override
  String pointsWeek(int n) {
    return '$n esta semana';
  }

  @override
  String pointsTotal(int n) {
    return '$n puntos';
  }

  @override
  String pointsPlus(int n) {
    return '+$n';
  }

  @override
  String get todayList => 'Hoy';

  @override
  String get allDoneToday => 'Todo listo por hoy.';

  @override
  String get emptyTitle => 'Tu lista de autocuidado está vacía';

  @override
  String get emptyBody => 'Empezá con algunos básicos o agregá los tuyos.';

  @override
  String get useStarter => 'Usar la lista inicial';

  @override
  String get addOwn => 'Agregar los míos';

  @override
  String get manageItems => 'Editar mi lista';

  @override
  String get checkinTitle => 'Registro diario';

  @override
  String get checkinPrompt => '¿Cómo estás hoy?';

  @override
  String get checkinStart => 'Registrar';

  @override
  String get checkinDone => 'Ya te registraste hoy';

  @override
  String get checkinEdit => 'Editar';

  @override
  String get checkinNote => '¿Algo más? (opcional)';

  @override
  String get checkinSave => 'Guardar';

  @override
  String get loadFailed => 'No se pudo cargar. Revisá tu conexión.';

  @override
  String get retry => 'Reintentar';

  @override
  String get saveFailed =>
      'No se pudo guardar. Revisá tu conexión y probá de nuevo.';

  @override
  String get itemsTitle => 'Mi lista';

  @override
  String get addItem => 'Agregar';

  @override
  String get editItem => 'Editar';

  @override
  String get itemTitle => 'Nombre';

  @override
  String get itemCategory => 'Tipo';

  @override
  String get itemCadence => 'Cada cuánto';

  @override
  String get itemPoints => 'Puntos';

  @override
  String get itemActive => 'Mostrar en mi lista';

  @override
  String get save => 'Guardar';

  @override
  String get catBasic => 'Básicos';

  @override
  String get catPeriodic => 'Cada tanto';

  @override
  String get catMeds => 'Medicación';

  @override
  String get catNutrition => 'Alimentación';

  @override
  String get cadDaily => 'Todos los días';

  @override
  String get cadWeekly => 'Todas las semanas';

  @override
  String get cadMonthly => 'Todos los meses';

  @override
  String get phItemTeeth => 'Cepillarme los dientes';

  @override
  String get phItemShower => 'Bañarme';

  @override
  String get phItemMeds => 'Tomar la medicación';

  @override
  String get phItemVitamins => 'Vitaminas';

  @override
  String get phItemMeal => 'Comer bien';

  @override
  String get phItemHaircut => 'Cortarme el pelo';

  @override
  String get phQMood => 'Ánimo';

  @override
  String get phQEnergy => 'Energía';

  @override
  String get phQStress => 'Estrés';

  @override
  String get phQSleep => 'Sueño';

  @override
  String get phQNeed => 'Lo que necesito hoy';

  @override
  String get phMoodGood => 'Bien';

  @override
  String get phMoodOkay => 'Más o menos';

  @override
  String get phMoodLow => 'Bajo';

  @override
  String get phEnergyHigh => 'Alta';

  @override
  String get phEnergyMedium => 'Media';

  @override
  String get phEnergyLow => 'Baja';

  @override
  String get phStressCalm => 'Tranqui';

  @override
  String get phStressSome => 'Un poco';

  @override
  String get phStressHigh => 'Mucho';

  @override
  String get phSleepGood => 'Bien';

  @override
  String get phSleepOkay => 'Más o menos';

  @override
  String get phSleepPoor => 'Mal';

  @override
  String get phNeedSpace => 'Espacio';

  @override
  String get phNeedCompany => 'Compañía';

  @override
  String get phNeedHelp => 'Una mano';

  @override
  String get phNeedRest => 'Descanso';
}
