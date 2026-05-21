import 'package:petcontrol_limpio/domain/entities/preferencia_medico.dart';
import 'package:petcontrol_limpio/domain/repositories/preferencia_medico_repository.dart';

// Sección: servicio de preferencia de médico
// Encapsula CRUD de preferencias sobre persistencia JSON local.
class PreferenciaMedicoService {
  PreferenciaMedicoService({
    required PreferenciaMedicoRepository preferenciaMedicoRepository,
  }) : _preferenciaMedicoRepository = preferenciaMedicoRepository;

  final PreferenciaMedicoRepository _preferenciaMedicoRepository;

  // Sección: listado completo
  // Retorna todas las preferencias registradas.
  Future<List<PreferenciaMedico>> obtenerPreferencias() async {
    return _preferenciaMedicoRepository.obtenerPreferencias();
  }

  Stream<List<PreferenciaMedico>> observarPreferencias() {
    return _preferenciaMedicoRepository.observarPreferencias();
  }

  // Sección: listado por usuario
  // Filtra preferencias del usuario indicado.
  Future<List<PreferenciaMedico>> obtenerPreferenciasPorUsuario(
    String idUsuario,
  ) async {
    final idLimpio = idUsuario.trim();
    if (idLimpio.isEmpty) {
      return <PreferenciaMedico>[];
    }

    final preferencias = await obtenerPreferencias();
    return preferencias
        .where((item) => item.idUsuario == idLimpio)
        .toList(growable: false);
  }

  // Sección: creación
  // Inserta una preferencia nueva validando id único.
  Future<void> crearPreferencia(PreferenciaMedico preferencia) async {
    final preferencias = await obtenerPreferencias();
    final existe = preferencias.any(
      (item) => item.idPreferencia == preferencia.idPreferencia,
    );
    if (existe) {
      throw StateError('Ya existe una preferencia con ese id.');
    }

    final actualizadas = <PreferenciaMedico>[...preferencias, preferencia];
    await _preferenciaMedicoRepository.guardarPreferencias(actualizadas);
  }

  // Sección: actualización
  // Reemplaza una preferencia existente por id.
  Future<void> actualizarPreferencia(PreferenciaMedico preferencia) async {
    final preferencias = await obtenerPreferencias();
    final indice = preferencias.indexWhere(
      (item) => item.idPreferencia == preferencia.idPreferencia,
    );
    if (indice < 0) {
      throw StateError('No existe la preferencia a actualizar.');
    }

    final actualizadas = <PreferenciaMedico>[...preferencias];
    actualizadas[indice] = preferencia;
    await _preferenciaMedicoRepository.guardarPreferencias(actualizadas);
  }

  // Sección: eliminación
  // Elimina una preferencia según su id.
  Future<void> eliminarPreferencia(String idPreferencia) async {
    final idLimpio = idPreferencia.trim();
    if (idLimpio.isEmpty) {
      return;
    }

    final preferencias = await obtenerPreferencias();
    final actualizadas = preferencias
        .where((item) => item.idPreferencia != idLimpio)
        .toList(growable: false);
    await _preferenciaMedicoRepository.guardarPreferencias(actualizadas);
  }
}
