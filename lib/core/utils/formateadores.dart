// Sección: imports
// Se usa intl para formatear fechas de manera consistente.
import 'package:intl/intl.dart';

// Sección: utilidades de formato
// Agrupa conversiones de fecha/texto reutilizables en la app.
class Formateadores {
  Formateadores._();

  // Sección: formato de fecha corta
  // Convierte DateTime al formato yyyy-MM-dd usado en Firestore.
  static String fechaSolo(DateTime fecha) {
    return DateFormat('yyyy-MM-dd').format(fecha);
  }
}
