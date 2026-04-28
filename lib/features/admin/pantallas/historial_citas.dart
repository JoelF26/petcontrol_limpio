// Seccion: imports
// Se importan servicios, funciones de negocio y widgets visuales de historial.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/core/widgets/popup_detalle.dart';
import 'package:petcontrol_limpio/features/admin/models/historial_citas_view_data.dart';
import 'package:petcontrol_limpio/features/admin/widgets/shared/admin_base_widgets.dart';
import 'package:petcontrol_limpio/features/admin/widgets/citas/historial_citas_content.dart';
import 'package:petcontrol_limpio/features/admin/widgets/citas/historial_citas_widgets.dart';
import 'package:petcontrol_limpio/services/cita_service.dart';
import 'package:petcontrol_limpio/services/catalogos_json_service.dart';
import 'package:petcontrol_limpio/services/personal_medico_service.dart';
import 'package:petcontrol_limpio/services/usuario_service.dart';

// Seccion: pantalla historial admin
// Define la IU principal del modulo de historial de citas.
class HistorialMedicoAdmin extends StatefulWidget {
  const HistorialMedicoAdmin({super.key});

  @override
  State<HistorialMedicoAdmin> createState() => _HistorialMedicoAdminState();
}

class _HistorialMedicoAdminState extends State<HistorialMedicoAdmin> {
  // Seccion: dependencias y estado local
  // Manejan carga de datos y valores seleccionados de filtros.
  final CitaService _citaService = CitaService();
  final CatalogosJsonService _catalogosService = CatalogosJsonService();
  final UsuarioService _usuarioService = UsuarioService();
  final PersonalMedicoService _personalMedicoService = PersonalMedicoService();

  final List<HistorialCitaVista> _historialCitas = <HistorialCitaVista>[];
  bool _cargando = true;
  String? _errorCarga;

  List<String> _estadosFiltroHistorial = const <String>[];
  List<String> _especiesFiltroHistorial = const <String>[];
  List<String> _fechasFiltroHistorial = const <String>[];
  String _estadoSeleccionado = '';
  String _especieSeleccionada = '';
  String _fechaSeleccionada = '';

  String get _estadoTodosHistorial => _estadosFiltroHistorial.first;
  String get _especieTodasHistorial => _especiesFiltroHistorial.first;
  String get _fechaTodoHistorial => _fechasFiltroHistorial.first;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  // Seccion: carga de historial
  // Obtiene registros desde servicios y actualiza estado visual.
  Future<void> _cargarHistorial() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });

    try {
      final resultados = await Future.wait<dynamic>([
        HistorialCitasFunciones.cargarHistorial(
          citaService: _citaService,
          usuarioService: _usuarioService,
          personalMedicoService: _personalMedicoService,
        ),
        _catalogosService.obtenerFiltrosHistorial(),
      ]);
      final historial = resultados[0] as List<HistorialCitaVista>;
      final filtros = resultados[1] as FiltrosHistorialCitas;

      if (!mounted) {
        return;
      }

      setState(() {
        _historialCitas
          ..clear()
          ..addAll(historial);
        _estadosFiltroHistorial = filtros.estados;
        _especiesFiltroHistorial = filtros.especies;
        _fechasFiltroHistorial = filtros.fechas;
        _estadoSeleccionado = filtros.estados.contains(_estadoSeleccionado)
            ? _estadoSeleccionado
            : filtros.estados.first;
        _especieSeleccionada = filtros.especies.contains(_especieSeleccionada)
            ? _especieSeleccionada
            : filtros.especies.first;
        _fechaSeleccionada = filtros.fechas.contains(_fechaSeleccionada)
            ? _fechaSeleccionada
            : filtros.fechas.first;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorCarga = 'No se pudo cargar el historial de citas.';
        _cargando = false;
      });
    }
  }

  // Seccion: historial filtrado
  // Aplica filtros activos sobre la lista en memoria.
  List<HistorialCitaVista> get _historialFiltrado {
    if (_estadosFiltroHistorial.isEmpty ||
        _especiesFiltroHistorial.isEmpty ||
        _fechasFiltroHistorial.isEmpty) {
      return const <HistorialCitaVista>[];
    }

    return HistorialCitasFunciones.filtrarHistorial(
      historial: _historialCitas,
      estadoSeleccionado: _estadoSeleccionado,
      especieSeleccionada: _especieSeleccionada,
      fechaSeleccionada: _fechaSeleccionada,
      estadoTodos: _estadoTodosHistorial,
      especieTodas: _especieTodasHistorial,
    );
  }

  // Seccion: conteos del resumen
  // Obtiene metricas por estado para las tarjetas superiores.
  int _contarEstado(String estado, List<HistorialCitaVista> historialFiltrado) {
    return HistorialCitasFunciones.contarEstado(historialFiltrado, estado);
  }

  // Seccion: popup de filtros
  // Muestra modal para seleccionar filtros y actualizar listado.
  Future<void> _abrirFiltroPopup() async {
    if (_estadosFiltroHistorial.isEmpty ||
        _especiesFiltroHistorial.isEmpty ||
        _fechasFiltroHistorial.isEmpty) {
      return;
    }

    var estadoTemp = _estadoSeleccionado;
    var especieTemp = _especieSeleccionada;
    var fechaTemp = _fechaSeleccionada;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColores.baseFFF2F6F4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtrar historial',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColores.baseFF1F352B,
                      ),
                    ),
                    const SizedBox(height: 12),
                    HistorialCampoFiltro(
                      etiqueta: 'Estado',
                      child: DropdownButtonFormField<String>(
                        initialValue: estadoTemp,
                        decoration: decoracionFiltroHistorial(),
                        items: _estadosFiltroHistorial
                            .map(
                              (estado) => DropdownMenuItem<String>(
                                value: estado,
                                child: Text(estado),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setModalState(() => estadoTemp = value);
                        },
                      ),
                    ),
                    HistorialCampoFiltro(
                      etiqueta: 'Especie',
                      child: DropdownButtonFormField<String>(
                        initialValue: especieTemp,
                        decoration: decoracionFiltroHistorial(),
                        items: _especiesFiltroHistorial
                            .map(
                              (especie) => DropdownMenuItem<String>(
                                value: especie,
                                child: Text(especie),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setModalState(() => especieTemp = value);
                        },
                      ),
                    ),
                    HistorialCampoFiltro(
                      etiqueta: 'Fecha',
                      child: DropdownButtonFormField<String>(
                        initialValue: fechaTemp,
                        decoration: decoracionFiltroHistorial(),
                        items: _fechasFiltroHistorial
                            .map(
                              (fecha) => DropdownMenuItem<String>(
                                value: fecha,
                                child: Text(fecha),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setModalState(() => fechaTemp = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _estadoSeleccionado = _estadoTodosHistorial;
                                _especieSeleccionada = _especieTodasHistorial;
                                _fechaSeleccionada = _fechaTodoHistorial;
                              });
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColores.baseFF2A3E35,
                              side: const BorderSide(
                                color: AppColores.baseFF8BA49A,
                              ),
                              minimumSize: const Size.fromHeight(44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Limpiar'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _estadoSeleccionado = estadoTemp;
                                _especieSeleccionada = especieTemp;
                                _fechaSeleccionada = fechaTemp;
                              });
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColores.baseFF1E6246,
                              foregroundColor: AppColores.blanco,
                              minimumSize: const Size.fromHeight(44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Aplicar',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Seccion: popup de detalle
  // Muestra el detalle completo de una cita del historial.
  void _abrirDetalleHistorial(HistorialCitaVista cita) {
    final fechaFormateada = HistorialCitasFunciones.formatearFecha(
      cita.fechaHora,
    );

    mostrarPopupDetalle(
      context,
      ConfigPopupDetalle(
        titulo: cita.nombreMascota,
        subtitulo: 'Detalle completo de cita pasada',
        icono: HistorialCitasFunciones.iconoEstado(cita.estado),
        colorAcento: HistorialCitasFunciones.colorTextoEstado(cita.estado),
        chips: <String>[cita.estado, cita.especie],
        campos: <DetalleCampo>[
          DetalleCampo(etiqueta: 'Mascota', valor: cita.nombreMascota),
          DetalleCampo(etiqueta: 'Especie', valor: cita.especie),
          DetalleCampo(etiqueta: 'Estado', valor: cita.estado),
          DetalleCampo(etiqueta: 'Procedimiento', valor: cita.procedimiento),
          DetalleCampo(etiqueta: 'Fecha y hora', valor: fechaFormateada),
          DetalleCampo(etiqueta: 'Doctor', valor: cita.doctor),
          DetalleCampo(etiqueta: 'Dueno', valor: cita.dueno),
          DetalleCampo(etiqueta: 'Descripcion', valor: cita.descripcion),
        ],
      ),
    );
  }

  // Seccion: composicion principal
  // Renderiza la estructura visual del historial llamando widgets reutilizables.
  @override
  Widget build(BuildContext context) {
    final historialFiltrado = _historialFiltrado;

    return Scaffold(
      backgroundColor: AppColores.baseFFF1F5F2,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: HistorialFondo()),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HistorialEncabezado(
                    onVolver: () => Navigator.of(context).pop(),
                    onFiltrar: _abrirFiltroPopup,
                  ),
                  const SizedBox(height: 14),
                  HistorialResumen(
                    total: historialFiltrado.length,
                    finalizadas: _contarEstado('finalizada', historialFiltrado),
                    canceladas: _contarEstado('cancelada', historialFiltrado),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                    decoration: BoxDecoration(
                      color: AppColores.baseFFF8FBF9,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColores.baseFFC0D2C8,
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColores.base1A183325,
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Historial de citas',
                          style: TextStyle(
                            color: AppColores.baseFF22362C,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${historialFiltrado.length} registros para los filtros actuales',
                          style: const TextStyle(
                            color: AppColores.baseFF617468,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            HistorialChipFiltroActivo(
                              texto: 'Estado: $_estadoSeleccionado',
                            ),
                            HistorialChipFiltroActivo(
                              texto: 'Especie: $_especieSeleccionada',
                            ),
                            HistorialChipFiltroActivo(
                              texto: 'Fecha: $_fechaSeleccionada',
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (_cargando)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.3,
                              ),
                            ),
                          )
                        else if (_errorCarga != null)
                          AdminEstadoVacioBase(
                            mensaje: _errorCarga!,
                            icono: Icons.error_outline_rounded,
                          )
                        else if (historialFiltrado.isEmpty)
                          const HistorialEstadoVacio()
                        else
                          for (
                            var i = 0;
                            i < historialFiltrado.length;
                            i++
                          ) ...[
                            HistorialTarjetaCita(
                              cita: historialFiltrado[i],
                              fechaFormateada:
                                  HistorialCitasFunciones.formatearFecha(
                                    historialFiltrado[i].fechaHora,
                                  ),
                              colorFondoEstado:
                                  HistorialCitasFunciones.colorFondoEstado(
                                    historialFiltrado[i].estado,
                                  ),
                              colorTextoEstado:
                                  HistorialCitasFunciones.colorTextoEstado(
                                    historialFiltrado[i].estado,
                                  ),
                              iconoEstado: HistorialCitasFunciones.iconoEstado(
                                historialFiltrado[i].estado,
                              ),
                              onTap: () =>
                                  _abrirDetalleHistorial(historialFiltrado[i]),
                            ),
                            if (i < historialFiltrado.length - 1)
                              const SizedBox(height: 12),
                          ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
