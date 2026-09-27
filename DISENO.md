# Brainglab UI · sistema de diseño para Flutter

Los componentes de DaisyUI con el tema **brainglab-dark** de brainglab.com, llevados a Flutter. DaisyUI es una librería de CSS y no funciona en Flutter, así que aquí se replican sus componentes (`btn`, `input`, `checkbox`, `card`, `badge`) con los mismos colores, radios y tipografía. Todo vive en `lib/diseno/` y se reutiliza en cualquier pantalla nueva.

## Uso en una pantalla nueva

```dart
import 'package:flutter/material.dart';

import '../diseno/componentes.dart';
import '../diseno/marca.dart';

class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Marca.e5),
          child: Column(
            children: [
              const Encabezado(
                titulo: 'Mi cuenta',
                subtitulo: 'Flutter + Supabase · Brainglab',
              ),
              const SizedBox(height: Marca.e5),
              Tarjeta(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Crear cuenta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

El tema se aplica una sola vez en `main.dart`: `MaterialApp(theme: temaBrainglab(), …)`. Con eso, los `FilledButton`, `TextField`, `Checkbox` y `CircularProgressIndicator` ya salen con el estilo de la marca, sin configurar nada en cada pantalla.

## Archivos

| Archivo | Contenido |
|---|---|
| `lib/diseno/marca.dart` | Tokens: colores, radios, espaciado y tipografía (`Marca.primario`, `Marca.radioCaja`, `Marca.e4`…) |
| `lib/diseno/tema.dart` | `temaBrainglab()`: `ThemeData` oscuro con los componentes de Material al estilo DaisyUI |
| `lib/diseno/componentes.dart` | Widgets reutilizables (tabla de abajo) |
| `assets/fuentes/` | Montserrat 400–800 (TTF oficiales, licencia OFL en `OFL.txt`) |
| `assets/marca/isotipo.png` | Isotipo de Brainglab |

## Equivalencias con DaisyUI

| DaisyUI | Brainglab UI | Detalle |
|---|---|---|
| `btn btn-primary rounded-full` | `FilledButton` (vía tema) | `#FA3E39`, forma de píldora, alto 48, Montserrat 600 |
| `input input-bordered` | `TextField` (vía tema) | Fondo `base-100`, borde `base-300`, radio 8; al enfocar, borde `#FA3E39` de 2 px |
| `checkbox checkbox-primary` | `Checkbox` / `CheckboxListTile` (vía tema) | Radio 6; marcado en `#FA3E39` |
| `card` | `Tarjeta` | Fondo `base-200`, borde `base-300`, radio 16. `resaltada: true` añade borde y brillo primarios |
| `badge badge-primary badge-soft` | `Insignia` | Primario al 12 %, texto primario, forma de píldora; icono opcional |
| caja de icono de brainglab.com | `IconoCaja` | Primario al 12 %, radio 12, icono primario |
| — | `Encabezado` | Isotipo + título (800) + subtítulo |
| — | `EstadoVacio` | `IconoCaja` + título + texto de ayuda, centrado |
| — | `BotonGoogle` | «Continuar con Google» con las pautas de marca de Google (tema oscuro): fondo `#131314`, borde `#8E918F`, texto `#E3E3E3`, Google Sans Medium 14/20 y logo oficial (`assets/google/`) |

## Tokens

| Token | Valor | Origen en brainglab.com |
|---|---|---|
| `Marca.primario` | `#FA3E39` | `--color-primary` (tema oscuro) |
| `Marca.base100` / `base200` / `base300` | `#040711` / `#0A0F1C` / `#141A29` | `--color-base-100/200/300` |
| `Marca.texto` / `secundario` | `#F0F2F4` / `#C7CEDF` | `--color-base-content` / `--color-secondary` |
| `Marca.acento` | `#FF715D` | `--color-accent` |
| `Marca.radioCaja` / `radioSelector` / `radioCampo` | 16 / 12 / 8 | `--radius-box` / `--radius-selector` / `--radius-field` |
| `Marca.e1` … `e6` | 4 … 24 | escala de 4 de Tailwind |
| `Marca.fuente` | Montserrat | `--font-sans` |

La ficha completa de la marca está en `marca-brainglab.md`, en la raíz del proyecto de videos.

## Reglas

- No uses colores sueltos (`Color(0xFF…)`) en las pantallas: usa `Marca.*`. Si falta un color, sale de la web de Brainglab y se añade primero a `marca.dart`.
- Única excepción: `BotonGoogle`. Sus colores, su fuente y su logo los fijan las pautas de Google (developers.google.com/identity/branding-guidelines), no la marca. No lo recolores.
- Para las opacidades, usa `Marca.al(color, .12)`, el equivalente a `bg-primary/12` de Tailwind.
- Un componente nuevo que se repita en dos pantallas va a `componentes.dart`. Si solo lo usa una pantalla, se queda en `lib/ui/`, como `FilaTarea`.
- Mantén 64 columnas (`analysis_options.yaml`): el código se enseña en las láminas del video.
