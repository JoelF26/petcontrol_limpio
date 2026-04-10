// Sección: imports
// Se importa FirestoreService para consultar la colección citas.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:petcontrol_limpio/models/cita.dart';
import 'package:petcontrol_limpio/services/firestore_service.dart';

// Sección: servicio de citas
// Encapsula consultas de citas vinculadas al usuario del cliente.
class CitaService {
  CitaService({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  // Sección: consulta por usuario
  // Obtiene citas por id_usuario y las ordena por fecha de más próxima a más lejana.
  Future<List<Cita>> obtenerCitasPorUsuario(String idUsuario) async {
    final idLimpio = idUsuario.trim();
    if (idLimpio.isEmpty) {
      return const <Cita>[];
    }

    final snapshot = await _firestoreService.citasRef
        .where('id_usuario', isEqualTo: idLimpio)
        .get();

    final citas = snapshot.docs
        .map((doc) => Cita.fromMap(doc.data(), idDocumento: doc.id))
        .toList(growable: false);
    final ordenadas = citas.toList()
      ..sort((a, b) => a.fechaOrden.compareTo(b.fechaOrden));
    return ordenadas;
  }

  // Sección: próximas citas para home
  // Retorna un máximo configurable de citas para la tarjeta principal.
  Future<List<Cita>> obtenerProximasCitasPorUsuario(
    String idUsuario, {
    int maximo = 4,
  }) async {
    final citas = await obtenerCitasPorUsuario(idUsuario);
    return citas.take(maximo).toList(growable: false);
  }

  // Sección: conteo de pendientes en memoria
  // Cuenta estados pendientes usando una lista ya consultada.
  int contarPendientesEnLista(List<Cita> citas) {
    return citas.where((cita) => cita.esPendiente).length;
  }

  // Sección: conteo de citas pendientes por usuario
  // Busca citas por id_usuario y cuenta solo las que estén en estado pendiente.
  Future<int> contarCitasPendientesPorUsuario(String idUsuario) async {
    final citas = await obtenerCitasPorUsuario(idUsuario);
    return contarPendientesEnLista(citas);
  }

  // Sección: actualización de cita
  // Modifica los campos editables de una cita existente en Firestore.
  Future<void> actualizarCitaCliente({
    required String idCita,
    required String idMascota,
    required String nombreMascota,
    required String especieMascota,
    required String motivo,
    required String descripcion,
    required DateTime fechaHora,
  }) async {
    final idCitaLimpio = idCita.trim();
    if (idCitaLimpio.isEmpty) {
      throw ArgumentError('El id de cita es obligatorio.');
    }

    final idMascotaLimpio = idMascota.trim();
    if (idMascotaLimpio.isEmpty) {
      throw ArgumentError('El id de mascota es obligatorio.');
    }

    await _firestoreService.citasRef.doc(idCitaLimpio).update(<String, dynamic>{
      'id_mascota': idMascotaLimpio,
      'nombre_mascota': nombreMascota.trim(),
      'especie_mascota': especieMascota.trim(),
      'motivo': motivo.trim(),
      'descripcion': descripcion.trim(),
      'fecha_hora': Timestamp.fromDate(fechaHora),
      'fecha_cita': DateFormat('yyyy-MM-dd').format(fechaHora),
      'hora_cita': DateFormat('HH:mm').format(fechaHora),
    });
  }
}
