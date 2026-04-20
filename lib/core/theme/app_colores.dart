// Sección: imports
// Se importa Material para declarar la paleta central de la app.
import 'package:flutter/material.dart';

// Sección: paleta unificada
// Se agrupan colores por propósito para evitar duplicación de variables.
class AppColores {
  AppColores._();

  // Sección: colores de marca
  // Tonos principales para identidad visual y acciones primarias.
  static const Color primario = Color(0xFF36A75C);
  static const Color primarioOscuro = Color(0xFF275B37);
  static const Color secundario = Color(0xFF3DA4C5);
  static const Color secundarioOscuro = Color(0xFF153743);

  // Sección: neutros base
  // Colores generales de fondo, texto y bordes.
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color negro = Color(0xFF000000);
  static const Color grisSuave = Color(0xFFD9D9D9);

  // Sección: colores de apoyo
  // Acentos útiles para componentes puntuales y estados visuales.
  static const Color acentoVerde = Color(0xFF359253);
  static const Color acentoVerdeOscuro = Color(0xFF358E51);
  static const Color acentoAzulTexto = Color(0xFF3DAFD2);
  static const Color error = Color(0xFFB42318);

  // Sección: compatibilidad de vistas heredadas
  // Mantiene nombres usados por pantallas antiguas para no cambiar diseño.
  static const Color verdepacientes = Color(0xFF4FAF75);

  // Sección: colores semánticos para UI
  // Variables orientadas a uso directo en tema/componentes.
  static const Color fondo = blanco;
  static const Color superficie = blanco;
  static const Color textoPrincipal = secundarioOscuro;
  static const Color textoSobrePrimario = negro;
  static const Color borde = grisSuave;
}
