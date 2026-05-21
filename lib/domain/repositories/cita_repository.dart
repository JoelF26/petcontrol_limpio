import 'package:petcontrol_limpio/domain/entities/cita.dart';

abstract class CitaRepository {
  Future<List<Cita>> obtenerCitas();
  Stream<List<Cita>> observarCitas();
  Future<void> guardarCita(Cita cita);
  Future<void> guardarCitas(List<Cita> citas);
}
