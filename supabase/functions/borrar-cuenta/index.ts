// Borra la cuenta de quien llama y, con ella, sus tareas
// (tareas.user_id tiene «on delete cascade»).
// Corre en el servidor: aquí sí se puede usar la secret key.
import { createClient } from 'npm:@supabase/supabase-js@2';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};
const json = (cuerpo: object, status = 200) =>
  Response.json(cuerpo, { status, headers: cors });

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: cors });
  }
  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    JSON.parse(Deno.env.get('SUPABASE_SECRET_KEYS')!).default,
  );

  // 1. ¿Quién llama? Lo dice su token, no el cuerpo
  const token = req.headers
    .get('Authorization')
    ?.replace('Bearer ', '');
  const { data, error } = await admin.auth.getUser(token);
  if (error || !data.user) {
    return json({ error: 'Sin sesión' }, 401);
  }

  // 2. Borrar al usuario: sus tareas se van con él
  const borrado = await admin.auth.admin.deleteUser(
    data.user.id,
  );
  if (borrado.error) {
    return json({ error: borrado.error.message }, 500);
  }
  return json({ borrado: data.user.id });
});
