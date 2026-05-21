import 'package:petcontrol_limpio/domain/repositories/session_repository.dart';

// Sección: servicio de sesión
// Encapsula persistencia del id de usuario autenticado.
class SessionService {
  SessionService({required SessionRepository sessionRepository})
    : _sessionRepository = sessionRepository;

  final SessionRepository _sessionRepository;

  // Sección: guardado de sesión
  // Persiste el id del usuario autenticado.
  Future<void> guardarSesion(String idUsuario) async {
    await _sessionRepository.guardarSesion(idUsuario);
  }

  // Sección: lectura de sesión
  // Recupera el id del usuario logueado, si existe.
  Future<String?> obtenerIdUsuarioSesion() async {
    return _sessionRepository.obtenerIdUsuarioSesion();
  }

  // Sección: limpieza de sesión
  // Elimina sesión local al cerrar sesión.
  Future<void> limpiarSesion() async {
    await _sessionRepository.limpiarSesion();
  }
}
