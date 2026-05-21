import 'package:petcontrol_limpio/domain/constants/entidades_locales.dart';
import 'package:petcontrol_limpio/domain/entities/personal_medico.dart';
import 'package:petcontrol_limpio/domain/repositories/personal_medico_repository.dart';
import 'package:petcontrol_limpio/infrastructure/storage/local_json_storage_service.dart';

class LocalPersonalMedicoRepository implements PersonalMedicoRepository {
  LocalPersonalMedicoRepository({
    required LocalJsonStorageService storageService,
  }) : _storageService = storageService;

  final LocalJsonStorageService _storageService;

  @override
  Future<List<PersonalMedico>> obtenerPersonalMedico() async {
    final registros = await _storageService.leerLista(
      EntidadesLocales.personalMedico,
    );
    return registros.map(PersonalMedico.fromMap).toList(growable: false);
  }

  @override
  Stream<List<PersonalMedico>> observarPersonalMedico() async* {
    yield await obtenerPersonalMedico();
  }

  @override
  Future<void> guardarPersonalMedico(List<PersonalMedico> medicos) async {
    final registros = medicos
        .map((medico) => medico.toMap())
        .toList(growable: false);
    await _storageService.guardarLista(
      EntidadesLocales.personalMedico,
      registros,
    );
  }
}
