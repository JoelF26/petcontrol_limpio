// Sección: entidades locales
// Centraliza los nombres de entidades persistidas en almacenamiento local.
class EntidadesLocales {
  EntidadesLocales._();

  // Sección: identificadores de entidades
  // Se usan como llave única en servicios y almacenamiento local.
  static const String usuarios = 'usuarios';
  static const String mascotas = 'mascotas';
  static const String citas = 'citas';
  static const String personalMedico = 'personal_medico';
  static const String preferenciaMedico = 'preferencia_medico';
  static const String historialClinico = 'historial_clinico';

  // Sección: listado de entidades soportadas
  // Permite validar y construir la base local inicial.
  static const List<String> todas = <String>[
    usuarios,
    mascotas,
    citas,
    personalMedico,
    preferenciaMedico,
    historialClinico,
  ];
}
