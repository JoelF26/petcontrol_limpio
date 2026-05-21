import 'package:firebase_auth/firebase_auth.dart';
import 'package:petcontrol_limpio/domain/repositories/session_repository.dart';

class FirebaseSessionRepository implements SessionRepository {
  FirebaseSessionRepository({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Future<void> guardarSesion(String idUsuario) async {}

  @override
  Future<String?> obtenerIdUsuarioSesion() async {
    return _auth.currentUser?.uid;
  }

  @override
  Future<void> limpiarSesion() async {
    await _auth.signOut();
  }
}
