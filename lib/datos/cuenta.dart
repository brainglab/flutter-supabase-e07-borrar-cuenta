import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Único punto de la app que habla con Supabase Auth.
///
/// Guardar la cuenta de un invitado no crea otro usuario:
/// le agrega correo y contraseña al mismo. Su id no cambia,
/// así que las políticas de RLS le siguen dando sus tareas.
class Cuenta {
  final GoTrueClient _auth = Supabase.instance.client.auth;

  /// El usuario actual, cada vez que cambia. Un error de
  /// sesión (por ejemplo, al volver de Google) no cambia de
  /// usuario: se descarta para no vaciar la pantalla.
  Stream<User?> observar() => _auth.onAuthStateChange
      .map((estado) => estado.session?.user)
      .handleError((Object _) {});

  /// Paso 1: Supabase envía un código a ese correo.
  Future<void> agregarCorreo(String correo) => _intentar(
    () => _auth.updateUser(UserAttributes(email: correo)),
  );

  /// Paso 2: el código confirma el correo.
  /// Desde aquí, el usuario ya no es anónimo.
  Future<void> confirmarCodigo(String correo, String codigo) =>
      _intentar(
        () => _auth.verifyOTP(
          type: OtpType.emailChange,
          email: correo,
          token: codigo,
        ),
      );

  /// Paso 3: con el correo confirmado, la contraseña.
  Future<void> crearContrasena(String contrasena) => _intentar(
    () =>
        _auth.updateUser(UserAttributes(password: contrasena)),
  );

  /// Guardar con Google: suma su cuenta de Google al mismo
  /// usuario (requiere enable_manual_linking). En web va a
  /// Google y vuelve; en Android e iOS, con un token de ID.
  Future<void> guardarConGoogle() => _intentar(() async {
    if (kIsWeb) {
      await _auth.linkIdentity(OAuthProvider.google);
    } else {
      await _auth.linkIdentityWithIdToken(
        provider: OAuthProvider.google,
        idToken: await _tokenDeGoogle(),
      );
    }
  });

  /// En otro dispositivo: entra con la misma cuenta de Google.
  Future<void> entrarConGoogle() => _intentar(() async {
    if (kIsWeb) {
      await _auth.signInWithOAuth(OAuthProvider.google);
    } else {
      await _auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: await _tokenDeGoogle(),
      );
    }
  });

  /// Android e iOS: el inicio de sesión nativo de Google
  /// entrega un token de ID que Supabase verifica.
  Future<String> _tokenDeGoogle() async {
    await _google;
    final cuenta = await GoogleSignIn.instance.authenticate();
    final token = cuenta.authentication.idToken;
    if (token == null) {
      throw const ErrorCuenta('Google no respondió.');
    }
    return token;
  }

  /// google_sign_in se inicializa una sola vez por app.
  static final Future<void>
  _google = GoogleSignIn.instance.initialize(
    // El token es para Supabase: lleva el ID del cliente web.
    serverClientId: const String.fromEnvironment(
      'GOOGLE_WEB_CLIENT_ID',
    ),
    clientId: defaultTargetPlatform == TargetPlatform.iOS
        ? const String.fromEnvironment('GOOGLE_IOS_CLIENT_ID')
        : null,
  );

  /// Recuperar: Supabase envía un código si el correo tiene
  /// cuenta. Si no la tiene, responde igual: no lo revela.
  Future<void> pedirCodigo(String correo) =>
      _intentar(() => _auth.resetPasswordForEmail(correo));

  /// El código abre una sesión de esa cuenta; después,
  /// crearContrasena guarda la nueva.
  Future<void> confirmarRecuperacion(
    String correo,
    String codigo,
  ) => _intentar(
    () => _auth.verifyOTP(
      type: OtpType.recovery,
      email: correo,
      token: codigo,
    ),
  );

  /// En otro dispositivo: entra con su cuenta.
  Future<void> iniciarSesion(
    String correo,
    String contrasena,
  ) => _intentar(
    () => _auth.signInWithPassword(
      email: correo,
      password: contrasena,
    ),
  );

  /// Borra la cuenta y sus tareas. Lo hace la Edge Function
  /// borrar-cuenta, en el servidor: la secret key nunca
  /// está en la app. Después sigue un invitado nuevo.
  Future<void> borrarCuenta() => _intentar(() async {
    await Supabase.instance.client.functions.invoke(
      'borrar-cuenta',
    );
    await _auth.signOut(); // ignora que el usuario ya no exista
    await _auth.signInAnonymously();
  });

  /// Al salir, la app sigue con un invitado nuevo.
  Future<void> cerrarSesion() => _intentar(() async {
    await _auth.signOut();
    await _auth.signInAnonymously();
  });

  Future<void> _intentar(Future<void> Function() accion) async {
    try {
      await accion();
    } on AuthException catch (e) {
      throw ErrorCuenta.desde(e);
    } on FunctionException {
      throw const ErrorCuenta('No se pudo borrar la cuenta.');
    } on GoogleSignInException catch (e) {
      throw ErrorCuenta(
        e.code == GoogleSignInExceptionCode.canceled
            ? 'Cancelaste el inicio de sesión con Google.'
            : 'Google no pudo iniciar sesión.',
      );
    }
  }
}

/// Error de Auth con un mensaje listo para la pantalla.
class ErrorCuenta implements Exception {
  const ErrorCuenta(this.mensaje);

  /// Códigos de error de Auth (docs de Supabase:
  /// guides/auth/debugging/error-codes).
  factory ErrorCuenta.desde(AuthException e) =>
      ErrorCuenta(switch (e.code) {
        'email_exists' => 'Ese correo ya tiene una cuenta.',
        'identity_already_exists' =>
          'Esa cuenta de Google ya es de otro usuario.',
        'validation_failed' => 'Revisa el correo.',
        'otp_expired' => 'El código no es válido o venció.',
        'weak_password' => 'Usa al menos 6 caracteres.',
        'same_password' => 'Usa una contraseña distinta.',
        'invalid_credentials' =>
          'Correo o contraseña incorrectos.',
        'over_email_send_rate_limit' =>
          'Espera unos segundos antes de pedir otro código.',
        _ => 'No se pudo completar. Inténtalo de nuevo.',
      });

  final String mensaje;

  @override
  String toString() => mensaje;
}
