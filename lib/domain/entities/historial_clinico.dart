// Sección: imports
// Se importa utilería JSON para serialización del modelo.
import 'dart:convert';

// Sección: modelo de historial clínico
// Representa el resumen clínico asociado a una atención veterinaria.
class HistorialClinico {
  const HistorialClinico({
    required this.idHistorial,
    required this.idCita,
    required this.idUsuario,
    required this.idMascota,
    required this.idMedico,
    required this.diagnostico,
    required this.tratamiento,
    required this.observaciones,
    required this.fechaRegistro,
    required this.createdAt,
  });

  final String idHistorial;
  final String idCita;
  final String idUsuario;
  final String idMascota;
  final String idMedico;
  final String diagnostico;
  final String tratamiento;
  final String observaciones;
  final String fechaRegistro;
  final String createdAt;

  // Sección: serialización a mapa
  // Convierte la entidad al esquema persistido en JSON local.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_historial': idHistorial,
      'id_cita': idCita,
      'id_usuario': idUsuario,
      'id_mascota': idMascota,
      'id_medico': idMedico,
      'diagnostico': diagnostico,
      'tratamiento': tratamiento,
      'observaciones': observaciones,
      'fecha_registro': fechaRegistro,
      'created_at': createdAt,
    };
  }

  // Sección: serialización a texto JSON
  // Genera representación textual para persistencia o depuración.
  String toJson() {
    return jsonEncode(toMap());
  }

  // Sección: deserialización desde mapa
  // Construye la entidad leyendo un registro dinámico.
  factory HistorialClinico.fromMap(Map<String, dynamic> map) {
    return HistorialClinico(
      idHistorial: _leerString(map, 'id_historial'),
      idCita: _leerString(map, 'id_cita'),
      idUsuario: _leerString(map, 'id_usuario'),
      idMascota: _leerString(map, 'id_mascota'),
      idMedico: _leerString(map, 'id_medico'),
      diagnostico: _leerString(map, 'diagnostico'),
      tratamiento: _leerString(map, 'tratamiento'),
      observaciones: _leerString(map, 'observaciones'),
      fechaRegistro: _leerString(map, 'fecha_registro'),
      createdAt: _leerString(
        map,
        'created_at',
        fallback: DateTime.now().toIso8601String(),
      ),
    );
  }

  // Sección: deserialización desde texto JSON
  // Convierte una cadena JSON en la entidad tipada.
  factory HistorialClinico.fromJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON de historial clínico inválido.');
    }
    return HistorialClinico.fromMap(decoded);
  }

  // Sección: copia inmutable
  // Permite actualizar campos sin mutar la instancia original.
  HistorialClinico copyWith({
    String? idHistorial,
    String? idCita,
    String? idUsuario,
    String? idMascota,
    String? idMedico,
    String? diagnostico,
    String? tratamiento,
    String? observaciones,
    String? fechaRegistro,
    String? createdAt,
  }) {
    return HistorialClinico(
      idHistorial: idHistorial ?? this.idHistorial,
      idCita: idCita ?? this.idCita,
      idUsuario: idUsuario ?? this.idUsuario,
      idMascota: idMascota ?? this.idMascota,
      idMedico: idMedico ?? this.idMedico,
      diagnostico: diagnostico ?? this.diagnostico,
      tratamiento: tratamiento ?? this.tratamiento,
      observaciones: observaciones ?? this.observaciones,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Sección: helper de lectura segura
  // Convierte valores dinámicos en string sin fallar por null o tipos.
  static String _leerString(
    Map<String, dynamic> map,
    String key, {
    String fallback = '',
  }) {
    final valor = map[key];
    if (valor == null) {
      return fallback;
    }
    return valor.toString();
  }
}
