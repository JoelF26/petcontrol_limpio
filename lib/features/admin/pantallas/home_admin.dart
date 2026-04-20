// Seccion: imports
// Se importan modelo, funciones y widgets del home admin modular y dinamico.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/routes/rutas.dart';
import 'package:petcontrol_limpio/features/admin/models/home_admin_view_data.dart';
import 'package:petcontrol_limpio/features/admin/widgets/admin_base_widgets.dart';
import 'package:petcontrol_limpio/features/admin/widgets/home_admin_content.dart';
import 'package:petcontrol_limpio/features/admin/widgets/home_admin_widgets.dart';

// Seccion: pantalla home admin
// Presenta el panel principal con datos reales del admin en sesion.
class HomeAdminPantalla extends StatefulWidget {
  const HomeAdminPantalla({super.key});

  @override
  State<HomeAdminPantalla> createState() => _HomeAdminPantallaState();
}

class _HomeAdminPantallaState extends State<HomeAdminPantalla> {
  // Seccion: estado local
  // Gestiona carga inicial del dashboard y posibles errores.
  bool _cargando = true;
  String? _errorCarga;
  HomeAdminDashboardData? _dashboard;

  static const List<HomeAdminMetricaVista> _metricasVacias =
      <HomeAdminMetricaVista>[
        HomeAdminMetricaVista(
          icono: Icons.pets,
          numero: '0',
          etiqueta: 'Pacientes',
        ),
        HomeAdminMetricaVista(
          icono: Icons.receipt_long_outlined,
          numero: '0',
          etiqueta: 'Citas',
        ),
        HomeAdminMetricaVista(
          icono: Icons.people_outline,
          numero: '0',
          etiqueta: 'Personal',
        ),
      ];

  @override
  void initState() {
    super.initState();
    _cargarDashboard();
  }

  // Seccion: carga de dashboard
  // Obtiene datos del admin logueado, metricas y proxima cita.
  Future<void> _cargarDashboard() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });

    try {
      final dashboard = await HomeAdminFunciones.cargarDashboardAdmin();
      if (!mounted) {
        return;
      }

      setState(() {
        _dashboard = dashboard;
        _cargando = false;
      });
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorCarga = error.message.toString();
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorCarga = 'No se pudo cargar el panel de administrador.';
        _cargando = false;
      });
    }
  }

  // Seccion: navegacion con refresco
  // Navega a un modulo admin y recarga metricas al volver a esta pantalla.
  Future<void> _irModuloYRecargar(String ruta) async {
    await Navigator.pushNamed(context, ruta);
    if (!mounted) {
      return;
    }
    await _cargarDashboard();
  }

  // Seccion: composicion principal
  // Dibuja fondo, encabezado, metricas, menu, proxima cita y navbar.
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final alturaCurva = (size.height * 0.74).clamp(560.0, 860.0);

    final dashboard = _dashboard;
    final inicialDoctor = dashboard?.inicialDoctor ?? 'A';
    final nombreDoctor = dashboard?.nombreDoctor ?? 'Administrador';
    final metricas = dashboard?.metricas ?? _metricasVacias;
    final proximasCitas =
        dashboard?.proximasCitas ?? const <HomeAdminProximaCitaVista>[];

    return Scaffold(
      backgroundColor: const Color(0xFFECECEC),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Color(0xFFECECEC))),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [Color(0xFF2E8A4F), Color(0xFF2FA74D)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipPath(
                clipper: HomeAdminCurvaClipper(),
                child: Container(
                  color: const Color(0xFFECECEC),
                  height: alturaCurva,
                  width: double.infinity,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 92),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeAdminHeader(
                    inicialDoctor: inicialDoctor,
                    nombreDoctor: nombreDoctor,
                    onSalir: () {
                      HomeAdminFunciones.cerrarSesionYSalir(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Controla agenda, pacientes y equipo medico desde el panel principal.',
                    style: TextStyle(
                      color: Color(0xFFDDF6E5),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_cargando) ...[
                    const SizedBox(height: 12),
                    const Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  if (_errorCarga != null) ...[
                    const SizedBox(height: 12),
                    AdminEstadoVacioBase(
                      mensaje: _errorCarga!,
                      icono: Icons.warning_amber_rounded,
                    ),
                  ],
                  const SizedBox(height: 16),
                  HomeAdminMetricasRow(metricas: metricas),
                  const SizedBox(height: 16),
                  HomeAdminPanelSeccion(
                    titulo: 'Menu Principal',
                    icono: Icons.dashboard_customize_outlined,
                    child: HomeAdminMenuPrincipalGrid(
                      onPacientes: () => _irModuloYRecargar(Rutas.adminPacientes),
                      onCitas: () => _irModuloYRecargar(Rutas.adminCitas),
                      onHistorial: () =>
                          _irModuloYRecargar(Rutas.adminHistorialCitas),
                      onPersonal: () =>
                          _irModuloYRecargar(Rutas.adminPersonalMedico),
                    ),
                  ),
                  const SizedBox(height: 14),
                  HomeAdminPanelSeccion(
                    titulo: 'Proxima Cita',
                    icono: Icons.event_note_outlined,
                    child: HomeAdminProximaCitaLista(
                      citas: proximasCitas,
                      onTap: (cita) {
                        HomeAdminFunciones.abrirDetalleProximaCita(context, cita);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeAdminBottomNavbar(
        onPacientes: () => _irModuloYRecargar(Rutas.adminPacientes),
        onCitas: () => _irModuloYRecargar(Rutas.adminCitas),
        onHistorial: () => _irModuloYRecargar(Rutas.adminHistorialCitas),
        onPersonal: () => _irModuloYRecargar(Rutas.adminPersonalMedico),
      ),
    );
  }
}
