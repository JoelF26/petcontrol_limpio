// Sección: imports
// Se importan utilidades de fecha, UUID, constantes y storage local JSON.
import 'package:intl/intl.dart';
import 'package:petcontrol_limpio/domain/entities/cita.dart';
import 'package:petcontrol_limpio/domain/entities/mascota.dart';
import 'package:petcontrol_limpio/domain/repositories/cita_repository.dart';
import 'package:uuid/uuid.dart';

// Sección: servicio de citas
// Encapsula consultas y mutaciones de citas sobre persistencia JSON local.
class CitaService {
  CitaService({required CitaRepository citaRepository, Uuid? uuid})
    : _citaRepository = citaRepository,
      _uuid = uuid ?? const Uuid();

  final CitaRepository _citaRepository;
  final Uuid _uuid;

  // Sección: listado completo
  // Retorna todas las citas almacenadas en la entidad local.
  Future<List<Cita>> obtenerCitas() async {
    return _citaRepository.obtenerCitas();
  }

  Stream<List<Cita>> observarCitas() {
    return _citaRepository.observarCitas();
  }

  // Sección: consulta por usuario
  // Obtiene citas por id_usuario y las ordena por fecha de más próxima a más lejana.
  // Por defecto oculta citas canceladas para la experiencia del cliente.
  Future<List<Cita>> obtenerCitasPorUsuario(
    String idUsuario, {
    bool incluirCanceladas = false,
    bool incluirPasadas = false,
  }) async {
    final idLimpio = idUsuario.trim();
    if (idLimpio.isEmpty) {
      return const <Cita>[];
    }

    final citas = await obtenerCitas();
    return filtrarCitasVisiblesPorUsuario(
      citas,
      idLimpio,
      incluirCanceladas: incluirCanceladas,
      incluirPasadas: incluirPasadas,
    );
  }

  // Sección: filtro de citas visibles para cliente
  // Reutiliza la misma regla en cargas iniciales y actualizaciones en tiempo real.
  List<Cita> filtrarCitasVisiblesPorUsuario(
    List<Cita> citas,
    String idUsuario, {
    bool incluirCanceladas = false,
    bool incluirPasadas = false,
  }) {
    final idLimpio = idUsuario.trim();
    if (idLimpio.isEmpty) {
      return const <Cita>[];
    }

    final filtradas = citas
        .where((cita) {
          if (cita.idUsuario != idLimpio) {
            return false;
          }
          if (!incluirCanceladas && _esEstadoCancelada(cita.estadoVisible)) {
            return false;
          }
          if (!incluirPasadas && !_esCitaVigente(cita)) {
            return false;
          }
          return true;
        })
        .toList(growable: false);

    final ordenadas = filtradas.toList(growable: false)
      ..sort((a, b) => a.fechaOrden.compareTo(b.fechaOrden));
    return ordenadas;
  }

  // Sección: filtro de citas activas
  // Oculta canceladas y pasadas para vistas operativas; historial conserva todo.
  List<Cita> filtrarCitasActivas(List<Cita> citas) {
    final activas = citas
        .where(
          (cita) =>
              !_esEstadoCancelada(cita.estadoVisible) && _esCitaVigente(cita),
        )
        .toList(growable: false);
    activas.sort((a, b) => a.fechaOrden.compareTo(b.fechaOrden));
    return activas;
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
  // Retorna médicos ocupados en el mismo minuto, ignorando citas canceladas.
  Future<Set<String>> obtenerIdsMedicosOcupadosEnHorario(
    DateTime fechaHora, {
    String? excluirIdCita,
  }) async {
    final citas = await obtenerCitas();
    final ocupados = <String>{};
    final idExcluido = (excluirIdCita ?? '').trim();

    for (final cita in citas) {
      // Al editar una cita, se excluye su propio id para no bloquear su horario actual.
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
      (item) =>
          item.idCita == idCitaLimpio && item.idUsuario == idUsuarioLimpio,
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
    await _citaRepository.guardarCitas(actualizadas);
  }

  // Sección: confirmación de cita por admin
  // Marca una cita existente como confirmada sin modificar sus demás datos.
  Future<void> confirmarCitaAdmin({required Cita cita}) async {
    final idCitaLimpio = cita.idCita.trim();
    if (idCitaLimpio.isEmpty) {
      throw ArgumentError('El id de cita es obligatorio.');
    }

    if (cita.estadoVisible.toLowerCase().contains('confirm')) {
      return;
    }

    await _citaRepository.guardarCita(cita.copyWith(estado: 'confirmada'));
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

    final nueva = await _construirNuevaCita(
      idUsuario: idUsuarioLimpio,
      mascota: mascota,
      motivo: motivo,
      descripcion: descripcion,
      fechaHora: fechaHora,
      idMedico: idMedico,
      estado: 'proxima',
    );

    await _citaRepository.guardarCita(nueva);

    return nueva.idCita;
  }

  Future<String> crearCitaAdmin({
    required String idUsuario,
    required Mascota mascota,
    required String motivo,
    required String descripcion,
    required DateTime fechaHora,
    required String estado,
    String? idMedico,
  }) async {
    final idUsuarioLimpio = idUsuario.trim();
    if (idUsuarioLimpio.isEmpty) {
      throw ArgumentError('El id de usuario es obligatorio.');
    }

    final estadoLimpio = estado.trim().toLowerCase();
    if (estadoLimpio != 'proxima' && estadoLimpio != 'confirmada') {
      throw StateError('Selecciona un estado válido para la cita.');
    }

    final nueva = await _construirNuevaCita(
      idUsuario: idUsuarioLimpio,
      mascota: mascota,
      motivo: motivo,
      descripcion: descripcion,
      fechaHora: fechaHora,
      idMedico: idMedico,
      estado: estadoLimpio,
    );

    await _citaRepository.guardarCita(nueva);

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
    String? idMedico,
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
    // La cita actual se excluye de la búsqueda de conflictos para permitir guardar sin cambios.
    final idMedicoLimpio = (idMedico ?? actual.idMedico).trim();
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
      idMedico: idMedicoLimpio,
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
    await _citaRepository.guardarCitas(actualizadas);
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
    // Admin puede cambiar el médico, pero se conserva la regla de no cruzar agendas.
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
    await _citaRepository.guardarCitas(actualizadas);
  }

  // Sección: helper de estado cancelado
  // Normaliza distintos textos para detectar citas canceladas.
  bool _esEstadoCancelada(String estadoRaw) {
    final estado = estadoRaw.trim().toLowerCase();
    return estado.contains('cancel');
  }

  Future<Cita> _construirNuevaCita({
    required String idUsuario,
    required Mascota mascota,
    required String motivo,
    required String descripcion,
    required DateTime fechaHora,
    required String estado,
    String? idMedico,
  }) async {
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

    final ahora = DateTime.now();
    return Cita(
      idCita: _uuid.v4(),
      idUsuario: idUsuario,
      idMascota: mascota.idMascota,
      idMedico: idMedicoLimpio,
      nombreMascota: mascota.nombreVisible,
      especieMascota: mascota.especieVisible,
      motivo: motivo.trim(),
      descripcion: descripcion.trim(),
      estado: estado.trim().toLowerCase(),
      fechaHora: fechaHora,
      fechaTexto: DateFormat('yyyy-MM-dd').format(fechaHora),
      horaTexto: DateFormat('HH:mm').format(fechaHora),
      fechaCreacion: DateFormat('yyyy-MM-dd').format(ahora),
      createdAt: ahora,
    );
  }

  bool _esCitaVigente(Cita cita) {
    final fecha = cita.fechaHora;
    if (fecha == null) {
      return false;
    }
    return !fecha.isBefore(DateTime.now());
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
