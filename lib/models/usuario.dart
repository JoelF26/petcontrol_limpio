// Sección: imports
// Se importa Timestamp para mapear fechas desde/hacia Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcontrol_limpio/core/constants/roles_usuario.dart';

// Sección: modelo de usuario
// Representa el documento de la colección usuarios en Firestore.
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
  final Timestamp createdAt;

  // Sección: regla de conveniencia
  // Permite saber rápidamente si el usuario es administrador.
  bool get esAdmin => rol == RolesUsuario.admin;

  // Sección: serialización a Firestore
  // Convierte la entidad Usuario al mapa esperado por la base de datos.
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

  // Sección: deserialización desde Firestore
  // Construye una entidad Usuario leyendo un mapa del documento.
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuario: (map['id_usuario'] as String?) ?? '',
      nombreCompleto: (map['nombre_completo'] as String?) ?? '',
      numeroDocumento: (map['numero_documento'] as String?) ?? '',
      telefono: (map['telefono'] as String?) ?? '',
      correo: (map['correo'] as String?) ?? '',
      contrasena: (map['contrasena'] as String?) ?? '',
      rol: (map['rol'] as String?) ?? RolesUsuario.cliente,
      fechaCreacion: (map['fecha_creacion'] as String?) ?? '',
      createdAt: _resolverTimestamp(map['created_at']),
    );
  }

  // Sección: copia inmutable
  // Permite clonar el usuario cambiando solo campos específicos.
  Usuario copyWith({
    String? idUsuario,
    String? nombreCompleto,
    String? numeroDocumento,
    String? telefono,
    String? correo,
    String? contrasena,
    String? rol,
    String? fechaCreacion,
    Timestamp? createdAt,
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

  // Sección: helper de fecha
  // Normaliza el valor de created_at para siempre manejar Timestamp.
  static Timestamp _resolverTimestamp(Object? rawValue) {
    if (rawValue is Timestamp) {
      return rawValue;
    }
    if (rawValue is DateTime) {
      return Timestamp.fromDate(rawValue);
    }
    return Timestamp.now();
  }
}
