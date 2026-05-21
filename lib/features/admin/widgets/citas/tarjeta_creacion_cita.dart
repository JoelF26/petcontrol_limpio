// Sección: imports
// Se importa material para construir el formulario visual de creación de citas admin.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/core/di/app_dependencies.dart';
import 'package:petcontrol_limpio/application/services/catalogos_json_service.dart';

// Sección: formato de fecha y hora
// Convierte DateTime a texto legible para mostrar en el formulario.
String _formatearFechaHora(DateTime fechaHora) {
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
  final hora = fechaHora.hour.toString().padLeft(2, '0');
  final minuto = fechaHora.minute.toString().padLeft(2, '0');
  final mes = meses[fechaHora.month - 1];
  return '$dia $mes ${fechaHora.year} $hora:$minuto';
}

// Sección: modelo visual de mascota para formulario admin
// Define las mascotas que pueden seleccionarse al crear cita.
class MascotaRegistradaMock {
  const MascotaRegistradaMock({
    required this.id,
    required this.nombre,
    required this.especie,
    required this.usuarioId,
  });

  final String id;
  final String nombre;
  final String especie;
  final String usuarioId;
}

// Sección: modelo visual de usuario para formulario admin
// Define los propietarios disponibles para vincular en la cita.
class UsuarioRegistradoMock {
  const UsuarioRegistradoMock({required this.id, required this.nombre});

  final String id;
  final String nombre;
}

// Sección: modelo visual de médico para formulario admin
// Define los médicos disponibles para asignar en la creación de la cita.
class MedicoRegistradoMock {
  const MedicoRegistradoMock({required this.id, required this.nombre});

  final String id;
  final String nombre;
}

// Sección: payload de creación
// Expone los datos del formulario al callback de la pantalla.
class CitaCreacionData {
  const CitaCreacionData({
    required this.idMascota,
    required this.nombreMascota,
    required this.idUsuario,
    required this.nombreUsuario,
    required this.idMedico,
    required this.fechaHora,
    required this.motivo,
    required this.estado,
    required this.descripcion,
  });

  final String idMascota;
  final String nombreMascota;
  final String idUsuario;
  final String nombreUsuario;
  final String idMedico;
  final DateTime fechaHora;
  final String motivo;
  final String estado;
  final String descripcion;

  String get fechaHoraFormateada => _formatearFechaHora(fechaHora);
}

// Sección: tarjeta de creación de cita
// Mantiene formulario visual de admin desacoplado de backend para fase UI-first.
class TarjetaCreacionCita extends StatefulWidget {
  const TarjetaCreacionCita({
    super.key,
    this.onCerrar,
    this.onRegistrar,
    this.mascotasRegistradas = const <MascotaRegistradaMock>[],
    this.usuariosRegistrados = const <UsuarioRegistradoMock>[],
    this.medicosRegistrados = const <MedicoRegistradoMock>[],
    this.motivosDisponibles = const <String>[],
    this.estadosDisponibles = const <String>[],
  });

  final VoidCallback? onCerrar;
  final ValueChanged<CitaCreacionData>? onRegistrar;
  final List<MascotaRegistradaMock> mascotasRegistradas;
  final List<UsuarioRegistradoMock> usuariosRegistrados;
  final List<MedicoRegistradoMock> medicosRegistrados;
  final List<String> motivosDisponibles;
  final List<String> estadosDisponibles;

  @override
  State<TarjetaCreacionCita> createState() => _TarjetaCreacionCitaState();
}

// Sección: estado de tarjeta de creación
// Gestiona selección de campos y validaciones del formulario.
class _TarjetaCreacionCitaState extends State<TarjetaCreacionCita> {
  final _formKey = GlobalKey<FormState>();
  final _fechaHoraController = TextEditingController();
  final _descripcionController = TextEditingController();
  final CatalogosJsonService _catalogosService =
      AppDependencies.catalogosJsonService;

  String? _mascotaSeleccionadaId;
  String? _usuarioSeleccionadoId;
  String? _medicoSeleccionadoId;
  String? _motivoSeleccionado;
  String? _estadoSeleccionado;
  DateTime? _fechaHoraSeleccionada;
  bool _cargandoCatalogos = true;
  List<String> _motivosCatalogo = const <String>[];
  List<String> _estadosCatalogo = const <String>[];

  // Sección: listas efectivas de opciones
  // Usa valores de JSON cuando la pantalla no inyecta una lista personalizada.
  List<String> get _motivosDisponibles {
    if (widget.motivosDisponibles.isEmpty) {
      return _motivosCatalogo;
    }
    return widget.motivosDisponibles;
  }

  List<String> get _estadosDisponibles {
    if (widget.estadosDisponibles.isEmpty) {
      return _estadosCatalogo;
    }
    return widget.estadosDisponibles;
  }

  List<MascotaRegistradaMock> get _mascotasDisponibles {
    final usuarioId = _usuarioSeleccionadoId;
    if (usuarioId == null) {
      return widget.mascotasRegistradas;
    }
    return widget.mascotasRegistradas
        .where((mascota) => mascota.usuarioId == usuarioId)
        .toList(growable: false);
  }

  MascotaRegistradaMock? _mascotaPorId(String id) {
    for (final mascota in widget.mascotasRegistradas) {
      if (mascota.id == id) {
        return mascota;
      }
    }
    return null;
  }

  UsuarioRegistradoMock? _usuarioPorId(String id) {
    for (final usuario in widget.usuariosRegistrados) {
      if (usuario.id == id) {
        return usuario;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _medicoSeleccionadoId = '';
    _cargarCatalogos();
  }

  @override
  void dispose() {
    _fechaHoraController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  // Sección: carga de catálogos
  // Obtiene motivos y estados desde assets antes de inicializar los dropdowns.
  Future<void> _cargarCatalogos() async {
    final resultados = await Future.wait<List<String>>([
      _catalogosService.obtenerMotivosCitaAdmin(),
      _catalogosService.obtenerEstadosCreacionCitaAdmin(),
    ]);
    if (!mounted) {
      return;
    }

    setState(() {
      _motivosCatalogo = resultados[0];
      _estadosCatalogo = resultados[1];
      _estadoSeleccionado = _estadosDisponibles.first;
      _motivoSeleccionado = _motivosDisponibles.first;
      _cargandoCatalogos = false;
    });
  }

  // Sección: estilo base de campos
  // Unifica visual del formulario sin alterar identidad de la tarjeta.
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

  String? _validadorRequerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }
    return null;
  }

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

    if (fechaHora.isBefore(ahora)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La cita debe programarse en una fecha y hora futuras.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _fechaHoraSeleccionada = fechaHora;
      _fechaHoraController.text = _formatearFechaHora(fechaHora);
    });
  }

  void _onUsuarioChanged(String? usuarioId) {
    setState(() {
      _usuarioSeleccionadoId = usuarioId;
      if (_mascotaSeleccionadaId == null) {
        return;
      }

      final mascotaSigueDisponible = _mascotasDisponibles.any(
        (mascota) => mascota.id == _mascotaSeleccionadaId,
      );
      if (!mascotaSigueDisponible) {
        _mascotaSeleccionadaId = null;
      }
    });
  }

  void _onMascotaChanged(String? mascotaId) {
    setState(() {
      _mascotaSeleccionadaId = mascotaId;
      if (mascotaId == null) {
        return;
      }

      final mascota = _mascotaPorId(mascotaId);
      if (mascota != null) {
        _usuarioSeleccionadoId = mascota.usuarioId;
      }
    });
  }

  void _registrar() {
    final esValido = _formKey.currentState?.validate() == true;
    if (!esValido || _fechaHoraSeleccionada == null) {
      setState(() {});
      return;
    }

    final mascota = _mascotaSeleccionadaId == null
        ? null
        : _mascotaPorId(_mascotaSeleccionadaId!);
    final usuario = _usuarioSeleccionadoId == null
        ? null
        : _usuarioPorId(_usuarioSeleccionadoId!);

    if (mascota == null || usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona usuario y mascota para registrar la cita.'),
        ),
      );
      return;
    }

    widget.onRegistrar?.call(
      CitaCreacionData(
        idMascota: mascota.id,
        nombreMascota: mascota.nombre,
        idUsuario: usuario.id,
        nombreUsuario: usuario.nombre,
        idMedico: (_medicoSeleccionadoId ?? '').trim(),
        fechaHora: _fechaHoraSeleccionada!,
        motivo: (_motivoSeleccionado ?? '').trim(),
        estado: (_estadoSeleccionado ?? '').trim(),
        descripcion: _descripcionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColores.baseFFDCDDDB,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColores.baseFF1A95F7, width: 2),
      ),
      child: _cargandoCatalogos
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.3)),
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
                            'Registrar cita',
                            style: TextStyle(
                              color: AppColores.baseFF223633,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onCerrar,
                          icon: const Icon(Icons.close, size: 20),
                          visualDensity: VisualDensity.compact,
                          color: AppColores.baseFF5E6A68,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const _EtiquetaCampo('Usuario registrado'),
                    DropdownButtonFormField<String>(
                      initialValue: _usuarioSeleccionadoId,
                      validator: (value) => value == null ? '' : null,
                      decoration: _decoracionCampo('Seleccionar usuario'),
                      items: widget.usuariosRegistrados
                          .map(
                            (usuario) => DropdownMenuItem<String>(
                              value: usuario.id,
                              child: Text(usuario.nombre),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: _onUsuarioChanged,
                    ),
                    const SizedBox(height: 10),
                    const _EtiquetaCampo('Mascota registrada'),
                    DropdownButtonFormField<String>(
                      initialValue: _mascotaSeleccionadaId,
                      validator: (value) => value == null ? '' : null,
                      decoration: _decoracionCampo('Seleccionar mascota'),
                      items: _mascotasDisponibles
                          .map(
                            (mascota) => DropdownMenuItem<String>(
                              value: mascota.id,
                              child: Text(
                                '${mascota.nombre} (${mascota.especie})',
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: _onMascotaChanged,
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
                              icon: const Icon(Icons.calendar_today_outlined),
                            ),
                          ),
                      onTap: _seleccionarFechaHora,
                    ),
                    const SizedBox(height: 10),
                    const _EtiquetaCampo('Motivo'),
                    DropdownButtonFormField<String>(
                      initialValue: _motivoSeleccionado,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? '' : null,
                      decoration: _decoracionCampo('Seleccionar motivo'),
                      items: _motivosDisponibles
                          .map(
                            (motivo) => DropdownMenuItem<String>(
                              value: motivo,
                              child: Text(motivo),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) =>
                          setState(() => _motivoSeleccionado = value),
                    ),
                    const SizedBox(height: 10),
                    const _EtiquetaCampo('Medico asignado'),
                    DropdownButtonFormField<String>(
                      initialValue: _medicoSeleccionadoId,
                      decoration: _decoracionCampo('Seleccionar medico'),
                      items: <DropdownMenuItem<String>>[
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('Sin asignar'),
                        ),
                        ...widget.medicosRegistrados.map(
                          (medico) => DropdownMenuItem<String>(
                            value: medico.id,
                            child: Text(medico.nombre),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _medicoSeleccionadoId = value ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    const _EtiquetaCampo('Estado'),
                    DropdownButtonFormField<String>(
                      initialValue: _estadoSeleccionado,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? '' : null,
                      decoration: _decoracionCampo('Estado'),
                      items: _estadosDisponibles
                          .map(
                            (estado) => DropdownMenuItem<String>(
                              value: estado,
                              child: Text(estado),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) =>
                          setState(() => _estadoSeleccionado = value),
                    ),
                    const SizedBox(height: 10),
                    const _EtiquetaCampo('Descripción'),
                    TextFormField(
                      controller: _descripcionController,
                      maxLines: 2,
                      decoration: _decoracionCampo('Descripción opcional'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _registrar,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColores.baseFF1E6246,
                          foregroundColor: AppColores.blanco,
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Guardar cita',
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
    );
  }
}

// Sección: etiqueta de campo
// Reutiliza el estilo de texto de las etiquetas en toda la tarjeta.
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
