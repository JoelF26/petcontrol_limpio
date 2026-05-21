import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreMapper {
  FirestoreMapper._();

  static Map<String, dynamic> normalizarLectura(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, _normalizarValor(value)));
  }

  static Map<String, dynamic> normalizarEscritura(Map<String, dynamic> data) {
    final limpio = Map<String, dynamic>.from(data);
    limpio.removeWhere((_, value) => value == null);
    return limpio;
  }

  static dynamic _normalizarValor(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }
    if (value is Map<String, dynamic>) {
      return normalizarLectura(value);
    }
    if (value is Map) {
      return normalizarLectura(
        value.map((key, val) => MapEntry(key.toString(), val)),
      );
    }
    if (value is List) {
      return value.map(_normalizarValor).toList(growable: false);
    }
    return value;
  }
}
