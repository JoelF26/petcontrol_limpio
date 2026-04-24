// Sección: excepción de colisión de correo médico
// Indica que el correo institucional propuesto ya está ocupado.
class CorreoMedicoEnUsoException implements Exception {
  const CorreoMedicoEnUsoException({required this.correoEnUso});

  final String correoEnUso;

  @override
  String toString() => 'Correo médico en uso: $correoEnUso';
}
