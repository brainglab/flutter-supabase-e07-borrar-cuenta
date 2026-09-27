-- Borrar tareas: su permiso y su política, igual que las demás
grant delete on table public.tareas to authenticated;

create policy "Borrar mis tareas" on public.tareas
  for delete to authenticated
  using ((select auth.uid()) = user_id);

-- Ojo: Realtime no aplica RLS a los DELETE. Todos los que
-- escuchan la tabla reciben el id borrado (solo el id).
