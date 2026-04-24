// Seccion: imports
// Se importan Material, modelos de dominio y servicio para editar citas.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/models/cita.dart';
import 'package:petcontrol_limpio/models/mascota.dart';
import 'package:petcontrol_limpio/models/personal_medico.dart';
import 'package:petcontrol_limpio/models/usuario.dart';
import 'package:petcontrol_limpio/services/cita_service.dart';

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
  final CitaService _citaService = CitaService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaHoraController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  static const List<String> _estadosDisponibles = <String>[
    'proxima',
    'pendiente',
    'confirmada',
    'cancelada',
    'reprogramada',
  ];

  String? _idMascotaSeleccionada;
  String _idMedicoSeleccionado = '';
  String? _estadoSeleccionado;
  DateTime? _fechaHoraSeleccionada;
  bool _modoEdicion = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _restaurarValoresOriginales();
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

  // Seccion: selector de fecha y hora
  // Permite actualizar programacion de la cita con calendarios nativos.
  Future<void> _seleccionarFechaHora() async {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final inicial = _fechaHoraSeleccionada ?? ahora;

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

  // Seccion: cierre seguro
  // Evita pop invalido y devuelve resultado opcional al llamador.
  void _cerrar(BuildContext context, [bool? resultado]) {
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

  // Seccion: contenedor base de campo
  // Reutiliza estilo del bloque para cada etiqueta y control.
  Widget _campoBase({required String etiqueta, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColores.baseFFE9EAEB,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
              color: AppColores.baseFF7A8088,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          child,
        ],
      ),
    );
  }

  // Seccion: build principal
  // Renderiza ficha completa y acciones de edicion/guardado.
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColores.transparente,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: AppColores.baseFFDCDDDE,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Seccion: encabezado
                // Muestra icono, titulo y boton de cierre.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColores.baseFFC6DACC,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: AppColores.baseFF2F7D68,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nombreMascotaVisible,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColores.baseFF1F2A35,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Detalle completo de la cita',
                            style: TextStyle(
                              color: AppColores.baseFF6B737E,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _cerrar(context),
                      splashRadius: 18,
                      icon: const Icon(
                        Icons.close,
                        color: AppColores.baseFF6B737E,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColores.baseFFCFE5DD,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _estadoSeleccionado ?? 'proxima',
                        style: const TextStyle(
                          color: AppColores.baseFF2D8A6C,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColores.baseFFCFE5DD,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.bloqueAgenda,
                        style: const TextStyle(
                          color: AppColores.baseFF2D8A6C,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Seccion: campos de ficha
                // Cambian a controles editables cuando el usuario activa edicion.
                _campoBase(
                  etiqueta: 'Mascota',
                  child: !_modoEdicion
                      ? Text(
                          _nombreMascotaVisible,
                          style: const TextStyle(
                            color: AppColores.baseFF1F2A35,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          initialValue: _idMascotaSeleccionada,
                          validator: (value) => value == null ? '' : null,
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: false,
                            fillColor: AppColores.transparente,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            errorStyle: TextStyle(height: 0.01, fontSize: 0),
                            contentPadding: EdgeInsets.zero,
                          ),
                          items: widget.mascotasDisponibles
                              .map(
                                (mascota) => DropdownMenuItem<String>(
                                  value: mascota.idMascota,
                                  child: Text(mascota.nombreVisible),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setState(() {
                              _idMascotaSeleccionada = value;
                            });
                          },
                        ),
                ),
                const SizedBox(height: 10),
                _campoBase(
                  etiqueta: 'Especie',
                  child: Text(
                    _especieVisible,
                    style: const TextStyle(
                      color: AppColores.baseFF1F2A35,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _campoBase(
                  etiqueta: 'Dueno',
                  child: Text(
                    _duenoVisible,
                    style: const TextStyle(
                      color: AppColores.baseFF1F2A35,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _campoBase(
                  etiqueta: 'Fecha y hora',
                  child: !_modoEdicion
                      ? Text(
                          _fechaHoraController.text.trim(),
                          style: const TextStyle(
                            color: AppColores.baseFF1F2A35,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : InkWell(
                          onTap: _seleccionarFechaHora,
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _fechaHoraController.text.trim().isEmpty
                                      ? 'Seleccionar fecha y hora'
                                      : _fechaHoraController.text.trim(),
                                  style: const TextStyle(
                                    color: AppColores.baseFF1F2A35,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: AppColores.baseFF34434A,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                _campoBase(
                  etiqueta: 'Estado',
                  child: !_modoEdicion
                      ? Text(
                          _estadoSeleccionado ?? 'proxima',
                          style: const TextStyle(
                            color: AppColores.baseFF1F2A35,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          initialValue: _estadoSeleccionado,
                          validator: (value) => value == null ? '' : null,
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: false,
                            fillColor: AppColores.transparente,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            errorStyle: TextStyle(height: 0.01, fontSize: 0),
                            contentPadding: EdgeInsets.zero,
                          ),
                          items: _estadosDisponibles
                              .map(
                                (estado) => DropdownMenuItem<String>(
                                  value: estado,
                                  child: Text(estado),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setState(() {
                              _estadoSeleccionado = value;
                            });
                          },
                        ),
                ),
                const SizedBox(height: 10),
                _campoBase(
                  etiqueta: 'Motivo',
                  child: TextFormField(
                    controller: _motivoController,
                    validator: _validarRequerido,
                    readOnly: !_modoEdicion,
                    maxLines: 1,
                    style: const TextStyle(
                      color: AppColores.baseFF1F2A35,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      filled: false,
                      fillColor: AppColores.transparente,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      errorStyle: TextStyle(height: 0.01, fontSize: 0),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _campoBase(
                  etiqueta: 'Descripcion',
                  child: TextFormField(
                    controller: _descripcionController,
                    readOnly: !_modoEdicion,
                    maxLines: 2,
                    style: const TextStyle(
                      color: AppColores.baseFF1F2A35,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      filled: false,
                      fillColor: AppColores.transparente,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      errorStyle: TextStyle(height: 0.01, fontSize: 0),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _campoBase(
                  etiqueta: 'Doctor',
                  child: !_modoEdicion
                      ? Text(
                          _medicoVisible,
                          style: const TextStyle(
                            color: AppColores.baseFF1F2A35,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          initialValue: _idMedicoSeleccionado,
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: false,
                            fillColor: AppColores.transparente,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            errorStyle: TextStyle(height: 0.01, fontSize: 0),
                            contentPadding: EdgeInsets.zero,
                          ),
                          items: <DropdownMenuItem<String>>[
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('Sin medico'),
                            ),
                            ...widget.medicosPorId.values.map(
                              (medico) => DropdownMenuItem<String>(
                                value: medico.idMedico,
                                child: Text(medico.nombreCompleto),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _idMedicoSeleccionado = (value ?? '').trim();
                            });
                          },
                        ),
                ),
                const SizedBox(height: 12),

                // Seccion: acciones inferiores
                // Muestra boton de editar o acciones de cancelar/guardar.
                if (!_modoEdicion)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _activarEdicion,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColores.baseFF1E6246,
                        foregroundColor: AppColores.blanco,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Editar informacion',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _guardando ? null : _cancelarEdicion,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColores.baseFF5A616A,
                            side: const BorderSide(
                              color: AppColores.baseFFA4ABB3,
                            ),
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _guardando ? null : _guardarCambios,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColores.baseFF1E6246,
                            foregroundColor: AppColores.blanco,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _guardando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColores.blanco,
                                  ),
                                )
                              : const Text(
                                  'Guardar cambios',
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
