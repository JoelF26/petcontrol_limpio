// Sección: imports
// Se importa Material para renderizar cada tarjeta de resumen.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';

// Sección: tarjeta de resumen del home
// Muestra cantidad y etiqueta de mascotas/citas con el mismo estilo del diseño original.
class HomeClienteResumenCard extends StatelessWidget {
  const HomeClienteResumenCard({
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.onTap,
    super.key,
  });

  final IconData icono;
  final String valor;
  final String etiqueta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColores.transparente,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 112),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColores.baseFFF9FBFF, AppColores.baseFFE7EDF6],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColores.baseFF516377, width: 1.05),
                boxShadow: const [
                  BoxShadow(
                    color: AppColores.base260D1A2A,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColores.baseFF4D6A89,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Icon(icono, size: 24, color: AppColores.baseFF1F3045),
                  const SizedBox(height: 8),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColores.baseFF1E2A36,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    etiqueta,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColores.baseFF586572,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
