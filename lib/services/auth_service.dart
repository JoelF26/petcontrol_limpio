// Sección: imports
// Se importan utilidades de fecha, UUID, roles, modelo de usuario y servicios locales.
import 'package:intl/intl.dart';
import 'package:petcontrol_limpio/core/constants/roles_usuario.dart';
import 'package:petcontrol_limpio/models/usuario.dart';
import 'package:petcontrol_limpio/services/session_service.dart';
import 'package:petcontrol_limpio/services/usuario_service.dart';
import 'package:uuid/uuid.dart';

// Sección: DTO de registro
// Define los datos que llegan desde el formulario para crear un cliente.
class DatosRegistroCliente {
  const DatosRegistroCliente({
    required this.nombreCompleto,
    required this.numeroDocumento,
    required this.telefono,
    required this.correo,
    required this.contrasena,
  });

  final String nombreCompleto;
  final String numeroDocumento;
  final String telefono;
  final String correo;
  final String contrasena;
}

// Sección: excepción de autenticación
// Expone mensajes legibles para mostrar en la UI.
class AuthException implements Exception {
  const AuthException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

// Sección: servicio de autenticación local
// Maneja registro, login y sesión usando JSON local como fuente de verdad.
class AuthService {
  AuthService({
    UsuarioService? usuarioService,
    SessionService? sessionService,
    Uuid? uuid,
  }) : _usuarioService = usuarioService,
       _sessionService = sessionService,
       _uuid = uuid;

  final UsuarioService? _usuarioService;
  final SessionService? _sessionService;
  final Uuid? _uuid;

  // Sección: acceso perezoso a servicios
  // Evita crear dependencias en constructor de pantallas.
  UsuarioService get _usuarios => _usuarioService ?? UsuarioService();
  SessionService get _sesion => _sessionService ?? SessionService();
  Uuid get _idGenerator => _uuid ?? const Uuid();

  // Sección: registro de cliente
  // Crea usuario local con rol cliente y abre sesión automática.
  Future<Usuario> registrarCliente(DatosRegistroCliente datos) async {
    final correo = datos.correo.trim().toLowerCase();
    final contrasena = datos.contrasena;

    if (correo.isEmpty || contrasena.isEmpty) {
      throw const AuthException('Correo y contraseña son obligatorios.');
    }

    final yaExiste = await _usuarios.obtenerUsuarioPorCorreo(correo);
    if (yaExiste != null) {
      throw const AuthException('Este correo ya está registrado.');
    }

    final ahora = DateTime.now();
    final usuario = Usuario(
      idUsuario: _idGenerator.v4(),
      nombreCompleto: datos.nombreCompleto.trim(),
      numeroDocumento: datos.numeroDocumento.trim(),
      telefono: datos.telefono.trim(),
      correo: correo,
      contrasena: contrasena,
      rol: RolesUsuario.cliente,
      fechaCreacion: DateFormat('yyyy-MM-dd').format(ahora),
      createdAt: ahora.toIso8601String(),
    );

    try {
      await _usuarios.crearUsuario(usuario);
      await _sesion.guardarSesion(usuario.idUsuario);
      return usuario;
    } on StateError catch (error) {
      throw AuthException(error.message.toString());
    } catch (_) {
      throw const AuthException('No se pudo completar el registro.');
    }
  }

  // Sección: inicio de sesión
  // Valida credenciales contra usuarios JSON y persiste sesión local.
  Future<Usuario> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    final usuario = await _usuarios.validarCredenciales(
      correo: correo.trim().toLowerCase(),
      contrasena: contrasena,
    );

    if (usuario == null) {
      throw const AuthException('Correo o contraseña incorrectos.');
    }

    await _sesion.guardarSesion(usuario.idUsuario);
    return usuario;
  }

  // Sección: lectura de usuario actual
  // Resuelve el perfil del usuario activo según la sesión guardada.
  Future<Usuario?> obtenerUsuarioActual() async {
    final idUsuario = await _sesion.obtenerIdUsuarioSesion();
    if (idUsuario == null) {
      return null;
    }
    return _usuarios.obtenerUsuarioPorId(idUsuario);
  }

  // Sección: cierre de sesión
  // Limpia el usuario activo almacenado localmente.
  Future<void> cerrarSesion() async {
    await _sesion.limpiarSesion();
  }
}
