import 'package:petcontrol_limpio/application/services/auth_service.dart';
import 'package:petcontrol_limpio/application/services/catalogos_json_service.dart';
import 'package:petcontrol_limpio/application/services/cita_service.dart';
import 'package:petcontrol_limpio/application/services/historial_clinico_service.dart';
import 'package:petcontrol_limpio/application/services/mascota_service.dart';
import 'package:petcontrol_limpio/application/services/personal_medico_service.dart';
import 'package:petcontrol_limpio/application/services/preferencia_medico_service.dart';
import 'package:petcontrol_limpio/application/services/session_service.dart';
import 'package:petcontrol_limpio/application/services/usuario_service.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_seed_service.dart';
import 'package:petcontrol_limpio/infrastructure/repositories/firebase/firebase_auth_identity_repository.dart';
import 'package:petcontrol_limpio/infrastructure/repositories/firebase/firebase_catalogos_repository.dart';
import 'package:petcontrol_limpio/infrastructure/repositories/firebase/firebase_cita_repository.dart';
import 'package:petcontrol_limpio/infrastructure/repositories/firebase/firebase_historial_clinico_repository.dart';
import 'package:petcontrol_limpio/infrastructure/repositories/firebase/firebase_mascota_repository.dart';
import 'package:petcontrol_limpio/infrastructure/repositories/firebase/firebase_personal_medico_repository.dart';
import 'package:petcontrol_limpio/infrastructure/repositories/firebase/firebase_preferencia_medico_repository.dart';
import 'package:petcontrol_limpio/infrastructure/repositories/firebase/firebase_session_repository.dart';
import 'package:petcontrol_limpio/infrastructure/repositories/firebase/firebase_usuario_repository.dart';

class AppDependencies {
  AppDependencies._();

  static final FirebaseUsuarioRepository _usuarioRepository =
      FirebaseUsuarioRepository();
  static final FirebaseMascotaRepository _mascotaRepository =
      FirebaseMascotaRepository();
  static final FirebaseCitaRepository _citaRepository =
      FirebaseCitaRepository();
  static final FirebasePersonalMedicoRepository _personalMedicoRepository =
      FirebasePersonalMedicoRepository();
  static final FirebasePreferenciaMedicoRepository
  _preferenciaMedicoRepository = FirebasePreferenciaMedicoRepository();
  static final FirebaseHistorialClinicoRepository _historialClinicoRepository =
      FirebaseHistorialClinicoRepository();
  static final FirebaseSessionRepository _sessionRepository =
      FirebaseSessionRepository();
  static final FirebaseCatalogosRepository _catalogosRepository =
      FirebaseCatalogosRepository();
  static final FirebaseAuthIdentityRepository _authIdentityRepository =
      FirebaseAuthIdentityRepository();
  static final FirebaseSeedService _seedService = FirebaseSeedService();

  static final UsuarioService usuarioService = UsuarioService(
    usuarioRepository: _usuarioRepository,
  );
  static final MascotaService mascotaService = MascotaService(
    mascotaRepository: _mascotaRepository,
  );
  static final CitaService citaService = CitaService(
    citaRepository: _citaRepository,
  );
  static final PersonalMedicoService personalMedicoService =
      PersonalMedicoService(
        personalMedicoRepository: _personalMedicoRepository,
      );
  static final PreferenciaMedicoService preferenciaMedicoService =
      PreferenciaMedicoService(
        preferenciaMedicoRepository: _preferenciaMedicoRepository,
      );
  static final HistorialClinicoService historialClinicoService =
      HistorialClinicoService(
        historialClinicoRepository: _historialClinicoRepository,
      );
  static final SessionService sessionService = SessionService(
    sessionRepository: _sessionRepository,
  );
  static final CatalogosJsonService catalogosJsonService = CatalogosJsonService(
    catalogosRepository: _catalogosRepository,
  );
  static final AuthService authService = AuthService(
    usuarioService: usuarioService,
    sessionService: sessionService,
    authIdentityRepository: _authIdentityRepository,
  );

  static Future<void> inicializar() async {
    await _seedService.migrarDatosInicialesSiEsPosible();
  }
}
