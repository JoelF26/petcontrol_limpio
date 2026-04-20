// Seccion: constantes de filtros para historial
// Definen valores iniciales y opciones de filtro para la vista admin.
const String estadoTodosHistorial = 'Todos';
const String especieTodasHistorial = 'Todas';
const String fechaTodoHistorial = 'Todo';

const List<String> estadosFiltroHistorial = <String>[
  estadoTodosHistorial,
  'proxima',
  'pendiente',
  'confirmada',
  'finalizada',
  'cancelada',
  'reprogramada',
];

const List<String> especiesFiltroHistorial = <String>[
  especieTodasHistorial,
  'Perro',
  'Gato',
  'Conejo',
  'Ave',
  'Sin especie',
];

const List<String> fechasFiltroHistorial = <String>[
  fechaTodoHistorial,
  'Ultimos 7 dias',
  'Ultimos 30 dias',
  'Ultimos 90 dias',
];

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
