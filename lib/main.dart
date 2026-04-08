// Sección: imports
// Se importan Firebase y la configuración base para arrancar la app.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/app.dart';
import 'package:petcontrol_limpio/firebase_options.dart';

// Sección: punto de entrada
// Inicializa Firebase y luego renderiza la aplicación principal.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _inicializarFirebase();
  runApp(const PetControlApp());
}

// Sección: inicialización segura de Firebase
// En Android/iOS/Web inicializa normalmente; en plataformas no configuradas
// permite seguir cargando la UI para pruebas de frontend.
Future<void> _inicializarFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on UnsupportedError {
    debugPrint(
      'Firebase no está configurado para esta plataforma. '
      'La app continuará para visualizar la interfaz.',
    );
  }
}
