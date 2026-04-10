// Sección: imports
// Se importa Timestamp para convertir fechas de Firestore al modelo de dominio.
import 'package:cloud_firestore/cloud_firestore.dart';

// Sección: modelo de cita
// Representa una cita del cliente con los campos visibles en el home.
class Cita {
  const Cita({
    required this.idCita,
    required this.idUsuario,
    required this.idMascota,
    required this.nombreMascota,
    required this.especieMascota,
    required this.motivo,
    required this.descripcion,
    required this.estado,
    required this.fechaHora,
    required this.fechaTexto,
    required this.horaTexto,
    required this.createdAt,
  });

  final String idCita;
  final String idUsuario;
  final String idMascota;
  final String nombreMascota;
  final String especieMascota;
  final String motivo;
  final String descripcion;
  final String estado;
  final DateTime? fechaHora;
  final String fechaTexto;
  final String horaTexto;
  final DateTime? createdAt;

  // Sección: fábrica desde Firestore
  // Lee el documento y soporta variaciones de nombres de campos.
  factory Cita.fromMap(
    Map<String, dynamic> map, {
    required String idDocumento,
  }) {
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
      idCita: idDocumento,
      idUsuario: _resolverString(
        map,
        llaves: const <String>['id_usuario', 'usuario_id', 'uid_usuario'],
      ),
      idMascota: _resolverString(
        map,
        llaves: const <String>['id_mascota', 'mascota_id'],
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
      estado: _resolverString(
        map,
        llaves: const <String>['estado'],
      ),
      fechaHora: fechaHoraDirecta ?? _combinarFechaHora(fechaTexto, horaTexto),
      fechaTexto: fechaTexto,
      horaTexto: horaTexto,
      createdAt: _resolverFecha(
        map,
        llaves: const <String>['created_at', 'fecha_creacion'],
      ),
    );
  }

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

  // Sección: helpers de parsing
  // Normalizan lectura de strings y fechas con tolerancia a distintos formatos.
  static String _resolverString(
    Map<String, dynamic> map, {
    required List<String> llaves,
  }) {
    for (final llave in llaves) {
      final valor = map[llave];
      if (valor is String && valor.trim().isNotEmpty) {
        return valor.trim();
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
      if (valor is Timestamp) {
        return valor.toDate();
      }
      if (valor is DateTime) {
        return valor;
      }
      if (valor is String) {
        final directa = DateTime.tryParse(valor);
        if (directa != null) {
          return directa;
        }
      }
    }
    return null;
  }

  static DateTime? _combinarFechaHora(String fecha, String hora) {
    final fechaLimpia = fecha.trim();
    if (fechaLimpia.isEmpty) {
      return null;
    }

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

    final match = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})$').firstMatch(fecha);
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
    final match = RegExp(r'^(\d{1,2}):(\d{2})(?:\s*([ap]m))?$').firstMatch(texto);
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
