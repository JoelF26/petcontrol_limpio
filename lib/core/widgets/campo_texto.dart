// Sección: imports
// Se importa Material para construir un campo de formulario reusable.
import 'package:flutter/material.dart';

// Sección: widget reutilizable de entrada
// Encapsula configuración común de TextFormField para mantener consistencia.
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.suffixIcon,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final Widget? suffixIcon;

  // Sección: construcción de UI
  // Devuelve un TextFormField configurado con etiqueta, validación y estilo.
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      decoration: InputDecoration(labelText: label, suffixIcon: suffixIcon),
    );
  }
}
