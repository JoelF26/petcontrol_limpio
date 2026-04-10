// Sección: imports
// Se importa Material para construir el contenedor de sección reutilizable.
import 'package:flutter/material.dart';

// Sección: panel de sección del home cliente
// Encapsula título, ícono, acción "Ver todo" y contenido interno.
class HomeClientePanelSeccion extends StatelessWidget {
  const HomeClientePanelSeccion({
    required this.titulo,
    required this.icono,
    required this.onVerTodo,
    required this.child,
    super.key,
  });

  final String titulo;
  final IconData icono;
  final VoidCallback onVerTodo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF93A2B2), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220E1C2F),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFE8F5),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icono, color: const Color(0xFF1E3D63), size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF1F2730),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
              TextButton(
                onPressed: onVerTodo,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1A6C90),
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('Ver todo'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
