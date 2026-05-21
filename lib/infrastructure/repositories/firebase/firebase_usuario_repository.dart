import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcontrol_limpio/domain/entities/usuario.dart';
import 'package:petcontrol_limpio/domain/repositories/usuario_repository.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_email_helper.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_paths.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firestore_mapper.dart';

class FirebaseUsuarioRepository implements UsuarioRepository {
  FirebaseUsuarioRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _firestore.collection(FirebasePaths.usuarios);

  CollectionReference<Map<String, dynamic>> get _usuariosAuth =>
      _firestore.collection(FirebasePaths.usuariosAuth);

  CollectionReference<Map<String, dynamic>> get _pendientes =>
      _firestore.collection(FirebasePaths.usuariosPendientes);

  CollectionReference<Map<String, dynamic>> get _accesosIniciales =>
      _firestore.collection(FirebasePaths.accesosIniciales);

  @override
  Future<List<Usuario>> obtenerUsuarios() async {
    final snapshot = await _usuarios.get();
    final usuarios = <Usuario>[];
    for (final doc in snapshot.docs) {
      final usuario = _usuarioDesdeDoc(doc);
      usuarios.add(usuario);
      if (usuario.idUsuario.trim().isNotEmpty &&
          doc.id != _crearIdDocumentoLegible(usuario)) {
        await guardarUsuario(usuario);
      }
    }
    return usuarios;
  }

  @override
  Stream<List<Usuario>> observarUsuarios() {
    return _usuarios.snapshots().map(
      (snapshot) => snapshot.docs.map(_usuarioDesdeDoc).toList(growable: false),
    );
  }

  @override
  Future<Usuario?> obtenerUsuarioPorId(String idUsuario) async {
    final idLimpio = idUsuario.trim();
    if (idLimpio.isEmpty) {
      return null;
    }

    final snapshot = await _usuarios
        .where('id_usuario', isEqualTo: idLimpio)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final usuario = _usuarioDesdeDoc(snapshot.docs.first);
      await _guardarResumenAuth(usuario, snapshot.docs.first.id);
      return usuario;
    }

    final doc = await _usuarios.doc(idLimpio).get();
    if (doc.exists && doc.data() != null) {
      final usuario = _usuarioDesdeDoc(doc);
      await _guardarResumenAuth(usuario, doc.id);
      return usuario;
    }

    return null;
  }

  @override
  Future<Usuario?> obtenerUsuarioPorCorreo(String correo) async {
    final correoLimpio = FirebaseEmailHelper.normalizarCorreo(correo);
    if (correoLimpio.isEmpty) {
      return null;
    }
    final snapshot = await _usuarios
        .where('correo', isEqualTo: correoLimpio)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    return _usuarioDesdeDoc(snapshot.docs.first);
  }

  @override
  Future<void> guardarUsuario(Usuario usuario) async {
    final docIdLegible = _crearIdDocumentoLegible(usuario);
    final existentes = await _usuarios
        .where('id_usuario', isEqualTo: usuario.idUsuario)
        .get();
    final batch = _firestore.batch();

    for (final doc in existentes.docs) {
      if (doc.id != docIdLegible) {
        batch.delete(doc.reference);
      }
    }

    batch.set(
      _usuarios.doc(docIdLegible),
      _usuarioParaFirestore(usuario),
      SetOptions(merge: true),
    );
    batch.set(
      _usuariosAuth.doc(usuario.idUsuario),
      _resumenAuthParaFirestore(usuario, docIdLegible),
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  @override
  Future<void> guardarUsuarios(List<Usuario> usuarios) async {
    for (final usuario in usuarios) {
      await guardarUsuario(usuario);
    }
  }

  @override
  Future<Usuario?> obtenerUsuarioPendientePorCorreo(String correo) async {
    final hash = FirebaseEmailHelper.hashCorreo(correo);
    final doc = await _pendientes.doc(hash).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return _usuarioDesdeDoc(doc);
  }

  @override
  Future<void> guardarUsuarioPendiente(Usuario usuario) async {
    final hash = FirebaseEmailHelper.hashCorreo(usuario.correo);
    final batch = _firestore.batch();
    batch.set(_pendientes.doc(hash), <String, dynamic>{
      ..._usuarioParaFirestore(usuario.copyWith(contrasena: '')),
      'id_usuario': '',
      'email_hash': hash,
      'pendiente': true,
    }, SetOptions(merge: true));
    batch.set(_accesosIniciales.doc(hash), <String, dynamic>{
      'estado': 'pendiente',
      'email_hash': hash,
      'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  @override
  Future<void> eliminarUsuarioPendientePorCorreo(String correo) async {
    final hash = FirebaseEmailHelper.hashCorreo(correo);
    final batch = _firestore.batch();
    batch.delete(_pendientes.doc(hash));
    batch.delete(_accesosIniciales.doc(hash));
    await batch.commit();
  }

  Usuario _usuarioDesdeDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = FirestoreMapper.normalizarLectura(doc.data() ?? {});
    data['id_usuario'] = (data['id_usuario']?.toString().isNotEmpty ?? false)
        ? data['id_usuario']
        : doc.id;
    data['contrasena'] = data['contrasena'] ?? '';
    return Usuario.fromMap(data);
  }

  Map<String, dynamic> _usuarioParaFirestore(Usuario usuario) {
    final data = FirestoreMapper.normalizarEscritura(usuario.toMap());
    data['correo'] = FirebaseEmailHelper.normalizarCorreo(usuario.correo);
    data['email_hash'] = FirebaseEmailHelper.hashCorreo(usuario.correo);
    data['contrasena'] = '';
    return data;
  }

  Future<void> _guardarResumenAuth(Usuario usuario, String docIdLegible) async {
    await _usuariosAuth
        .doc(usuario.idUsuario)
        .set(
          _resumenAuthParaFirestore(usuario, docIdLegible),
          SetOptions(merge: true),
        );
  }

  Map<String, dynamic> _resumenAuthParaFirestore(
    Usuario usuario,
    String docIdLegible,
  ) {
    return <String, dynamic>{
      'id_usuario': usuario.idUsuario,
      'correo': FirebaseEmailHelper.normalizarCorreo(usuario.correo),
      'rol': usuario.rol,
      'nombre_completo': usuario.nombreCompleto.trim(),
      'email_hash': FirebaseEmailHelper.hashCorreo(usuario.correo),
      'usuario_doc_id': docIdLegible,
      'updated_at': FieldValue.serverTimestamp(),
    };
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
