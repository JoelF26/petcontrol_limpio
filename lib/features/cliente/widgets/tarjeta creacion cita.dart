// Sección: imports
// Se importan Firebase, utilidades de fecha y servicios de dominio del proyecto.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petcontrol_limpio/core/constants/colecciones.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/models/mascota.dart';
import 'package:petcontrol_limpio/services/auth_service.dart';
import 'package:petcontrol_limpio/services/firestore_service.dart';
import 'package:petcontrol_limpio/services/mascota_service.dart';

// Sección: tarjeta de creación de cita
// Renderiza el formulario popup para registrar citas del cliente en Firestore.
class TarjetaCreacionCita extends StatefulWidget {
  const TarjetaCreacionCita({
    super.key,
    this.onCerrar,
    this.onCitaCreada,
  });

  final VoidCallback? onCerrar;
  final VoidCallback? onCitaCreada;

  @override
  State<TarjetaCreacionCita> createState() => _TarjetaCreacionCitaState();
}

// Sección: estado del formulario de cita
// Gestiona carga de datos, validación y guardado de una nueva cita.
class _TarjetaCreacionCitaState extends State<TarjetaCreacionCita> {
  // Sección: claves y controladores del formulario
  // Permiten validar campos y manejar entradas de fecha/descripción.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaHoraController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  // Sección: servicios backend
  // Encapsulan acceso a sesión, mascotas y colección citas de Firestore.
  final AuthService _authService = AuthService();
  final MascotaService _mascotaService = MascotaService();
  final FirestoreService _firestoreService = FirestoreService();

  // Sección: estado de carga y guardado
  // Controla loaders del popup para evitar acciones duplicadas.
  bool _cargandoDatos = true;
  bool _guardando = false;

  // Sección: estado de usuario y listas dinámicas
  // Almacena id usuario, mascotas asociadas y médicos disponibles.
  String _idUsuarioActual = '';
  List<Mascota> _mascotasDisponibles = const <Mascota>[];
  List<_MedicoItem> _medicosDisponibles = const <_MedicoItem>[];

  // Sección: estado de selección del formulario
  // Guarda las opciones elegidas por el usuario durante el registro.
  String? _idMascotaSeleccionada;
  String? _motivoSeleccionado;
  String? _idMedicoSeleccionado;
  DateTime? _fechaHoraSeleccionada;

  // Sección: catálogo de motivos
  // Lista cerrada para el desplegable de motivo de cita.
  static const List<String> _motivosDisponibles = <String>[
    'Vacunacion anual',
    'Control general',
    'Desparasitacion',
    'Revision de piel',
    'Corte de uñas',
    'Revisión odontologica',
    'Otro',
  ];

  // Sección: inicialización del widget
  // Carga mascotas y médicos apenas se abre el popup.
  @override
  void initState() {
    super.initState();
    _cargarDatosFormulario();
  }

  // Sección: liberación de controladores
  // Evita fugas de memoria al cerrar el popup.
  @override
  void dispose() {
    _fechaHoraController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  // Sección: carga de datos base
  // Resuelve usuario actual, mascotas asociadas y médicos disponibles.
  Future<void> _cargarDatosFormulario() async {
    try {
      final usuario = await _authService.obtenerUsuarioActual();
      final idUsuario = _resolverIdUsuario(usuario?.idUsuario);

      if (idUsuario.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() {
          _idUsuarioActual = '';
          _mascotasDisponibles = const <Mascota>[];
          _medicosDisponibles = const <_MedicoItem>[];
          _cargandoDatos = false;
        });
        return;
      }

      final mascotasFuture = _mascotaService.obtenerMascotasPorUsuario(idUsuario);
      final medicosFuture = _obtenerMedicosDisponibles();
      final mascotas = await mascotasFuture;
      final medicos = await medicosFuture;

      if (!mounted) {
        return;
      }
      setState(() {
        _idUsuarioActual = idUsuario;
        _mascotasDisponibles = mascotas;
        _medicosDisponibles = medicos;
        _cargandoDatos = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _idUsuarioActual = '';
        _mascotasDisponibles = const <Mascota>[];
        _medicosDisponibles = const <_MedicoItem>[];
        _cargandoDatos = false;
      });
    }
  }

  // Sección: consulta de personal médico
  // Lee la colección personal_medico y normaliza id/nombre para el dropdown.
  Future<List<_MedicoItem>> _obtenerMedicosDisponibles() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(ColeccionesFirestore.personalMedico)
        .get();

    final medicos = snapshot.docs
        .map((doc) => _MedicoItem.fromMap(doc.id, doc.data()))
        .where((medico) => medico.id.isNotEmpty && medico.nombre.isNotEmpty)
        .toList(growable: false);

    final ordenados = medicos.toList()
      ..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    return ordenados;
  }

  // Sección: resolver id de usuario para consultas
  // Prioriza id del perfil y usa uid Firebase como respaldo.
  String _resolverIdUsuario(String? idPerfil) {
    final idLimpio = (idPerfil ?? '').trim();
    if (idLimpio.isNotEmpty) {
      return idLimpio;
    }
    return (_authService.usuarioFirebaseActual?.uid ?? '').trim();
  }

  // Sección: búsqueda local de mascota por id
  // Recupera la mascota seleccionada para armar los datos de la cita.
  Mascota? _buscarMascotaPorId(String idMascota) {
    for (final mascota in _mascotasDisponibles) {
      if (mascota.idMascota == idMascota) {
        return mascota;
      }
    }
    return null;
  }

  // Sección: decoración visual de campos
  // Reutiliza la misma apariencia de inputs en toda la tarjeta.
  InputDecoration _decoracionCampo(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF6E7A78),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: const Color(0xFFE8EBEA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCDD4D1), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF5ABF9A), width: 1.7),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFB53939), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFB53939), width: 1.7),
      ),
      errorStyle: const TextStyle(height: 0.01),
    );
  }

  // Sección: validadores de campos requeridos
  // Devuelven error vacío para mantener el estilo de tu diseño actual.
  String? _validadorRequerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }
    return null;
  }

  // Sección: selector de fecha y hora
  // Abre calendario y reloj para registrar la cita en una fecha futura.
  Future<void> _seleccionarFechaHora() async {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final inicial =
        _fechaHoraSeleccionada ?? ahora.add(const Duration(hours: 1));

    final fecha = await showDatePicker(
      context: context,
      initialDate: inicial.isBefore(hoy) ? hoy : inicial,
      firstDate: hoy,
      lastDate: DateTime(ahora.year + 3),
      helpText: 'Selecciona la fecha de la cita',
      builder: (context, child) {
        return _aplicarTemaAzulSelector(context, child);
      },
    );
    if (fecha == null || !mounted) {
      return;
    }

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(inicial),
      helpText: 'Selecciona la hora de la cita',
      builder: (context, child) {
        return _aplicarTemaAzulSelector(context, child);
      },
    );
    if (hora == null || !mounted) {
      return;
    }

    final fechaHora = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hora.hour,
      hora.minute,
    );
    if (fechaHora.isBefore(ahora)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La cita debe programarse en una fecha y hora futura.'),
        ),
      );
      return;
    }

    setState(() {
      _fechaHoraSeleccionada = fechaHora;
      _fechaHoraController.text = _formatearFechaHoraVisible(fechaHora);
    });
  }

  // Sección: tema azul para calendario y reloj
  // Uniforma la apariencia de los selectores de fecha/hora con la identidad azul.
  Widget _aplicarTemaAzulSelector(BuildContext context, Widget? child) {
    final base = Theme.of(context);
    final colorScheme = base.colorScheme.copyWith(
      primary: AppColores.secundarioOscuro,
      onPrimary: Colors.white,
      secondary: AppColores.secundario,
    );

    return Theme(
      data: base.copyWith(
        colorScheme: colorScheme,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColores.secundarioOscuro),
        ),
        // Sección: tema de días del calendario
        // Mantiene estilo azul y fuerza el número en blanco cuando el día está seleccionado.
        datePickerTheme: DatePickerThemeData(
          backgroundColor: const Color(0xFFE7ECF4),
          dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColores.secundarioOscuro;
            }
            return null;
          }),
          dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return const Color(0xFF1F2B3B);
          }),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: const Color(0xFFE7ECF4),
          dialHandColor: AppColores.secundarioOscuro,
          dialBackgroundColor: const Color(0xFFD7E4F5),
          hourMinuteTextColor: const Color(0xFF1F2B3B),
          hourMinuteColor: const Color(0xFFD7E4F5),
          dayPeriodTextColor: const Color(0xFF1F2B3B),
          dayPeriodColor: const Color(0xFFD7E4F5),
          entryModeIconColor: AppColores.secundarioOscuro,
          cancelButtonStyle: TextButton.styleFrom(
            foregroundColor: AppColores.secundarioOscuro,
          ),
          confirmButtonStyle: TextButton.styleFrom(
            foregroundColor: AppColores.secundarioOscuro,
          ),
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }

  // Sección: guardado de cita en Firestore
  // Crea id único, asocia usuario/mascota/médico y persiste la cita.
  Future<void> _registrarCita() async {
    final esValido = _formKey.currentState?.validate() == true;
    if (!esValido || _guardando) {
      return;
    }

    final idMascota = _idMascotaSeleccionada;
    final motivo = _motivoSeleccionado;
    final fechaHora = _fechaHoraSeleccionada;
    if (idMascota == null || motivo == null || fechaHora == null) {
      setState(() {});
      return;
    }
    if (_idUsuarioActual.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el usuario autenticado.')),
      );
      return;
    }

    final mascota = _buscarMascotaPorId(idMascota);
    if (mascota == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La mascota seleccionada no es válida.')),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final ahora = DateTime.now();
      final docRef = _firestoreService.citasRef.doc();
      final idCita = docRef.id;

      final data = <String, dynamic>{
        'id_cita': idCita,
        'id_usuario': _idUsuarioActual,
        'id_mascota': mascota.idMascota,
        'id_medico': (_idMedicoSeleccionado ?? '').trim().isEmpty
            ? null
            : _idMedicoSeleccionado,
        'nombre_mascota': mascota.nombreVisible,
        'especie_mascota': mascota.especieVisible,
        'motivo': motivo,
        'descripcion': _descripcionController.text.trim(),
        'estado': 'proxima',
        'fecha_hora': Timestamp.fromDate(fechaHora),
        'fecha_cita': DateFormat('yyyy-MM-dd').format(fechaHora),
        'hora_cita': DateFormat('HH:mm').format(fechaHora),
        'fecha_creacion': DateFormat('yyyy-MM-dd').format(ahora),
        'created_at': Timestamp.fromDate(ahora),
      };

      await docRef.set(data);

      if (!mounted) {
        return;
      }
      widget.onCitaCreada?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita creada correctamente.')),
      );
      _cerrarDialogoSeguro(true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo crear la cita.')),
      );
      setState(() {
        _guardando = false;
      });
    }
  }

  // Sección: cierre del popup
  // Cierra modal y ejecuta callback opcional para pantallas contenedoras.
  void _cerrar() {
    widget.onCerrar?.call();
    _cerrarDialogoSeguro(false);
  }

  // Sección: cierre seguro del diálogo
  // Evita hacer pop cuando ya no hay rutas disponibles en el Navigator.
  void _cerrarDialogoSeguro([bool? resultado]) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (!navigator.canPop()) {
      return;
    }
    navigator.pop(resultado);
  }

  // Sección: construcción principal
  // Mantiene el diseño de tarjeta y agrega estados de carga/guardado.
  @override
  Widget build(BuildContext context) {
    final alturaMaxima = MediaQuery.of(context).size.height * 0.82;

    // Sección: contenedor material del popup
    // Asegura un ancestro Material para Dropdown y widgets interactivos.
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: alturaMaxima),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFDCDDDB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1A95F7), width: 2),
        ),
        child: _cargandoDatos
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Registrar Cita',
                            style: TextStyle(
                              color: Color(0xFF223633),
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _cerrar,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Color(0xFF5E6A68),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const _EtiquetaCampo('Mascota registrada'),
                    DropdownButtonFormField<String>(
                      initialValue: _idMascotaSeleccionada,
                      validator: (value) => value == null ? '' : null,
                      isExpanded: true,
                      menuMaxHeight: 260,
                      decoration: _decoracionCampo('Seleccionar mascota'),
                      items: _mascotasDisponibles
                          .map(
                            (mascota) => DropdownMenuItem<String>(
                              value: mascota.idMascota,
                              child: Text(
                                '${mascota.nombreVisible} (${mascota.especieVisible})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: _mascotasDisponibles.isEmpty
                          ? null
                          : (value) {
                              setState(() {
                                _idMascotaSeleccionada = value;
                              });
                            },
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 2),
                      child: Text(
                        'Se muestran las mascotas asociadas a tu cuenta.',
                        style: TextStyle(
                          color: Color(0xFF6A7674),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _EtiquetaCampo('Fecha y hora de la cita'),
                    TextFormField(
                      controller: _fechaHoraController,
                      readOnly: true,
                      validator: _validadorRequerido,
                      decoration: _decoracionCampo('Seleccionar fecha y hora')
                          .copyWith(
                            suffixIcon: IconButton(
                              onPressed: _seleccionarFechaHora,
                              icon: const Icon(
                                Icons.event_available_outlined,
                                size: 20,
                              ),
                            ),
                          ),
                      onTap: _seleccionarFechaHora,
                    ),
                    const SizedBox(height: 10),
                    const _EtiquetaCampo('Motivo de la cita'),
                    DropdownButtonFormField<String>(
                      initialValue: _motivoSeleccionado,
                      validator: (value) => value == null ? '' : null,
                      isExpanded: true,
                      menuMaxHeight: 300,
                      decoration: _decoracionCampo('Seleccionar motivo'),
                      items: _motivosDisponibles
                          .map(
                            (motivo) => DropdownMenuItem<String>(
                              value: motivo,
                              child: Text(
                                motivo,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        setState(() {
                          _motivoSeleccionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    const _EtiquetaCampo('Médico asignado (opcional)'),
                    DropdownButtonFormField<String?>(
                      initialValue: _idMedicoSeleccionado,
                      isExpanded: true,
                      menuMaxHeight: 260,
                      decoration: _decoracionCampo('Seleccionar médico'),
                      items: [
                        // Sección: opción vacía de médico
                        // Permite crear la cita sin médico preferido (sin valor mock).
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Sin preferencia'),
                        ),
                        ..._medicosDisponibles.map(
                          (medico) => DropdownMenuItem<String?>(
                            value: medico.id,
                            child: Text(
                              medico.nombreVisible,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _idMedicoSeleccionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    const _EtiquetaCampo('Descripción de la cita'),
                    TextFormField(
                      controller: _descripcionController,
                      maxLines: 6,
                      minLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: _decoracionCampo(
                        'Describe con detalle lo que se evaluará o realizará.',
                      ).copyWith(alignLabelWithHint: true),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guardando ? null : _registrarCita,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColores.secundarioOscuro,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _guardando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.1,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Crear Cita',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Sección: helper de formato visible
  // Convierte DateTime en texto corto para el campo del formulario.
  String _formatearFechaHoraVisible(DateTime fechaHora) {
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
}

// Sección: etiqueta de campo reutilizable
// Estandariza el estilo visual de títulos de cada input.
class _EtiquetaCampo extends StatelessWidget {
  const _EtiquetaCampo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 5),
      child: Text(
        texto,
        style: const TextStyle(
          color: Color(0xFF4A5B58),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// Sección: modelo local de médico para dropdown
// Simplifica mapeo flexible de documentos de personal_medico.
class _MedicoItem {
  const _MedicoItem({
    required this.id,
    required this.nombre,
    required this.especialidad,
  });

  final String id;
  final String nombre;
  final String especialidad;

  // Sección: nombre visible de médico
  // Combina nombre y especialidad solo cuando hay especialidad cargada.
  String get nombreVisible {
    final especialidadLimpia = especialidad.trim();
    if (especialidadLimpia.isEmpty) {
      return nombre;
    }
    return '$nombre - $especialidadLimpia';
    }

  // Sección: fábrica robusta desde Firestore
  // Acepta variantes de campos para evitar fallos por esquema heterogéneo.
  factory _MedicoItem.fromMap(String idDocumento, Map<String, dynamic> map) {
    final id = _resolverString(map, const <String>[
      'id_medico',
      'id_personal',
      'id_usuario',
    ]);
    final nombre = _resolverString(map, const <String>[
      'nombre_completo',
      'nombre',
      'nombres',
    ]);
    final especialidad = _resolverString(map, const <String>[
      'especialidad',
      'area',
      'especializacion',
    ]);

    return _MedicoItem(
      id: id.isEmpty ? idDocumento : id,
      nombre: nombre,
      especialidad: especialidad,
    );
  }

  // Sección: helper de strings por prioridad
  // Recorre varias llaves posibles y devuelve la primera válida.
  static String _resolverString(
    Map<String, dynamic> map,
    List<String> llaves,
  ) {
    for (final llave in llaves) {
      final valor = map[llave];
      if (valor is String && valor.trim().isNotEmpty) {
        return valor.trim();
      }
    }
    return '';
  }
}
