/// Una fila de la tabla `tareas`.
class Tarea {
  const Tarea({
    required this.id,
    required this.titulo,
    required this.completada,
  });

  factory Tarea.desdeFila(Map<String, dynamic> fila) => Tarea(
    id: fila['id'] as int,
    titulo: fila['titulo'] as String,
    completada: fila['completada'] as bool,
  );

  final int id;
  final String titulo;
  final bool completada;
}
