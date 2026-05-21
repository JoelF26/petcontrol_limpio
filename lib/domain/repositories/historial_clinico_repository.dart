import 'package:petcontrol_limpio/domain/entities/historial_clinico.dart';

abstract class HistorialClinicoRepository {
  Future<List<HistorialClinico>> obtenerHistoriales();
  Stream<List<HistorialClinico>> observarHistoriales();
  Future<void> guardarHistoriales(List<HistorialClinico> historiales);
}
