// Seccion: modelo visual de historial
// Representa la informacion que consumen las tarjetas y el popup detalle.
class HistorialCitaVista {
  const HistorialCitaVista({
    required this.nombreMascota,
    required this.especie,
    required this.estado,
    required this.procedimiento,
    required this.fechaHora,
    required this.doctor,
    required this.dueno,
    required this.descripcion,
  });

  final String nombreMascota;
  final String especie;
  final String estado;
  final String procedimiento;
  final DateTime fechaHora;
  final String doctor;
  final String dueno;
  final String descripcion;
}
