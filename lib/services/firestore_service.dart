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

  // Sección: referencia de mascotas
  // Expone la colección mascotas tipada para consultas de cliente.
  CollectionReference<Map<String, dynamic>> get mascotasRef {
    return _firestore.collection(ColeccionesFirestore.mascotas);
  }

  // Sección: referencia de citas
  // Expone la colección citas tipada para consultas del módulo de agenda.
  CollectionReference<Map<String, dynamic>> get citasRef {
    return _firestore.collection(ColeccionesFirestore.citas);
  }
}
