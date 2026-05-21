import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:petcontrol_limpio/domain/repositories/catalogos_repository.dart';

class LocalCatalogosRepository implements CatalogosRepository {
  static const String _rutaCatalogos = 'assets/data/catalogos.json';

  Future<Map<String, dynamic>>? _cacheEnCurso;
  Map<String, dynamic>? _cache;

  @override
  Future<Map<String, dynamic>> leerCatalogos() {
    final cache = _cache;
    if (cache != null) {
      return Future<Map<String, dynamic>>.value(cache);
    }

    final enCurso = _cacheEnCurso;
    if (enCurso != null) {
      return enCurso;
    }

    final tarea = _cargarCatalogos();
    _cacheEnCurso = tarea;
    return tarea;
  }

  Future<Map<String, dynamic>> _cargarCatalogos() async {
    try {
      final contenido = await rootBundle.loadString(_rutaCatalogos);
      final decoded = jsonDecode(contenido);
      if (decoded is Map<String, dynamic>) {
        _cache = decoded;
      } else if (decoded is Map) {
        _cache = decoded.map((key, value) => MapEntry(key.toString(), value));
      } else {
        _cache = <String, dynamic>{};
      }
      return _cache!;
    } catch (_) {
      _cache = <String, dynamic>{};
      return _cache!;
    } finally {
      _cacheEnCurso = null;
    }
  }
}
