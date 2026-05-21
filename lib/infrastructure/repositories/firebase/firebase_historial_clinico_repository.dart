import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petcontrol_limpio/domain/entities/historial_clinico.dart';
import 'package:petcontrol_limpio/domain/repositories/historial_clinico_repository.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_auth_profile_helper.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_paths.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firestore_mapper.dart';

class FirebaseHistorialClinicoRepository implements HistorialClinicoRepository {
  FirebaseHistorialClinicoRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _historial =>
      _firestore.collection(FirebasePaths.historialClinico);

  @override
  Future<List<HistorialClinico>> obtenerHistoriales() async {
    final query = await _consultaVisible();
    final snapshot = await query.get();
    return snapshot.docs.map(_desdeDoc).toList(growable: false);
  }

  @override
  Stream<List<HistorialClinico>> observarHistoriales() async* {
    final query = await _consultaVisible();
    yield* query.snapshots().map(
      (snapshot) => snapshot.docs.map(_desdeDoc).toList(growable: false),
    );
  }

  @override
  Future<void> guardarHistoriales(List<HistorialClinico> historiales) async {
    final query = await _consultaVisible();
    final actuales = await query.get();
    final idsNuevos = historiales.map((item) => item.idHistorial).toSet();
    final batch = _firestore.batch();

    for (final doc in actuales.docs) {
      if (!idsNuevos.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }
    for (final historial in historiales) {
      batch.set(
        _historial.doc(historial.idHistorial),
        FirestoreMapper.normalizarEscritura(historial.toMap()),
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  Future<Query<Map<String, dynamic>>> _consultaVisible() async {
    if (await _esAdmin()) {
      return _historial;
    }
    return _historial.where(
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

  HistorialClinico _desdeDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = FirestoreMapper.normalizarLectura(doc.data() ?? {});
    data['id_historial'] = data['id_historial'] ?? doc.id;
    return HistorialClinico.fromMap(data);
  }
}
