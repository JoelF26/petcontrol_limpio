import 'package:petcontrol_limpio/domain/entities/usuario.dart';
import 'package:petcontrol_limpio/domain/repositories/usuario_repository.dart';

// Sección: servicio de usuarios
// Encapsula lectura y escritura de usuarios en persistencia local JSON.
class UsuarioService {
  UsuarioService({required UsuarioRepository usuarioRepository})
    : _usuarioRepository = usuarioRepository;

  final UsuarioRepository _usuarioRepository;

  // Sección: creación de usuario
  // Inserta un usuario nuevo validando duplicados por id y correo.
  Future<void> crearUsuario(Usuario usuario) async {
    if (usuario.contrasena.trim().isEmpty) {
      await _usuarioRepository.guardarUsuarioPendiente(usuario);
      return;
    }

    final existeId = await obtenerUsuarioPorId(usuario.idUsuario);
    if (existeId != null) {
      throw StateError('Ya existe un usuario con ese id.');
    }

    // El correo se compara normalizado para evitar duplicados por mayúsculas.
    final correo = usuario.correo.trim().toLowerCase();
    final existeCorreo = await obtenerUsuarioPorCorreo(correo);
    if (existeCorreo != null) {
      throw StateError('Este correo ya está registrado.');
    }

    await _usuarioRepository.guardarUsuario(usuario);
  }

  // Sección: actualización de usuario
  // Reemplaza un usuario existente manteniendo consistencia de correo único.
  Future<void> actualizarUsuario(Usuario usuario) async {
    if (usuario.contrasena.trim().isEmpty) {
      await _usuarioRepository.guardarUsuarioPendiente(usuario);
      return;
    }

    final actual = await obtenerUsuarioPorId(usuario.idUsuario);
    if (actual == null) {
      throw StateError('No existe el usuario a actualizar.');
    }

    // Permite conservar el correo propio, pero bloquea colisiones con otros usuarios.
    final correo = usuario.correo.trim().toLowerCase();
    final usuarioCorreo = await obtenerUsuarioPorCorreo(correo);
    if (usuarioCorreo != null && usuarioCorreo.idUsuario != usuario.idUsuario) {
      throw StateError('El correo ya está en uso por otro usuario.');
    }

    await _usuarioRepository.guardarUsuario(usuario);
  }

  // Sección: consulta por id
  // Retorna el usuario cuyo id coincida con el solicitado.
  Future<Usuario?> obtenerUsuarioPorId(String idUsuario) async {
    final idLimpio = idUsuario.trim();
    if (idLimpio.isEmpty) {
      return null;
    }

    return _usuarioRepository.obtenerUsuarioPorId(idLimpio);
  }

  // Sección: consulta por correo
  // Retorna el usuario cuyo correo coincida de forma case-insensitive.
  Future<Usuario?> obtenerUsuarioPorCorreo(String correo) async {
    final correoLimpio = correo.trim().toLowerCase();
    if (correoLimpio.isEmpty) {
      return null;
    }

    return _usuarioRepository.obtenerUsuarioPorCorreo(correoLimpio);
  }

  // Sección: validación de credenciales
  // Busca un usuario por correo y contraseña para iniciar sesión.
  Future<Usuario?> validarCredenciales({
    required String correo,
    required String contrasena,
  }) async {
    final usuario = await obtenerUsuarioPorCorreo(correo);
    if (usuario == null) {
      return null;
    }

    if (usuario.contrasena != contrasena) {
      return null;
    }

    return usuario;
  }

  // Sección: listado completo
  // Carga todos los usuarios persistidos en la entidad local.
  Future<List<Usuario>> obtenerUsuarios() async {
    return _usuarioRepository.obtenerUsuarios();
  }

  Stream<List<Usuario>> observarUsuarios() {
    return _usuarioRepository.observarUsuarios();
  }

  Future<Usuario?> obtenerUsuarioPendientePorCorreo(String correo) {
    return _usuarioRepository.obtenerUsuarioPendientePorCorreo(correo);
  }

  Future<void> guardarUsuarioAutenticado(Usuario usuario) {
    return _usuarioRepository.guardarUsuario(usuario);
  }

  Future<void> eliminarUsuarioPendientePorCorreo(String correo) {
    return _usuarioRepository.eliminarUsuarioPendientePorCorreo(correo);
  }
}
