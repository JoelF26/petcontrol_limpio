// Seccion: imports
// Se importan utilidades JSON y rootBundle para leer catalogos desde assets.
import 'dart:convert';

import 'package:flutter/services.dart';

// Seccion: catalogos de personal medico
// Agrupa opciones visibles del formulario de personal medico.
class CatalogosPersonalMedico {
  const CatalogosPersonalMedico({
    required this.especialidades,
    required this.jornadas,
    required this.estados,
  });

  final List<String> especialidades;
  final List<String> jornadas;
  final List<String> estados;
}

// Seccion: filtros de historial
// Agrupa listas visibles usadas por la pantalla de historial.
class FiltrosHistorialCitas {
  const FiltrosHistorialCitas({
    required this.estados,
    required this.especies,
    required this.fechas,
  });

  final List<String> estados;
  final List<String> especies;
  final List<String> fechas;
}

// Seccion: servicio de catalogos JSON
// Centraliza lectura de listas visibles desde assets con fallbacks seguros.
class CatalogosJsonService {
  static final CatalogosJsonService _instanciaCompartida =
      CatalogosJsonService._interno();

  factory CatalogosJsonService() {
    return _instanciaCompartida;
  }

  CatalogosJsonService._interno();

  static const String _rutaCatalogos = 'assets/data/catalogos.json';

  Future<Map<String, dynamic>>? _cacheEnCurso;
  Map<String, dynamic>? _cache;

  static const List<String> _fallbackEspecialidadesMedicas = <String>[
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

  static const List<String> _fallbackJornadasMedicas = <String>[
    'Manana',
    'Tarde',
    'Noche',
  ];

  static const List<String> _fallbackEstadosMedico = <String>[
    'Activo',
    'Vacaciones',
    'Inactivo',
  ];

  static const List<String> _fallbackMotivosCitaCliente = <String>[
    'Vacunacion anual',
    'Control general',
    'Desparasitacion',
    'Revision de piel',
    'Corte de unas',
    'Revision odontologica',
    'Otro',
  ];

  static const List<String> _fallbackMotivosCitaAdmin = <String>[
    'Control general',
    'Vacunacion',
    'Desparasitacion',
    'Chequeo preventivo',
    'Valoracion prequirurgica',
    'Cirugia',
    'Revision postoperatoria',
    'Consulta dermatologica',
    'Odontologia veterinaria',
    'Examenes de laboratorio',
    'Imagen diagnostica',
    'Urgencia',
  ];

  static const List<String> _fallbackEstadosCita = <String>[
    'proxima',
    'pendiente',
    'confirmada',
    'cancelada',
    'reprogramada',
  ];

  static const List<String> _fallbackEstadosCreacionCitaAdmin = <String>[
    'proxima',
  ];

  static const List<String> _fallbackSexosMascota = <String>['Hembra', 'Macho'];

  static const List<String> _fallbackEstadosFiltroHistorial = <String>[
    'Todos',
    'proxima',
    'pendiente',
    'confirmada',
    'finalizada',
    'cancelada',
    'reprogramada',
  ];

  static const List<String> _fallbackEspeciesFiltroHistorial = <String>[
    'Todas',
    'Perro',
    'Gato',
    'Conejo',
    'Ave',
    'Sin especie',
  ];

  static const List<String> _fallbackFechasFiltroHistorial = <String>[
    'Todo',
    'Ultimos 7 dias',
    'Ultimos 30 dias',
    'Ultimos 90 dias',
  ];

  Future<CatalogosPersonalMedico> obtenerCatalogosPersonalMedico() async {
    final data = await _leerCatalogos();
    return CatalogosPersonalMedico(
      especialidades: _leerLista(data, const <String>[
        'personal_medico',
        'especialidades',
      ], _fallbackEspecialidadesMedicas),
      jornadas: _leerLista(data, const <String>[
        'personal_medico',
        'jornadas',
      ], _fallbackJornadasMedicas),
      estados: _leerLista(data, const <String>[
        'personal_medico',
        'estados',
      ], _fallbackEstadosMedico),
    );
  }

  Future<List<String>> obtenerMotivosCitaCliente() async {
    final data = await _leerCatalogos();
    return _leerLista(data, const <String>[
      'citas',
      'motivos_cliente',
    ], _fallbackMotivosCitaCliente);
  }

  Future<List<String>> obtenerMotivosCitaAdmin() async {
    final data = await _leerCatalogos();
    return _leerLista(data, const <String>[
      'citas',
      'motivos_admin',
    ], _fallbackMotivosCitaAdmin);
  }

  Future<List<String>> obtenerEstadosCita() async {
    final data = await _leerCatalogos();
    return _leerLista(data, const <String>[
      'citas',
      'estados',
    ], _fallbackEstadosCita);
  }

  Future<List<String>> obtenerEstadosCreacionCitaAdmin() async {
    final data = await _leerCatalogos();
    return _leerLista(data, const <String>[
      'citas',
      'estados_creacion_admin',
    ], _fallbackEstadosCreacionCitaAdmin);
  }

  Future<List<String>> obtenerOpcionesMascotaSexo() async {
    final data = await _leerCatalogos();
    return _leerLista(data, const <String>[
      'mascotas',
      'sexos',
    ], _fallbackSexosMascota);
  }

  Future<FiltrosHistorialCitas> obtenerFiltrosHistorial() async {
    final data = await _leerCatalogos();
    return FiltrosHistorialCitas(
      estados: _leerLista(data, const <String>[
        'historial_citas',
        'estados_filtro',
      ], _fallbackEstadosFiltroHistorial),
      especies: _leerLista(data, const <String>[
        'historial_citas',
        'especies_filtro',
      ], _fallbackEspeciesFiltroHistorial),
      fechas: _leerLista(data, const <String>[
        'historial_citas',
        'fechas_filtro',
      ], _fallbackFechasFiltroHistorial),
    );
  }

  Future<Map<String, dynamic>> _leerCatalogos() {
    final cache = _cache;
    if (cache != null) {
      return Future<Map<String, dynamic>>.value(cache);
    }

    final enCurso = _cacheEnCurso;
    if (enCurso != null) {
      return enCurso;
    }

    final tarea = _cargarCatalogos();
    _cacheEnCurso = tarea;
    return tarea;
  }

  Future<Map<String, dynamic>> _cargarCatalogos() async {
    try {
      final contenido = await rootBundle.loadString(_rutaCatalogos);
      final decoded = jsonDecode(contenido);
      if (decoded is Map<String, dynamic>) {
        _cache = decoded;
      } else if (decoded is Map) {
        _cache = decoded.map((key, value) => MapEntry(key.toString(), value));
      } else {
        _cache = <String, dynamic>{};
      }
      return _cache!;
    } catch (_) {
      _cache = <String, dynamic>{};
      return _cache!;
    } finally {
      _cacheEnCurso = null;
    }
  }

  List<String> _leerLista(
    Map<String, dynamic> data,
    List<String> ruta,
    List<String> fallback,
  ) {
    dynamic actual = data;
    for (final llave in ruta) {
      if (actual is! Map) {
        return fallback;
      }
      actual = actual[llave];
    }

    if (actual is! List) {
      return fallback;
    }

    final valores = actual
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    return valores.isEmpty ? fallback : valores;
  }
}
