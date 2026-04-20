// Sección: imports
// Se usa estrategia de path para mostrar rutas limpias en navegador web.
import 'package:flutter_web_plugins/url_strategy.dart';

// Sección: implementación web
// Elimina '#' de la URL y permite ver rutas como /login y /registro.
void configurarEstrategiaUrlImpl() {
  usePathUrlStrategy();
}
