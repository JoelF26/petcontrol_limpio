abstract class AuthIdentityRepository {
  String? get idUsuarioActual;

  Future<String> registrarConCorreo({
    required String correo,
    required String contrasena,
  });

  Future<String> iniciarSesionConCorreo({
    required String correo,
    required String contrasena,
  });

  Future<bool> existeCuentaConContrasena(String correo);

  Future<bool> existeAccesoInicial(String correo);

  Future<void> cerrarSesion();
}
