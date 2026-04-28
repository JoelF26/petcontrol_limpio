// Seccion: imports
// Se importan servicios, funciones y widgets reutilizables de citas admin.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/admin/models/vista_cita_admin_view_data.dart';
import 'package:petcontrol_limpio/features/admin/widgets/shared/admin_base_widgets.dart';
import 'package:petcontrol_limpio/features/admin/widgets/citas/detalle_cita_admin_popup.dart';
import 'package:petcontrol_limpio/features/admin/widgets/citas/tarjeta_creacion_cita.dart';
import 'package:petcontrol_limpio/features/admin/widgets/citas/vista_cita_admin_content.dart';
import 'package:petcontrol_limpio/features/admin/widgets/citas/vista_cita_admin_widgets.dart';
import 'package:petcontrol_limpio/models/cita.dart';
import 'package:petcontrol_limpio/models/mascota.dart';
import 'package:petcontrol_limpio/models/personal_medico.dart';
import 'package:petcontrol_limpio/models/usuario.dart';
import 'package:petcontrol_limpio/services/catalogos_json_service.dart';
import 'package:petcontrol_limpio/services/cita_service.dart';
import 'package:petcontrol_limpio/services/mascota_service.dart';
import 'package:petcontrol_limpio/services/personal_medico_service.dart';
import 'package:petcontrol_limpio/services/usuario_service.dart';

// Seccion: pantalla de citas admin
// Muestra agenda completa y permite registrar citas nuevas.
class VistaCitaAdmin extends StatefulWidget {
  const VistaCitaAdmin({super.key});

  @override
  State<VistaCitaAdmin> createState() => _VistaCitaAdminState();
}

class _VistaCitaAdminState extends State<VistaCitaAdmin> {
  // Seccion: dependencias y estado local
  // Mantiene cache de datos y estado de carga para la pantalla.
  final CitaService _citaService = CitaService();
  final CatalogosJsonService _catalogosService = CatalogosJsonService();
  final MascotaService _mascotaService = MascotaService();
  final UsuarioService _usuarioService = UsuarioService();
  final PersonalMedicoService _personalMedicoService = PersonalMedicoService();

  bool _cargando = true;
  String? _errorCarga;
  List<Cita> _citas = const <Cita>[];
  List<Mascota> _mascotas = const <Mascota>[];
  List<String> _estadosCreacionCitaAdmin = const <String>[];
  Map<String, Usuario> _usuariosPorId = const <String, Usuario>{};
  Map<String, PersonalMedico> _medicosPorId = const <String, PersonalMedico>{};

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Seccion: carga de datos
  // Recupera toda la informacion necesaria para renderizar agenda admin.
  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });

    try {
      final resultados = await Future.wait<dynamic>([
        VistaCitaAdminFunciones.cargarDatos(
          citaService: _citaService,
          mascotaService: _mascotaService,
          usuarioService: _usuarioService,
          personalMedicoService: _personalMedicoService,
        ),
        _catalogosService.obtenerEstadosCreacionCitaAdmin(),
      ]);
      final data = resultados[0] as CitasAdminCargaData;
      final estadosCreacion = resultados[1] as List<String>;

      if (!mounted) {
        return;
      }

      setState(() {
        _citas = data.citas;
        _mascotas = data.mascotas;
        _estadosCreacionCitaAdmin = estadosCreacion;
        _usuariosPorId = data.usuariosPorId;
        _medicosPorId = data.medicosPorId;
        _cargando = false;
      });
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message.toString())));
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorCarga = 'No se pudo cargar la agenda de citas.';
        _cargando = false;
      });
    }
  }

  // Seccion: bloques de agenda
  // Obtiene listas para hoy y proximas segun fecha de cita.
  List<Cita> get _citasHoy => VistaCitaAdminFunciones.citasHoy(_citas);
  List<Cita> get _citasProximas =>
      VistaCitaAdminFunciones.citasProximas(_citas);
  int get _confirmadas => VistaCitaAdminFunciones.contarConfirmadas(_citas);

  // Seccion: registro de cita
  // Abre el formulario admin e inyecta usuarios/mascotas reales.
  Future<void> _abrirRegistroCita() async {
    final usuariosFormulario =
        VistaCitaAdminFunciones.construirUsuariosFormulario(_usuariosPorId);
    final mascotasFormulario =
        VistaCitaAdminFunciones.construirMascotasFormulario(_mascotas);
    final medicosFormulario =
        VistaCitaAdminFunciones.construirMedicosFormulario(_medicosPorId);

    await showGeneralDialog<void>(
      context: context,
      barrierLabel: 'registro_cita',
      barrierColor: AppColores.negro38,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Material(
                type: MaterialType.transparency,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: TarjetaCreacionCita(
                    onCerrar: () => Navigator.of(dialogContext).pop(),
                    usuariosRegistrados: usuariosFormulario,
                    mascotasRegistradas: mascotasFormulario,
                    medicosRegistrados: medicosFormulario,
                    estadosDisponibles: _estadosCreacionCitaAdmin,
                    onRegistrar: (data) {
                      _registrarCitaDesdeDialogo(data: data);
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curva = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curva,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(curva),
            child: child,
          ),
        );
      },
    );
  }

  // Seccion: persistencia de cita
  // Valida mascota y guarda nueva cita en storage local.
  Future<void> _registrarCitaDesdeDialogo({
    required CitaCreacionData data,
  }) async {
    final mascotaSeleccionada = VistaCitaAdminFunciones.buscarMascotaPorId(
      _mascotas,
      data.idMascota,
    );

    if (mascotaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La mascota seleccionada no existe.')),
      );
      return;
    }

    try {
      await _citaService.crearCitaCliente(
        idUsuario: data.idUsuario,
        mascota: mascotaSeleccionada,
        motivo: data.motivo,
        descripcion: data.descripcion,
        fechaHora: data.fechaHora,
        idMedico: data.idMedico,
      );

      if (!mounted) {
        return;
      }
      final navigator = Navigator.of(context, rootNavigator: true);
      if (navigator.canPop()) {
        navigator.pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita registrada correctamente.')),
      );
      await _cargarDatos();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo registrar la cita.')),
      );
    }
  }

  // Seccion: detalle de cita
  // Abre popup editable y recarga la agenda cuando se guardan cambios.
  Future<void> _abrirDetalleCita(
    Cita cita, {
    required String bloqueAgenda,
  }) async {
    final actualizada = await mostrarDetalleCitaAdmin(
      context,
      cita: cita,
      bloqueAgenda: bloqueAgenda,
      mascotasDisponibles: _mascotas,
      usuariosPorId: _usuariosPorId,
      medicosPorId: _medicosPorId,
    );

    if (!mounted || !actualizada) {
      return;
    }
    await _cargarDatos();
  }

  // Seccion: build principal
  // Composicion de IU llamando widgets reutilizables y datos de estado.
  @override
  Widget build(BuildContext context) {
    final citasHoy = _citasHoy;
    final citasProximas = _citasProximas;

    return Scaffold(
      backgroundColor: AppColores.baseFFF1F5F2,
      floatingActionButton: SizedBox(
        width: 62,
        height: 62,
        child: FloatingActionButton(
          onPressed: _abrirRegistroCita,
          backgroundColor: AppColores.baseFF1E6246,
          foregroundColor: AppColores.blanco,
          child: const Icon(Icons.add, size: 34),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: VistaCitaAdminFondo()),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VistaCitaAdminEncabezado(
                    onVolver: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 14),
                  VistaCitaAdminResumen(
                    totalHoy: citasHoy.length,
                    totalProximas: citasProximas.length,
                    confirmadas: _confirmadas,
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
                          'Agenda de citas',
                          style: TextStyle(
                            color: AppColores.baseFF22362C,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_citas.length} registros visibles',
                          style: const TextStyle(
                            color: AppColores.baseFF617468,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
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
                        else ...[
                          VistaCitaAdminSeccionAgenda(
                            titulo: 'Programadas para hoy',
                            cantidad: citasHoy.length,
                            citas: citasHoy
                                .map(VistaCitaAdminFunciones.mapearCitaVista)
                                .toList(growable: false),
                            onTap: (citaVista) {
                              final cita =
                                  VistaCitaAdminFunciones.buscarCitaPorId(
                                    _citas,
                                    citaVista.idCita,
                                  );
                              if (cita != null) {
                                _abrirDetalleCita(cita, bloqueAgenda: 'Hoy');
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          const Divider(
                            color: AppColores.baseFFD8E4DE,
                            thickness: 1,
                          ),
                          const SizedBox(height: 12),
                          VistaCitaAdminSeccionAgenda(
                            titulo: 'Proximas citas',
                            cantidad: citasProximas.length,
                            citas: citasProximas
                                .map(VistaCitaAdminFunciones.mapearCitaVista)
                                .toList(growable: false),
                            onTap: (citaVista) {
                              final cita =
                                  VistaCitaAdminFunciones.buscarCitaPorId(
                                    _citas,
                                    citaVista.idCita,
                                  );
                              if (cita != null) {
                                _abrirDetalleCita(
                                  cita,
                                  bloqueAgenda: 'Proxima',
                                );
                              }
                            },
                          ),
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
