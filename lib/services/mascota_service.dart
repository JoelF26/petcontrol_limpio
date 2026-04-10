// Sección: imports
// Se importa FirestoreService para consultar la colección mascotas.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:petcontrol_limpio/models/mascota.dart';
import 'package:petcontrol_limpio/services/firestore_service.dart';

// Sección: servicio de mascotas
// Encapsula consultas de mascotas relacionadas con el cliente autenticado.
class MascotaService {
  MascotaService({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  // Sección: consulta de mascotas por usuario
  // Obtiene todas las mascotas de un cliente y las ordena de más reciente a más antigua.
  Future<List<Mascota>> obtenerMascotasPorUsuario(String idUsuario) async {
    final idLimpio = idUsuario.trim();
    if (idLimpio.isEmpty) {
      return const <Mascota>[];
    }

    final snapshot = await _firestoreService.mascotasRef
        .where('id_usuario', isEqualTo: idLimpio)
        .get();

    final mascotas = snapshot.docs
        .map((doc) => Mascota.fromMap(doc.data(), idDocumento: doc.id))
        .toList(growable: false);
    final ordenadas = mascotas.toList()
      ..sort((a, b) => b.fechaOrden.compareTo(a.fechaOrden));
    return ordenadas;
  }

  // Sección: conteo por usuario
  // Retorna cuántas mascotas tiene registradas un usuario por id_usuario.
  Future<int> contarMascotasPorUsuario(String idUsuario) async {
    final mascotas = await obtenerMascotasPorUsuario(idUsuario);
    return mascotas.length;
  }

  // Sección: creación de mascota de cliente
  // Registra una nueva mascota con id único y la asocia al id_usuario autenticado.
  Future<String> crearMascotaCliente({
    required String idUsuario,
    required String nombre,
    required String especie,
    required String raza,
    required String sexo,
    required int edadAnios,
    required double pesoKg,
  }) async {
    final idUsuarioLimpio = idUsuario.trim();
    if (idUsuarioLimpio.isEmpty) {
      throw ArgumentError('El id de usuario es obligatorio.');
    }

    final ahora = DateTime.now();
    final referencia = _firestoreService.mascotasRef.doc();
    final idMascota = referencia.id;

    await referencia.set(<String, dynamic>{
      'id_mascota': idMascota,
      'id_usuario': idUsuarioLimpio,
      'nombre': nombre.trim(),
      'especie': especie.trim(),
      'raza': raza.trim(),
      'sexo': sexo.trim(),
      'edad_anios': edadAnios,
      'peso_kg': pesoKg,
      'fecha_creacion': DateFormat('yyyy-MM-dd').format(ahora),
      'created_at': Timestamp.fromDate(ahora),
    });

    return idMascota;
  }

  // Sección: actualización de mascota
  // Modifica los datos editables de una mascota existente en Firestore.
  Future<void> actualizarMascotaCliente({
    required String idMascota,
    required String nombre,
    required String especie,
    required String raza,
    required int edadAnios,
    required double pesoKg,
  }) async {
    final idMascotaLimpio = idMascota.trim();
    if (idMascotaLimpio.isEmpty) {
      throw ArgumentError('El id de mascota es obligatorio.');
    }

    await _firestoreService.mascotasRef.doc(idMascotaLimpio).update(<String, dynamic>{
      'nombre': nombre.trim(),
      'especie': especie.trim(),
      'raza': raza.trim(),
      'edad_anios': edadAnios,
      'peso_kg': pesoKg,
    });
  }
}
