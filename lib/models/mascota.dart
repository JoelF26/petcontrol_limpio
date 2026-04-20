// Sección: imports
// Se importa utilería JSON para serialización del modelo.
import 'dart:convert';

// Sección: modelo de mascota
// Representa una mascota del cliente con campos persistidos en JSON local.
class Mascota {
  const Mascota({
    required this.idMascota,
    required this.idUsuario,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.sexo,
    required this.edadAnios,
    required this.pesoKg,
    required this.fechaCreacion,
    required this.createdAt,
  });

  final String idMascota;
  final String idUsuario;
  final String nombre;
  final String especie;
  final String raza;
  final String sexo;
  final int? edadAnios;
  final double? pesoKg;
  final String fechaCreacion;
  final DateTime? createdAt;

  // Sección: valores amigables de UI
  // Exponen texto consistente para renderizar la tarjeta sin lógica extra en el widget.
  String get nombreVisible {
    final valor = nombre.trim();
    return valor.isEmpty ? 'Sin nombre' : valor;
  }

  String get especieVisible {
    final valor = especie.trim();
    return valor.isEmpty ? 'Sin especie' : _capitalizar(valor);
  }

  String get razaVisible {
    final valor = raza.trim();
    return valor.isEmpty ? 'Sin raza' : valor;
  }

  String get edadVisible {
    if (edadAnios == null || edadAnios! < 0) {
      return '-- años';
    }
    final sufijo = edadAnios == 1 ? 'año' : 'años';
    return '$edadAnios $sufijo';
  }

  String get pesoVisible {
    if (pesoKg == null || pesoKg! < 0) {
      return '-- kg';
    }
    if (pesoKg!.truncateToDouble() == pesoKg) {
      return '${pesoKg!.toInt()} kg';
    }
    return '${pesoKg!.toStringAsFixed(1)} kg';
  }

  // Sección: valor de ordenamiento
  // Permite ordenar mascotas de más reciente a más antigua.
  DateTime get fechaOrden {
    if (createdAt != null) {
      return createdAt!;
    }
    final desdeFechaCreacion = DateTime.tryParse(fechaCreacion.trim());
    return desdeFechaCreacion ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  // Sección: serialización a mapa
  // Convierte la entidad al esquema usado en archivos JSON.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_mascota': idMascota,
      'id_usuario': idUsuario,
      'nombre': nombre,
      'especie': especie,
      'raza': raza,
      'sexo': sexo,
      'edad_anios': edadAnios,
      'peso_kg': pesoKg,
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
  // Construye la entidad leyendo el mapa persistido.
  factory Mascota.fromMap(Map<String, dynamic> map) {
    return Mascota(
      idMascota: _resolverString(
        map,
        llaves: const <String>['id_mascota', 'id', 'mascota_id'],
      ),
      idUsuario: _resolverString(
        map,
        llaves: const <String>['id_usuario', 'uid_usuario', 'usuario_id'],
      ),
      nombre: _resolverString(
        map,
        llaves: const <String>['nombre', 'nombre_mascota'],
      ),
      especie: _resolverString(
        map,
        llaves: const <String>['especie', 'tipo_mascota'],
      ),
      raza: _resolverString(map, llaves: const <String>['raza']),
      sexo: _resolverString(map, llaves: const <String>['sexo']),
      edadAnios: _resolverEntero(
        map,
        llaves: const <String>['edad_anios', 'edad', 'anios', 'anos'],
      ),
      pesoKg: _resolverDouble(
        map,
        llaves: const <String>['peso_kg', 'peso', 'pesoKg'],
      ),
      fechaCreacion: _resolverString(
        map,
        llaves: const <String>['fecha_creacion', 'fecha_registro'],
      ),
      createdAt: _resolverFecha(
        map,
        llaves: const <String>['created_at', 'fecha_creacion', 'fecha_registro'],
      ),
    );
  }

  // Sección: deserialización desde texto JSON
  // Convierte una cadena JSON en la entidad tipada.
  factory Mascota.fromJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON de mascota inválido.');
    }
    return Mascota.fromMap(decoded);
  }

  // Sección: copia inmutable
  // Permite modificar campos puntuales sin mutar la instancia original.
  Mascota copyWith({
    String? idMascota,
    String? idUsuario,
    String? nombre,
    String? especie,
    String? raza,
    String? sexo,
    int? edadAnios,
    double? pesoKg,
    String? fechaCreacion,
    DateTime? createdAt,
  }) {
    return Mascota(
      idMascota: idMascota ?? this.idMascota,
      idUsuario: idUsuario ?? this.idUsuario,
      nombre: nombre ?? this.nombre,
      especie: especie ?? this.especie,
      raza: raza ?? this.raza,
      sexo: sexo ?? this.sexo,
      edadAnios: edadAnios ?? this.edadAnios,
      pesoKg: pesoKg ?? this.pesoKg,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Sección: helpers de lectura de mapa
  // Normalizan extracción de valores con tolerancia a tipos variados.
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

  static int? _resolverEntero(
    Map<String, dynamic> map, {
    required List<String> llaves,
  }) {
    for (final llave in llaves) {
      final valor = map[llave];
      if (valor is int) {
        return valor;
      }
      if (valor is double) {
        return valor.round();
      }
      if (valor is String) {
        final coincidencia = RegExp(r'-?\d+').firstMatch(valor);
        final numero = int.tryParse(coincidencia?.group(0) ?? '');
        if (numero != null) {
          return numero;
        }
      }
    }
    return null;
  }

  static double? _resolverDouble(
    Map<String, dynamic> map, {
    required List<String> llaves,
  }) {
    for (final llave in llaves) {
      final valor = map[llave];
      if (valor is int) {
        return valor.toDouble();
      }
      if (valor is double) {
        return valor;
      }
      if (valor is String) {
        final normalizado = valor.replaceAll(',', '.');
        final coincidencia = RegExp(r'-?\d+(\.\d+)?').firstMatch(normalizado);
        final numero = double.tryParse(coincidencia?.group(0) ?? '');
        if (numero != null) {
          return numero;
        }
      }
    }
    return null;
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
        final fecha = DateTime.tryParse(valor);
        if (fecha != null) {
          return fecha;
        }
      }
      if (valor is int) {
        return DateTime.fromMillisecondsSinceEpoch(valor);
      }
    }
    return null;
  }

  // Sección: helper de texto
  // Capitaliza la primera letra de cada palabra para etiquetas visuales.
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
