import 'package:petcontrol_limpio/domain/entities/personal_medico.dart';
import 'package:petcontrol_limpio/domain/repositories/personal_medico_repository.dart';

// Sección: servicio de personal médico
// Encapsula CRUD de profesionales en persistencia JSON local.
class PersonalMedicoService {
  PersonalMedicoService({
    required PersonalMedicoRepository personalMedicoRepository,
  }) : _personalMedicoRepository = personalMedicoRepository;

  final PersonalMedicoRepository _personalMedicoRepository;

  // Sección: listado completo
  // Retorna todos los médicos registrados.
  Future<List<PersonalMedico>> obtenerPersonalMedico() async {
    return _personalMedicoRepository.obtenerPersonalMedico();
  }

  Stream<List<PersonalMedico>> observarPersonalMedico() {
    return _personalMedicoRepository.observarPersonalMedico();
  }

  // Sección: listado de médicos activos
  // Filtra únicamente personal médico marcado como activo.
  Future<List<PersonalMedico>> obtenerMedicosActivos() async {
    final medicos = await obtenerPersonalMedico();
    // El formulario de citas solo debe ofrecer profesionales actualmente activos.
    final activos = medicos
        .where((medico) => medico.activo)
        .toList(growable: false);
    final ordenados = activos.toList(growable: false)
      ..sort(
        (a, b) => a.nombreCompleto.toLowerCase().compareTo(
          b.nombreCompleto.toLowerCase(),
        ),
      );
    return ordenados;
  }

  // Sección: búsqueda por id
  // Devuelve un médico puntual según su identificador.
  Future<PersonalMedico?> obtenerMedicoPorId(String idMedico) async {
    final idLimpio = idMedico.trim();
    if (idLimpio.isEmpty) {
      return null;
    }

    final medicos = await obtenerPersonalMedico();
    // La unicidad por id evita pisar otro registro al sincronizar con usuarios admin.
    for (final medico in medicos) {
      if (medico.idMedico == idLimpio) {
        return medico;
      }
    }
    return null;
  }

  // Sección: creación
  // Inserta un profesional validando id único.
  Future<void> crearMedico(PersonalMedico medico) async {
    final medicos = await obtenerPersonalMedico();
    final existe = medicos.any((item) => item.idMedico == medico.idMedico);
    if (existe) {
      throw StateError('Ya existe un médico con ese id.');
    }

    final actualizados = <PersonalMedico>[...medicos, medico];
    await _personalMedicoRepository.guardarPersonalMedico(actualizados);
  }

  // Sección: actualización
  // Reemplaza un profesional existente por id.
  Future<void> actualizarMedico(PersonalMedico medico) async {
    final medicos = await obtenerPersonalMedico();
    final indice = medicos.indexWhere(
      (item) => item.idMedico == medico.idMedico,
    );
    if (indice < 0) {
      throw StateError('No existe el médico a actualizar.');
    }

    final actualizados = <PersonalMedico>[...medicos];
    actualizados[indice] = medico;
    await _personalMedicoRepository.guardarPersonalMedico(actualizados);
  }

  // Sección: eliminación
  // Elimina el profesional asociado al id indicado.
  Future<void> eliminarMedico(String idMedico) async {
    final idLimpio = idMedico.trim();
    if (idLimpio.isEmpty) {
      return;
    }

    final medicos = await obtenerPersonalMedico();
    final actualizados = medicos
        .where((item) => item.idMedico != idLimpio)
        .toList(growable: false);
    await _personalMedicoRepository.guardarPersonalMedico(actualizados);
  }
}
