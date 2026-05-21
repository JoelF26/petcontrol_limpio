import 'package:petcontrol_limpio/domain/entities/historial_clinico.dart';
import 'package:petcontrol_limpio/domain/repositories/historial_clinico_repository.dart';

// Sección: servicio de historial clínico
// Encapsula CRUD de historiales en persistencia JSON local.
class HistorialClinicoService {
  HistorialClinicoService({
    required HistorialClinicoRepository historialClinicoRepository,
  }) : _historialClinicoRepository = historialClinicoRepository;

  final HistorialClinicoRepository _historialClinicoRepository;

  // Sección: listado completo
  // Retorna todos los historiales clínicos almacenados.
  Future<List<HistorialClinico>> obtenerHistoriales() async {
    return _historialClinicoRepository.obtenerHistoriales();
  }

  Stream<List<HistorialClinico>> observarHistoriales() {
    return _historialClinicoRepository.observarHistoriales();
  }

  // Sección: listado por mascota
  // Filtra historiales relacionados con la mascota indicada.
  Future<List<HistorialClinico>> obtenerHistorialesPorMascota(
    String idMascota,
  ) async {
    final idLimpio = idMascota.trim();
    if (idLimpio.isEmpty) {
      return <HistorialClinico>[];
    }

    final historiales = await obtenerHistoriales();
    return historiales
        .where((item) => item.idMascota == idLimpio)
        .toList(growable: false);
  }

  // Sección: creación
  // Inserta un historial nuevo validando id único.
  Future<void> crearHistorial(HistorialClinico historial) async {
    final historiales = await obtenerHistoriales();
    final existe = historiales.any(
      (item) => item.idHistorial == historial.idHistorial,
    );
    if (existe) {
      throw StateError('Ya existe un historial con ese id.');
    }

    final actualizados = <HistorialClinico>[...historiales, historial];
    await _historialClinicoRepository.guardarHistoriales(actualizados);
  }

  // Sección: actualización
  // Reemplaza un historial existente por id.
  Future<void> actualizarHistorial(HistorialClinico historial) async {
    final historiales = await obtenerHistoriales();
    final indice = historiales.indexWhere(
      (item) => item.idHistorial == historial.idHistorial,
    );
    if (indice < 0) {
      throw StateError('No existe el historial a actualizar.');
    }

    final actualizados = <HistorialClinico>[...historiales];
    actualizados[indice] = historial;
    await _historialClinicoRepository.guardarHistoriales(actualizados);
  }

  // Sección: eliminación
  // Elimina un historial según su id.
  Future<void> eliminarHistorial(String idHistorial) async {
    final idLimpio = idHistorial.trim();
    if (idLimpio.isEmpty) {
      return;
    }

    final historiales = await obtenerHistoriales();
    final actualizados = historiales
        .where((item) => item.idHistorial != idLimpio)
        .toList(growable: false);
    await _historialClinicoRepository.guardarHistoriales(actualizados);
  }
}
