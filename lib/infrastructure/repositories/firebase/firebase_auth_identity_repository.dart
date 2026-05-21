import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:petcontrol_limpio/domain/repositories/auth_identity_repository.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_email_helper.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_paths.dart';

class FirebaseAuthIdentityRepository implements AuthIdentityRepository {
  FirebaseAuthIdentityRepository({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  String? get idUsuarioActual => _auth.currentUser?.uid;

  @override
  Future<String> registrarConCorreo({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: FirebaseEmailHelper.normalizarCorreo(correo),
        password: contrasena,
      );
      return credencial.user!.uid;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw StateError(_mensajeRegistro(error.code));
    }
  }

  @override
  Future<String> iniciarSesionConCorreo({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: FirebaseEmailHelper.normalizarCorreo(correo),
        password: contrasena,
      );
      return credencial.user!.uid;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw StateError(_mensajeInicioSesion(error.code));
    }
  }

  @override
  Future<bool> existeCuentaConContrasena(String correo) async => true;

  @override
  Future<bool> existeAccesoInicial(String correo) async {
    final hash = FirebaseEmailHelper.hashCorreo(correo);
    final doc = await _firestore
        .collection(FirebasePaths.accesosIniciales)
        .doc(hash)
        .get();
    return doc.exists && doc.data()?['estado'] == 'pendiente';
  }

  @override
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  String _mensajeRegistro(String code) {
    return switch (code) {
      'email-already-in-use' => 'Este correo ya está registrado.',
      'invalid-email' => 'Ingresa un correo válido.',
      'weak-password' => 'La contraseña debe tener mínimo 6 caracteres.',
      'operation-not-allowed' =>
        'El registro con correo y contraseña no está habilitado.',
      _ => 'No se pudo completar el registro.',
    };
  }

  String _mensajeInicioSesion(String code) {
    return switch (code) {
      'invalid-email' => 'Ingresa un correo válido.',
      'user-disabled' => 'Esta cuenta está deshabilitada.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Correo o contraseña incorrectos.',
      _ => 'No se pudo iniciar sesión.',
    };
  }
}
