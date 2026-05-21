// Sección: imports
// Se importa utilería JSON y constantes de rol para reglas de dominio.
import 'dart:convert';

import 'package:petcontrol_limpio/domain/constants/roles_usuario.dart';

// Sección: modelo de usuario
// Representa el registro de usuario persistido en JSON local.
class Usuario {
  const Usuario({
    required this.idUsuario,
    required this.nombreCompleto,
    required this.numeroDocumento,
    required this.telefono,
    required this.correo,
    required this.contrasena,
    required this.rol,
    required this.fechaCreacion,
    required this.createdAt,
  });

  final String idUsuario;
  final String nombreCompleto;
  final String numeroDocumento;
  final String telefono;
  final String correo;
  final String contrasena;
  final String rol;
  final String fechaCreacion;
  final String createdAt;

  // Sección: regla de conveniencia
  // Permite validar rápidamente si el usuario corresponde a administrador.
  bool get esAdmin => rol == RolesUsuario.admin;

  // Sección: serialización a mapa
  // Convierte la entidad al formato persistido en JSON local.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_usuario': idUsuario,
      'nombre_completo': nombreCompleto,
      'numero_documento': numeroDocumento,
      'telefono': telefono,
      'correo': correo,
      'contrasena': contrasena,
      'rol': rol,
      'fecha_creacion': fechaCreacion,
      'created_at': createdAt,
    };
  }

  // Sección: serialización a texto JSON
  // Genera una representación textual para persistencia o debug.
  String toJson() {
    return jsonEncode(toMap());
  }

  // Sección: deserialización desde mapa
  // Construye la entidad leyendo un mapa con claves del dominio.
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuario: _leerString(map, 'id_usuario'),
      nombreCompleto: _leerString(map, 'nombre_completo'),
      numeroDocumento: _leerString(map, 'numero_documento'),
      telefono: _leerString(map, 'telefono'),
      correo: _leerString(map, 'correo').toLowerCase(),
      contrasena: _leerString(map, 'contrasena'),
      rol: _leerString(map, 'rol', fallback: RolesUsuario.cliente),
      fechaCreacion: _leerString(map, 'fecha_creacion'),
      createdAt: _leerString(
        map,
        'created_at',
        fallback: DateTime.now().toIso8601String(),
      ),
    );
  }

  // Sección: deserialización desde texto JSON
  // Convierte una cadena JSON al modelo tipado de usuario.
  factory Usuario.fromJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON de usuario inválido.');
    }
    return Usuario.fromMap(decoded);
  }

  // Sección: copia inmutable
  // Permite clonar la entidad cambiando solo campos puntuales.
  Usuario copyWith({
    String? idUsuario,
    String? nombreCompleto,
    String? numeroDocumento,
    String? telefono,
    String? correo,
    String? contrasena,
    String? rol,
    String? fechaCreacion,
    String? createdAt,
  }) {
    return Usuario(
      idUsuario: idUsuario ?? this.idUsuario,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      contrasena: contrasena ?? this.contrasena,
      rol: rol ?? this.rol,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Sección: helper de lectura segura
  // Normaliza cualquier valor a string para evitar cast inseguros.
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
