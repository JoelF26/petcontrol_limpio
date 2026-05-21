import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petcontrol_limpio/domain/entities/mascota.dart';
import 'package:petcontrol_limpio/domain/repositories/mascota_repository.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_auth_profile_helper.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_paths.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firestore_mapper.dart';

class FirebaseMascotaRepository implements MascotaRepository {
  FirebaseMascotaRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _mascotas =>
      _firestore.collection(FirebasePaths.mascotas);

  @override
  Future<List<Mascota>> obtenerMascotas() async {
    final query = await _consultaVisible();
    final snapshot = await query.get();
    return snapshot.docs.map(_desdeDoc).toList(growable: false);
  }

  @override
  Stream<List<Mascota>> observarMascotas() async* {
    final query = await _consultaVisible();
    yield* query.snapshots().map(
      (snapshot) => snapshot.docs.map(_desdeDoc).toList(growable: false),
    );
  }

  @override
  Future<void> guardarMascotas(List<Mascota> mascotas) async {
    final query = await _consultaVisible();
    final actuales = await query.get();
    final idsNuevos = mascotas.map((item) => item.idMascota).toSet();
    final batch = _firestore.batch();

    for (final doc in actuales.docs) {
      if (!idsNuevos.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }

    for (final mascota in mascotas) {
      batch.set(
        _mascotas.doc(mascota.idMascota),
        FirestoreMapper.normalizarEscritura(mascota.toMap()),
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  Future<Query<Map<String, dynamic>>> _consultaVisible() async {
    if (await _esAdmin()) {
      return _mascotas;
    }
    final uid = _auth.currentUser?.uid ?? '';
    return _mascotas.where('id_usuario', isEqualTo: uid);
  }

  Future<bool> _esAdmin() async {
    return FirebaseAuthProfileHelper.esAdmin(
      firestore: _firestore,
      auth: _auth,
    );
  }

  Mascota _desdeDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = FirestoreMapper.normalizarLectura(doc.data() ?? {});
    data['id_mascota'] = data['id_mascota'] ?? doc.id;
    return Mascota.fromMap(data);
  }
}
