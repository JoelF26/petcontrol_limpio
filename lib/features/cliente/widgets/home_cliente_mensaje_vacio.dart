// Sección: imports
// Se importa Material para construir el bloque visual de listas vacías.
import 'package:flutter/material.dart';

// Sección: mensaje vacío del home cliente
// Muestra un bloque informativo cuando no hay mascotas o citas registradas.
class HomeClienteMensajeVacio extends StatelessWidget {
  const HomeClienteMensajeVacio({required this.texto, super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4F4F4F), width: 1),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Color(0xFF616A71),
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
