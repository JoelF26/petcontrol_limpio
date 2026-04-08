// Sección: imports
// Se importan Firebase Auth, Firestore e utilidades para crear el perfil.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:petcontrol_limpio/core/constants/roles_usuario.dart';
import 'package:petcontrol_limpio/firebase_options.dart';
import 'package:petcontrol_limpio/models/usuario.dart';
import 'package:petcontrol_limpio/services/usuario_service.dart';

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
// Contiene login, registro y sesión sin mezclar lógica en pantallas.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth, UsuarioService? usuarioService})
    : _firebaseAuth = firebaseAuth,
      _usuarioService = usuarioService;

  final FirebaseAuth? _firebaseAuth;
  final UsuarioService? _usuarioService;

  // Sección: acceso perezoso a FirebaseAuth
  // Evita resolver FirebaseAuth.instance en el constructor de la pantalla.
  FirebaseAuth get _auth => _firebaseAuth ?? FirebaseAuth.instance;

  // Sección: acceso perezoso a UsuarioService
  // Evita tocar Firestore en el constructor si aún no corresponde.
  UsuarioService get _usuarios => _usuarioService ?? UsuarioService();

  // Sección: estado de sesión
  // Retorna el usuario actual autenticado en Firebase Auth.
  User? get usuarioFirebaseActual {
    if (Firebase.apps.isEmpty) {
      return null;
    }
    return _auth.currentUser;
  }

  // Sección: registro de cliente
  // Crea cuenta en Firebase Auth y luego guarda el perfil en Firestore.
  Future<Usuario> registrarCliente(DatosRegistroCliente datos) async {
    // Sección: validación previa de Firebase
    // Evita llamar Auth/Firestore si Firebase no está inicializado.
    await _asegurarFirebaseInicializado();

    UserCredential credencial;
    // Sección: creación de credenciales en Auth
    // Da de alta el correo/contraseña y obtiene el uid generado.
    try {
      credencial = await _auth.createUserWithEmailAndPassword(
        email: datos.correo.trim().toLowerCase(),
        password: datos.contrasena,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mensajeErrorAuth(error));
    } catch (_) {
      throw const AuthException('No se pudo completar el registro.');
    }

    // Sección: validación de credencial resultante
    // Garantiza que Firebase haya devuelto un usuario válido.
    final user = credencial.user;
    if (user == null) {
      throw const AuthException('No fue posible crear el usuario.');
    }

    // Sección: armado de entidad Usuario
    // Se completa el perfil con rol fijo cliente y campos requeridos.
    final ahora = DateTime.now();
    final usuario = Usuario(
      idUsuario: user.uid,
      nombreCompleto: datos.nombreCompleto.trim(),
      numeroDocumento: datos.numeroDocumento.trim(),
      telefono: datos.telefono.trim(),
      correo: datos.correo.trim().toLowerCase(),
      contrasena: datos.contrasena,
      rol: RolesUsuario.cliente,
      fechaCreacion: DateFormat('yyyy-MM-dd').format(ahora),
      createdAt: Timestamp.fromDate(ahora),
    );

    // Sección: persistencia de perfil
    // Si falla Firestore, se revierte el usuario creado en Auth.
    try {
      await _usuarios.crearUsuario(usuario);
      return usuario;
    } catch (_) {
      await user.delete();
      throw const AuthException(
        'Se creó la cuenta de acceso, pero falló el guardado del perfil.',
      );
    }
  }

  // Sección: inicio de sesión
  // Valida credenciales y luego carga el perfil desde Firestore.
  Future<Usuario> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    // Sección: validación previa de Firebase
    // Evita llamar Auth/Firestore si Firebase no está inicializado.
    await _asegurarFirebaseInicializado();

    UserCredential credencial;
    // Sección: autenticación por correo y contraseña
    // Verifica credenciales en Firebase Auth.
    try {
      credencial = await _auth.signInWithEmailAndPassword(
        email: correo.trim().toLowerCase(),
        password: contrasena,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mensajeErrorAuth(error));
    } catch (_) {
      throw const AuthException('No se pudo iniciar sesión.');
    }

    // Sección: resolución de uid
    // Se usa el uid para encontrar el perfil en la colección usuarios.
    final uid = credencial.user?.uid;
    if (uid == null) {
      throw const AuthException('No se pudo validar la cuenta.');
    }

    // Sección: carga de perfil de dominio
    // Sin perfil Firestore se considera sesión incompleta.
    final usuario = await _usuarios.obtenerUsuarioPorId(uid);
    if (usuario == null) {
      throw const AuthException(
        'La cuenta existe en autenticación, pero no tiene perfil en Firestore.',
      );
    }

    return usuario;
  }

  // Sección: obtención de usuario actual
  // Retorna el perfil de Firestore del usuario logueado actualmente.
  Future<Usuario?> obtenerUsuarioActual() async {
    // Sección: validación previa de Firebase
    // Si Firebase no está inicializado, no hay usuario para consultar.
    if (Firebase.apps.isEmpty) {
      return null;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return _usuarios.obtenerUsuarioPorId(uid);
  }

  // Sección: cierre de sesión
  // Cierra la sesión activa en Firebase Auth.
  Future<void> cerrarSesion() async {
    if (Firebase.apps.isEmpty) {
      return;
    }
    await _auth.signOut();
  }

  // Sección: traducción de errores
  // Convierte códigos de Firebase Auth en mensajes amigables.
  String _mensajeErrorAuth(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'El correo no tiene un formato válido.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta de nuevo en unos minutos.';
      case 'configuration-not-found':
        return 'Firebase Auth no está configurado en el proyecto. Activa Authentication y el proveedor Correo/Contraseña en Firebase Console.';
      default:
        return 'Error de autenticación: ${error.code}.';
    }
  }

  // Sección: verificación de inicialización de Firebase
  // Intenta inicializar Firebase de forma diferida y reporta errores claros.
  Future<void> _asegurarFirebaseInicializado() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on UnsupportedError {
      throw const AuthException(
        'Firebase no está configurado en esta plataforma.',
      );
    } on FirebaseException catch (error) {
      throw AuthException(
        'No se pudo inicializar Firebase (${error.code}). Revisa la configuración web.',
      );
    } catch (_) {
      throw const AuthException(
        'No se pudo inicializar Firebase en esta plataforma.',
      );
    }

    if (Firebase.apps.isEmpty) {
      throw const AuthException(
        'Firebase no está disponible en esta plataforma.',
      );
    }
  }
}
