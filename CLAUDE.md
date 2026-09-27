# App de tareas · Flutter + Supabase

## Stack
- Flutter 3.47.5 vía FVM · supabase_flutter ^2.17
- Supabase: Postgres, Auth (anónima, correo y Google) y Realtime

## Reglas
- Inicializa con `publishableKey`: `anonKey` está obsoleto.
- La secret key nunca entra en la app.
- Configuración solo con `--dart-define-from-file=.env`.
- Cada tabla: RLS activo, grants mínimos
  y una política por operación.
- La UI no llama a Supabase: todo pasa por `lib/datos/`.

## Tareas
- Borrar: `grant delete` y su política «Borrar mis tareas».
- Realtime avisa de cada DELETE a todos los suscriptores,
  solo con el id: RLS no filtra los DELETE. El id no debe
  revelar nada.
- Dismissible: la fila se oculta al instante (`_borradas`)
  y el stream la quita después.

## Cuenta
- Todo empieza con un invitado (`signInAnonymously`).
- Guardar la cuenta no crea otro usuario: `updateUser`
  con el correo, `verifyOTP` con el código y, al final,
  la contraseña. El id no cambia.
- Con Google, `linkIdentity` (vinculación manual activa).
  En web vuelve a la app por la URL del sitio.
- Recuperar la contraseña: `resetPasswordForEmail`,
  `verifyOTP` (tipo recovery) y `updateUser`. Plantilla
  «recovery» con `{{ .Token }}`. No revelar si el correo
  existe: la respuesta es la misma.
- Auth solo desde `lib/datos/cuenta.dart`.

## Servidor
- Lo que necesita la secret key va en una Edge Function
  (`supabase/functions/`), nunca en la app.
- La función sabe quién llama por su token, no por el
  cuerpo de la petición.

## Forma de trabajar
- Antes de editar, propón un plan y espera mi OK.
- Al terminar: `fvm flutter analyze` sin avisos.
