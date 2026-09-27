import 'package:app_tareas/datos/cuenta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  // Códigos reales devueltos por Supabase local
  // (fuente/verificacion/probar_cuenta.sh).
  test('ErrorCuenta traduce los códigos de Auth', () {
    String mensaje(String? code) =>
        ErrorCuenta.desde(AuthException('x', code: code))
            .mensaje;

    expect(
      mensaje('email_exists'),
      'Ese correo ya tiene una cuenta.',
    );
    expect(
      mensaje('otp_expired'),
      'El código no es válido o venció.',
    );
    expect(
      mensaje('weak_password'),
      'Usa al menos 6 caracteres.',
    );
    expect(
      mensaje('same_password'),
      'Usa una contraseña distinta.',
    );
    expect(
      mensaje('invalid_credentials'),
      'Correo o contraseña incorrectos.',
    );
    expect(
      mensaje(null),
      'No se pudo completar. Inténtalo de nuevo.',
    );
  });
}
