import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petcontrol_limpio/domain/entities/cita.dart';
import 'package:petcontrol_limpio/domain/repositories/cita_repository.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_auth_profile_helper.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_paths.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firestore_mapper.dart';

class FirebaseCitaRepository implements CitaRepository {
  FirebaseCitaRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _citas =>
      _firestore.collection(FirebasePaths.citas);

  @override
  Future<List<Cita>> obtenerCitas() async {
    final query = await _consultaVisible();
    final snapshot = await query.get();
    return snapshot.docs.map(_desdeDoc).toList(growable: false);
  }

  @override
  Stream<List<Cita>> observarCitas() async* {
    final query = await _consultaVisible();
    yield* query.snapshots().map(
      (snapshot) => snapshot.docs.map(_desdeDoc).toList(growable: false),
    );
  }

  @override
  Future<void> guardarCita(Cita cita) async {
    await _citas
        .doc(cita.idCita)
        .set(
          FirestoreMapper.normalizarEscritura(cita.toMap()),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> guardarCitas(List<Cita> citas) async {
    final query = await _consultaVisible();
    final actuales = await query.get();
    final idsNuevos = citas.map((item) => item.idCita).toSet();
    final batch = _firestore.batch();

    for (final doc in actuales.docs) {
      if (!idsNuevos.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }

    for (final cita in citas) {
      batch.set(
        _citas.doc(cita.idCita),
        FirestoreMapper.normalizarEscritura(cita.toMap()),
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  Future<Query<Map<String, dynamic>>> _consultaVisible() async {
    if (await _esAdmin()) {
      return _citas;
    }
    final uid = _auth.currentUser?.uid ?? '';
    return _citas.where('id_usuario', isEqualTo: uid);
  }

  Future<bool> _esAdmin() async {
    return FirebaseAuthProfileHelper.esAdmin(
      firestore: _firestore,
      auth: _auth,
    );
  }

  Cita _desdeDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = FirestoreMapper.normalizarLectura(doc.data() ?? {});
    data['id_cita'] = data['id_cita'] ?? doc.id;
    return Cita.fromMap(data);
  }
}
