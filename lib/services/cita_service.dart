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
  // Por defecto oculta citas canceladas para la experiencia del cliente.
  Future<List<Cita>> obtenerCitasPorUsuario(
    String idUsuario, {
    bool incluirCanceladas = false,
  }) async {
    final idLimpio = idUsuario.trim();
    if (idLimpio.isEmpty) {
      return const <Cita>[];
    }

    final citas = await obtenerCitas();
    final filtradas = citas
        .where((cita) {
          if (cita.idUsuario != idLimpio) {
            return false;
          }
          if (!incluirCanceladas && _esEstadoCancelada(cita.estadoVisible)) {
            return false;
          }
          return true;
        })
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
    bool incluirCanceladas = false,
  }) async {
    final citas = await obtenerCitasPorUsuario(
      idUsuario,
      incluirCanceladas: incluirCanceladas,
    );
    return citas.take(maximo).toList(growable: false);
  }

  // Sección: disponibilidad de médicos por horario
  // Retorna los ids de médicos que ya tienen cita en el mismo minuto seleccionado.
  Future<Set<String>> obtenerIdsMedicosOcupadosEnHorario(
    DateTime fechaHora, {
    String? excluirIdCita,
  }) async {
    final citas = await obtenerCitas();
    final ocupados = <String>{};
    final idExcluido = (excluirIdCita ?? '').trim();

    for (final cita in citas) {
      if (_esEstadoCancelada(cita.estadoVisible)) {
        continue;
      }
      if (idExcluido.isNotEmpty && cita.idCita == idExcluido) {
        continue;
      }

      final idMedico = cita.idMedico.trim();
      if (idMedico.isEmpty) {
        continue;
      }

      final fechaCita = cita.fechaHora;
      if (fechaCita == null) {
        continue;
      }

      if (_esMismoMinuto(fechaCita, fechaHora)) {
        ocupados.add(idMedico);
      }
    }

    return ocupados;
  }

  // Sección: médicos disponibles por horario
  // Filtra una lista de ids de médicos removiendo los que estén ocupados.
  Future<List<String>> obtenerIdsMedicosDisponiblesEnHorario({
    required DateTime fechaHora,
    required List<String> idsMedico,
    String? excluirIdCita,
  }) async {
    if (idsMedico.isEmpty) {
      return const <String>[];
    }

    final ocupados = await obtenerIdsMedicosOcupadosEnHorario(
      fechaHora,
      excluirIdCita: excluirIdCita,
    );

    return idsMedico
        .where((id) => id.trim().isNotEmpty && !ocupados.contains(id.trim()))
        .toList(growable: false);
  }

  // Sección: disponibilidad puntual de médico
  // Indica si el médico puede recibir una cita en el minuto seleccionado.
  Future<bool> estaMedicoDisponibleEnHorario({
    required String idMedico,
    required DateTime fechaHora,
    String? excluirIdCita,
  }) async {
    final idLimpio = idMedico.trim();
    if (idLimpio.isEmpty) {
      return true;
    }

    final ocupados = await obtenerIdsMedicosOcupadosEnHorario(
      fechaHora,
      excluirIdCita: excluirIdCita,
    );
    return !ocupados.contains(idLimpio);
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

  // Sección: cancelación de cita por cliente
  // Marca la cita como cancelada sin eliminarla, para mantener trazabilidad clínica.
  Future<void> cancelarCitaCliente({
    required String idCita,
    required String idUsuario,
  }) async {
    final idCitaLimpio = idCita.trim();
    if (idCitaLimpio.isEmpty) {
      throw ArgumentError('El id de cita es obligatorio.');
    }

    final idUsuarioLimpio = idUsuario.trim();
    if (idUsuarioLimpio.isEmpty) {
      throw ArgumentError('El id de usuario es obligatorio.');
    }

    final citas = await obtenerCitas();
    final indice = citas.indexWhere(
      (item) => item.idCita == idCitaLimpio && item.idUsuario == idUsuarioLimpio,
    );
    if (indice < 0) {
      throw StateError('No existe la cita a cancelar.');
    }

    final actual = citas[indice];
    if (_esEstadoCancelada(actual.estadoVisible)) {
      return;
    }

    final actualizadas = <Cita>[...citas];
    actualizadas[indice] = actual.copyWith(estado: 'cancelada');
    await _guardarCitas(actualizadas);
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
    final idMedicoLimpio = (idMedico ?? '').trim();
    if (idMedicoLimpio.isNotEmpty) {
      final disponible = await estaMedicoDisponibleEnHorario(
        idMedico: idMedicoLimpio,
        fechaHora: fechaHora,
      );
      if (!disponible) {
        throw StateError(
          'El médico seleccionado ya tiene una cita en ese horario.',
        );
      }
    }

    final nueva = Cita(
      idCita: _uuid.v4(),
      idUsuario: idUsuarioLimpio,
      idMascota: mascota.idMascota,
      idMedico: idMedicoLimpio,
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
    final idMedicoLimpio = actual.idMedico.trim();
    if (idMedicoLimpio.isNotEmpty) {
      final disponible = await estaMedicoDisponibleEnHorario(
        idMedico: idMedicoLimpio,
        fechaHora: fechaHora,
        excluirIdCita: actual.idCita,
      );
      if (!disponible) {
        throw StateError(
          'El médico asignado ya tiene una cita en ese horario.',
        );
      }
    }

    final nuevaFechaTexto = DateFormat('yyyy-MM-dd').format(fechaHora);
    final nuevaHoraTexto = DateFormat('HH:mm').format(fechaHora);

    // Si el cliente modifica la programación (fecha/hora), la cita pasa a reprogramada.
    final programacionCambio = actual.fechaHora != null
        ? !actual.fechaHora!.isAtSameMomentAs(fechaHora)
        : actual.fechaTexto.trim() != nuevaFechaTexto ||
              actual.horaTexto.trim() != nuevaHoraTexto;

    final editada = actual.copyWith(
      idMascota: idMascotaLimpio,
      nombreMascota: nombreMascota.trim(),
      especieMascota: especieMascota.trim(),
      motivo: motivo.trim(),
      descripcion: descripcion.trim(),
      estado: programacionCambio ? 'reprogramada' : actual.estado,
      fechaHora: fechaHora,
      fechaTexto: nuevaFechaTexto,
      horaTexto: nuevaHoraTexto,
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
    final idMedicoLimpio = idMedico.trim();
    if (idMedicoLimpio.isNotEmpty) {
      final disponible = await estaMedicoDisponibleEnHorario(
        idMedico: idMedicoLimpio,
        fechaHora: fechaHora,
        excluirIdCita: actual.idCita,
      );
      if (!disponible) {
        throw StateError(
          'El médico seleccionado ya tiene una cita en ese horario.',
        );
      }
    }

    final editada = actual.copyWith(
      idUsuario: idUsuarioLimpio,
      idMascota: idMascotaLimpio,
      idMedico: idMedicoLimpio,
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

  // Sección: helper de estado cancelado
  // Normaliza distintos textos para detectar citas canceladas.
  bool _esEstadoCancelada(String estadoRaw) {
    final estado = estadoRaw.trim().toLowerCase();
    return estado.contains('cancel');
  }

  // Sección: comparación por minuto
  // Evalúa conflicto exacto de agenda usando año/mes/día/hora/minuto.
  bool _esMismoMinuto(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }
}

