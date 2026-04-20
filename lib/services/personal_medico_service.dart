// Sección: imports
// Se importan constantes de entidad, modelo de médico y storage local JSON.
import 'package:petcontrol_limpio/core/constants/entidades_locales.dart';
import 'package:petcontrol_limpio/models/personal_medico.dart';
import 'package:petcontrol_limpio/services/storage/local_json_storage_service.dart';

// Sección: servicio de personal médico
// Encapsula CRUD de profesionales en persistencia JSON local.
class PersonalMedicoService {
  PersonalMedicoService({LocalJsonStorageService? storageService})
    : _storageService = storageService ?? LocalJsonStorageService();

  final LocalJsonStorageService _storageService;

  // Sección: listado completo
  // Retorna todos los médicos registrados.
  Future<List<PersonalMedico>> obtenerPersonalMedico() async {
    final registros = await _storageService.leerLista(
      EntidadesLocales.personalMedico,
    );
    return registros.map(PersonalMedico.fromMap).toList(growable: false);
  }

  // Sección: listado de médicos activos
  // Filtra únicamente personal médico marcado como activo.
  Future<List<PersonalMedico>> obtenerMedicosActivos() async {
    final medicos = await obtenerPersonalMedico();
    final activos = medicos
        .where((medico) => medico.activo)
        .toList(growable: false);
    final ordenados = activos.toList(growable: false)
      ..sort((a, b) => a.nombreCompleto.toLowerCase().compareTo(b.nombreCompleto.toLowerCase()));
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
    await _guardarMedicos(actualizados);
  }

  // Sección: actualización
  // Reemplaza un profesional existente por id.
  Future<void> actualizarMedico(PersonalMedico medico) async {
    final medicos = await obtenerPersonalMedico();
    final indice = medicos.indexWhere((item) => item.idMedico == medico.idMedico);
    if (indice < 0) {
      throw StateError('No existe el médico a actualizar.');
    }

    final actualizados = <PersonalMedico>[...medicos];
    actualizados[indice] = medico;
    await _guardarMedicos(actualizados);
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
    await _guardarMedicos(actualizados);
  }

  // Sección: persistencia interna
  // Guarda la lista completa de médicos en storage local.
  Future<void> _guardarMedicos(List<PersonalMedico> medicos) async {
    final registros = medicos
        .map((medico) => medico.toMap())
        .toList(growable: false);
    await _storageService.guardarLista(EntidadesLocales.personalMedico, registros);
  }
}

