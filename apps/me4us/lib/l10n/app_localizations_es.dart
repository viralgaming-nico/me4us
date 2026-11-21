// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get tagline => 'un poco más yo, un poco más nosotros';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get copyCode => 'Copiar código';

  @override
  String get continueButton => 'Continuar';

  @override
  String get save => 'Guardar';

  @override
  String get yourName => 'Tu nombre';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get createAnAccount => 'Crear una cuenta';

  @override
  String get haveAccount => 'Ya tengo una cuenta';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get or => 'o';

  @override
  String get authNeedEmailPassword =>
      'Ingresá tu correo y una contraseña de al menos 6 caracteres.';

  @override
  String get authCheckEmail =>
      'Revisá tu correo para confirmar la cuenta y después iniciá sesión.';

  @override
  String get authCreateFailed =>
      'No se pudo crear la cuenta. Probá con otro correo.';

  @override
  String get authSignInFailed =>
      'No se pudo iniciar sesión. Revisá tu correo y contraseña.';

  @override
  String get authGoogleFailed =>
      'No se pudo iniciar sesión con Google. Probá de nuevo.';

  @override
  String get loadAccountFailed => 'No se pudo cargar tu cuenta.';

  @override
  String get loadUnionFailed => 'No se pudo cargar tu unión.';

  @override
  String get linkUp => 'Conectarse';

  @override
  String get unionExplainer =>
      'Una unión son 2 o 3 personas, cada una con su teléfono.';

  @override
  String get startUnion => 'Crear una unión';

  @override
  String get haveCode => '¿Tenés un código?';

  @override
  String get inviteCode => 'Código de invitación';

  @override
  String get join => 'Unirme';

  @override
  String get unionReady => 'Tu unión está lista';

  @override
  String get shareCode =>
      'Compartí este código con la otra persona. Vale por 7 días.';

  @override
  String get errAlreadyInUnion => 'Ya estás en una unión.';

  @override
  String get errTooManyAttempts =>
      'Demasiados intentos. Probá de nuevo en una hora.';

  @override
  String get errInvalidCode =>
      'Ese código no es válido. Revisalo y probá de nuevo.';

  @override
  String get errGeneric => 'No funcionó. Probá de nuevo.';

  @override
  String get errConnection =>
      'Algo salió mal. Revisá tu conexión y probá de nuevo.';

  @override
  String get yourDoors => 'Tus puertas';

  @override
  String get doorsExplainer =>
      'Elegí a qué estás abierto. No se muestra nada a menos que todos en tu unión abran esa puerta, y nadie ve tus elecciones individuales. Podés cambiarlo cuando quieras.';

  @override
  String get doorKids => 'Hijos';

  @override
  String get doorKidsDesc =>
      'Calendarios y tareas para los chicos de tu unión.';

  @override
  String get doorThirdPerson => 'Una tercera persona';

  @override
  String get doorThirdPersonDesc =>
      'Incluir a un tercer miembro en lo compartido.';

  @override
  String get doorAlcohol => 'Alcohol';

  @override
  String get doorAlcoholDesc => 'Contenido que menciona bebidas alcohólicas.';

  @override
  String get doorLite => 'Diversión lite';

  @override
  String get doorLiteDesc => 'Contenido juguetón suave, apto mayores de 13.';

  @override
  String get saveFailed =>
      'No se pudo guardar. Revisá tu conexión y probá de nuevo.';

  @override
  String get yourUnion => 'Tu unión';

  @override
  String get you => 'Vos';

  @override
  String memberN(int n) {
    return 'Miembro $n';
  }

  @override
  String get startedUnion => 'Creó esta unión';

  @override
  String get inviteSomeone => 'Invitar a alguien';

  @override
  String get inviteThird => 'Invitar a una tercera persona';

  @override
  String get unionFull => 'Tu unión está completa.';

  @override
  String get inviteFailed => 'No se pudo generar un código. Probá de nuevo.';

  @override
  String get inviteFailedConnection =>
      'No se pudo generar un código. Revisá tu conexión.';

  @override
  String get openForEveryone => 'Abierto para todos';

  @override
  String get doorOpen => 'Abierta';

  @override
  String get doorClosed => 'Cerrada';

  @override
  String get changeDoors => 'Cambiar mis puertas';
}
