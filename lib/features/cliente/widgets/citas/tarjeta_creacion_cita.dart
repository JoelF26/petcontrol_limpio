// Sección: imports
// Se importan utilidades visuales y servicios de dominio del proyecto.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/citas/creacion/formulario_creacion_cita_content.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/citas/creacion/medico_cita_item.dart';
import 'package:petcontrol_limpio/models/mascota.dart';
import 'package:petcontrol_limpio/services/auth_service.dart';
import 'package:petcontrol_limpio/services/catalogos_json_service.dart';
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
  final CatalogosJsonService _catalogosService = CatalogosJsonService();
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
  List<MedicoCitaItem> _todosMedicos = const <MedicoCitaItem>[];
  List<MedicoCitaItem> _medicosDisponibles = const <MedicoCitaItem>[];
  List<String> _motivosDisponibles = const <String>[];
  int _tokenConsultaDisponibilidad = 0;

  // Sección: estado de selección del formulario
  // Guarda las opciones elegidas por el usuario durante el registro.
  String? _idMascotaSeleccionada;
  String? _motivoSeleccionado;
  String? _idMedicoSeleccionado;
  DateTime? _fechaHoraSeleccionada;

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
          _medicosDisponibles = const <MedicoCitaItem>[];
          _cargandoDatos = false;
        });
        return;
      }

      final mascotasFuture = _mascotaService.obtenerMascotasPorUsuario(
        idUsuario,
      );
      final medicosFuture = _obtenerMedicosDisponibles();
      final motivosFuture = _catalogosService.obtenerMotivosCitaCliente();
      final resultados = await Future.wait<dynamic>([
        mascotasFuture,
        medicosFuture,
        motivosFuture,
      ]);
      final mascotas = resultados[0] as List<Mascota>;
      final medicos = resultados[1] as List<MedicoCitaItem>;
      final motivos = resultados[2] as List<String>;

      if (!mounted) {
        return;
      }
      setState(() {
        _idUsuarioActual = idUsuario;
        _mascotasDisponibles = mascotas;
        _todosMedicos = medicos;
        _medicosDisponibles = medicos;
        _motivosDisponibles = motivos;
        _cargandoDatos = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _idUsuarioActual = '';
        _mascotasDisponibles = const <Mascota>[];
        _todosMedicos = const <MedicoCitaItem>[];
        _medicosDisponibles = const <MedicoCitaItem>[];
        _motivosDisponibles = const <String>[];
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

    final idsDisponibles = await _citaService
        .obtenerIdsMedicosDisponiblesEnHorario(
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
  Future<List<MedicoCitaItem>> _obtenerMedicosDisponibles() async {
    final medicosActivos = await _personalMedicoService.obtenerMedicosActivos();
    final medicos = medicosActivos
        .map(
          (medico) => MedicoCitaItem(
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
        // Diferencia días pasados deshabilitados de fechas disponibles.
        datePickerTheme: DatePickerThemeData(
          backgroundColor: AppColores.baseFFE7ECF4,
          dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColores.transparente;
            }
            if (states.contains(WidgetState.selected)) {
              return AppColores.secundarioOscuro;
            }
            return null;
          }),
          dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColores.baseFF93A2B2.withValues(alpha: 0.42);
            }
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
  // Delega el formulario visual para mantener este archivo enfocado en estado y guardado.
  @override
  Widget build(BuildContext context) {
    return FormularioCreacionCitaContent(
      cargandoDatos: _cargandoDatos,
      guardando: _guardando,
      formKey: _formKey,
      fechaHoraController: _fechaHoraController,
      descripcionController: _descripcionController,
      mascotasDisponibles: _mascotasDisponibles,
      medicosDisponibles: _medicosDisponibles,
      motivosDisponibles: _motivosDisponibles,
      idMascotaSeleccionada: _idMascotaSeleccionada,
      motivoSeleccionado: _motivoSeleccionado,
      idMedicoSeleccionado: _idMedicoSeleccionado,
      fechaHoraSeleccionada: _fechaHoraSeleccionada,
      onCerrar: _cerrar,
      onSeleccionarFechaHora: _seleccionarFechaHora,
      onRegistrarCita: _registrarCita,
      onMascotaChanged: (value) {
        setState(() {
          _idMascotaSeleccionada = value;
        });
      },
      onMotivoChanged: (value) {
        setState(() {
          _motivoSeleccionado = value;
        });
      },
      onMedicoChanged: _onMedicoChanged,
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
