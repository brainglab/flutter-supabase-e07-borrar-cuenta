import 'package:app_tareas/datos/tarea.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Tarea.desdeFila lee una fila de Supabase', () {
    final tarea = Tarea.desdeFila({
      'id': 7,
      'titulo': 'Grabar el video',
      'completada': false,
      'user_id': '00000000-0000-0000-0000-000000000000',
      'created_at': '2026-09-26T12:00:00+00:00',
    });

    expect(tarea.id, 7);
    expect(tarea.titulo, 'Grabar el video');
    expect(tarea.completada, isFalse);
  });
}
