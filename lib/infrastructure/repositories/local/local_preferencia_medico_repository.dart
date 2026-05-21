import 'package:petcontrol_limpio/domain/constants/entidades_locales.dart';
import 'package:petcontrol_limpio/domain/entities/preferencia_medico.dart';
import 'package:petcontrol_limpio/domain/repositories/preferencia_medico_repository.dart';
import 'package:petcontrol_limpio/infrastructure/storage/local_json_storage_service.dart';

class LocalPreferenciaMedicoRepository implements PreferenciaMedicoRepository {
  LocalPreferenciaMedicoRepository({
    required LocalJsonStorageService storageService,
  }) : _storageService = storageService;

  final LocalJsonStorageService _storageService;

  @override
  Future<List<PreferenciaMedico>> obtenerPreferencias() async {
    final registros = await _storageService.leerLista(
      EntidadesLocales.preferenciaMedico,
    );
    return registros.map(PreferenciaMedico.fromMap).toList(growable: false);
  }

  @override
  Stream<List<PreferenciaMedico>> observarPreferencias() async* {
    yield await obtenerPreferencias();
  }

  @override
  Future<void> guardarPreferencias(List<PreferenciaMedico> preferencias) async {
    final registros = preferencias
        .map((item) => item.toMap())
        .toList(growable: false);
    await _storageService.guardarLista(
      EntidadesLocales.preferenciaMedico,
      registros,
    );
  }
}
