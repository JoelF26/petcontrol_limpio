import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petcontrol_limpio/domain/constants/roles_usuario.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_paths.dart';

class FirebaseAuthProfileHelper {
  FirebaseAuthProfileHelper._();

  static Future<bool> esAdmin({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) async {
    final uid = auth.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) {
      return false;
    }

    final resumen = await firestore
        .collection(FirebasePaths.usuariosAuth)
        .doc(uid)
        .get();
    if (resumen.data()?['rol'] == RolesUsuario.admin) {
      return true;
    }

    final perfil = await firestore
        .collection(FirebasePaths.usuarios)
        .where('id_usuario', isEqualTo: uid)
        .limit(1)
        .get();
    return perfil.docs.isNotEmpty &&
        perfil.docs.first.data()['rol'] == RolesUsuario.admin;
  }
}
