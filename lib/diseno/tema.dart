import 'package:flutter/material.dart';

import 'marca.dart';

/// Tema oscuro de Brainglab UI: los componentes de Material
/// con la forma y los colores de DaisyUI (btn, input,
/// checkbox, card) y el tema brainglab-dark.
ThemeData temaBrainglab() {
  const esquema = ColorScheme.dark(
    primary: Marca.primario,
    onPrimary: Marca.primarioTexto,
    secondary: Marca.acento,
    onSecondary: Marca.base100,
    surface: Marca.base100,
    onSurface: Marca.texto,
    onSurfaceVariant: Marca.secundario,
    surfaceContainerLow: Marca.base200,
    surfaceContainerHighest: Marca.base300,
    outline: Marca.base300,
    outlineVariant: Marca.base300,
    error: Marca.primario,
  );
  final base = ThemeData(
    colorScheme: esquema,
    fontFamily: Marca.fuente,
    scaffoldBackgroundColor: Marca.base100,
  );
  final radioCampo = BorderRadius.circular(Marca.radioCampo);

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: Marca.texto,
      displayColor: Marca.texto,
    ),
    // btn btn-primary rounded-full
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Marca.primario,
        foregroundColor: Marca.primarioTexto,
        shape: const StadiumBorder(),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: Marca.e5,
        ),
        textStyle: const TextStyle(
          fontFamily: Marca.fuente,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    // input input-bordered
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Marca.base100,
      hintStyle: TextStyle(
        color: Marca.al(Marca.secundario, .55),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Marca.e4,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: radioCampo,
        borderSide: const BorderSide(color: Marca.base300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radioCampo,
        borderSide: const BorderSide(color: Marca.base300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radioCampo,
        borderSide: const BorderSide(
          color: Marca.primario,
          width: 2,
        ),
      ),
    ),
    // checkbox checkbox-primary
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      side: BorderSide(
        color: Marca.al(Marca.secundario, .45),
        width: 1.5,
      ),
      fillColor: WidgetStateProperty.resolveWith(
        (estados) => estados.contains(WidgetState.selected)
            ? Marca.primario
            : Colors.transparent,
      ),
      checkColor: const WidgetStatePropertyAll(
        Marca.primarioTexto,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Marca.primario,
    ),
    dividerColor: Marca.base300,
  );
}
