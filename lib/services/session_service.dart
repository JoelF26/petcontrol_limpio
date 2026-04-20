// Sección: imports
// Se usa SharedPreferences para mantener el usuario logueado entre sesiones.
import 'package:shared_preferences/shared_preferences.dart';

// Sección: servicio de sesión
// Encapsula persistencia del id de usuario autenticado.
class SessionService {
  // Sección: llave de sesión
  // Identifica de forma única el id del usuario actual en almacenamiento local.
  static const String _llaveUsuarioSesion = 'petcontrol_sesion_usuario_id';

  // Sección: guardado de sesión
  // Persiste el id del usuario autenticado.
  Future<void> guardarSesion(String idUsuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_llaveUsuarioSesion, idUsuario);
  }

  // Sección: lectura de sesión
  // Recupera el id del usuario logueado, si existe.
  Future<String?> obtenerIdUsuarioSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final idUsuario = prefs.getString(_llaveUsuarioSesion);
    if (idUsuario == null || idUsuario.trim().isEmpty) {
      return null;
    }
    return idUsuario;
  }

  // Sección: limpieza de sesión
  // Elimina sesión local al cerrar sesión.
  Future<void> limpiarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_llaveUsuarioSesion);
  }
}
