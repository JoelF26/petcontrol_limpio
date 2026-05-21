import 'package:petcontrol_limpio/domain/constants/entidades_locales.dart';
import 'package:petcontrol_limpio/domain/entities/mascota.dart';
import 'package:petcontrol_limpio/domain/repositories/mascota_repository.dart';
import 'package:petcontrol_limpio/infrastructure/storage/local_json_storage_service.dart';

class LocalMascotaRepository implements MascotaRepository {
  LocalMascotaRepository({required LocalJsonStorageService storageService})
    : _storageService = storageService;

  final LocalJsonStorageService _storageService;

  @override
  Future<List<Mascota>> obtenerMascotas() async {
    final registros = await _storageService.leerLista(
      EntidadesLocales.mascotas,
    );
    return registros.map(Mascota.fromMap).toList(growable: false);
  }

  @override
  Stream<List<Mascota>> observarMascotas() async* {
    yield await obtenerMascotas();
  }

  @override
  Future<void> guardarMascotas(List<Mascota> mascotas) async {
    final registros = mascotas
        .map((mascota) => mascota.toMap())
        .toList(growable: false);
    await _storageService.guardarLista(EntidadesLocales.mascotas, registros);
  }
}
