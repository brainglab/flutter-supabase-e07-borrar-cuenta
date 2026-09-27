import 'package:flutter/material.dart';

import '../datos/tarea.dart';
import '../diseno/marca.dart';

/// Una tarea: tarjeta con casilla (card + checkbox). Se
/// desliza a la izquierda para borrarla; el lápiz la edita.
class FilaTarea extends StatelessWidget {
  const FilaTarea({
    super.key,
    required this.tarea,
    required this.onChanged,
    required this.onEditar,
    required this.onBorrar,
  });

  final Tarea tarea;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onEditar;
  final VoidCallback onBorrar;

  @override
  Widget build(BuildContext context) {
    final hecha = tarea.completada;
    return Padding(
      padding: const EdgeInsets.only(bottom: Marca.e3),
      child: Dismissible(
        key: ValueKey(tarea.id),
        direction: DismissDirection.endToStart,
        background: const _FondoBorrar(),
        onDismissed: (_) => onBorrar(),
        child: Material(
          color: Marca.base200,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(Marca.radioCaja),
            ),
            side: const BorderSide(color: Marca.base300),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Expanded(child: _casilla(hecha)),
              // Fuera de CheckboxListTile, que fusiona la
              // semántica: así «Editar» es su propio botón.
              IconButton(
                onPressed: onEditar,
                tooltip: 'Editar',
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
              const SizedBox(width: Marca.e1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _casilla(bool hecha) {
    return CheckboxListTile(
      value: hecha,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Marca.e3,
        vertical: Marca.e1,
      ),
      title: Text(
        tarea.titulo,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: hecha
              ? Marca.al(Marca.secundario, .5)
              : Marca.texto,
          decoration: hecha
              ? TextDecoration.lineThrough
              : TextDecoration.none,
          decorationColor: Marca.primario,
        ),
      ),
    );
  }
}

/// Lo que aparece detrás de la tarjeta al deslizarla.
class _FondoBorrar extends StatelessWidget {
  const _FondoBorrar();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: Marca.e5),
      decoration: BoxDecoration(
        color: Marca.al(Marca.primario, .18),
        borderRadius: BorderRadius.circular(Marca.radioCaja),
      ),
      child: const Icon(
        Icons.delete_outline_rounded,
        color: Marca.primario,
      ),
    );
  }
}
