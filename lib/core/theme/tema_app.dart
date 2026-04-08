// Sección: imports
// Se importan fuentes y paleta de colores para construir el tema global.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';

// Sección: configuración de tema
// Define el tema principal reutilizable para toda la aplicación.
class TemaApp {
  TemaApp._();

  // Sección: tema claro principal
  // Combina la estructura sólida anterior con la tipografía nueva.
  static ThemeData get temaLigero {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColores.primario,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColores.primario,
          secondary: AppColores.secundario,
          surface: AppColores.superficie,
          error: AppColores.error,
          onPrimary: AppColores.textoSobrePrimario,
          onSurface: AppColores.textoPrincipal,
        );

    const bordeFormulario = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppColores.borde),
    );

    final temaBase = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColores.fondo,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColores.superficie,
        foregroundColor: AppColores.textoPrincipal,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColores.superficie,
        border: bordeFormulario,
        enabledBorder: bordeFormulario,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColores.primario, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColores.primario,
          foregroundColor: AppColores.textoSobrePrimario,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColores.secundarioOscuro,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );

    return temaBase.copyWith(
      textTheme: GoogleFonts.montserratTextTheme(temaBase.textTheme).apply(
        bodyColor: AppColores.textoPrincipal,
        displayColor: AppColores.textoPrincipal,
      ),
    );
  }
}
