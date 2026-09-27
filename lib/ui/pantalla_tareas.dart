import 'package:flutter/material.dart';

import '../datos/cuenta.dart';
import '../datos/repositorio_tareas.dart';
import '../datos/tarea.dart';
import '../diseno/componentes.dart';
import '../diseno/marca.dart';
import 'fila_tarea.dart';
import 'pantalla_cuenta.dart';

class PantallaTareas extends StatefulWidget {
  const PantallaTareas({
    super.key,
    required this.invitado,
    this.correo,
  });

  /// Usuario anónimo: todavía sin correo ni contraseña.
  final bool invitado;
  final String? correo;

  @override
  State<PantallaTareas> createState() => _PantallaTareasState();
}

class _PantallaTareasState extends State<PantallaTareas> {
  final _repositorio = RepositorioTareas();
  final _cuenta = Cuenta();
  final _campo = TextEditingController();
  final _foco = FocusNode();

  // Una sola vez: si lo creas en build(),
  // cada redibujado abre una suscripción nueva.
  late final Stream<List<Tarea>> _tareas = _repositorio
      .observar();

  // Dismissible exige que la fila desaparezca al instante;
  // el stream la quita un momento después.
  final _borradas = <int>{};

  @override
  void dispose() {
    _campo.dispose();
    _foco.dispose();
    super.dispose();
  }

  Future<void> _borrar(Tarea tarea) async {
    setState(() => _borradas.add(tarea.id));
    try {
      await _repositorio.borrar(tarea);
    } catch (_) {
      setState(() => _borradas.remove(tarea.id)); // vuelve
    }
  }

  /// Pide confirmación: borrar la cuenta no se deshace.
  Future<void> _borrarCuenta() async {
    final seguro = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmarBorrado(),
    );
    if (seguro != true) return;
    try {
      await _cuenta.borrarCuenta();
    } on ErrorCuenta catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.mensaje)));
    }
  }

  Future<void> _editar(Tarea tarea) async {
    final titulo = await showDialog<String>(
      context: context,
      builder: (_) => _EditarTarea(titulo: tarea.titulo),
    );
    if (titulo == null || titulo == tarea.titulo) return;
    await _repositorio.renombrar(tarea, titulo);
  }

  Future<void> _crear() async {
    final titulo = _campo.text.trim();
    if (titulo.isEmpty) return;
    _campo.clear();
    _foco.requestFocus(); // listo para la siguiente
    await _repositorio.crear(titulo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Marca.e5),
          child: Column(
            children: [
              const Encabezado(
                titulo: 'Mis tareas',
                subtitulo: 'Flutter + Supabase · Brainglab',
              ),
              const SizedBox(height: Marca.e4),
              widget.invitado
                  ? _GuardarCuenta(abrir: _abrirCuenta)
                  : _MiCuenta(
                      correo: widget.correo ?? '',
                      salir: _cuenta.cerrarSesion,
                      borrar: _borrarCuenta,
                    ),
              const SizedBox(height: Marca.e4),
              _nuevaTarea(),
              const SizedBox(height: Marca.e5),
              Expanded(child: _lista()),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirCuenta(ModoCuenta modo) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PantallaCuenta(modo: modo),
      ),
    );
  }

  Widget _nuevaTarea() {
    return Tarjeta(
      padding: const EdgeInsets.all(Marca.e3),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _campo,
              focusNode: _foco,
              decoration: const InputDecoration(
                hintText: 'Nueva tarea',
              ),
              onSubmitted: (_) => _crear(),
            ),
          ),
          const SizedBox(width: Marca.e3),
          FilledButton.icon(
            onPressed: _crear,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Widget _lista() {
    return StreamBuilder<List<Tarea>>(
      stream: _tareas,
      builder: (context, snapshot) {
        if (snapshot.hasError) return _Error(snapshot.error);
        if (!snapshot.hasData) return const _Cargando();
        final tareas = snapshot.data!
            .where((t) => !_borradas.contains(t.id))
            .toList();
        if (tareas.isEmpty) return const _SinTareas();
        return ListView(
          children: [
            _Resumen(tareas: tareas),
            for (final tarea in tareas)
              FilaTarea(
                tarea: tarea,
                onChanged: (_) => _repositorio.alternar(tarea),
                onEditar: () => _editar(tarea),
                onBorrar: () => _borrar(tarea),
              ),
          ],
        );
      },
    );
  }
}

/// Diálogo para cambiar el título de una tarea.
class _EditarTarea extends StatefulWidget {
  const _EditarTarea({required this.titulo});

  final String titulo;

  @override
  State<_EditarTarea> createState() => _EditarTareaState();
}

class _EditarTareaState extends State<_EditarTarea> {
  late final _campo = TextEditingController(
    text: widget.titulo,
  );

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  void _guardar() {
    final titulo = _campo.text.trim();
    if (titulo.isNotEmpty) Navigator.pop(context, titulo);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Marca.base200,
      title: const Text('Editar tarea'),
      content: TextField(
        controller: _campo,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Título'),
        onSubmitted: (_) => _guardar(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

/// Aviso para el invitado: guardar su cuenta o entrar.
class _GuardarCuenta extends StatelessWidget {
  const _GuardarCuenta({required this.abrir});

  final void Function(ModoCuenta modo) abrir;

  @override
  Widget build(BuildContext context) {
    return Tarjeta(
      resaltada: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconoCaja(Icons.person_outline_rounded),
              const SizedBox(width: Marca.e3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estás como invitado',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Guárdala para no perder tus tareas.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Marca.al(Marca.secundario, .7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Marca.e3),
          // Wrap: si no caben en una línea (por ejemplo, con
          // las métricas de la fuente en iOS), baja el segundo.
          Wrap(
            spacing: Marca.e2,
            runSpacing: Marca.e2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton(
                onPressed: () => abrir(ModoCuenta.guardar),
                child: const Text('Guardar mi cuenta'),
              ),
              TextButton(
                onPressed: () => abrir(ModoCuenta.entrar),
                child: const Text('Ya tengo cuenta'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Cuenta guardada: su correo y un menú con Salir y
/// Borrar cuenta.
class _MiCuenta extends StatelessWidget {
  const _MiCuenta({
    required this.correo,
    required this.salir,
    required this.borrar,
  });

  final String correo;
  final Future<void> Function() salir;
  final Future<void> Function() borrar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Insignia(
              correo,
              icono: Icons.verified_user_rounded,
            ),
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Mi cuenta',
          icon: const Icon(Icons.more_vert_rounded),
          color: Marca.base200,
          onSelected: (opcion) =>
              opcion == 'salir' ? salir() : borrar(),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'salir', child: Text('Salir')),
            PopupMenuItem(
              value: 'borrar',
              child: Text(
                'Borrar cuenta',
                style: TextStyle(color: Marca.primario),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// «¿Borrar tu cuenta?»: devuelve true si se confirma.
class _ConfirmarBorrado extends StatelessWidget {
  const _ConfirmarBorrado();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Marca.base200,
      title: const Text('¿Borrar tu cuenta?'),
      content: const Text(
        'Se borrarán tu cuenta y todas tus tareas. '
        'No se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Borrar'),
        ),
      ],
    );
  }
}

/// Cabecera de la lista: cuántas tareas quedan pendientes.
class _Resumen extends StatelessWidget {
  const _Resumen({required this.tareas});

  final List<Tarea> tareas;

  @override
  Widget build(BuildContext context) {
    final pendientes = tareas
        .where((t) => !t.completada)
        .length;
    return Padding(
      padding: const EdgeInsets.only(bottom: Marca.e3),
      child: Row(
        children: [
          Text(
            'TAREAS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Marca.al(Marca.secundario, .6),
            ),
          ),
          const Spacer(),
          Insignia(
            pendientes == 1
                ? '1 pendiente'
                : '$pendientes pendientes',
            icono: Icons.bolt_rounded,
          ),
        ],
      ),
    );
  }
}

class _SinTareas extends StatelessWidget {
  const _SinTareas();

  @override
  Widget build(BuildContext context) {
    return const EstadoVacio(
      icono: Icons.task_alt_rounded,
      titulo: 'Sin tareas todavía',
      texto: 'Escribe la primera y pulsa Agregar.',
    );
  }
}

/// Mientras llega la primera lista.
class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Si el stream informa un error.
class _Error extends StatelessWidget {
  const _Error(this.error);

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return EstadoVacio(
      icono: Icons.cloud_off_rounded,
      titulo: 'No se pudieron cargar las tareas',
      texto: '$error',
    );
  }
}
