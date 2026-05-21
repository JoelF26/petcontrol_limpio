// Sección: imports
// Se importan Material, colores, modelo Cita y servicio para actualizar JSON local.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/domain/constants/roles_usuario.dart';
import 'package:petcontrol_limpio/core/di/app_dependencies.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/citas/detalle_cliente/detalle_cita_cliente_content.dart';
import 'package:petcontrol_limpio/domain/entities/cita.dart';
import 'package:petcontrol_limpio/domain/entities/mascota.dart';
import 'package:petcontrol_limpio/domain/entities/personal_medico.dart';
import 'package:petcontrol_limpio/application/services/catalogos_json_service.dart';
import 'package:petcontrol_limpio/application/services/cita_service.dart';
import 'package:petcontrol_limpio/application/services/mascota_service.dart';
import 'package:petcontrol_limpio/application/services/personal_medico_service.dart';
import 'package:petcontrol_limpio/application/services/usuario_service.dart';

// Sección: helper de apertura de detalle
// Muestra el popup centrado y retorna true cuando se actualiza la cita.
Future<bool> mostrarDetalleCitaCliente(BuildContext context, Cita cita) async {
  // El popup devuelve true solo si editó o canceló la cita.
  final actualizada = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColores.negro.withValues(alpha: 0.55),
    builder: (context) {
      final teclado = MediaQuery.of(context).viewInsets;
      return AnimatedPadding(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOut,
        padding: EdgeInsets.fromLTRB(12, 16, 12, 16 + teclado.bottom),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: _DetalleCitaClientePopup(cita: cita),
          ),
        ),
      );
    },
  );
  return actualizada == true;
}

// Sección: popup de detalle de cita
// Renderiza la información completa de la cita y permite edición por botón.
class _DetalleCitaClientePopup extends StatefulWidget {
  const _DetalleCitaClientePopup({required this.cita});

  final Cita cita;

  @override
  State<_DetalleCitaClientePopup> createState() =>
      _DetalleCitaClientePopupState();
}

// Sección: estado del popup de cita
// Gestiona controladores, validación, selección de fecha/hora y guardado.
class _DetalleCitaClientePopupState extends State<_DetalleCitaClientePopup> {
  // Sección: dependencias y formulario
  // Se prepara el servicio para persistir cambios y validar datos.
  final CatalogosJsonService _catalogosService =
      AppDependencies.catalogosJsonService;
  final CitaService _citaService = AppDependencies.citaService;
  final MascotaService _mascotaService = AppDependencies.mascotaService;
  final PersonalMedicoService _personalMedicoService =
      AppDependencies.personalMedicoService;
  final UsuarioService _usuarioService = AppDependencies.usuarioService;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreMascotaController =
      TextEditingController();
  final TextEditingController _especieController = TextEditingController();
  final TextEditingController _fechaHoraController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  // Sección: estado visual y de guardado
  // Controla el modo edición y evita envíos duplicados.
  bool _modoEdicion = false;
  bool _guardando = false;
  bool _cancelandoCita = false;
  DateTime? _fechaHoraSeleccionada;
  bool _cargandoMascotas = true;
  bool _cargandoMedicos = true;
  bool _cargandoMotivos = true;
  List<Mascota>? _mascotasDisponibles;
  List<PersonalMedico> _medicosDisponibles = const <PersonalMedico>[];
  List<String> _motivosDisponibles = const <String>[];
  PersonalMedico? _medicoSeleccionado;
  String? _idMascotaSeleccionada;
  String _idMedicoSeleccionado = '';

  // Sección: inicialización de datos
  // Carga datos de la cita en controladores para lectura y edición.
  @override
  void initState() {
    super.initState();
    _mascotasDisponibles = const <Mascota>[];
    _resetearControladores();
    _cargarMascotas();
    _cargarMedicos();
    _cargarMotivos();
  }

  // Sección: liberación de recursos
  // Evita fugas de memoria al cerrar el popup.
  @override
  void dispose() {
    _nombreMascotaController.dispose();
    _especieController.dispose();
    _fechaHoraController.dispose();
    _motivoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  // Sección: reset de campos
  // Restablece los valores originales de la cita.
  void _resetearControladores() {
    // También se usa al cancelar edición para volver a la cita original.
    _idMascotaSeleccionada = widget.cita.idMascota.trim().isEmpty
        ? null
        : widget.cita.idMascota;
    _idMedicoSeleccionado = widget.cita.idMedico.trim();
    _nombreMascotaController.text = widget.cita.nombreMascotaVisible;
    _especieController.text = widget.cita.especieMascotaVisible;
    _motivoController.text = widget.cita.motivoVisible;
    _descripcionController.text =
        widget.cita.descripcionVisible == 'Sin descripción'
        ? ''
        : widget.cita.descripcionVisible;
    _fechaHoraSeleccionada = _resolverFechaHoraInicial(widget.cita);
    _fechaHoraController.text = _formatearFechaHoraVisible(
      _fechaHoraSeleccionada,
      fallbackFecha: widget.cita.fechaTexto.trim(),
      fallbackHora: widget.cita.horaTexto.trim(),
    );
  }

  // Sección: carga de mascotas disponibles
  // Consulta mascotas del usuario para permitir seleccionar otra en edición.
  Future<void> _cargarMascotas() async {
    final idUsuario = widget.cita.idUsuario.trim();
    if (idUsuario.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _mascotasDisponibles = const <Mascota>[];
        _cargandoMascotas = false;
      });
      return;
    }

    try {
      final mascotas = await _mascotaService.obtenerMascotasPorUsuario(
        idUsuario,
      );
      if (!mounted) {
        return;
      }

      // Si la cita antigua no tiene id de mascota, intenta inferirlo por nombre.
      String? idSeleccionado = _idMascotaSeleccionada;
      if ((idSeleccionado ?? '').isEmpty) {
        for (final mascota in mascotas) {
          if (mascota.nombreVisible.toLowerCase() ==
              widget.cita.nombreMascotaVisible.toLowerCase()) {
            idSeleccionado = mascota.idMascota;
            break;
          }
        }
      }

      final mascotaSeleccionada = _buscarMascotaPorIdEnLista(
        mascotas,
        idSeleccionado,
      );

      setState(() {
        _mascotasDisponibles = mascotas;
        _cargandoMascotas = false;
        _idMascotaSeleccionada = idSeleccionado;
        if (mascotaSeleccionada != null) {
          _nombreMascotaController.text = mascotaSeleccionada.nombreVisible;
          _especieController.text = mascotaSeleccionada.especieVisible;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _mascotasDisponibles = const <Mascota>[];
        _cargandoMascotas = false;
      });
    }
  }

  // Sección: búsqueda local por id
  // Recupera la mascota seleccionada para sincronizar nombre/especie.
  Mascota? _buscarMascotaPorId(String? idMascota) {
    return _buscarMascotaPorIdEnLista(
      _mascotasDisponibles ?? const <Mascota>[],
      idMascota,
    );
  }

  // Sección: helper de búsqueda en lista
  // Permite reutilizar la lógica durante carga inicial y edición.
  Mascota? _buscarMascotaPorIdEnLista(
    List<Mascota> mascotas,
    String? idMascota,
  ) {
    final idLimpio = (idMascota ?? '').trim();
    if (idLimpio.isEmpty) {
      return null;
    }
    for (final mascota in mascotas) {
      if (mascota.idMascota == idLimpio) {
        return mascota;
      }
    }
    return null;
  }

  // Sección: fecha inicial de edición
  // Intenta usar fecha_hora o combina fecha/hora textual como respaldo.
  DateTime? _resolverFechaHoraInicial(Cita cita) {
    if (cita.fechaHora != null) {
      return cita.fechaHora;
    }
    final fecha = cita.fechaTexto.trim();
    final hora = cita.horaTexto.trim();
    if (fecha.isEmpty) {
      return null;
    }
    // Este respaldo cubre registros antiguos con fecha y hora guardadas por separado.
    final fechaBase = DateTime.tryParse(fecha);
    if (fechaBase == null) {
      return null;
    }
    final matchHora = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(hora);
    final horas = int.tryParse(matchHora?.group(1) ?? '');
    final minutos = int.tryParse(matchHora?.group(2) ?? '');
    if (horas == null || minutos == null) {
      return DateTime(fechaBase.year, fechaBase.month, fechaBase.day);
    }
    return DateTime(
      fechaBase.year,
      fechaBase.month,
      fechaBase.day,
      horas,
      minutos,
    );
  }

  // Sección: activación y cancelación de edición
  // Habilita edición bajo demanda y permite volver a lectura.
  void _activarEdicion() {
    setState(() {
      _modoEdicion = true;
    });
  }

  void _cancelarEdicion() {
    _resetearControladores();
    setState(() {
      _modoEdicion = false;
    });
  }

  // Sección: selector de fecha y hora
  // Permite ajustar programación de la cita desde calendarios nativos.
  Future<void> _seleccionarFechaHora() async {
    final ahora = DateTime.now();
    final inicial = _fechaHoraSeleccionada ?? ahora;
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    // Fecha y hora se seleccionan por separado y luego se combinan.
    final fecha = await showDatePicker(
      context: context,
      initialDate: inicial.isBefore(hoy) ? hoy : inicial,
      firstDate: hoy,
      lastDate: DateTime(ahora.year + 3),
      helpText: 'Selecciona la fecha de la cita',
      builder: (context, child) => _aplicarTemaAzulSelector(context, child),
    );
    if (fecha == null || !mounted) {
      return;
    }

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(inicial),
      helpText: 'Selecciona la hora de la cita',
      builder: (context, child) => _aplicarTemaAzulSelector(context, child),
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
    setState(() {
      _fechaHoraSeleccionada = fechaHora;
      _fechaHoraController.text = _formatearFechaHoraVisible(fechaHora);
    });
  }

  // Sección: tema azul de selectores
  // Mantiene coherencia visual con el resto de popups de cita.
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
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }

  // Sección: guardado de cambios
  // Persiste los datos editados en JSON local y cierra con resultado exitoso.
  Future<void> _guardarCambios() async {
    if (_guardando) {
      return;
    }
    final valido = _formKey.currentState?.validate() == true;
    if (!valido) {
      return;
    }

    final fechaHora = _fechaHoraSeleccionada;
    if (fechaHora == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha y hora de la cita.')),
      );
      return;
    }

    // Guarda nombre/especie desde la mascota actual para evitar textos desactualizados.
    final mascotaSeleccionada = _buscarMascotaPorId(_idMascotaSeleccionada);
    if (mascotaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una mascota válida.')),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      await _citaService.actualizarCitaCliente(
        idCita: widget.cita.idCita,
        idMascota: mascotaSeleccionada.idMascota,
        nombreMascota: mascotaSeleccionada.nombreVisible,
        especieMascota: mascotaSeleccionada.especieVisible,
        motivo: _motivoController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        fechaHora: fechaHora,
        idMedico: _idMedicoSeleccionado,
      );

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Información de la cita actualizada.')),
      );
      // true indica a la pantalla contenedora que debe recargar la agenda.
      _cerrar(context, true);
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
        const SnackBar(content: Text('No se pudo actualizar la cita.')),
      );
      setState(() {
        _guardando = false;
      });
    }
  }

  // Sección: carga de médicos disponibles
  // Lista personal médico asociado a usuarios con rol admin.
  Future<void> _cargarMedicos() async {
    try {
      // Cruza personal médico con usuarios admin para mostrar solo médicos válidos.
      final resultados = await Future.wait<dynamic>([
        _personalMedicoService.obtenerPersonalMedico(),
        _usuarioService.obtenerUsuarios(),
      ]);
      if (!mounted) {
        return;
      }

      final personal = resultados[0] as List<PersonalMedico>;
      final usuarios = resultados[1];
      final correosAdmin = <String>{
        for (final usuario in usuarios)
          if (usuario.rol == RolesUsuario.admin)
            usuario.correo.trim().toLowerCase(),
      };
      final medicos =
          personal
              .where(
                (medico) =>
                    correosAdmin.contains(medico.correo.trim().toLowerCase()),
              )
              .toList(growable: false)
            ..sort(
              (a, b) => a.nombreCompleto.toLowerCase().compareTo(
                b.nombreCompleto.toLowerCase(),
              ),
            );

      setState(() {
        _medicosDisponibles = medicos;
        _medicoSeleccionado = _buscarMedicoPorId(
          _idMedicoSeleccionado,
          medicos,
        );
        _cargandoMedicos = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _medicosDisponibles = const <PersonalMedico>[];
        _medicoSeleccionado = null;
        _cargandoMedicos = false;
      });
    }
  }

  // Sección: búsqueda local de médico
  // Resuelve un médico dentro de una lista ya cargada.
  PersonalMedico? _buscarMedicoPorId(
    String idMedico,
    List<PersonalMedico> medicos,
  ) {
    final idLimpio = idMedico.trim();
    if (idLimpio.isEmpty) {
      return null;
    }

    for (final medico in medicos) {
      if (medico.idMedico == idLimpio) {
        return medico;
      }
    }
    return null;
  }

  // Sección: carga de motivos
  // Lee las opciones del selector desde catalogos.json.
  Future<void> _cargarMotivos() async {
    final motivos = await _catalogosService.obtenerMotivosCitaCliente();
    if (!mounted) {
      return;
    }

    setState(() {
      _motivosDisponibles = motivos;
      _cargandoMotivos = false;
    });
  }

  // Sección: confirmación de cancelación
  // Solicita confirmación explícita antes de cambiar el estado a cancelada.
  Future<bool> _confirmarCancelacion() async {
    // Se separa la confirmación del guardado para no cancelar por toque accidental.
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar cita'),
          content: const Text('¿De verdad deseas cancelar esta cita?'),
          actions: [
            // Botón: cierra la confirmación y mantiene la cita activa.
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Volver'),
            ),
            // Botón: confirma la cancelación definitiva de la cita.
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColores.baseFFB53939,
                foregroundColor: AppColores.blanco,
              ),
              child: const Text('Sí, cancelar'),
            ),
          ],
        );
      },
    );

    return confirmar == true;
  }

  // Sección: cancelación de cita
  // Marca la cita como cancelada y cierra el popup para refrescar el listado.
  Future<void> _cancelarCita() async {
    if (_cancelandoCita || _guardando) {
      return;
    }

    final confirmada = await _confirmarCancelacion();
    if (!confirmada || !mounted) {
      return;
    }

    setState(() {
      _cancelandoCita = true;
    });

    try {
      await _citaService.cancelarCitaCliente(
        idCita: widget.cita.idCita,
        idUsuario: widget.cita.idUsuario,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita cancelada correctamente.')),
      );
      // La cancelación cambia el estado en storage, por eso se fuerza recarga externa.
      _cerrar(context, true);
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
        const SnackBar(content: Text('No se pudo cancelar la cita.')),
      );
      setState(() {
        _cancelandoCita = false;
      });
    }
  }

  // Sección: formato visual de fecha/hora
  // Convierte DateTime a texto corto y usa fallback si no hay fecha parseada.
  String _formatearFechaHoraVisible(
    DateTime? fechaHora, {
    String fallbackFecha = '',
    String fallbackHora = '',
  }) {
    if (fechaHora == null) {
      final fecha = fallbackFecha.trim();
      final hora = fallbackHora.trim();
      if (fecha.isEmpty && hora.isEmpty) {
        return 'Fecha por definir';
      }
      if (fecha.isNotEmpty && hora.isNotEmpty) {
        return '$fecha - $hora';
      }
      return fecha.isNotEmpty ? fecha : hora;
    }

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

  // Sección: cierre seguro
  // Evita pop inválido y retorna resultado opcional al llamador.
  void _cerrar(BuildContext context, [bool? resultado]) {
    // rootNavigator evita que un contexto interno cierre una ruta equivocada.
    final navigator = Navigator.of(context, rootNavigator: true);
    if (!navigator.canPop()) {
      return;
    }
    navigator.pop(resultado);
  }

  // Sección: construcción del popup
  // Delega la UI para mantener este archivo enfocado en datos y persistencia.
  @override
  Widget build(BuildContext context) {
    return DetalleCitaClienteContent(
      formKey: _formKey,
      nombreMascotaController: _nombreMascotaController,
      especieController: _especieController,
      fechaHoraController: _fechaHoraController,
      motivoController: _motivoController,
      descripcionController: _descripcionController,
      modoEdicion: _modoEdicion,
      guardando: _guardando,
      cancelandoCita: _cancelandoCita,
      cargandoMascotas: _cargandoMascotas,
      cargandoMedicos: _cargandoMedicos,
      cargandoMotivos: _cargandoMotivos,
      mascotasDisponibles: _mascotasDisponibles,
      medicosDisponibles: _medicosDisponibles,
      motivosDisponibles: _motivosDisponibles,
      idMascotaSeleccionada: _idMascotaSeleccionada,
      idMedicoSeleccionado: _idMedicoSeleccionado,
      medicoSeleccionado: _medicoSeleccionado,
      onCerrar: () => _cerrar(context),
      onActivarEdicion: _activarEdicion,
      onCancelarCita: _cancelarCita,
      onCancelarEdicion: _cancelarEdicion,
      onGuardarCambios: _guardarCambios,
      onSeleccionarFechaHora: _seleccionarFechaHora,
      onMascotaChanged: (idSeleccionado) {
        final mascota = _buscarMascotaPorId(idSeleccionado);
        setState(() {
          _idMascotaSeleccionada = idSeleccionado;
          if (mascota != null) {
            _nombreMascotaController.text = mascota.nombreVisible;
            _especieController.text = mascota.especieVisible;
          }
        });
      },
      onMedicoChanged: (idMedico) {
        final idLimpio = idMedico.trim();
        setState(() {
          _idMedicoSeleccionado = idLimpio;
          _medicoSeleccionado = _buscarMedicoPorId(
            idLimpio,
            _medicosDisponibles,
          );
        });
      },
      onMotivoChanged: (motivo) {
        setState(() {
          _motivoController.text = motivo;
        });
      },
    );
  }
}
