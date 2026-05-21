import 'package:petcontrol_limpio/domain/repositories/session_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSessionRepository implements SessionRepository {
  static const String _llaveUsuarioSesion = 'petcontrol_sesion_usuario_id';

  @override
  Future<void> guardarSesion(String idUsuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_llaveUsuarioSesion, idUsuario);
  }

  @override
  Future<String?> obtenerIdUsuarioSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final idUsuario = prefs.getString(_llaveUsuarioSesion);
    if (idUsuario == null || idUsuario.trim().isEmpty) {
      return null;
    }
    return idUsuario;
  }

  @override
  Future<void> limpiarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_llaveUsuarioSesion);
  }
}
