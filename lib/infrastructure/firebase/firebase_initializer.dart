import 'package:firebase_core/firebase_core.dart';
import 'package:petcontrol_limpio/firebase_options.dart';

class FirebaseInitializer {
  FirebaseInitializer._();

  static Future<void> inicializar() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
