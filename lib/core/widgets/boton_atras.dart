// Sección: imports
// Se importan rutas y paleta para resolver navegación y estilo base del botón.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/routes/rutas.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';

// Sección: widget reutilizable de botón atrás
// Permite volver a la pantalla anterior y, si no existe historial, usar una ruta fallback.
class BotonAtras extends StatelessWidget {
  const BotonAtras({
    super.key,
    this.rutaFallback = Rutas.bienvenida,
    this.colorIcono = AppColores.blanco,
    this.padding = const EdgeInsets.only(left: 8, top: 4),
    this.icono = Icons.arrow_back_ios_new_rounded,
    this.onPressed,
  });

  final String? rutaFallback;
  final Color colorIcono;
  final EdgeInsets padding;
  final IconData icono;
  final VoidCallback? onPressed;

  // Sección: construcción de UI
  // Renderiza el botón en zona segura para evitar superposición con la barra superior.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: padding,
        child: IconButton(
          onPressed: () => _manejarRegreso(context),
          icon: Icon(icono),
          color: colorIcono,
        ),
      ),
    );
  }

  // Sección: lógica de navegación atrás
  // Prioriza callback personalizado, luego pop del historial y por último ruta fallback.
  void _manejarRegreso(BuildContext context) {
    if (onPressed != null) {
      onPressed!();
      return;
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    if (rutaFallback != null) {
      Navigator.pushReplacementNamed(context, rutaFallback!);
    }
  }
}
