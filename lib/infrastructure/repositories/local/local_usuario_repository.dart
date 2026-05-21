import 'package:petcontrol_limpio/domain/constants/entidades_locales.dart';
import 'package:petcontrol_limpio/domain/entities/usuario.dart';
import 'package:petcontrol_limpio/domain/repositories/usuario_repository.dart';
import 'package:petcontrol_limpio/infrastructure/storage/local_json_storage_service.dart';

class LocalUsuarioRepository implements UsuarioRepository {
  LocalUsuarioRepository({required LocalJsonStorageService storageService})
    : _storageService = storageService;

  final LocalJsonStorageService _storageService;

  @override
  Future<List<Usuario>> obtenerUsuarios() async {
    final registros = await _storageService.leerLista(
      EntidadesLocales.usuarios,
    );
    return registros.map(Usuario.fromMap).toList(growable: false);
  }

  @override
  Stream<List<Usuario>> observarUsuarios() async* {
    yield await obtenerUsuarios();
  }

  @override
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

  @override
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

  @override
  Future<void> guardarUsuario(Usuario usuario) async {
    final usuarios = await obtenerUsuarios();
    final indice = usuarios.indexWhere(
      (item) => item.idUsuario == usuario.idUsuario,
    );
    final actualizados = <Usuario>[...usuarios];
    if (indice < 0) {
      actualizados.add(usuario);
    } else {
      actualizados[indice] = usuario;
    }
    await guardarUsuarios(actualizados);
  }

  @override
  Future<void> guardarUsuarios(List<Usuario> usuarios) async {
    final registros = usuarios
        .map((usuario) => usuario.toMap())
        .toList(growable: false);
    await _storageService.guardarLista(EntidadesLocales.usuarios, registros);
  }

  @override
  Future<Usuario?> obtenerUsuarioPendientePorCorreo(String correo) {
    return obtenerUsuarioPorCorreo(correo);
  }

  @override
  Future<void> guardarUsuarioPendiente(Usuario usuario) {
    return guardarUsuario(usuario);
  }

  @override
  Future<void> eliminarUsuarioPendientePorCorreo(String correo) async {}
}
