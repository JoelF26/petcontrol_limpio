import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petcontrol_limpio/domain/entities/preferencia_medico.dart';
import 'package:petcontrol_limpio/domain/repositories/preferencia_medico_repository.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_auth_profile_helper.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_paths.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firestore_mapper.dart';

class FirebasePreferenciaMedicoRepository
    implements PreferenciaMedicoRepository {
  FirebasePreferenciaMedicoRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _preferencias =>
      _firestore.collection(FirebasePaths.preferenciaMedico);

  @override
  Future<List<PreferenciaMedico>> obtenerPreferencias() async {
    final query = await _consultaVisible();
    final snapshot = await query.get();
    return snapshot.docs.map(_desdeDoc).toList(growable: false);
  }

  @override
  Stream<List<PreferenciaMedico>> observarPreferencias() async* {
    final query = await _consultaVisible();
    yield* query.snapshots().map(
      (snapshot) => snapshot.docs.map(_desdeDoc).toList(growable: false),
    );
  }

  @override
  Future<void> guardarPreferencias(List<PreferenciaMedico> preferencias) async {
    final query = await _consultaVisible();
    final actuales = await query.get();
    final idsNuevos = preferencias.map((item) => item.idPreferencia).toSet();
    final batch = _firestore.batch();

    for (final doc in actuales.docs) {
      if (!idsNuevos.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }
    for (final preferencia in preferencias) {
      batch.set(
        _preferencias.doc(preferencia.idPreferencia),
        FirestoreMapper.normalizarEscritura(preferencia.toMap()),
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  Future<Query<Map<String, dynamic>>> _consultaVisible() async {
    if (await _esAdmin()) {
      return _preferencias;
    }
    return _preferencias.where(
      'id_usuario',
      isEqualTo: _auth.currentUser?.uid ?? '',
    );
  }

  Future<bool> _esAdmin() async {
    return FirebaseAuthProfileHelper.esAdmin(
      firestore: _firestore,
      auth: _auth,
    );
  }

  PreferenciaMedico _desdeDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = FirestoreMapper.normalizarLectura(doc.data() ?? {});
    data['id_preferencia'] = data['id_preferencia'] ?? doc.id;
    return PreferenciaMedico.fromMap(data);
  }
}
