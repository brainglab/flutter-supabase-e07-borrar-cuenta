# Borrar la cuenta y sus datos (Edge Function) · Flutter + Supabase

**Episodio 7 de 8** de la serie *Flutter + Supabase con Claude Code* de [Brainglab](https://www.youtube.com/@brainglab). Es la app que se explica en el video, tal como queda al final del episodio.

## Qué hay en este episodio

- Edge Function `borrar-cuenta`: sabe quién llama por su token y usa `admin.auth.admin.deleteUser`.
- Las tareas se van en cascada (`on delete cascade`).
- La app invoca la función (`functions.invoke`) y sigue con un invitado nuevo.

## Versiones

Flutter 3.47.5 (con [FVM](https://fvm.app), fijado en `.fvmrc`) · supabase_flutter 2.17 · Supabase CLI 2.118 · google_sign_in 7.2

## Ejecutar con Supabase local

```bash
fvm install                 # la versión de Flutter de .fvmrc (3.47.5)
fvm flutter pub get
supabase start              # Supabase completo en local (necesita Docker)
supabase status             # copia API_URL y PUBLISHABLE_KEY a .env.local (ver .env.example)
supabase functions serve    # en otra terminal: la Edge Function borrar-cuenta
fvm flutter run -d chrome --dart-define-from-file=.env.local
# Los correos con el código llegan a Mailpit: http://127.0.0.1:54324
```

### Google

1. En Google Cloud (Google Auth Platform → Clients) crea un cliente **Aplicación web** con la URL de retorno `http://127.0.0.1:54321/auth/v1/callback` (y la de tu proyecto en la nube si lo usas: `https://<ref>.supabase.co/auth/v1/callback`).
2. `cp supabase/.env.example supabase/.env` y pon ahí su ID y su secreto. **El secreto solo lo usa Supabase: nunca va en la app.**
3. Para Android e iOS, crea además un cliente **Android** (paquete `com.brainglab.app_tareas` + SHA-1 de tu certificado: `cd android && ./gradlew signingReport`) y uno **iOS** (bundle `com.brainglab.appTareas`). En `supabase/.env` van los tres IDs separados por comas, el web primero.
4. Crea `.env.android` (`SUPABASE_URL=http://10.0.2.2:54321`) y `.env.ios` (`SUPABASE_URL=http://127.0.0.1:54321`) con la publishable key, `GOOGLE_WEB_CLIENT_ID` y, en iOS, `GOOGLE_IOS_CLIENT_ID`.
5. En `ios/Runner/Info.plist`, el esquema de URL (`CFBundleURLTypes`) debe ser **el ID de tu cliente iOS al revés** (`com.googleusercontent.apps.…`): cambia el del video por el tuyo.

```bash
fvm flutter run -d <emulador> --dart-define-from-file=.env.android
fvm flutter run -d <simulador> --dart-define-from-file=.env.ios
```

## Seguridad

- Los `.env` están en `.gitignore`. La app solo usa la **publishable key**, que puede ir en el cliente; la **secret key** nunca entra en la app.
- Cada tabla tiene RLS activo y una política por operación (`supabase/migrations/`).

## La serie

| # | Episodio |
|---|---|
| 1 | [App de tareas con Flutter, Supabase y Claude Code](https://github.com/brainglab/flutter-supabase-e01-app-tareas) |
| 2 | [De usuario anónimo a cuenta real](https://github.com/brainglab/flutter-supabase-e02-de-anonimo-a-cuenta) |
| 3 | [Guardar la cuenta con Google (web)](https://github.com/brainglab/flutter-supabase-e03-cuenta-con-google) |
| 4 | [Google en Android e iOS](https://github.com/brainglab/flutter-supabase-e04-google-nativo) |
| 5 | [Editar y borrar tareas](https://github.com/brainglab/flutter-supabase-e05-editar-y-borrar) |
| 6 | [Recuperar la contraseña con un código](https://github.com/brainglab/flutter-supabase-e06-recuperar-contrasena) |
| 7 | [Borrar la cuenta y sus datos (Edge Function)](https://github.com/brainglab/flutter-supabase-e07-borrar-cuenta) **(este episodio)** |
| 8 | [De local a la nube (final de la serie)](https://github.com/brainglab/flutter-supabase-e08-de-local-a-la-nube) |

Hecho por [Brainglab](https://www.brainglab.com) · videos en [YouTube](https://www.youtube.com/@brainglab).
