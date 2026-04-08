// Sección: imports
// Se importa Material para construir el botón reutilizable.
import 'package:flutter/material.dart';

// Sección: widget reutilizable de acción principal
// Estandariza botones principales con soporte de estado de carga.
class BotonPrincipal extends StatelessWidget {
  const BotonPrincipal({
    required this.texto,
    required this.onPressed,
    this.cargando = false,
    super.key,
  });

  final String texto;
  final VoidCallback? onPressed;
  final bool cargando;

  // Sección: construcción de UI
  // Renderiza botón ancho completo y muestra spinner cuando está cargando.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: cargando ? null : onPressed,
        child: cargando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(texto),
      ),
    );
  }
}
