// Sección: imports
// Se importan constantes, modelo de historial clínico y storage local JSON.
import 'package:petcontrol_limpio/core/constants/entidades_locales.dart';
import 'package:petcontrol_limpio/models/historial_clinico.dart';
import 'package:petcontrol_limpio/services/storage/local_json_storage_service.dart';

// Sección: servicio de historial clínico
// Encapsula CRUD de historiales en persistencia JSON local.
class HistorialClinicoService {
  HistorialClinicoService({LocalJsonStorageService? storageService})
    : _storageService = storageService ?? LocalJsonStorageService();

  final LocalJsonStorageService _storageService;

  // Sección: listado completo
  // Retorna todos los historiales clínicos almacenados.
  Future<List<HistorialClinico>> obtenerHistoriales() async {
    final registros = await _storageService.leerLista(
      EntidadesLocales.historialClinico,
    );
    return registros.map(HistorialClinico.fromMap).toList(growable: false);
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
    await _guardarHistoriales(actualizados);
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
    await _guardarHistoriales(actualizados);
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
    await _guardarHistoriales(actualizados);
  }

  // Sección: persistencia interna
  // Guarda la lista completa de historiales en storage local.
  Future<void> _guardarHistoriales(List<HistorialClinico> historiales) async {
    final registros = historiales
        .map((item) => item.toMap())
        .toList(growable: false);
    await _storageService.guardarLista(EntidadesLocales.historialClinico, registros);
  }
}

