// Sección: imports
// Se importan utilidades JSON, constantes de entidades y almacenamiento local unificado.
import 'dart:convert';

import 'package:petcontrol_limpio/core/constants/entidades_locales.dart';
import 'package:petcontrol_limpio/core/constants/roles_usuario.dart';
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

  // Sección: estado de inicialización
  // Evita recalcular la base inicial más de una vez.
  bool _inicializado = false;
  Future<void>? _inicializacionEnCurso;

  // Sección: usuarios base
  // Define cuentas iniciales solicitadas para admin y cliente.
  static const List<Map<String, dynamic>> _usuariosBase =
      <Map<String, dynamic>>[
        <String, dynamic>{
          'id_usuario': 'usuario_admin_001',
          'nombre_completo': 'Maria',
          'numero_documento': '100000001',
          'telefono': '3000000001',
          'correo': 'maria@gmail.com',
          'contrasena': 'M123456',
          'rol': RolesUsuario.admin,
          'fecha_creacion': '2026-04-14',
          'created_at': '2026-04-14T00:00:00.000',
        },
        <String, dynamic>{
          'id_usuario': 'usuario_cliente_001',
          'nombre_completo': 'Joel',
          'numero_documento': '100000002',
          'telefono': '3000000002',
          'correo': 'joel@gmail.com',
          'contrasena': 'J123456',
          'rol': RolesUsuario.cliente,
          'fecha_creacion': '2026-04-14',
          'created_at': '2026-04-14T00:00:00.000',
        },
      ];

  // Sección: inicialización principal
  // Si no existe base local, crea una base inicial con listas vacías.
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

  // Sección: construcción de base inicial
  // Genera una estructura con todas las entidades apuntando a listas vacías.
  Map<String, dynamic> _crearBaseInicialVacia() {
    final Map<String, dynamic> base = <String, dynamic>{};
    for (final entidad in EntidadesLocales.todas) {
      base[entidad] = <dynamic>[];
    }
    return base;
  }

  // Sección: inserción/sincronización de usuarios base
  // Agrega por correo y sincroniza datos clave aunque el usuario ya exista.
  bool _asegurarUsuariosBase(Map<String, dynamic> base) {
    final dynamic usuariosRaw = base[EntidadesLocales.usuarios];
    final List<dynamic> usuarios = usuariosRaw is List
        ? usuariosRaw
        : <dynamic>[];

    var cambio = false;

    for (final usuarioBase in _usuariosBase) {
      final correo =
          (usuarioBase['correo'] ?? '').toString().trim().toLowerCase();
      if (correo.isEmpty) {
        continue;
      }

      final indice = usuarios.indexWhere((item) {
        if (item is! Map) {
          return false;
        }
        final correoItem = (item['correo'] ?? '').toString().trim().toLowerCase();
        return correoItem == correo;
      });

      if (indice < 0) {
        usuarios.add(Map<String, dynamic>.from(usuarioBase));
        cambio = true;
        continue;
      }

      final actual = usuarios[indice];
      if (actual is! Map) {
        usuarios[indice] = Map<String, dynamic>.from(usuarioBase);
        cambio = true;
        continue;
      }

      final actualizado = Map<String, dynamic>.from(actual);
      for (final entrada in usuarioBase.entries) {
        if (actualizado[entrada.key] != entrada.value) {
          actualizado[entrada.key] = entrada.value;
          cambio = true;
        }
      }
      usuarios[indice] = actualizado;
    }

    base[EntidadesLocales.usuarios] = usuarios;
    return cambio;
  }

  // Sección: bootstrap de base local
  // Si no hay base persistida la crea, y luego asegura usuarios base en ambos casos.
  Future<void> _ejecutarInicializacion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final baseActual = prefs.getString(_llaveBase);

      Map<String, dynamic> base;
      if (baseActual != null && baseActual.trim().isNotEmpty) {
        final decoded = jsonDecode(baseActual);
        if (decoded is Map<String, dynamic>) {
          base = decoded;
        } else if (decoded is Map) {
          base = decoded.map((key, value) => MapEntry(key.toString(), value));
        } else {
          base = _crearBaseInicialVacia();
        }
      } else {
        base = _crearBaseInicialVacia();
      }

      // Sección: normalización de entidades faltantes
      // Completa llaves ausentes con listas vacías antes de guardar.
      for (final entidad in EntidadesLocales.todas) {
        if (base[entidad] is! List) {
          base[entidad] = <dynamic>[];
        }
      }

      _asegurarUsuariosBase(base);
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

    if (_asegurarUsuariosBase(base)) {
      requiereGuardar = true;
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

    return valorEntidad.map((item) {
      if (item is Map<String, dynamic>) {
        return item;
      }
      if (item is Map) {
        return item.map((key, value) => MapEntry(key.toString(), value));
      }
      throw const FormatException(
        'La lista contiene registros con formato inválido.',
      );
    }).toList(growable: false);
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
