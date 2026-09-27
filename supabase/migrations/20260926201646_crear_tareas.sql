-- Tabla de tareas: cada fila pertenece a un usuario
create table public.tareas (
  id bigint generated always as identity primary key,
  titulo text not null,
  completada boolean not null default false,
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);

-- Seguridad: RLS activo y solo los permisos que usa la app
alter table public.tareas enable row level security;
revoke all on table public.tareas from anon, authenticated;
grant select, insert, update on table public.tareas
  to authenticated;

-- Una política por operación
create policy "Leer mis tareas" on public.tareas
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "Crear mis tareas" on public.tareas
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Actualizar mis tareas" on public.tareas
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- Tiempo real: publicar los cambios de la tabla
alter publication supabase_realtime add table public.tareas;
