import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:petcontrol_limpio/domain/entities/usuario.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_email_helper.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_paths.dart';

class FirebaseSeedService {
  FirebaseSeedService({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<void> migrarDatosInicialesSiEsPosible() async {
    if (_auth.currentUser != null) {
      return;
    }

    try {
      final seed = await _leerJson('assets/data/local_db_seed.json');
      final usuariosRaw = seed['usuarios'];
      if (usuariosRaw is! List) {
        return;
      }

      var adminAutenticado = false;
      for (final item in usuariosRaw) {
        if (item is! Map) {
          continue;
        }
        final usuario = Usuario.fromMap(
          item.map((key, value) => MapEntry(key.toString(), value)),
        );
        final pudoAutenticar = await _crearOIngresarUsuarioSeed(usuario);
        if (pudoAutenticar) {
          await _guardarPerfilUsuarioSeed(usuario);
          if (usuario.esAdmin) {
            adminAutenticado = true;
            await _migrarCatalogos();
          }
          await _auth.signOut();
        }
      }

      if (!adminAutenticado) {
        await _migrarCatalogos();
      }
    } catch (error) {
      debugPrint('No se pudo migrar seed inicial a Firebase: $error');
      await _auth.signOut();
    }
  }

  Future<bool> _crearOIngresarUsuarioSeed(Usuario usuario) async {
    final correo = FirebaseEmailHelper.normalizarCorreo(usuario.correo);
    final contrasena = usuario.contrasena.trim();
    if (correo.isEmpty || contrasena.isEmpty) {
      return false;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
      return true;
    } on firebase_auth.FirebaseAuthException catch (error) {
      if (error.code != 'email-already-in-use') {
        rethrow;
      }
      try {
        await _auth.signInWithEmailAndPassword(
          email: correo,
          password: contrasena,
        );
        return true;
      } on firebase_auth.FirebaseAuthException {
        return false;
      }
    }
  }

  Future<void> _guardarPerfilUsuarioSeed(Usuario usuario) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return;
    }
    final perfil = usuario.copyWith(idUsuario: uid, contrasena: '');
    final docIdLegible = _crearIdDocumentoLegible(perfil);
    final batch = _firestore.batch();
    batch.set(
      _firestore.collection(FirebasePaths.usuarios).doc(docIdLegible),
      <String, dynamic>{
        ...perfil.toMap(),
        'contrasena': '',
        'email_hash': FirebaseEmailHelper.hashCorreo(perfil.correo),
      },
      SetOptions(merge: true),
    );
    batch.set(
      _firestore.collection(FirebasePaths.usuariosAuth).doc(uid),
      <String, dynamic>{
        'id_usuario': uid,
        'correo': FirebaseEmailHelper.normalizarCorreo(perfil.correo),
        'rol': perfil.rol,
        'nombre_completo': perfil.nombreCompleto.trim(),
        'email_hash': FirebaseEmailHelper.hashCorreo(perfil.correo),
        'usuario_doc_id': docIdLegible,
        'updated_at': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Future<void> _migrarCatalogos() async {
    final catalogos = await _leerJson('assets/data/catalogos.json');
    if (catalogos.isEmpty) {
      return;
    }
    await _firestore
        .collection(FirebasePaths.catalogos)
        .doc(FirebasePaths.catalogosConfig)
        .set(catalogos, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> _leerJson(String ruta) async {
    final contenido = await rootBundle.loadString(ruta);
    final decoded = jsonDecode(contenido);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  String _crearIdDocumentoLegible(Usuario usuario) {
    final nombre = usuario.nombreCompleto.trim().isEmpty
        ? 'usuario'
        : usuario.nombreCompleto.trim();
    final base = nombre
        .replaceAll(RegExp(r'[/\\#?\[\]]'), ' ')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final prefijo = base.isEmpty ? 'usuario' : base;
    final id = usuario.idUsuario.trim();
    final sufijo = id.length <= 8 ? id : id.substring(0, 8);
    return '${prefijo}_$sufijo';
  }
}
