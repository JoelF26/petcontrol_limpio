// Sección: imports
// Se cargan rutas y tema global de la aplicación.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/routes/app_router.dart';
import 'package:petcontrol_limpio/core/routes/rutas.dart';
import 'package:petcontrol_limpio/core/theme/tema_app.dart';

// Sección: raíz de la app
// Configura MaterialApp con tema, ruta inicial y enrutador centralizado.
class PetControlApp extends StatelessWidget {
  const PetControlApp({super.key});

  // Sección: construcción de UI raíz
  // Retorna la configuración global de navegación y apariencia.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetControl',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.temaLigero,
      initialRoute: Rutas.bienvenida,
      onGenerateRoute: AppRouter.generarRuta,
    );
  }
}
