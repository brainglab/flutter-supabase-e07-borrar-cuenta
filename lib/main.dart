import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'datos/cuenta.dart';
import 'diseno/tema.dart';
import 'ui/pantalla_tareas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_KEY',
    ),
  );

  // Sin pantalla de login: un usuario anónimo real.
  final auth = Supabase.instance.client.auth;
  if (auth.currentSession == null) {
    await auth.signInAnonymously();
  }

  runApp(
    MaterialApp(
      title: 'Mis tareas',
      theme: temaBrainglab(), // Brainglab UI (lib/diseno)
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: Cuenta().observar(),
        builder: (context, snapshot) {
          final usuario = snapshot.data;
          if (usuario == null) return const _Cargando();
          // La clave es el id: otro usuario, pantalla nueva.
          // Al guardar la cuenta el id no cambia, así que
          // la lista y su stream siguen vivos.
          return PantallaTareas(
            key: ValueKey(usuario.id),
            invitado: usuario.isAnonymous,
            correo: usuario.email,
          );
        },
      ),
    ),
  );
}

/// Entre dos usuarios (al salir), un instante sin sesión.
class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
