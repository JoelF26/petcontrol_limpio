// Sección: imports
// Se importa utilería JSON para serializar el modelo.
import 'dart:convert';

// Sección: modelo de personal médico
// Representa un profesional veterinario del sistema.
class PersonalMedico {
  const PersonalMedico({
    required this.idMedico,
    required this.nombreCompleto,
    required this.especialidad,
    required this.telefono,
    required this.correo,
    required this.activo,
    required this.fechaCreacion,
    required this.createdAt,
    this.documento = '',
    this.jornada = '',
    this.estado = '',
  });

  final String idMedico;
  final String nombreCompleto;
  final String especialidad;
  final String telefono;
  final String correo;
  final bool activo;
  final String fechaCreacion;
  final String createdAt;
  final String documento;
  final String jornada;
  final String estado;

  // Sección: getters de presentación
  // Entregan valores limpios para renderizado en dropdowns y tarjetas.
  String get nombreVisible {
    final nombre = nombreCompleto.trim();
    if (nombre.isEmpty) {
      return 'Sin nombre';
    }
    final especialidadLimpia = especialidad.trim();
    if (especialidadLimpia.isEmpty) {
      return nombre;
    }
    return '$nombre - $especialidadLimpia';
  }

  // Sección: estado visible normalizado
  // Prioriza el campo estado del registro y usa activo como respaldo.
  String get estadoVisible {
    final estadoLimpio = estado.trim();
    if (estadoLimpio.isNotEmpty) {
      return estadoLimpio;
    }
    return activo ? 'Activo' : 'Inactivo';
  }

  // Sección: serialización a mapa
  // Convierte la entidad al esquema JSON local.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_medico': idMedico,
      'nombre_completo': nombreCompleto,
      'especialidad': especialidad,
      'telefono': telefono,
      'correo': correo,
      'activo': activo,
      'fecha_creacion': fechaCreacion,
      'created_at': createdAt,
      'documento': documento,
      'jornada': jornada,
      'estado': estado,
    };
  }

  // Sección: serialización a texto JSON
  // Genera representación textual de la entidad.
  String toJson() {
    return jsonEncode(toMap());
  }

  // Sección: deserialización desde mapa
  // Acepta llaves actuales y variantes legadas del seed o de versiones anteriores.
  factory PersonalMedico.fromMap(Map<String, dynamic> map) {
    return PersonalMedico(
      idMedico: _resolverString(map, const <String>[
        'id_medico',
        'id_personal',
        'id_usuario',
        'id',
      ]),
      nombreCompleto: _resolverString(map, const <String>[
        'nombre_completo',
        'nombre',
        'nombres',
      ]),
      especialidad: _resolverString(map, const <String>[
        'especialidad',
        'area',
        'especializacion',
      ]),
      telefono: _resolverString(map, const <String>['telefono']),
      correo: _resolverString(map, const <String>['correo']).toLowerCase(),
      // Por defecto se considera activo para no ocultar médicos antiguos sin ese campo.
      activo: _leerBool(map, 'activo', fallback: true),
      fechaCreacion: _resolverString(map, const <String>['fecha_creacion']),
      createdAt: _resolverString(map, const <String>[
        'created_at',
      ], fallback: DateTime.now().toIso8601String()),
      documento: _resolverString(map, const <String>[
        'documento',
        'numero_documento',
      ]),
      jornada: _resolverString(map, const <String>['jornada']),
      estado: _resolverString(map, const <String>['estado']),
    );
  }

  // Sección: deserialización desde texto JSON
  // Convierte una cadena JSON a entidad tipada.
  factory PersonalMedico.fromJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON de personal médico inválido.');
    }
    return PersonalMedico.fromMap(decoded);
  }

  // Sección: copia inmutable
  // Permite actualizar campos puntuales sin mutar la instancia.
  PersonalMedico copyWith({
    String? idMedico,
    String? nombreCompleto,
    String? especialidad,
    String? telefono,
    String? correo,
    bool? activo,
    String? fechaCreacion,
    String? createdAt,
    String? documento,
    String? jornada,
    String? estado,
  }) {
    return PersonalMedico(
      idMedico: idMedico ?? this.idMedico,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      especialidad: especialidad ?? this.especialidad,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      createdAt: createdAt ?? this.createdAt,
      documento: documento ?? this.documento,
      jornada: jornada ?? this.jornada,
      estado: estado ?? this.estado,
    );
  }

  // Sección: helpers de parseo seguro
  // Normalizan valores dinámicos y aplican fallback cuando falta la llave esperada.
  static String _resolverString(
    Map<String, dynamic> map,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final valor = map[key];
      if (valor is String && valor.trim().isNotEmpty) {
        return valor.trim();
      }
      if (valor != null && valor.toString().trim().isNotEmpty) {
        return valor.toString().trim();
      }
    }
    return fallback;
  }

  static bool _leerBool(
    Map<String, dynamic> map,
    String key, {
    bool fallback = false,
  }) {
    final valor = map[key];
    if (valor is bool) {
      return valor;
    }
    // Soporta booleanos guardados como texto desde JSON o formularios previos.
    final texto = valor?.toString().toLowerCase() ?? '';
    if (texto == 'true') {
      return true;
    }
    if (texto == 'false') {
      return false;
    }
    return fallback;
  }
}
