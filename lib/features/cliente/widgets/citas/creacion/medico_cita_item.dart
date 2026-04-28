class MedicoCitaItem {
  const MedicoCitaItem({
    required this.id,
    required this.nombre,
    required this.especialidad,
  });

  final String id;
  final String nombre;
  final String especialidad;

  String get nombreVisible {
    final especialidadLimpia = especialidad.trim();
    if (especialidadLimpia.isEmpty) {
      return nombre;
    }
    return '$nombre - $especialidadLimpia';
  }
}
