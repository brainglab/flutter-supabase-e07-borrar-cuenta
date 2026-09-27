import 'package:flutter/material.dart';

import '../datos/cuenta.dart';
import '../diseno/componentes.dart';
import '../diseno/marca.dart';

enum ModoCuenta { guardar, entrar, recuperar }

/// Guardar la cuenta de un invitado (con Google, o con
/// correo → código → contraseña), entrar con una que existe
/// o recuperar su contraseña (correo → código → contraseña).
class PantallaCuenta extends StatefulWidget {
  const PantallaCuenta({super.key, required this.modo});

  final ModoCuenta modo;

  @override
  State<PantallaCuenta> createState() => _PantallaCuentaState();
}

class _PantallaCuentaState extends State<PantallaCuenta> {
  final _cuenta = Cuenta();
  final _correo = TextEditingController();
  final _codigo = TextEditingController();
  final _clave = TextEditingController();
  var _paso = 1; // 1 correo · 2 código · 3 contraseña
  var _ocupado = false;
  String? _error;

  bool get _guardar => widget.modo == ModoCuenta.guardar;
  bool get _entrar => widget.modo == ModoCuenta.entrar;
  bool get _recuperar => widget.modo == ModoCuenta.recuperar;

  @override
  void dispose() {
    _correo.dispose();
    _codigo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _continuar() => _hacer(_siguientePaso);

  /// En web, la pestaña va a Google y la app vuelve a abrir
  /// con la sesión ya guardada.
  Future<void> _conGoogle() => _hacer(
    _guardar
        ? _cuenta.guardarConGoogle
        : _cuenta.entrarConGoogle,
  );

  Future<void> _hacer(Future<void> Function() accion) async {
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      await accion();
    } on ErrorCuenta catch (e) {
      setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _siguientePaso() async {
    final correo = _correo.text.trim();
    if (_entrar) {
      await _cuenta.iniciarSesion(correo, _clave.text);
      return _volver();
    }
    switch (_paso) {
      case 1:
        await (_recuperar
            ? _cuenta.pedirCodigo(correo)
            : _cuenta.agregarCorreo(correo));
        setState(() => _paso = 2);
      case 2:
        final codigo = _codigo.text.trim();
        await (_recuperar
            ? _cuenta.confirmarRecuperacion(correo, codigo)
            : _cuenta.confirmarCodigo(correo, codigo));
        setState(() => _paso = 3);
      case 3:
        await _cuenta.crearContrasena(_clave.text);
        _volver();
    }
  }

  void _volver() {
    if (mounted) Navigator.pop(context);
  }

  /// «¿Olvidaste tu contraseña?»: reemplaza esta pantalla.
  void _olvide() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            const PantallaCuenta(modo: ModoCuenta.recuperar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Marca.e5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _volver,
                  tooltip: 'Volver',
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              const SizedBox(height: Marca.e3),
              Encabezado(
                titulo: switch (widget.modo) {
                  ModoCuenta.guardar => 'Guarda tu cuenta',
                  ModoCuenta.entrar => 'Ya tengo cuenta',
                  ModoCuenta.recuperar => 'Nueva contraseña',
                },
                subtitulo: switch (widget.modo) {
                  ModoCuenta.guardar =>
                    'Tus tareas se quedan contigo',
                  ModoCuenta.entrar =>
                    'Entra con Google o con tu correo',
                  ModoCuenta.recuperar =>
                    'Con un código por correo',
                },
              ),
              const SizedBox(height: Marca.e5),
              // Google en todas las plataformas: web con
              // redirección; Android e iOS con token de ID.
              if (_paso == 1 && !_recuperar) ...[
                BotonGoogle(
                  onPressed: _ocupado ? null : _conGoogle,
                ),
                const SizedBox(height: Marca.e4),
                const _Separador('o con tu correo'),
                const SizedBox(height: Marca.e4),
              ],
              if (!_entrar) ...[
                _Pasos(actual: _paso),
                const SizedBox(height: Marca.e4),
              ],
              Tarjeta(child: _formulario()),
              if (_entrar)
                TextButton(
                  onPressed: _olvide,
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._campos(),
        if (_error != null) ...[
          const SizedBox(height: Marca.e3),
          Text(
            _error!,
            style: const TextStyle(
              color: Marca.primario,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: Marca.e4),
        FilledButton.icon(
          onPressed: _ocupado ? null : _continuar,
          icon: Icon(_icono()),
          label: Text(_accion()),
        ),
      ],
    );
  }

  List<Widget> _campos() {
    final correo = TextField(
      controller: _correo,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(
        labelText: 'Correo',
        hintText: 'tu@correo.com',
      ),
    );
    if (_entrar) {
      return [
        correo,
        const SizedBox(height: Marca.e3),
        _contrasena(),
      ];
    }
    return switch (_paso) {
      1 => [correo],
      2 => [
        TextField(
          controller: _codigo,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: 'Código',
            hintText: '6 dígitos',
            helperText: 'Lo enviamos a ${_correo.text.trim()}',
            counterText: '',
          ),
        ),
      ],
      _ => [
        _contrasena(
          ayuda: _recuperar
              ? 'Código confirmado ✓'
              : 'Correo confirmado ✓',
        ),
      ],
    };
  }

  TextField _contrasena({String? ayuda}) => TextField(
    controller: _clave,
    obscureText: true,
    decoration: InputDecoration(
      labelText: 'Contraseña',
      hintText: 'Al menos 6 caracteres',
      helperText: ayuda,
    ),
  );

  String _accion() => _entrar
      ? 'Entrar'
      : switch (_paso) {
          1 => 'Enviar código',
          2 => 'Confirmar',
          _ =>
            _guardar ? 'Guardar cuenta' : 'Guardar contraseña',
        };

  IconData _icono() => _entrar
      ? Icons.login_rounded
      : switch (_paso) {
          1 => Icons.mail_outline_rounded,
          2 => Icons.verified_outlined,
          _ => Icons.lock_outline_rounded,
        };
}

/// Los tres pasos, con el actual resaltado.
class _Pasos extends StatelessWidget {
  const _Pasos({required this.actual});

  final int actual;

  static const _nombres = ['Correo', 'Código', 'Contraseña'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _nombres.length; i++) ...[
          if (i > 0) const SizedBox(width: Marca.e2),
          Expanded(child: _paso(i + 1, _nombres[i])),
        ],
      ],
    );
  }

  Widget _paso(int n, String nombre) {
    final hecho = n < actual;
    final activo = n == actual;
    final color = activo || hecho
        ? Marca.primario
        : Marca.al(Marca.secundario, .5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 4,
          decoration: BoxDecoration(
            color: activo || hecho
                ? Marca.primario
                : Marca.base300,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: Marca.e2),
        Text(
          hecho ? '✓ $nombre' : '$n · $nombre',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Línea con un texto en el centro: «o con tu correo».
class _Separador extends StatelessWidget {
  const _Separador(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final linea = Expanded(
      child: Container(height: 1, color: Marca.base300),
    );
    return Row(
      children: [
        linea,
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Marca.e3,
          ),
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              color: Marca.al(Marca.secundario, .6),
            ),
          ),
        ),
        linea,
      ],
    );
  }
}
