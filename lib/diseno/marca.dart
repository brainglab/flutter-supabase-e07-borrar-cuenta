import 'package:flutter/material.dart';

/// Tokens de Brainglab UI.
///
/// Salen del tema DaisyUI «brainglab-dark» de brainglab.com
/// (ver marca-brainglab.md en la raíz del proyecto de videos).
abstract final class Marca {
  // Colores
  static const primario = Color(0xFFFA3E39); // --color-primary
  static const primarioTexto = Color(0xFFFCFCFC);
  static const rojoMarca = Color(0xFFF92C02); // .highlight-word
  static const acento = Color(0xFFFF715D); // --color-accent
  static const base100 = Color(0xFF040711); // fondo
  static const base200 = Color(0xFF0A0F1C); // superficies
  static const base300 = Color(0xFF141A29); // bordes
  // --color-base-content
  static const texto = Color(0xFFF0F2F4);
  static const secundario = Color(0xFFC7CEDF);

  // Radios de DaisyUI
  static const radioCaja = 16.0; // --radius-box (card)
  static const radioSelector = 12.0; // --radius-selector
  static const radioCampo = 8.0; // --radius-field (input, btn)

  // Espaciado (múltiplos de 4, como Tailwind)
  static const e1 = 4.0;
  static const e2 = 8.0;
  static const e3 = 12.0;
  static const e4 = 16.0;
  static const e5 = 20.0;
  static const e6 = 24.0;

  static const fuente = 'Montserrat';

  /// Color con opacidad, como bg-primary/10 de Tailwind.
  static Color al(Color color, double opacidad) =>
      color.withValues(alpha: opacidad);
}
