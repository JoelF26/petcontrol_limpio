import 'package:petcontrol_limpio/domain/entities/mascota.dart';

abstract class MascotaRepository {
  Future<List<Mascota>> obtenerMascotas();
  Stream<List<Mascota>> observarMascotas();
  Future<void> guardarMascotas(List<Mascota> mascotas);
}
