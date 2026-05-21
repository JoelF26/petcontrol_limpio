import 'package:petcontrol_limpio/domain/constants/entidades_locales.dart';
import 'package:petcontrol_limpio/domain/entities/historial_clinico.dart';
import 'package:petcontrol_limpio/domain/repositories/historial_clinico_repository.dart';
import 'package:petcontrol_limpio/infrastructure/storage/local_json_storage_service.dart';

class LocalHistorialClinicoRepository implements HistorialClinicoRepository {
  LocalHistorialClinicoRepository({
    required LocalJsonStorageService storageService,
  }) : _storageService = storageService;

  final LocalJsonStorageService _storageService;

  @override
  Future<List<HistorialClinico>> obtenerHistoriales() async {
    final registros = await _storageService.leerLista(
      EntidadesLocales.historialClinico,
    );
    return registros.map(HistorialClinico.fromMap).toList(growable: false);
  }

  @override
  Stream<List<HistorialClinico>> observarHistoriales() async* {
    yield await obtenerHistoriales();
  }

  @override
  Future<void> guardarHistoriales(List<HistorialClinico> historiales) async {
    final registros = historiales
        .map((item) => item.toMap())
        .toList(growable: false);
    await _storageService.guardarLista(
      EntidadesLocales.historialClinico,
      registros,
    );
  }
}
