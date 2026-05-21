import 'package:petcontrol_limpio/domain/constants/entidades_locales.dart';
import 'package:petcontrol_limpio/domain/entities/cita.dart';
import 'package:petcontrol_limpio/domain/repositories/cita_repository.dart';
import 'package:petcontrol_limpio/infrastructure/storage/local_json_storage_service.dart';

class LocalCitaRepository implements CitaRepository {
  LocalCitaRepository({required LocalJsonStorageService storageService})
    : _storageService = storageService;

  final LocalJsonStorageService _storageService;

  @override
  Future<List<Cita>> obtenerCitas() async {
    final registros = await _storageService.leerLista(EntidadesLocales.citas);
    return registros.map(Cita.fromMap).toList(growable: false);
  }

  @override
  Stream<List<Cita>> observarCitas() async* {
    yield await obtenerCitas();
  }

  @override
  Future<void> guardarCita(Cita cita) async {
    final citas = await obtenerCitas();
    final indice = citas.indexWhere((item) => item.idCita == cita.idCita);
    final actualizadas = <Cita>[...citas];
    if (indice < 0) {
      actualizadas.add(cita);
    } else {
      actualizadas[indice] = cita;
    }
    await guardarCitas(actualizadas);
  }

  @override
  Future<void> guardarCitas(List<Cita> citas) async {
    final registros = citas.map((cita) => cita.toMap()).toList(growable: false);
    await _storageService.guardarLista(EntidadesLocales.citas, registros);
  }
}
