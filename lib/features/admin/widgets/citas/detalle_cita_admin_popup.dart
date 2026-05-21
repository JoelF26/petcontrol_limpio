// Seccion: imports
// Se importan Material, modelos de dominio y servicio para editar citas.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/core/di/app_dependencies.dart';
import 'package:petcontrol_limpio/features/admin/widgets/citas/detalle_admin/detalle_cita_admin_content.dart';
import 'package:petcontrol_limpio/domain/entities/cita.dart';
import 'package:petcontrol_limpio/domain/entities/mascota.dart';
import 'package:petcontrol_limpio/domain/entities/personal_medico.dart';
import 'package:petcontrol_limpio/domain/entities/usuario.dart';
import 'package:petcontrol_limpio/application/services/catalogos_json_service.dart';
import 'package:petcontrol_limpio/application/services/cita_service.dart';

// Seccion: helper de apertura
// Muestra popup editable de cita admin y retorna true cuando se guardan cambios.
Future<bool> mostrarDetalleCitaAdmin(
  BuildContext context, {
  required Cita cita,
  required String bloqueAgenda,
  required List<Mascota> mascotasDisponibles,
  required Map<String, Usuario> usuariosPorId,
  required Map<String, PersonalMedico> medicosPorId,
}) async {
  // El resultado booleano permite a la pantalla recargar solo cuando hubo guardado.
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
            child: _DetalleCitaAdminPopup(
              cita: cita,
              bloqueAgenda: bloqueAgenda,
              mascotasDisponibles: mascotasDisponibles,
              usuariosPorId: usuariosPorId,
              medicosPorId: medicosPorId,
            ),
          ),
        ),
      );
    },
  );

  return actualizada == true;
}

// Seccion: popup de detalle de cita admin
// Conserva la ficha completa y habilita edicion al presionar el boton inferior.
class _DetalleCitaAdminPopup extends StatefulWidget {
  const _DetalleCitaAdminPopup({
    required this.cita,
    required this.bloqueAgenda,
    required this.mascotasDisponibles,
    required this.usuariosPorId,
    required this.medicosPorId,
  });

  final Cita cita;
  final String bloqueAgenda;
  final List<Mascota> mascotasDisponibles;
  final Map<String, Usuario> usuariosPorId;
  final Map<String, PersonalMedico> medicosPorId;

  @override
  State<_DetalleCitaAdminPopup> createState() => _DetalleCitaAdminPopupState();
}

// Seccion: estado del popup
// Gestiona edicion, validacion de campos y guardado en storage local.
class _DetalleCitaAdminPopupState extends State<_DetalleCitaAdminPopup> {
  // Seccion: dependencias y estado base
  // Mantiene controladores y flags de UI para modo lectura/edicion.
  final CitaService _citaService = AppDependencies.citaService;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaHoraController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final CatalogosJsonService _catalogosService =
      AppDependencies.catalogosJsonService;

  List<String> _estadosDisponibles = const <String>[];
  String? _idMascotaSeleccionada;
  String _idMedicoSeleccionado = '';
  String? _estadoSeleccionado;
  DateTime? _fechaHoraSeleccionada;
  bool _modoEdicion = false;
  bool _guardando = false;
  bool _confirmando = false;
  bool _cargandoCatalogos = true;

  @override
  void initState() {
    super.initState();
    _restaurarValoresOriginales();
    _cargarCatalogos();
  }

  @override
  void dispose() {
    _fechaHoraController.dispose();
    _motivoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  // Seccion: restauracion de formulario
  // Reinicia los campos a los valores actuales de la cita.
  void _restaurarValoresOriginales() {
    // Se usa tanto al abrir como al cancelar edición para descartar cambios temporales.
    _idMascotaSeleccionada = widget.cita.idMascota.trim().isEmpty
        ? null
        : widget.cita.idMascota;
    _idMedicoSeleccionado = widget.cita.idMedico.trim();
    _estadoSeleccionado = _normalizarEstado(widget.cita.estadoVisible);
    _fechaHoraSeleccionada = _resolverFechaHoraInicial(widget.cita);
    _fechaHoraController.text = _formatearFechaHoraVisible(
      _fechaHoraSeleccionada,
    );
    _motivoController.text = widget.cita.motivo.trim().isEmpty
        ? ''
        : widget.cita.motivo.trim();
    _descripcionController.text = widget.cita.descripcion.trim();
  }

  // Seccion: carga de catalogos
  // Lee los estados de cita desde JSON para el selector de edicion.
  Future<void> _cargarCatalogos() async {
    final estados = await _catalogosService.obtenerEstadosCita();
    if (!mounted) {
      return;
    }

    setState(() {
      _estadosDisponibles = estados;
      // Tras cargar catálogo, se revalida el estado porque antes no había opciones.
      _estadoSeleccionado = _normalizarEstado(widget.cita.estadoVisible);
      _cargandoCatalogos = false;
    });
  }

  // Seccion: normalizacion de estado
  // Garantiza que el valor inicial del dropdown exista en opciones.
  String _normalizarEstado(String estadoRaw) {
    final estado = estadoRaw.trim().toLowerCase();
    if (_estadosDisponibles.contains(estado)) {
      return estado;
    }
    return 'proxima';
  }

  // Seccion: resolucion de mascota seleccionada
  // Obtiene la mascota activa desde la lista de mascotas disponibles.
  Mascota? get _mascotaSeleccionada {
    final idMascota = (_idMascotaSeleccionada ?? '').trim();
    if (idMascota.isEmpty) {
      return null;
    }

    for (final mascota in widget.mascotasDisponibles) {
      if (mascota.idMascota == idMascota) {
        return mascota;
      }
    }
    return null;
  }

  // Seccion: valores visuales derivados
  // Genera textos visibles de especie, dueno y medico segun seleccion actual.
  String get _nombreMascotaVisible {
    return _mascotaSeleccionada?.nombreVisible ??
        widget.cita.nombreMascotaVisible;
  }

  String get _especieVisible {
    return _mascotaSeleccionada?.especieVisible ??
        widget.cita.especieMascotaVisible;
  }

  String get _duenoVisible {
    // Al cambiar mascota, también cambia el dueño visible de la cita.
    final idUsuario = _mascotaSeleccionada?.idUsuario.trim().isNotEmpty == true
        ? _mascotaSeleccionada!.idUsuario
        : widget.cita.idUsuario;
    final dueno = widget.usuariosPorId[idUsuario]?.nombreCompleto.trim() ?? '';
    return dueno.isEmpty ? 'Sin dueno' : dueno;
  }

  String get _medicoVisible {
    final idMedico = _idMedicoSeleccionado.trim();
    if (idMedico.isEmpty) {
      return 'Sin medico';
    }
    final medico = widget.medicosPorId[idMedico]?.nombreCompleto.trim() ?? '';
    return medico.isEmpty ? 'Sin medico' : medico;
  }

  // Seccion: validaciones basicas
  // Define reglas requeridas para campos editables.
  String? _validarRequerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }
    return null;
  }

  bool get _citaConfirmada {
    final estado = (_estadoSeleccionado ?? widget.cita.estadoVisible)
        .trim()
        .toLowerCase();
    return estado.contains('confirm');
  }

  // Seccion: selector de fecha y hora
  // Permite actualizar programacion de la cita con calendarios nativos.
  Future<void> _seleccionarFechaHora() async {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final inicial = _fechaHoraSeleccionada ?? ahora;

    // Fecha y hora se eligen por separado para construir el DateTime final.
    final fecha = await showDatePicker(
      context: context,
      initialDate: inicial.isBefore(hoy) ? hoy : inicial,
      firstDate: hoy,
      lastDate: DateTime(ahora.year + 3),
      helpText: 'Selecciona la fecha de la cita',
    );
    if (fecha == null || !mounted) {
      return;
    }

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(inicial),
      helpText: 'Selecciona la hora de la cita',
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

  // Seccion: activacion y cancelacion de edicion
  // Cambia entre modo lectura y formulario editable.
  void _activarEdicion() {
    setState(() {
      _modoEdicion = true;
    });
  }

  void _cancelarEdicion() {
    _restaurarValoresOriginales();
    setState(() {
      _modoEdicion = false;
    });
  }

  // Seccion: guardado de cambios
  // Persiste todos los campos editables de la cita en JSON local.
  Future<void> _guardarCambios() async {
    if (_guardando) {
      return;
    }

    final formularioValido = _formKey.currentState?.validate() == true;
    if (!formularioValido ||
        _idMascotaSeleccionada == null ||
        _estadoSeleccionado == null ||
        _fechaHoraSeleccionada == null) {
      setState(() {});
      return;
    }

    // La mascota seleccionada define dueño, nombre y especie persistidos en la cita.
    final mascota = _mascotaSeleccionada;
    if (mascota == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una mascota valida.')),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      await _citaService.actualizarCitaAdmin(
        idCita: widget.cita.idCita,
        idUsuario: mascota.idUsuario,
        idMascota: mascota.idMascota,
        idMedico: _idMedicoSeleccionado,
        nombreMascota: mascota.nombreVisible,
        especieMascota: mascota.especieVisible,
        motivo: _motivoController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        estado: _estadoSeleccionado!,
        fechaHora: _fechaHoraSeleccionada!,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informacion de la cita actualizada.')),
      );
      // true avisa a la pantalla de agenda que debe recargar sus datos.
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

  // Seccion: confirmacion directa
  // Actualiza solo el estado de la cita desde el detalle admin.
  Future<void> _confirmarCita() async {
    if (_confirmando || _citaConfirmada) {
      return;
    }

    setState(() {
      _confirmando = true;
    });

    try {
      await _citaService.confirmarCitaAdmin(cita: widget.cita);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cita confirmada.')));
      _cerrar(context, true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo confirmar la cita.')),
      );
      setState(() {
        _confirmando = false;
      });
    }
  }

  // Seccion: cierre seguro
  // Evita pop invalido y devuelve resultado opcional al llamador.
  void _cerrar(BuildContext context, [bool? resultado]) {
    // rootNavigator cierra el dialogo aunque la acción venga desde un widget interno.
    final navigator = Navigator.of(context, rootNavigator: true);
    if (!navigator.canPop()) {
      return;
    }
    navigator.pop(resultado);
  }

  // Seccion: formato de fecha para UI
  // Convierte DateTime a texto corto para el campo de fecha/hora.
  String _formatearFechaHoraVisible(DateTime? fechaHora) {
    if (fechaHora == null) {
      return widget.cita.fechaHoraVisible;
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

  // Seccion: fecha inicial
  // Toma fecha_hora si existe y usa now como respaldo.
  DateTime _resolverFechaHoraInicial(Cita cita) {
    return cita.fechaHora ?? DateTime.now();
  }

  // Seccion: build principal
  // Delega la ficha visual para mantener esta clase enfocada en estado y guardado.
  @override
  Widget build(BuildContext context) {
    return DetalleCitaAdminContent(
      formKey: _formKey,
      fechaHoraController: _fechaHoraController,
      motivoController: _motivoController,
      descripcionController: _descripcionController,
      bloqueAgenda: widget.bloqueAgenda,
      mascotasDisponibles: widget.mascotasDisponibles,
      medicosPorId: widget.medicosPorId,
      nombreMascotaVisible: _nombreMascotaVisible,
      especieVisible: _especieVisible,
      duenoVisible: _duenoVisible,
      medicoVisible: _medicoVisible,
      estadosDisponibles: _estadosDisponibles,
      idMascotaSeleccionada: _idMascotaSeleccionada,
      idMedicoSeleccionado: _idMedicoSeleccionado,
      estadoSeleccionado: _estadoSeleccionado,
      modoEdicion: _modoEdicion,
      guardando: _guardando,
      confirmando: _confirmando,
      cargandoCatalogos: _cargandoCatalogos,
      citaConfirmada: _citaConfirmada,
      validarRequerido: _validarRequerido,
      onCerrar: () => _cerrar(context),
      onSeleccionarFechaHora: _seleccionarFechaHora,
      onActivarEdicion: _activarEdicion,
      onConfirmarCita: _confirmarCita,
      onCancelarEdicion: _cancelarEdicion,
      onGuardarCambios: _guardarCambios,
      onMascotaChanged: (value) {
        setState(() {
          _idMascotaSeleccionada = value;
        });
      },
      onEstadoChanged: (value) {
        setState(() {
          _estadoSeleccionado = value;
        });
      },
      onMedicoChanged: (value) {
        setState(() {
          _idMedicoSeleccionado = (value ?? '').trim();
        });
      },
    );
  }
}
