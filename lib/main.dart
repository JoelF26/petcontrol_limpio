// Sección: imports
// Se importan Flutter, app principal, configuración de URL y servicio de persistencia local.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/app.dart';
import 'package:petcontrol_limpio/core/routes/url_strategy.dart';
import 'package:petcontrol_limpio/services/storage/local_json_storage_service.dart';

// Sección: punto de entrada
// Inicializa estrategia de URL en web, persistencia local y luego renderiza la app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configurarEstrategiaUrl();
  await _inicializarPersistenciaLocal();
  runApp(const PetControlApp());
}

// Sección: inicialización de persistencia local
// Garantiza que la base local esté disponible antes de abrir pantallas.
Future<void> _inicializarPersistenciaLocal() async {
  await LocalJsonStorageService().inicializar();
}
