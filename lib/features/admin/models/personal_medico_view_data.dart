// Seccion: opciones base del formulario
// Mantiene listas de seleccion para especialidad, jornada y estado.
const List<String> especialidadesMedicas = <String>[
  'Medicina general',
  'Medicina interna',
  'Pediatria veterinaria',
  'Geriatria veterinaria',
  'Dermatologia',
  'Cardiologia',
  'Neurologia',
  'Oftalmologia',
  'Odontologia veterinaria',
  'Ortopedia y traumatologia',
  'Anestesiologia',
  'Imagenologia diagnostica',
  'Rehabilitacion y fisioterapia',
  'Urgencias y cuidados intensivos',
  'Etologia clinica',
  'Nutricion clinica',
  'Animales exoticos',
  'Cirugia',
  'Oncologia',
  'Otro',
];

const List<String> jornadasMedicas = <String>[
  'Manana',
  'Tarde',
  'Noche',
];

const List<String> estadosMedico = <String>[
  'Activo',
  'Vacaciones',
  'Inactivo',
];

// Seccion: modelo de entrada del formulario
// Representa el payload para registrar nuevo personal medico.
class NuevoMedicoInput {
  const NuevoMedicoInput({
    required this.nombreCompleto,
    required this.correo,
    required this.telefono,
    required this.documento,
    required this.especialidad,
    required this.jornada,
    required this.estado,
  });

  final String nombreCompleto;
  final String correo;
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
