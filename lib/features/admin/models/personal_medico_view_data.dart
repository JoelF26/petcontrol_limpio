// Seccion: modelo de entrada del formulario
// Representa el payload para registrar nuevo personal medico.
class NuevoMedicoInput {
  const NuevoMedicoInput({
    required this.nombreCompleto,
    required this.telefono,
    required this.documento,
    required this.especialidad,
    required this.jornada,
    required this.estado,
  });

  final String nombreCompleto;
  final String telefono;
  final String documento;
  final String especialidad;
  final String jornada;
  final String estado;
}

// Seccion: modelo visual de medico
// Define la estructura usada por tarjetas, filtros y popup de detalle.
class MedicoVista {
  const MedicoVista({
    required this.id,
    required this.nombreCompleto,
    required this.correo,
    required this.telefono,
    required this.documento,
    required this.especialidad,
    required this.jornada,
    required this.estado,
    required this.fechaIngreso,
  });

  final String id;
  final String nombreCompleto;
  final String correo;
  final String telefono;
  final String documento;
  final String especialidad;
  final String jornada;
  final String estado;
  final DateTime fechaIngreso;
}
