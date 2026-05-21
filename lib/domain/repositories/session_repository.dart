abstract class SessionRepository {
  Future<void> guardarSesion(String idUsuario);
  Future<String?> obtenerIdUsuarioSesion();
  Future<void> limpiarSesion();
}
