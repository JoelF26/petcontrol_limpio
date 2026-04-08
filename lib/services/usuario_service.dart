// Sección: imports
// Se importan Firestore y el modelo Usuario para persistencia.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcontrol_limpio/models/usuario.dart';
import 'package:petcontrol_limpio/services/firestore_service.dart';

// Sección: servicio de usuarios
// Encapsula operaciones de lectura/escritura de perfiles de usuario.
class UsuarioService {
  UsuarioService({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  // Sección: creación de perfil
  // Guarda el usuario en Firestore usando id_usuario como id de documento.
  Future<void> crearUsuario(Usuario usuario) async {
    await _firestoreService.usuariosRef
        .doc(usuario.idUsuario)
        .set(usuario.toMap(), SetOptions(merge: false));
  }

  // Sección: consulta por id
  // Busca un usuario por su id y lo convierte al modelo de dominio.
  Future<Usuario?> obtenerUsuarioPorId(String idUsuario) async {
    final snapshot = await _firestoreService.usuariosRef.doc(idUsuario).get();
    final data = snapshot.data();
    if (data == null) {
      return null;
    }
    return Usuario.fromMap(data);
  }
}
