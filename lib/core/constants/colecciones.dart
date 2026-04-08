// Sección: nombres de colecciones
// Centraliza las colecciones de Firestore para evitar errores por strings sueltos.
class ColeccionesFirestore {
  ColeccionesFirestore._();

  // Sección: colecciones principales del dominio
  // Estas constantes representan las colecciones ya creadas en Firestore.
  static const String usuarios = 'usuarios';
  static const String mascotas = 'mascotas';
  static const String personalMedico = 'personal_medico';
  static const String preferenciaMedico = 'preferencia_medico';
  static const String citas = 'citas';
  static const String historialClinico = 'historial_clinico';
}
