// Sección: imports
// Se importa Timestamp para normalizar fechas de registro desde Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';

// Sección: modelo de mascota
// Representa una mascota del cliente con los campos necesarios para el home.
class Mascota {
  const Mascota({
    required this.idMascota,
    required this.idUsuario,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.edadAnios,
    required this.pesoKg,
    required this.createdAt,
  });

  final String idMascota;
  final String idUsuario;
  final String nombre;
  final String especie;
  final String raza;
  final int? edadAnios;
  final double? pesoKg;
  final DateTime? createdAt;

  // Sección: fábrica desde Firestore
  // Resuelve variantes comunes de claves para evitar fallos por diferencias de esquema.
  factory Mascota.fromMap(
    Map<String, dynamic> map, {
    required String idDocumento,
  }) {
    return Mascota(
      idMascota: idDocumento,
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
      raza: _resolverString(
        map,
        llaves: const <String>['raza'],
      ),
      edadAnios: _resolverEntero(
        map,
        llaves: const <String>['edad_anios', 'edad', 'anios', 'anos'],
      ),
      pesoKg: _resolverDouble(
        map,
        llaves: const <String>['peso_kg', 'peso', 'pesoKg'],
      ),
      createdAt: _resolverFecha(
        map,
        llaves: const <String>['created_at', 'fecha_creacion', 'fecha_registro'],
      ),
    );
  }

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
    return createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  // Sección: helpers de lectura de mapa
  // Normalizan extracción de valores con tolerancia a tipos de datos variados.
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
      if (valor is Timestamp) {
        return valor.toDate();
      }
      if (valor is DateTime) {
        return valor;
      }
      if (valor is String) {
        final fecha = DateTime.tryParse(valor);
        if (fecha != null) {
          return fecha;
        }
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
