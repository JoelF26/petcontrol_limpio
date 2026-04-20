// Sección: imports
// Se usa import condicional para aplicar URL strategy solo en web.
import 'package:petcontrol_limpio/core/routes/url_strategy_stub.dart'
    if (dart.library.html) 'package:petcontrol_limpio/core/routes/url_strategy_web.dart';

// Sección: configuración de URL
// Expone una única función para inicializar estrategia de URL por plataforma.
void configurarEstrategiaUrl() {
  configurarEstrategiaUrlImpl();
}
