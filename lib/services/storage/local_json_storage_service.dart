// Sección: imports
// Se importan utilidades JSON, assets, constantes de entidades y storage local.
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:petcontrol_limpio/core/constants/entidades_locales.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Sección: servicio central de almacenamiento local
// Mantiene una base única con listas por entidad para toda la app.
class LocalJsonStorageService {
  // Sección: singleton compartido
  // Se mantiene una sola instancia para toda la app.
  static final LocalJsonStorageService _instanciaCompartida =
      LocalJsonStorageService._interno();

  // Sección: constructor público
  // Siempre retorna la misma instancia central.
  factory LocalJsonStorageService() {
    return _instanciaCompartida;
  }

  // Sección: constructor interno
  // Evita construir instancias externas por error.
  LocalJsonStorageService._interno();

  // Sección: clave de almacenamiento
  // Guarda toda la base en una sola clave para tener fuente única de verdad.
  static const String _llaveBase = 'petcontrol_json_db_v1';
  static const String _rutaSeed = 'assets/data/local_db_seed.json';

  // Sección: estado de inicialización
  // Evita recalcular la base inicial más de una vez.
  bool _inicializado = false;
  Future<void>? _inicializacionEnCurso;

  // Sección: inicialización principal
  // Si no existe base local, crea una base inicial desde el seed JSON.
  Future<void> inicializar() {
    if (_inicializado) {
      return Future<void>.value();
    }

    final enCurso = _inicializacionEnCurso;
    if (enCurso != null) {
      return enCurso;
    }

    final tarea = _ejecutarInicializacion();
    _inicializacionEnCurso = tarea;
    return tarea;
  }

  // Sección: construcción de base inicial vacía
  // Genera una estructura con todas las entidades apuntando a listas vacías.
  Map<String, dynamic> _crearBaseInicialVacia() {
    final Map<String, dynamic> base = <String, dynamic>{};
    for (final entidad in EntidadesLocales.todas) {
      base[entidad] = <dynamic>[];
    }
    return base;
  }

  // Sección: construcción desde seed JSON
  // Lee la base inicial desde assets y completa entidades faltantes.
  Future<Map<String, dynamic>> _crearBaseInicialDesdeSeed() async {
    try {
      final contenido = await rootBundle.loadString(_rutaSeed);
      final decoded = jsonDecode(contenido);
      if (decoded is Map<String, dynamic>) {
        return _normalizarBase(decoded);
      }
      if (decoded is Map) {
        return _normalizarBase(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
    } catch (_) {
      // Si el asset no está disponible, la app conserva una base vacía operable.
    }
    return _crearBaseInicialVacia();
  }

  // Sección: normalización de base
  // Asegura que todas las entidades soportadas existan como listas.
  Map<String, dynamic> _normalizarBase(Map<String, dynamic> baseRaw) {
    final base = Map<String, dynamic>.from(baseRaw);
    for (final entidad in EntidadesLocales.todas) {
      if (base[entidad] is! List) {
        base[entidad] = <dynamic>[];
      }
    }
    return base;
  }

  // Sección: bootstrap de base local
  // Si no hay base persistida la crea desde el seed JSON inicial.
  Future<void> _ejecutarInicializacion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final baseActual = prefs.getString(_llaveBase);

      Map<String, dynamic> base;
      if (baseActual != null && baseActual.trim().isNotEmpty) {
        final decoded = jsonDecode(baseActual);
        if (decoded is Map<String, dynamic>) {
          base = _normalizarBase(decoded);
        } else if (decoded is Map) {
          base = _normalizarBase(
            decoded.map((key, value) => MapEntry(key.toString(), value)),
          );
        } else {
          base = await _crearBaseInicialDesdeSeed();
        }
      } else {
        base = await _crearBaseInicialDesdeSeed();
      }
      await prefs.setString(_llaveBase, jsonEncode(base));
      _inicializado = true;
    } finally {
      _inicializacionEnCurso = null;
    }
  }

  // Sección: validación de entidad
  // Impide operar sobre entidades no soportadas por la app.
  void _validarEntidad(String entidad) {
    if (!EntidadesLocales.todas.contains(entidad)) {
      throw ArgumentError('Entidad no soportada: $entidad');
    }
  }

  // Sección: lectura de base completa
  // Obtiene la base unificada y garantiza llaves faltantes con listas vacías.
  Future<Map<String, dynamic>> _leerBase() async {
    await inicializar();
    final prefs = await SharedPreferences.getInstance();
    final contenido = prefs.getString(_llaveBase) ?? '{}';

    Map<String, dynamic> base;
    final decoded = jsonDecode(contenido);
    if (decoded is Map<String, dynamic>) {
      base = decoded;
    } else if (decoded is Map) {
      base = decoded.map((key, value) => MapEntry(key.toString(), value));
    } else {
      base = <String, dynamic>{};
    }

    var requiereGuardar = false;
    for (final entidad in EntidadesLocales.todas) {
      if (base[entidad] is! List) {
        base[entidad] = <dynamic>[];
        requiereGuardar = true;
      }
    }

    if (requiereGuardar) {
      await _guardarBase(base);
    }

    return base;
  }

  // Sección: guardado de base completa
  // Persiste de forma atómica la base unificada.
  Future<void> _guardarBase(Map<String, dynamic> base) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_llaveBase, jsonEncode(base));
  }

  // Sección: normalización de listas
  // Convierte cualquier lista dinámica en lista de mapas tipados.
  List<Map<String, dynamic>> _normalizarLista(dynamic valorEntidad) {
    if (valorEntidad is! List) {
      return <Map<String, dynamic>>[];
    }

    return valorEntidad
        .map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          }
          if (item is Map) {
            return item.map((key, value) => MapEntry(key.toString(), value));
          }
          throw const FormatException(
            'La lista contiene registros con formato inválido.',
          );
        })
        .toList(growable: false);
  }

  // Sección: lectura tipada de lista
  // Retorna la colección de una entidad desde la base unificada.
  Future<List<Map<String, dynamic>>> leerLista(String entidad) async {
    _validarEntidad(entidad);
    final base = await _leerBase();
    return _normalizarLista(base[entidad]);
  }

  // Sección: escritura tipada de lista
  // Actualiza solo una entidad y persiste la base completa.
  Future<void> guardarLista(
    String entidad,
    List<Map<String, dynamic>> registros,
  ) async {
    _validarEntidad(entidad);
    final base = await _leerBase();
    base[entidad] = registros;
    await _guardarBase(base);
  }
}
