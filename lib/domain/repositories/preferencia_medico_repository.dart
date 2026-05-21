import 'package:petcontrol_limpio/domain/entities/preferencia_medico.dart';

abstract class PreferenciaMedicoRepository {
  Future<List<PreferenciaMedico>> obtenerPreferencias();
  Stream<List<PreferenciaMedico>> observarPreferencias();
  Future<void> guardarPreferencias(List<PreferenciaMedico> preferencias);
}
