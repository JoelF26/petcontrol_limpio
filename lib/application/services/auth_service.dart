// Sección: imports
// Se importan utilidades de fecha, roles, modelo de usuario y servicios de aplicación.
import 'package:intl/intl.dart';
import 'package:petcontrol_limpio/domain/constants/roles_usuario.dart';
import 'package:petcontrol_limpio/domain/entities/usuario.dart';
import 'package:petcontrol_limpio/domain/repositories/auth_identity_repository.dart';
import 'package:petcontrol_limpio/application/services/auth/login_access_state.dart';
import 'package:petcontrol_limpio/application/services/session_service.dart';
import 'package:petcontrol_limpio/application/services/usuario_service.dart';

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

// Sección: servicio de autenticación
// Maneja registro, login y sesión usando el proveedor de identidad configurado.
class AuthService {
  AuthService({
    required UsuarioService usuarioService,
    required SessionService sessionService,
    required AuthIdentityRepository authIdentityRepository,
  }) : _usuarioService = usuarioService,
       _sessionService = sessionService,
       _authIdentityRepository = authIdentityRepository;

  final UsuarioService _usuarioService;
  final SessionService _sessionService;
  final AuthIdentityRepository _authIdentityRepository;

  // Sección: acceso perezoso a servicios
  // Evita crear dependencias en constructor de pantallas.
  UsuarioService get _usuarios => _usuarioService;
  SessionService get _sesion => _sessionService;

  // Sección: registro de cliente
  // Crea la cuenta de autenticación, guarda el perfil cliente y abre sesión automática.
  Future<Usuario> registrarCliente(DatosRegistroCliente datos) async {
    final correo = datos.correo.trim().toLowerCase();
    final contrasena = datos.contrasena;

    if (correo.isEmpty || contrasena.isEmpty) {
      throw const AuthException('Correo y contraseña son obligatorios.');
    }

    try {
      final ahora = DateTime.now();
      final idUsuario = await _authIdentityRepository.registrarConCorreo(
        correo: correo,
        contrasena: contrasena,
      );
      final usuario = Usuario(
        idUsuario: idUsuario,
        nombreCompleto: datos.nombreCompleto.trim(),
        numeroDocumento: datos.numeroDocumento.trim(),
        telefono: datos.telefono.trim(),
        correo: correo,
        contrasena: '',
        rol: RolesUsuario.cliente,
        fechaCreacion: DateFormat('yyyy-MM-dd').format(ahora),
        createdAt: ahora.toIso8601String(),
      );

      // Si el registro persiste correctamente, la sesión queda abierta de inmediato.
      await _usuarios.guardarUsuarioAutenticado(usuario);
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
    final correoLimpio = correo.trim().toLowerCase();
    final idUsuario = await _authIdentityRepository.iniciarSesionConCorreo(
      correo: correoLimpio,
      contrasena: contrasena,
    );
    final usuario = await _usuarios.obtenerUsuarioPorId(idUsuario);
    if (usuario == null) {
      throw const AuthException('Correo o contraseña incorrectos.');
    }

    await _sesion.guardarSesion(usuario.idUsuario);
    return usuario;
  }

  // Sección: pre-chequeo de acceso por correo
  // Determina si el correo existe y qué flujo corresponde antes de autenticar.
  Future<EstadoAccesoLogin> evaluarAccesoPorCorreo(String correo) async {
    final correoLimpio = correo.trim().toLowerCase();
    if (correoLimpio.isEmpty) {
      throw const AuthException('Ingresa tu correo electrónico.');
    }

    final requiereInicial = await _authIdentityRepository.existeAccesoInicial(
      correoLimpio,
    );
    if (requiereInicial) {
      return const EstadoAccesoLogin(
        tipo: TipoAccesoLogin.requiereContrasenaInicial,
      );
    }

    final existeCuenta = await _authIdentityRepository
        .existeCuentaConContrasena(correoLimpio);
    if (!existeCuenta) {
      return const EstadoAccesoLogin(tipo: TipoAccesoLogin.correoNoRegistrado);
    }

    return const EstadoAccesoLogin(
      tipo: TipoAccesoLogin.requiereContrasenaExistente,
    );
  }

  // Sección: configuración de contraseña inicial
  // Asigna contraseña por primera vez y deja la sesión iniciada.
  Future<Usuario> configurarContrasenaInicialYEntrar({
    required String correo,
    required String nuevaContrasena,
  }) async {
    final correoLimpio = correo.trim().toLowerCase();
    final contrasena = nuevaContrasena.trim();

    if (correoLimpio.isEmpty) {
      throw const AuthException('Ingresa un correo válido.');
    }
    if (contrasena.isEmpty) {
      throw const AuthException('La contraseña es obligatoria.');
    }
    if (contrasena.length < 6) {
      throw const AuthException(
        'La contraseña debe tener mínimo 6 caracteres.',
      );
    }

    final tieneAccesoInicial = await _authIdentityRepository
        .existeAccesoInicial(correoLimpio);
    if (!tieneAccesoInicial) {
      throw const AuthException(
        'No existe una cuenta pendiente para ese correo.',
      );
    }

    final idUsuario = await _authIdentityRepository.registrarConCorreo(
      correo: correoLimpio,
      contrasena: contrasena,
    );
    final usuario = await _usuarios.obtenerUsuarioPendientePorCorreo(
      correoLimpio,
    );
    if (usuario == null) {
      throw const AuthException('No existe una cuenta para ese correo.');
    }

    // Solo las cuentas creadas sin contraseña pasan por este flujo inicial.
    final actualizado = usuario.copyWith(idUsuario: idUsuario, contrasena: '');
    try {
      await _usuarios.guardarUsuarioAutenticado(actualizado);
      await _usuarios.eliminarUsuarioPendientePorCorreo(correoLimpio);
      await _sesion.guardarSesion(actualizado.idUsuario);
      return actualizado;
    } on StateError catch (error) {
      throw AuthException(error.message.toString());
    } catch (_) {
      throw const AuthException('No se pudo guardar la contraseña inicial.');
    }
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
    await _authIdentityRepository.cerrarSesion();
    await _sesion.limpiarSesion();
  }
}
