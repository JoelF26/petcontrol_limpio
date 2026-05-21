import 'package:petcontrol_limpio/domain/entities/personal_medico.dart';

abstract class PersonalMedicoRepository {
  Future<List<PersonalMedico>> obtenerPersonalMedico();
  Stream<List<PersonalMedico>> observarPersonalMedico();
  Future<void> guardarPersonalMedico(List<PersonalMedico> medicos);
}
