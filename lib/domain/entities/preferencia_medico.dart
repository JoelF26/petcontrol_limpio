// Sección: imports
// Se importa utilería JSON para serialización del modelo.
import 'dart:convert';

// Sección: modelo de preferencia de médico
// Vincula la preferencia de médico de una mascota específica.
class PreferenciaMedico {
  const PreferenciaMedico({
    required this.idPreferencia,
    required this.idUsuario,
    required this.idMascota,
    required this.idMedico,
    required this.fechaCreacion,
    required this.createdAt,
  });

  final String idPreferencia;
  final String idUsuario;
  final String idMascota;
  final String idMedico;
  final String fechaCreacion;
  final String createdAt;

  // Sección: serialización a mapa
  // Convierte la entidad al esquema persistido en JSON local.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_preferencia': idPreferencia,
      'id_usuario': idUsuario,
      'id_mascota': idMascota,
      'id_medico': idMedico,
      'fecha_creacion': fechaCreacion,
      'created_at': createdAt,
    };
  }

  // Sección: serialización a texto JSON
  // Genera representación textual del modelo.
  String toJson() {
    return jsonEncode(toMap());
  }

  // Sección: deserialización desde mapa
  // Reconstruye la entidad desde datos dinámicos.
  factory PreferenciaMedico.fromMap(Map<String, dynamic> map) {
    return PreferenciaMedico(
      idPreferencia: _leerString(map, 'id_preferencia'),
      idUsuario: _leerString(map, 'id_usuario'),
      idMascota: _leerString(map, 'id_mascota'),
      idMedico: _leerString(map, 'id_medico'),
      fechaCreacion: _leerString(map, 'fecha_creacion'),
      createdAt: _leerString(
        map,
        'created_at',
        fallback: DateTime.now().toIso8601String(),
      ),
    );
  }

  // Sección: deserialización desde texto JSON
  // Convierte una cadena JSON en entidad tipada.
  factory PreferenciaMedico.fromJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON de preferencia médico inválido.');
    }
    return PreferenciaMedico.fromMap(decoded);
  }

  // Sección: copia inmutable
  // Permite cambiar campos puntuales manteniendo inmutabilidad.
  PreferenciaMedico copyWith({
    String? idPreferencia,
    String? idUsuario,
    String? idMascota,
    String? idMedico,
    String? fechaCreacion,
    String? createdAt,
  }) {
    return PreferenciaMedico(
      idPreferencia: idPreferencia ?? this.idPreferencia,
      idUsuario: idUsuario ?? this.idUsuario,
      idMascota: idMascota ?? this.idMascota,
      idMedico: idMedico ?? this.idMedico,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Sección: helper de lectura segura
  // Convierte valores dinámicos en string controlado.
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
