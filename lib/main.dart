// Sección: imports
// Se importan Flutter, app principal, configuración de URL y Firebase.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/app.dart';
import 'package:petcontrol_limpio/core/di/app_dependencies.dart';
import 'package:petcontrol_limpio/core/routes/url_strategy.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_initializer.dart';

// Sección: punto de entrada
// Inicializa estrategia de URL en web, Firebase, dependencias y luego renderiza la app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configurarEstrategiaUrl();
  await FirebaseInitializer.inicializar();
  await AppDependencies.inicializar();
  runApp(const PetControlApp());
}
