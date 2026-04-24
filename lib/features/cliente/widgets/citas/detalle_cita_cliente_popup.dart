// Sección: imports
// Se importan Material, colores, modelo Cita y servicio para actualizar JSON local.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/models/cita.dart';
import 'package:petcontrol_limpio/models/mascota.dart';
import 'package:petcontrol_limpio/services/cita_service.dart';
import 'package:petcontrol_limpio/services/mascota_service.dart';

// Sección: helper de apertura de detalle
// Muestra el popup centrado y retorna true cuando se actualiza la cita.
Future<bool> mostrarDetalleCitaCliente(BuildContext context, Cita cita) async {
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
  final CitaService _citaService = CitaService();
  final MascotaService _mascotaService = MascotaService();
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
  List<Mascota>? _mascotasDisponibles;
  String? _idMascotaSeleccionada;

  // Sección: inicialización de datos
  // Carga datos de la cita en controladores para lectura y edición.
  @override
  void initState() {
    super.initState();
    _mascotasDisponibles = const <Mascota>[];
    _resetearControladores();
    _cargarMascotas();
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
    _idMascotaSeleccionada = widget.cita.idMascota.trim().isEmpty
        ? null
        : widget.cita.idMascota;
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

  // Sección: validaciones básicas
  // Asegura que los campos obligatorios se completen antes de guardar.
  String? _validarRequerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }
    return null;
  }

  // Sección: selector de fecha y hora
  // Permite ajustar programación de la cita desde calendarios nativos.
  Future<void> _seleccionarFechaHora() async {
    final ahora = DateTime.now();
    final inicial = _fechaHoraSeleccionada ?? ahora;
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

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
      );

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Información de la cita actualizada.')),
      );
      _cerrar(context, true);
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

  // Sección: confirmación de cancelación
  // Solicita confirmación explícita antes de cambiar el estado a cancelada.
  Future<bool> _confirmarCancelacion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar cita'),
          content: const Text(
            '¿De verdad deseas cancelar esta cita?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Volver'),
            ),
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
    final navigator = Navigator.of(context, rootNavigator: true);
    if (!navigator.canPop()) {
      return;
    }
    navigator.pop(resultado);
  }

  // Sección: construcción del popup
  // Mantiene ficha en modo lectura y habilita edición sólo con botón.
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
                // Sección: encabezado del popup
                // Muestra icono, título y botón de cierre.
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
                            _nombreMascotaController.text.trim().isEmpty
                                ? 'Detalle de cita'
                                : _nombreMascotaController.text.trim(),
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
                            'Ficha completa de la cita',
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

                // Sección: campos de la cita
                // Muestran solo lectura y se vuelven editables al activar edición.
                _campoMascotaSeleccion(),
                const SizedBox(height: 10),
                _campoEspecieSoloLectura(),
                const SizedBox(height: 10),
                _campoFechaHora(),
                const SizedBox(height: 10),
                _campoFicha(
                  etiqueta: 'Motivo',
                  controller: _motivoController,
                  habilitado: _modoEdicion,
                  validator: _validarRequerido,
                ),
                const SizedBox(height: 10),
                _campoFicha(
                  etiqueta: 'Descripción',
                  controller: _descripcionController,
                  habilitado: _modoEdicion,
                  minLines: 2,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),

                // Sección: acciones inferiores
                // Muestra editar o cancelar/guardar según modo actual.
                if (!_modoEdicion)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _cancelandoCita ? null : _activarEdicion,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColores.baseFF143B5F,
                            foregroundColor: AppColores.blanco,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Editar información',
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancelandoCita ? null : _cancelarCita,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColores.baseFFB53939,
                            side: const BorderSide(
                              color: AppColores.baseFFB53939,
                            ),
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _cancelandoCita
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColores.baseFFB53939,
                                  ),
                                )
                              : const Text(
                                  'Cancelar cita',
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
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
                            backgroundColor: AppColores.baseFF143B5F,
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

  // Sección: campo visual reutilizable
  // Mantiene bloque de ficha y alterna entre texto o input según modo edición.
  Widget _campoMascotaSeleccion() {
    final mascotas = _mascotasDisponibles ?? const <Mascota>[];
    final existeSeleccion = mascotas.any(
      (mascota) => mascota.idMascota == _idMascotaSeleccionada,
    );
    final valorSeleccionado = existeSeleccion ? _idMascotaSeleccionada : null;

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
          const Text(
            'Mascota',
            style: TextStyle(
              color: AppColores.baseFF7A8088,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          if (!_modoEdicion)
            Text(
              _nombreMascotaController.text.trim().isEmpty
                  ? '-'
                  : _nombreMascotaController.text.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColores.baseFF1F2A35,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            )
          else if (_cargandoMascotas)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: valorSeleccionado,
              isExpanded: true,
              icon: const Icon(
                Icons.expand_more_rounded,
                color: AppColores.baseFF5F6772,
                size: 20,
              ),
              dropdownColor: AppColores.baseFFE9EAEB,
              style: const TextStyle(
                color: AppColores.baseFF1F2A35,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
                fillColor: AppColores.transparente,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
              hint: const Text(
                'Seleccionar mascota',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColores.baseFF6B737E,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
              items: mascotas
                  .map(
                    (mascota) => DropdownMenuItem<String>(
                      value: mascota.idMascota,
                      child: Text(
                        mascota.nombreVisible,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (idSeleccionado) {
                if (idSeleccionado == null) {
                  return;
                }
                final mascota = _buscarMascotaPorId(idSeleccionado);
                setState(() {
                  _idMascotaSeleccionada = idSeleccionado;
                  if (mascota != null) {
                    _nombreMascotaController.text = mascota.nombreVisible;
                    _especieController.text = mascota.especieVisible;
                  }
                });
              },
            ),
        ],
      ),
    );
  }

  // Sección: campo de especie solo lectura
  // La especie se deriva de la mascota seleccionada y no se edita manualmente.
  Widget _campoEspecieSoloLectura() {
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
          const Text(
            'Especie',
            style: TextStyle(
              color: AppColores.baseFF7A8088,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _especieController.text.trim().isEmpty
                ? '-'
                : _especieController.text.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColores.baseFF1F2A35,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // Sección: campo visual reutilizable
  // Mantiene bloque de ficha y alterna entre texto o input según modo edición.
  Widget _campoFicha({
    required String etiqueta,
    required TextEditingController controller,
    required bool habilitado,
    String? Function(String?)? validator,
    int minLines = 1,
    int maxLines = 1,
  }) {
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
          if (!habilitado)
            Text(
              controller.text.trim().isEmpty ? '-' : controller.text.trim(),
              maxLines: maxLines + 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColores.baseFF1F2A35,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            )
          else
            TextFormField(
              controller: controller,
              validator: validator,
              minLines: minLines,
              maxLines: maxLines,
              style: const TextStyle(
                color: AppColores.baseFF1F2A35,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                errorStyle: TextStyle(height: 0.01, fontSize: 0),
              ),
            ),
        ],
      ),
    );
  }

  // Sección: campo fecha y hora
  // En modo edición abre selector; en lectura solo muestra el texto actual.
  Widget _campoFechaHora() {
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
          const Text(
            'Fecha y hora',
            style: TextStyle(
              color: AppColores.baseFF7A8088,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          if (!_modoEdicion)
            Text(
              _fechaHoraController.text.trim().isEmpty
                  ? 'Fecha por definir'
                  : _fechaHoraController.text.trim(),
              style: const TextStyle(
                color: AppColores.baseFF1F2A35,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            )
          else
            InkWell(
              onTap: _seleccionarFechaHora,
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
                        height: 1.1,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColores.baseFF1F2A35,
                    size: 18,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
