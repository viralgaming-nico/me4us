// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'couple_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class CoupleLocalizationsEs extends CoupleLocalizations {
  CoupleLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get calendarTitle => 'Nuestro calendario';

  @override
  String get nudgesTitle => 'Toques';

  @override
  String get paywallTitle => 'Yo + Vos';

  @override
  String get paywallBody =>
      'El calendario compartido y los toques son parte de Yo + Vos. Muy pronto vas a poder desbloquearlo.';

  @override
  String get paywallNote => 'Yo sigue siendo gratis.';

  @override
  String get noEvents => 'Todavía no hay nada planeado.';

  @override
  String get addEvent => 'Agregar evento';

  @override
  String get editEvent => 'Editar evento';

  @override
  String get eventTitle => 'Qué';

  @override
  String get allDay => 'Todo el día';

  @override
  String get starts => 'Empieza';

  @override
  String get ends => 'Termina';

  @override
  String get noEnd => 'Sin hora de fin';

  @override
  String get sharedEvent => 'Compartido';

  @override
  String get sharedEventDesc => 'Cualquiera de tu unión puede cambiarlo.';

  @override
  String get mineEvent => 'Mío';

  @override
  String get mineEventDesc => 'Todos lo ven; solo vos podés cambiarlo.';

  @override
  String get reminders => 'Avisarme';

  @override
  String remindMinutes(int n) {
    return '$n min antes';
  }

  @override
  String get remindHour => '1 hora antes';

  @override
  String get remindDay => '1 día antes';

  @override
  String get remindersLater =>
      'Los avisos se guardan ahora; las alertas en el teléfono llegan en una próxima versión.';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Borrar';

  @override
  String get today => 'Hoy';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get loadFailed => 'No se pudo cargar. Revisá tu conexión.';

  @override
  String get saveFailed =>
      'No se pudo guardar. Revisá tu conexión y probá de nuevo.';

  @override
  String get acceptNudges => 'Aceptar toques';

  @override
  String get acceptNudgesDesc =>
      'Permitir que la gente de tu unión te mande toques.';

  @override
  String get sendTo => 'Mandar a';

  @override
  String get kindFlag => 'Toque';

  @override
  String get kindPresence => 'Estar presente';

  @override
  String get presenceDesc =>
      'Solo manda: \"andá a estar presente un momento\".';

  @override
  String get nudgeText => 'Mensaje corto (opcional)';

  @override
  String get send => 'Mandar';

  @override
  String get sent => 'Enviado.';

  @override
  String get errNotAccepting => 'No activó los toques.';

  @override
  String get errRateLimited =>
      'Ya mandaste 3 toques en las últimas 24 horas. Probá más tarde.';

  @override
  String get errNotEntitled => 'Yo + Vos no está desbloqueado.';

  @override
  String get errGeneric => 'No funcionó. Probá de nuevo.';

  @override
  String get received => 'Recibidos';

  @override
  String get sentList => 'Enviados';

  @override
  String get noNudges => 'Todavía no hay toques.';

  @override
  String get presenceMessage => 'Andá a estar presente un momento.';

  @override
  String get nudgeFallback => 'Pensando en vos.';

  @override
  String get markRead => 'Marcar como leído';

  @override
  String get nobodyToNudge => 'Todavía no hay nadie más en tu unión.';
}
