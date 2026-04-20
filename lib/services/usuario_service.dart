// Sección: imports
// Se importan constantes de entidades, modelo de usuario y storage local JSON.
import 'package:petcontrol_limpio/core/constants/entidades_locales.dart';
import 'package:petcontrol_limpio/models/usuario.dart';
import 'package:petcontrol_limpio/services/storage/local_json_storage_service.dart';

// Sección: servicio de usuarios
// Encapsula lectura y escritura de usuarios en persistencia local JSON.
class UsuarioService {
  UsuarioService({LocalJsonStorageService? storageService})
    : _storageService = storageService ?? LocalJsonStorageService();

  final LocalJsonStorageService _storageService;

  // Sección: creación de usuario
  // Inserta un usuario nuevo validando duplicados por id y correo.
  Future<void> crearUsuario(Usuario usuario) async {
    final usuarios = await obtenerUsuarios();

    final existeId = usuarios.any((item) => item.idUsuario == usuario.idUsuario);
    if (existeId) {
      throw StateError('Ya existe un usuario con ese id.');
    }

    final correo = usuario.correo.trim().toLowerCase();
    final existeCorreo = usuarios.any(
      (item) => item.correo.trim().toLowerCase() == correo,
    );
    if (existeCorreo) {
      throw StateError('Este correo ya está registrado.');
    }

    final actualizados = <Usuario>[...usuarios, usuario];
    await _guardarUsuarios(actualizados);
  }

  // Sección: actualización de usuario
  // Reemplaza un usuario existente manteniendo consistencia de correo único.
  Future<void> actualizarUsuario(Usuario usuario) async {
    final usuarios = await obtenerUsuarios();
    final indice = usuarios.indexWhere((item) => item.idUsuario == usuario.idUsuario);
    if (indice < 0) {
      throw StateError('No existe el usuario a actualizar.');
    }

    final correo = usuario.correo.trim().toLowerCase();
    final correoDuplicado = usuarios.any(
      (item) =>
          item.idUsuario != usuario.idUsuario &&
          item.correo.trim().toLowerCase() == correo,
    );
    if (correoDuplicado) {
      throw StateError('El correo ya está en uso por otro usuario.');
    }

    final actualizados = <Usuario>[...usuarios];
    actualizados[indice] = usuario;
    await _guardarUsuarios(actualizados);
  }

  // Sección: consulta por id
  // Retorna el usuario cuyo id coincida con el solicitado.
  Future<Usuario?> obtenerUsuarioPorId(String idUsuario) async {
    final idLimpio = idUsuario.trim();
    if (idLimpio.isEmpty) {
      return null;
    }

    final usuarios = await obtenerUsuarios();
    for (final usuario in usuarios) {
      if (usuario.idUsuario == idLimpio) {
        return usuario;
      }
    }
    return null;
  }

  // Sección: consulta por correo
  // Retorna el usuario cuyo correo coincida de forma case-insensitive.
  Future<Usuario?> obtenerUsuarioPorCorreo(String correo) async {
    final correoLimpio = correo.trim().toLowerCase();
    if (correoLimpio.isEmpty) {
      return null;
    }

    final usuarios = await obtenerUsuarios();
    for (final usuario in usuarios) {
      if (usuario.correo.trim().toLowerCase() == correoLimpio) {
        return usuario;
      }
    }
    return null;
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
    final registros = await _storageService.leerLista(EntidadesLocales.usuarios);
    return registros
        .map(Usuario.fromMap)
        .toList(growable: false);
  }

  // Sección: persistencia interna
  // Guarda la lista completa de usuarios en el storage local.
  Future<void> _guardarUsuarios(List<Usuario> usuarios) async {
    final registros = usuarios
        .map((usuario) => usuario.toMap())
        .toList(growable: false);
    await _storageService.guardarLista(EntidadesLocales.usuarios, registros);
  }
}

