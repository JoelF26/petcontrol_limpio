// Sección: imports
// Se importan utilidades de fecha, UUID, constantes y storage local JSON.
import 'package:intl/intl.dart';
import 'package:petcontrol_limpio/core/constants/entidades_locales.dart';
import 'package:petcontrol_limpio/models/cita.dart';
import 'package:petcontrol_limpio/models/mascota.dart';
import 'package:petcontrol_limpio/services/storage/local_json_storage_service.dart';
import 'package:uuid/uuid.dart';

// Sección: servicio de citas
// Encapsula consultas y mutaciones de citas sobre persistencia JSON local.
class CitaService {
  CitaService({
    LocalJsonStorageService? storageService,
    Uuid? uuid,
  }) : _storageService = storageService ?? LocalJsonStorageService(),
       _uuid = uuid ?? const Uuid();

  final LocalJsonStorageService _storageService;
  final Uuid _uuid;

  // Sección: listado completo
  // Retorna todas las citas almacenadas en la entidad local.
  Future<List<Cita>> obtenerCitas() async {
    final registros = await _storageService.leerLista(EntidadesLocales.citas);
    return registros.map(Cita.fromMap).toList(growable: false);
  }

  // Sección: consulta por usuario
  // Obtiene citas por id_usuario y las ordena por fecha de más próxima a más lejana.
  Future<List<Cita>> obtenerCitasPorUsuario(String idUsuario) async {
    final idLimpio = idUsuario.trim();
    if (idLimpio.isEmpty) {
      return const <Cita>[];
    }

    final citas = await obtenerCitas();
    final filtradas = citas
        .where((cita) => cita.idUsuario == idLimpio)
        .toList(growable: false);

    final ordenadas = filtradas.toList(growable: false)
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

  // Sección: creación de cita de cliente
  // Crea una cita con id único, asociando usuario, mascota y médico opcional.
  Future<String> crearCitaCliente({
    required String idUsuario,
    required Mascota mascota,
    required String motivo,
    required String descripcion,
    required DateTime fechaHora,
    String? idMedico,
  }) async {
    final idUsuarioLimpio = idUsuario.trim();
    if (idUsuarioLimpio.isEmpty) {
      throw ArgumentError('El id de usuario es obligatorio.');
    }

    final ahora = DateTime.now();
    final nueva = Cita(
      idCita: _uuid.v4(),
      idUsuario: idUsuarioLimpio,
      idMascota: mascota.idMascota,
      idMedico: (idMedico ?? '').trim(),
      nombreMascota: mascota.nombreVisible,
      especieMascota: mascota.especieVisible,
      motivo: motivo.trim(),
      descripcion: descripcion.trim(),
      estado: 'proxima',
      fechaHora: fechaHora,
      fechaTexto: DateFormat('yyyy-MM-dd').format(fechaHora),
      horaTexto: DateFormat('HH:mm').format(fechaHora),
      fechaCreacion: DateFormat('yyyy-MM-dd').format(ahora),
      createdAt: ahora,
    );

    final citas = await obtenerCitas();
    final actualizadas = <Cita>[...citas, nueva];
    await _guardarCitas(actualizadas);

    return nueva.idCita;
  }

  // Sección: actualización de cita
  // Modifica los campos editables de una cita existente.
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

    final citas = await obtenerCitas();
    final indice = citas.indexWhere((item) => item.idCita == idCitaLimpio);
    if (indice < 0) {
      throw StateError('No existe la cita a actualizar.');
    }

    final actual = citas[indice];
    final editada = actual.copyWith(
      idMascota: idMascotaLimpio,
      nombreMascota: nombreMascota.trim(),
      especieMascota: especieMascota.trim(),
      motivo: motivo.trim(),
      descripcion: descripcion.trim(),
      fechaHora: fechaHora,
      fechaTexto: DateFormat('yyyy-MM-dd').format(fechaHora),
      horaTexto: DateFormat('HH:mm').format(fechaHora),
    );

    final actualizadas = <Cita>[...citas];
    actualizadas[indice] = editada;
    await _guardarCitas(actualizadas);
  }

  // Sección: actualización de cita por admin
  // Permite modificar todos los campos de una cita desde la vista administrativa.
  Future<void> actualizarCitaAdmin({
    required String idCita,
    required String idUsuario,
    required String idMascota,
    required String idMedico,
    required String nombreMascota,
    required String especieMascota,
    required String motivo,
    required String descripcion,
    required String estado,
    required DateTime fechaHora,
  }) async {
    final idCitaLimpio = idCita.trim();
    if (idCitaLimpio.isEmpty) {
      throw ArgumentError('El id de cita es obligatorio.');
    }

    final idUsuarioLimpio = idUsuario.trim();
    if (idUsuarioLimpio.isEmpty) {
      throw ArgumentError('El id de usuario es obligatorio.');
    }

    final idMascotaLimpio = idMascota.trim();
    if (idMascotaLimpio.isEmpty) {
      throw ArgumentError('El id de mascota es obligatorio.');
    }

    final citas = await obtenerCitas();
    final indice = citas.indexWhere((item) => item.idCita == idCitaLimpio);
    if (indice < 0) {
      throw StateError('No existe la cita a actualizar.');
    }

    final actual = citas[indice];
    final editada = actual.copyWith(
      idUsuario: idUsuarioLimpio,
      idMascota: idMascotaLimpio,
      idMedico: idMedico.trim(),
      nombreMascota: nombreMascota.trim(),
      especieMascota: especieMascota.trim(),
      motivo: motivo.trim(),
      descripcion: descripcion.trim(),
      estado: estado.trim(),
      fechaHora: fechaHora,
      fechaTexto: DateFormat('yyyy-MM-dd').format(fechaHora),
      horaTexto: DateFormat('HH:mm').format(fechaHora),
    );

    final actualizadas = <Cita>[...citas];
    actualizadas[indice] = editada;
    await _guardarCitas(actualizadas);
  }

  // Sección: persistencia interna
  // Guarda la lista completa de citas en storage local.
  Future<void> _guardarCitas(List<Cita> citas) async {
    final registros = citas
        .map((cita) => cita.toMap())
        .toList(growable: false);
    await _storageService.guardarLista(EntidadesLocales.citas, registros);
  }
}

