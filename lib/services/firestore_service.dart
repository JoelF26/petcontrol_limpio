// Sección: imports
// Se importa Firestore y las constantes de nombres de colección.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcontrol_limpio/core/constants/colecciones.dart';

// Sección: servicio base de Firestore
// Centraliza referencias de colecciones para reutilizarlas en servicios.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // Sección: referencia de usuarios
  // Expone la colección usuarios tipada como Map<String, dynamic>.
  CollectionReference<Map<String, dynamic>> get usuariosRef {
    return _firestore.collection(ColeccionesFirestore.usuarios);
  }
}
