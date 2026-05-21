import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcontrol_limpio/domain/entities/personal_medico.dart';
import 'package:petcontrol_limpio/domain/repositories/personal_medico_repository.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_paths.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firestore_mapper.dart';

class FirebasePersonalMedicoRepository implements PersonalMedicoRepository {
  FirebasePersonalMedicoRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _personal =>
      _firestore.collection(FirebasePaths.personalMedico);

  @override
  Future<List<PersonalMedico>> obtenerPersonalMedico() async {
    final snapshot = await _personal.get();
    return snapshot.docs.map(_desdeDoc).toList(growable: false);
  }

  @override
  Stream<List<PersonalMedico>> observarPersonalMedico() {
    return _personal.snapshots().map(
      (snapshot) => snapshot.docs.map(_desdeDoc).toList(growable: false),
    );
  }

  @override
  Future<void> guardarPersonalMedico(List<PersonalMedico> medicos) async {
    final actuales = await _personal.get();
    final idsNuevos = medicos.map((item) => item.idMedico).toSet();
    final batch = _firestore.batch();

    for (final doc in actuales.docs) {
      if (!idsNuevos.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }

    for (final medico in medicos) {
      batch.set(
        _personal.doc(medico.idMedico),
        FirestoreMapper.normalizarEscritura(medico.toMap()),
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  PersonalMedico _desdeDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = FirestoreMapper.normalizarLectura(doc.data() ?? {});
    data['id_medico'] = data['id_medico'] ?? doc.id;
    return PersonalMedico.fromMap(data);
  }
}
