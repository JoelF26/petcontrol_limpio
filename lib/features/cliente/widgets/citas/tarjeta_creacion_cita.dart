// Sección: imports
// Se importan utilidades visuales y servicios de dominio del proyecto.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/models/mascota.dart';
import 'package:petcontrol_limpio/services/auth_service.dart';
import 'package:petcontrol_limpio/services/cita_service.dart';
import 'package:petcontrol_limpio/services/personal_medico_service.dart';
import 'package:petcontrol_limpio/services/mascota_service.dart';

// Sección: tarjeta de creación de cita
// Renderiza el formulario popup para registrar citas del cliente en JSON local.
class TarjetaCreacionCita extends StatefulWidget {
  const TarjetaCreacionCita({super.key, this.onCerrar, this.onCitaCreada});

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
  // Encapsulan acceso a sesión, mascotas, médicos y persistencia de citas.
  final AuthService _authService = AuthService();
  final MascotaService _mascotaService = MascotaService();
  final CitaService _citaService = CitaService();
  final PersonalMedicoService _personalMedicoService = PersonalMedicoService();

  // Sección: estado de carga y guardado
  // Controla loaders del popup para evitar acciones duplicadas.
  bool _cargandoDatos = true;
  bool _guardando = false;

  // Sección: estado de usuario y listas dinámicas
  // Almacena id usuario, mascotas asociadas y médicos disponibles.
  String _idUsuarioActual = '';
  List<Mascota> _mascotasDisponibles = const <Mascota>[];
  List<_MedicoItem> _todosMedicos = const <_MedicoItem>[];
  List<_MedicoItem> _medicosDisponibles = const <_MedicoItem>[];
  int _tokenConsultaDisponibilidad = 0;

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

      final mascotasFuture = _mascotaService.obtenerMascotasPorUsuario(
        idUsuario,
      );
      final medicosFuture = _obtenerMedicosDisponibles();
      final mascotas = await mascotasFuture;
      final medicos = await medicosFuture;

      if (!mounted) {
        return;
      }
      setState(() {
        _idUsuarioActual = idUsuario;
        _mascotasDisponibles = mascotas;
        _todosMedicos = medicos;
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
        _todosMedicos = const <_MedicoItem>[];
        _medicosDisponibles = const <_MedicoItem>[];
        _cargandoDatos = false;
      });
    }
  }

  // Sección: filtrado dinámico de médicos por horario
  // Si ya hay fecha/hora, sólo deja visibles los médicos libres en ese minuto.
  Future<void> _actualizarDisponibilidadMedicos(DateTime fechaHora) async {
    final token = ++_tokenConsultaDisponibilidad;
    final idsMedicos = _todosMedicos
        .map((medico) => medico.id.trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    final idsDisponibles = await _citaService.obtenerIdsMedicosDisponiblesEnHorario(
      fechaHora: fechaHora,
      idsMedico: idsMedicos,
    );

    if (!mounted || token != _tokenConsultaDisponibilidad) {
      return;
    }

    final idsDisponiblesSet = idsDisponibles.toSet();
    final medicosFiltrados = _todosMedicos
        .where((medico) => idsDisponiblesSet.contains(medico.id))
        .toList(growable: false);

    final idMedicoActual = (_idMedicoSeleccionado ?? '').trim();
    final medicoSigueDisponible =
        idMedicoActual.isEmpty || idsDisponiblesSet.contains(idMedicoActual);

    setState(() {
      _medicosDisponibles = medicosFiltrados;
      if (!medicoSigueDisponible) {
        _idMedicoSeleccionado = null;
      }
    });

    if (!medicoSigueDisponible && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El médico seleccionado está ocupado en ese horario. Elige otro médico u hora.',
          ),
        ),
      );
    }
  }

  // Sección: selección de médico
  // Valida disponibilidad cuando ya existe fecha/hora elegida.
  Future<void> _onMedicoChanged(String? value) async {
    final idMedico = (value ?? '').trim();
    if (idMedico.isEmpty) {
      setState(() {
        _idMedicoSeleccionado = null;
      });
      return;
    }

    final fechaHora = _fechaHoraSeleccionada;
    if (fechaHora == null) {
      setState(() {
        _idMedicoSeleccionado = idMedico;
      });
      return;
    }

    final disponible = await _citaService.estaMedicoDisponibleEnHorario(
      idMedico: idMedico,
      fechaHora: fechaHora,
    );

    if (!mounted) {
      return;
    }

    if (!disponible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ese médico ya tiene una cita en la hora seleccionada.',
          ),
        ),
      );
      await _actualizarDisponibilidadMedicos(fechaHora);
      return;
    }

    setState(() {
      _idMedicoSeleccionado = idMedico;
    });
  }

  // Sección: consulta de personal médico
  // Lee personal médico activo y normaliza id/nombre para el dropdown.
  Future<List<_MedicoItem>> _obtenerMedicosDisponibles() async {
    final medicosActivos = await _personalMedicoService.obtenerMedicosActivos();
    final medicos = medicosActivos
        .map(
          (medico) => _MedicoItem(
            id: medico.idMedico,
            nombre: medico.nombreCompleto,
            especialidad: medico.especialidad,
          ),
        )
        .where((medico) => medico.id.isNotEmpty && medico.nombre.isNotEmpty)
        .toList(growable: false);

    final ordenados = medicos.toList()
      ..sort(
        (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
      );
    return ordenados;
  }

  // Sección: resolver id de usuario para consultas
  // Usa id del perfil persistido en sesión local.
  String _resolverIdUsuario(String? idPerfil) {
    return (idPerfil ?? '').trim();
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
        color: AppColores.baseFF6E7A78,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppColores.baseFFE8EBEA,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColores.baseFFCDD4D1,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColores.baseFF5ABF9A,
          width: 1.7,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColores.baseFFB53939,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColores.baseFFB53939,
          width: 1.7,
        ),
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

    final idMedicoSeleccionado = (_idMedicoSeleccionado ?? '').trim();
    if (idMedicoSeleccionado.isNotEmpty) {
      final medicoDisponible = await _citaService.estaMedicoDisponibleEnHorario(
        idMedico: idMedicoSeleccionado,
        fechaHora: fechaHora,
      );
      if (!medicoDisponible) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La hora seleccionada ya está ocupada para ese médico. Elige otra hora.',
            ),
          ),
        );
        return;
      }
    }

    setState(() {
      _fechaHoraSeleccionada = fechaHora;
      _fechaHoraController.text = _formatearFechaHoraVisible(fechaHora);
    });
    await _actualizarDisponibilidadMedicos(fechaHora);
  }

  // Sección: tema azul para calendario y reloj
  // Uniforma la apariencia de los selectores de fecha/hora con la identidad azul.
  Widget _aplicarTemaAzulSelector(BuildContext context, Widget? child) {
    final base = Theme.of(context);
    final colorScheme = base.colorScheme.copyWith(
      primary: AppColores.secundarioOscuro,
      onPrimary: AppColores.blanco,
      secondary: AppColores.secundario,
    );

    return Theme(
      data: base.copyWith(
        colorScheme: colorScheme,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColores.secundarioOscuro,
          ),
        ),
        // Sección: tema de días del calendario
        // Mantiene estilo azul y fuerza el número en blanco cuando el día está seleccionado.
        datePickerTheme: DatePickerThemeData(
          backgroundColor: AppColores.baseFFE7ECF4,
          dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColores.secundarioOscuro;
            }
            return null;
          }),
          dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColores.blanco;
            }
            return AppColores.baseFF1F2B3B;
          }),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: AppColores.baseFFE7ECF4,
          dialHandColor: AppColores.secundarioOscuro,
          dialBackgroundColor: AppColores.baseFFD7E4F5,
          hourMinuteTextColor: AppColores.baseFF1F2B3B,
          hourMinuteColor: AppColores.baseFFD7E4F5,
          dayPeriodTextColor: AppColores.baseFF1F2B3B,
          dayPeriodColor: AppColores.baseFFD7E4F5,
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

  // Sección: guardado de cita en JSON local
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
      await _citaService.crearCitaCliente(
        idUsuario: _idUsuarioActual,
        mascota: mascota,
        motivo: motivo,
        descripcion: _descripcionController.text.trim(),
        fechaHora: fechaHora,
        idMedico: _idMedicoSeleccionado,
      );

      if (!mounted) {
        return;
      }
      widget.onCitaCreada?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita creada correctamente.')),
      );
      _cerrarDialogoSeguro(true);
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message.toString())));
      setState(() {
        _guardando = false;
      });
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
      color: AppColores.transparente,
      child: Container(
        constraints: BoxConstraints(maxHeight: alturaMaxima),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: AppColores.baseFFDCDDDB,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColores.baseFF1A95F7, width: 2),
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
                                color: AppColores.baseFF223633,
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
                                color: AppColores.baseFF5E6A68,
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
                            color: AppColores.baseFF6A7674,
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
                          _onMedicoChanged(value);
                        },
                      ),
                      if (_fechaHoraSeleccionada != null &&
                          _medicosDisponibles.isEmpty) ...[
                        const SizedBox(height: 4),
                        const Padding(
                          padding: EdgeInsets.only(left: 2),
                          child: Text(
                            'No hay médicos disponibles en esa hora. Puedes elegir otra hora o dejar sin preferencia.',
                            style: TextStyle(
                              color: AppColores.baseFF7F3A3A,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
                            foregroundColor: AppColores.blanco,
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
                                    color: AppColores.blanco,
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
          color: AppColores.baseFF4A5B58,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// Sección: modelo local de médico para dropdown
// Simplifica renderizado de personal médico en el formulario.
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
}
