import 'package:petcontrol_limpio/domain/entities/usuario.dart';

abstract class UsuarioRepository {
  Future<List<Usuario>> obtenerUsuarios();
  Stream<List<Usuario>> observarUsuarios();
  Future<Usuario?> obtenerUsuarioPorId(String idUsuario);
  Future<Usuario?> obtenerUsuarioPorCorreo(String correo);
  Future<void> guardarUsuario(Usuario usuario);
  Future<void> guardarUsuarios(List<Usuario> usuarios);
  Future<Usuario?> obtenerUsuarioPendientePorCorreo(String correo);
  Future<void> guardarUsuarioPendiente(Usuario usuario);
  Future<void> eliminarUsuarioPendientePorCorreo(String correo);
}
