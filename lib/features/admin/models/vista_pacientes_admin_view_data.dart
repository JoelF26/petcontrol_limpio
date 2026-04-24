// Seccion: modelo visual de paciente admin
// Define los campos que consume la UI de tarjetas y detalle.
class PacienteVistaAdmin {
  const PacienteVistaAdmin({
    required this.idMascota,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.edad,
    required this.peso,
    required this.dueno,
  });

  final String idMascota;
  final String nombre;
  final String especie;
  final String raza;
  final int edad;
  final int peso;
  final String dueno;
}
