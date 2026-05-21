// Sección: imports
// Se importa utilería JSON para serialización del modelo.
import 'dart:convert';

// Sección: modelo de cita
// Representa una cita veterinaria persistida en JSON local.
class Cita {
  const Cita({
    required this.idCita,
    required this.idUsuario,
    required this.idMascota,
    required this.idMedico,
    required this.nombreMascota,
    required this.especieMascota,
    required this.motivo,
    required this.descripcion,
    required this.estado,
    required this.fechaHora,
    required this.fechaTexto,
    required this.horaTexto,
    required this.fechaCreacion,
    required this.createdAt,
  });

  final String idCita;
  final String idUsuario;
  final String idMascota;
  final String idMedico;
  final String nombreMascota;
  final String especieMascota;
  final String motivo;
  final String descripcion;
  final String estado;
  final DateTime? fechaHora;
  final String fechaTexto;
  final String horaTexto;
  final String fechaCreacion;
  final DateTime? createdAt;

  // Sección: propiedades amigables para UI
  // Preparan texto consistente para los widgets del home.
  String get nombreMascotaVisible {
    final valor = nombreMascota.trim();
    return valor.isEmpty ? 'Mascota' : valor;
  }

  String get especieMascotaVisible {
    final valor = especieMascota.trim();
    return valor.isEmpty ? 'Sin especie' : _capitalizar(valor);
  }

  String get motivoVisible {
    final valor = motivo.trim();
    return valor.isEmpty ? 'Sin motivo' : valor;
  }

  String get descripcionVisible {
    final valor = descripcion.trim();
    return valor.isEmpty ? 'Sin descripción' : valor;
  }

  String get estadoVisible {
    final valor = estado.trim().toLowerCase();
    if (valor.isEmpty) {
      return 'pendiente';
    }
    if (valor.contains('proxim')) {
      return 'proxima';
    }
    if (valor.contains('pend')) {
      return 'pendiente';
    }
    return valor;
  }

  String get fechaHoraVisible {
    if (fechaHora != null) {
      return _formatearFechaHora(fechaHora!);
    }

    final fecha = fechaTexto.trim();
    final hora = horaTexto.trim();
    if (fecha.isNotEmpty && hora.isNotEmpty) {
      return '$fecha - $hora';
    }
    if (fecha.isNotEmpty) {
      return fecha;
    }
    return 'Fecha por definir';
  }

  // Sección: propiedades para lógica
  // Definen orden de presentación y estado pendiente para resúmenes.
  DateTime get fechaOrden {
    if (fechaHora != null) {
      return fechaHora!;
    }
    if (createdAt != null) {
      return createdAt!;
    }
    return DateTime(9999, 1, 1);
  }

  bool get esPendiente {
    final normalizado = estadoVisible;
    return normalizado == 'pendiente' || normalizado == 'proxima';
  }

  // Sección: serialización a mapa
  // Convierte la entidad al esquema de almacenamiento local.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_cita': idCita,
      'id_usuario': idUsuario,
      'id_mascota': idMascota,
      'id_medico': idMedico,
      'nombre_mascota': nombreMascota,
      'especie_mascota': especieMascota,
      'motivo': motivo,
      'descripcion': descripcion,
      'estado': estado,
      'fecha_hora': fechaHora?.toIso8601String() ?? '',
      'fecha_cita': fechaTexto,
      'hora_cita': horaTexto,
      'fecha_creacion': fechaCreacion,
      'created_at': createdAt?.toIso8601String() ?? '',
    };
  }

  // Sección: serialización a texto JSON
  // Genera una cadena JSON para persistencia o depuración.
  String toJson() {
    return jsonEncode(toMap());
  }

  // Sección: deserialización desde mapa
  // Soporta registros actuales y legados con nombres alternativos de campos.
  factory Cita.fromMap(Map<String, dynamic> map) {
    // Primero intenta leer fecha/hora separadas; luego acepta una fecha_hora directa.
    final fechaTexto = _resolverString(
      map,
      llaves: const <String>['fecha_cita', 'fecha', 'dia'],
    );
    final horaTexto = _resolverString(
      map,
      llaves: const <String>['hora_cita', 'hora'],
    );
    final fechaHoraDirecta = _resolverFecha(
      map,
      llaves: const <String>['fecha_hora', 'fechaHora', 'fecha_cita_hora'],
    );

    return Cita(
      idCita: _resolverString(map, llaves: const <String>['id_cita', 'id']),
      idUsuario: _resolverString(
        map,
        llaves: const <String>['id_usuario', 'usuario_id', 'uid_usuario'],
      ),
      idMascota: _resolverString(
        map,
        llaves: const <String>['id_mascota', 'mascota_id'],
      ),
      idMedico: _resolverString(
        map,
        llaves: const <String>['id_medico', 'medico_id'],
      ),
      nombreMascota: _resolverString(
        map,
        llaves: const <String>['nombre_mascota', 'mascota_nombre', 'mascota'],
      ),
      especieMascota: _resolverString(
        map,
        llaves: const <String>['especie_mascota', 'especie'],
      ),
      motivo: _resolverString(
        map,
        llaves: const <String>['motivo', 'tipo_cita', 'descripcion'],
      ),
      descripcion: _resolverString(
        map,
        llaves: const <String>['descripcion', 'detalle', 'notas'],
      ),
      estado: _resolverString(map, llaves: const <String>['estado']),
      fechaHora: fechaHoraDirecta ?? _combinarFechaHora(fechaTexto, horaTexto),
      fechaTexto: fechaTexto,
      horaTexto: horaTexto,
      fechaCreacion: _resolverString(
        map,
        llaves: const <String>['fecha_creacion', 'fecha_registro'],
      ),
      createdAt: _resolverFecha(
        map,
        llaves: const <String>['created_at', 'fecha_creacion'],
      ),
    );
  }

  // Sección: deserialización desde texto JSON
  // Convierte una cadena JSON en entidad tipada.
  factory Cita.fromJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON de cita inválido.');
    }
    return Cita.fromMap(decoded);
  }

  // Sección: copia inmutable
  // Permite actualizar campos específicos sin mutar la instancia original.
  Cita copyWith({
    String? idCita,
    String? idUsuario,
    String? idMascota,
    String? idMedico,
    String? nombreMascota,
    String? especieMascota,
    String? motivo,
    String? descripcion,
    String? estado,
    DateTime? fechaHora,
    String? fechaTexto,
    String? horaTexto,
    String? fechaCreacion,
    DateTime? createdAt,
  }) {
    return Cita(
      idCita: idCita ?? this.idCita,
      idUsuario: idUsuario ?? this.idUsuario,
      idMascota: idMascota ?? this.idMascota,
      idMedico: idMedico ?? this.idMedico,
      nombreMascota: nombreMascota ?? this.nombreMascota,
      especieMascota: especieMascota ?? this.especieMascota,
      motivo: motivo ?? this.motivo,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
      fechaHora: fechaHora ?? this.fechaHora,
      fechaTexto: fechaTexto ?? this.fechaTexto,
      horaTexto: horaTexto ?? this.horaTexto,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Sección: helpers de parsing
  // Centralizan tolerancia a tipos mixtos para no duplicarla en cada campo.
  static String _resolverString(
    Map<String, dynamic> map, {
    required List<String> llaves,
  }) {
    for (final llave in llaves) {
      final valor = map[llave];
      if (valor is String && valor.trim().isNotEmpty) {
        return valor.trim();
      }
      if (valor != null && valor.toString().trim().isNotEmpty) {
        return valor.toString().trim();
      }
    }
    return '';
  }

  static DateTime? _resolverFecha(
    Map<String, dynamic> map, {
    required List<String> llaves,
  }) {
    for (final llave in llaves) {
      final valor = map[llave];
      if (valor is DateTime) {
        return valor;
      }
      if (valor is String) {
        final directa = DateTime.tryParse(valor);
        if (directa != null) {
          return directa;
        }
      }
      if (valor is int) {
        return DateTime.fromMillisecondsSinceEpoch(valor);
      }
    }
    return null;
  }

  static DateTime? _combinarFechaHora(String fecha, String hora) {
    final fechaLimpia = fecha.trim();
    if (fechaLimpia.isEmpty) {
      return null;
    }

    // Convierte formatos humanos como dd/mm/yyyy + 7:30 pm a un DateTime ordenable.
    final horaLimpia = hora.trim();
    final fechaIso = _normalizarFechaAFormatoIso(fechaLimpia);
    if (fechaIso == null) {
      return null;
    }

    if (horaLimpia.isEmpty) {
      return DateTime.tryParse('$fechaIso 00:00:00');
    }

    final hora24 = _normalizarHora24(horaLimpia);
    if (hora24 == null) {
      return DateTime.tryParse('$fechaIso 00:00:00');
    }
    return DateTime.tryParse('$fechaIso $hora24:00');
  }

  static String? _normalizarFechaAFormatoIso(String fecha) {
    final isoDirecto = DateTime.tryParse(fecha);
    if (isoDirecto != null) {
      return _isoDate(isoDirecto);
    }

    // Acepta fechas escritas como 03/05/2026 o 03-05-26 desde datos antiguos.
    final match = RegExp(
      r'^(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})$',
    ).firstMatch(fecha);
    if (match == null) {
      return null;
    }

    final dia = int.tryParse(match.group(1) ?? '');
    final mes = int.tryParse(match.group(2) ?? '');
    var anio = int.tryParse(match.group(3) ?? '');
    if (dia == null || mes == null || anio == null) {
      return null;
    }
    if (anio < 100) {
      anio += 2000;
    }
    final date = DateTime(anio, mes, dia);
    return _isoDate(date);
  }

  static String _isoDate(DateTime fecha) {
    final anio = fecha.year.toString().padLeft(4, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');
    return '$anio-$mes-$dia';
  }

  static String? _normalizarHora24(String hora) {
    final texto = hora.toLowerCase().replaceAll('.', '').trim();
    // Permite horas con o sin am/pm y las lleva a HH:mm.
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})(?:\s*([ap]m))?$',
    ).firstMatch(texto);
    if (match == null) {
      return null;
    }

    var horas = int.tryParse(match.group(1) ?? '');
    final minutos = int.tryParse(match.group(2) ?? '');
    final meridiano = match.group(3);
    if (horas == null || minutos == null) {
      return null;
    }
    if (meridiano != null) {
      if (meridiano == 'pm' && horas < 12) {
        horas += 12;
      }
      if (meridiano == 'am' && horas == 12) {
        horas = 0;
      }
    }
    final h = horas.toString().padLeft(2, '0');
    final m = minutos.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String _formatearFechaHora(DateTime fechaHora) {
    const meses = <String>[
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];

    final dia = fechaHora.day.toString().padLeft(2, '0');
    final mes = meses[fechaHora.month - 1];
    final anio = fechaHora.year.toString();
    final hora = fechaHora.hour.toString().padLeft(2, '0');
    final minuto = fechaHora.minute.toString().padLeft(2, '0');
    return '$dia $mes $anio - $hora:$minuto';
  }

  static String _capitalizar(String texto) {
    return texto
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .map(
          (parte) =>
              '${parte.substring(0, 1).toUpperCase()}${parte.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
