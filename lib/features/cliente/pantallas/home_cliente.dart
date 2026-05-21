// Sección: imports
// Se importan rutas, paleta y widgets modulares del home de cliente.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/routes/rutas.dart';
import 'package:petcontrol_limpio/core/di/app_dependencies.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/home/home_cliente_mascotas_registradas_card.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/home/home_cliente_menu_flotante.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/home/home_cliente_proximas_citas_card.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/home/home_cliente_resumen_card.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/citas/detalle_cita_cliente_popup.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/mascotas/detalle_mascota_cliente_popup.dart';
import 'package:petcontrol_limpio/features/cliente/pantallas/mis_citas_cliente.dart';
import 'package:petcontrol_limpio/features/cliente/pantallas/mis_mascotas_cliente.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/citas/tarjeta_creacion_cita.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/mascotas/tarjeta_creacion_paciente.dart';
import 'package:petcontrol_limpio/domain/entities/cita.dart';
import 'package:petcontrol_limpio/domain/entities/mascota.dart';
import 'package:petcontrol_limpio/application/services/auth_service.dart';
import 'package:petcontrol_limpio/application/services/cita_service.dart';
import 'package:petcontrol_limpio/application/services/mascota_service.dart';

// Sección: pantalla principal del cliente
// Presenta el dashboard visual del cliente sin datos mock ni acciones de creación.
class HomeClientePantalla extends StatefulWidget {
  const HomeClientePantalla({super.key});

  @override
  State<HomeClientePantalla> createState() => _HomeClientePantallaState();
}

// Sección: estado de pantalla principal
// Se encarga de cargar datos del usuario autenticado para el header dinámico.
class _HomeClientePantallaState extends State<HomeClientePantalla> {
  // Sección: constantes visuales base
  // Se centralizan textos fijos y ajustes visuales para mantener el archivo compacto.
  static const String _subtituloHome =
      'Gestiona tus citas y mascotas desde un solo lugar.';
  static const double _superposicionResumenes = 14;
  static const double _superposicionPaneles = 8;

  // Sección: dependencias y estado del header
  // Mantiene los datos de sesión y conteos para mostrar resumen real del cliente.
  final AuthService _authService = AppDependencies.authService;
  final MascotaService _mascotaService = AppDependencies.mascotaService;
  final CitaService _citaService = AppDependencies.citaService;
  String _nombreCliente = 'Cliente';
  String _inicialCliente = 'C';
  int _totalMascotas = 0;
  int _totalCitas = 0;
  List<Mascota> _mascotasRecientes = const <Mascota>[];
  List<Cita> _proximasCitas = const <Cita>[];
  StreamSubscription<List<Mascota>>? _mascotasSubscription;
  StreamSubscription<List<Cita>>? _citasSubscription;

  // Sección: ciclo de vida inicial
  // Dispara la carga del perfil al entrar al home.
  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  // Sección: carga inicial del home
  // Resuelve datos de sesión y consulta JSON local para llenar resúmenes.
  Future<void> _cargarDatosIniciales() async {
    try {
      final usuario = await _authService.obtenerUsuarioActual();
      final nombre = _resolverNombreVisible(usuario?.nombreCompleto);
      final idUsuario = _resolverIdUsuario(usuario?.idUsuario);

      var totalMascotas = 0;
      var totalCitas = 0;
      var mascotasRecientes = const <Mascota>[];
      var proximasCitas = const <Cita>[];
      if (idUsuario.isNotEmpty) {
        // Lanza ambas consultas antes de esperar para reducir el tiempo de carga del home.
        final mascotasFuture = _mascotaService.obtenerMascotasPorUsuario(
          idUsuario,
        );
        final citasFuture = _citaService.obtenerCitasPorUsuario(idUsuario);

        final mascotas = await mascotasFuture;
        totalMascotas = mascotas.length;
        mascotasRecientes = mascotas.take(2).toList(growable: false);
        final citas = await citasFuture;
        totalCitas = citas.length;
        proximasCitas = citas.take(4).toList(growable: false);
      }

      if (!mounted) {
        return;
      }

      // Ante fallos de lectura local, se muestra un home vacío pero navegable.
      setState(() {
        _nombreCliente = nombre;
        _inicialCliente = _resolverInicial(nombre);
        _totalMascotas = totalMascotas;
        _totalCitas = totalCitas;
        _mascotasRecientes = mascotasRecientes;
        _proximasCitas = proximasCitas;
      });
      _suscribirTiempoReal(idUsuario);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _nombreCliente = _resolverNombreVisible(null);
        _inicialCliente = _resolverInicial(_nombreCliente);
        _totalMascotas = 0;
        _totalCitas = 0;
        _mascotasRecientes = const <Mascota>[];
        _proximasCitas = const <Cita>[];
      });
    }
  }

  void _suscribirTiempoReal(String idUsuario) {
    if (idUsuario.isEmpty) {
      return;
    }

    _mascotasSubscription?.cancel();
    _mascotasSubscription = _mascotaService.observarMascotas().listen((
      mascotas,
    ) {
      if (!mounted) {
        return;
      }
      final propias = mascotas
          .where((mascota) => mascota.idUsuario == idUsuario)
          .toList(growable: false);
      setState(() {
        _totalMascotas = propias.length;
        _mascotasRecientes = propias.take(2).toList(growable: false);
      });
    });

    _citasSubscription?.cancel();
    _citasSubscription = _citaService.observarCitas().listen((citas) {
      if (!mounted) {
        return;
      }
      final propias = _citaService.filtrarCitasVisiblesPorUsuario(
        citas,
        idUsuario,
      );
      setState(() {
        _totalCitas = propias.length;
        _proximasCitas = propias.take(4).toList(growable: false);
      });
    });
  }

  @override
  void dispose() {
    _mascotasSubscription?.cancel();
    _citasSubscription?.cancel();
    super.dispose();
  }

  // Sección: resolución de id de usuario
  // Prioriza id del perfil y usa uid de Auth como respaldo para las consultas.
  String _resolverIdUsuario(String? idPerfil) {
    return (idPerfil ?? '').trim();
  }

  // Sección: resolución de nombre visible
  // Prioriza nombre del perfil y usa correo como respaldo si aún no hay perfil.
  String _resolverNombreVisible(String? nombrePerfil) {
    final nombreLimpio = (nombrePerfil ?? '').trim();
    if (nombreLimpio.isNotEmpty) {
      return nombreLimpio;
    }
    return 'Cliente';
  }

  // Sección: cálculo de inicial
  // Toma la primera letra del primer bloque del nombre mostrado.
  String _resolverInicial(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) {
      return 'C';
    }
    return partes.first.substring(0, 1).toUpperCase();
  }

  // Sección: salida a bienvenida
  // Cierra la sesión y redirige a la pantalla de bienvenida.
  Future<void> _irABienvenida() async {
    try {
      await _authService.cerrarSesion();
    } catch (_) {}
    if (!mounted) {
      return;
    }
    // Limpia el historial para que el usuario no regrese al home con atrás.
    Navigator.pushNamedAndRemoveUntil(context, Rutas.bienvenida, (_) => false);
  }

  // Sección: navegación a pantalla de citas
  // Abre la vista completa de citas y al volver refresca el home.
  Future<void> _irAMisCitas() async {
    if (!mounted) {
      return;
    }
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const MisCitasCliente()));
    if (!mounted) {
      return;
    }
    await _cargarDatosIniciales();
  }

  // Sección: navegación a pantalla de mascotas
  // Abre la vista completa de mascotas y al volver refresca el home.
  Future<void> _irAMisMascotas() async {
    if (!mounted) {
      return;
    }
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const MisMascotasCliente()));
    if (!mounted) {
      return;
    }
    await _cargarDatosIniciales();
  }

  // Sección: apertura de detalle de mascota
  // Muestra ficha extendida y, si se actualiza, refresca los datos del home.
  Future<void> _abrirDetalleMascota(Mascota mascota) async {
    if (!mounted) {
      return;
    }
    final actualizada = await mostrarDetalleMascotaCliente(context, mascota);
    // El popup devuelve true solo cuando guardó cambios en la mascota.
    if (actualizada) {
      await _cargarDatosIniciales();
    }
  }

  // Sección: apertura de detalle de cita
  // Muestra la ficha extendida de la cita y refresca Home si se actualiza.
  Future<void> _abrirDetalleCita(Cita cita) async {
    if (!mounted) {
      return;
    }
    final actualizada = await mostrarDetalleCitaCliente(context, cita);
    // Si hubo edición o cancelación, se recalculan totales y próximas citas.
    if (actualizada) {
      await _cargarDatosIniciales();
    }
  }

  // Sección: acciones del menú
  // Dejan listo el punto de navegación para formularios futuros.
  Future<void> _accionRegistrarMascota() async {
    if (!mounted) {
      return;
    }

    bool? creada;
    try {
      // Sección: apertura de popup para registrar mascota
      // Muestra la tarjeta centrada y oscurece el fondo mientras está abierta.
      creada = await showDialog<bool>(
        context: context,
        barrierColor: AppColores.negro.withValues(alpha: 0.62),
        barrierDismissible: true,
        builder: (context) {
          final teclado = MediaQuery.of(context).viewInsets;
          return AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + teclado.bottom),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: const TarjetaCreacionPaciente(),
              ),
            ),
          );
        },
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el formulario de mascota.'),
        ),
      );
      return;
    }

    // Sección: refresco del home tras crear mascota
    // Si se confirma creación, recarga totales y listado reciente de mascotas.
    // El formulario cierra con true únicamente cuando la mascota fue persistida.
    if (creada == true) {
      await _cargarDatosIniciales();
    }
  }

  Future<void> _accionCrearCita() async {
    if (!mounted) {
      return;
    }

    bool? creada;
    try {
      // Sección: apertura de popup para crear cita
      // Muestra la tarjeta centrada como diálogo y oscurece el fondo.
      creada = await showDialog<bool>(
        context: context,
        barrierColor: AppColores.negro.withValues(alpha: 0.62),
        barrierDismissible: true,
        builder: (context) {
          final teclado = MediaQuery.of(context).viewInsets;
          return AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + teclado.bottom),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: const TarjetaCreacionCita(),
              ),
            ),
          );
        },
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el formulario de cita.'),
        ),
      );
      return;
    }

    // Sección: refresco del home tras crear cita
    // Si se confirma creación, vuelve a consultar resúmenes y tarjetas.
    // El formulario cierra con true únicamente cuando la cita fue persistida.
    if (creada == true) {
      await _cargarDatosIniciales();
    }
  }

  // Sección: construcción de la pantalla
  // Mantiene el diseño original, pero delega bloques visuales a widgets separados.
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Sección: altura de la curva base
    // Se aumenta esta altura para que el fondo azul termine más arriba
    // sin modificar la forma de la curva definida en el clipper.
    final alturaCurva = (size.height * 0.78).clamp(620.0, 900.0);

    return Scaffold(
      backgroundColor: AppColores.baseFFECECEC,
      body: SafeArea(
        child: Stack(
          children: [
            // Sección: base de fondo
            // Capa inferior gris para conservar contraste con los paneles.
            const Positioned.fill(
              child: ColoredBox(color: AppColores.baseFFECECEC),
            ),

            // Sección: degradado superior
            // Replica el encabezado azul del diseño de referencia.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      AppColores.secundarioOscuro,
                      //AppColores.secundarioOscuro,
                      AppColores.secundario,
                    ],
                  ),
                ),
              ),
            ),

            // Sección: recorte curvo inferior
            // Forma orgánica que separa el encabezado del contenido principal.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipPath(
                clipper: _CurvaHomeClienteClipper(),
                child: Container(
                  color: AppColores.baseFFECECEC,
                  height: alturaCurva,
                  width: double.infinity,
                ),
              ),
            ),

            // Sección: contenido desplazable del home
            // Agrupa encabezado, resumen y paneles principales.
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 82),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  const SizedBox(height: 8),
                  const Text(
                    _subtituloHome,
                    style: TextStyle(
                      color: AppColores.baseFFDCE8FF,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sección: resúmenes superpuestos sobre la curva
                  // Se elevan levemente para que el azul y la curva pasen por detrás
                  // sin afectar el diseño ni la distribución general.
                  Transform.translate(
                    offset: const Offset(0, -_superposicionResumenes),
                    child: Row(
                      children: [
                        HomeClienteResumenCard(
                          icono: Icons.pets,
                          valor: '$_totalMascotas',
                          etiqueta: 'Mis mascotas',
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        HomeClienteResumenCard(
                          icono: Icons.calendar_month_outlined,
                          valor: '$_totalCitas',
                          etiqueta: 'Mis citas',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  // Sección: paneles superpuestos sobre la curva
                  // Se desplazan visualmente para que el fondo azul/curva quede detrás,
                  // manteniendo separación correcta respecto a los resúmenes.
                  const SizedBox(height: 14),
                  Transform.translate(
                    offset: const Offset(0, -_superposicionPaneles),
                    child: Column(
                      children: [
                        HomeClienteProximasCitasCard(
                          onVerTodo: () {
                            _irAMisCitas();
                          },
                          onTapCita: (cita) {
                            _abrirDetalleCita(cita);
                          },
                          proximasCitas: _proximasCitas,
                        ),
                        const SizedBox(height: 14),
                        HomeClienteMascotasRegistradasCard(
                          onVerTodo: () {
                            _irAMisMascotas();
                          },
                          onTapMascota: (mascota) {
                            _abrirDetalleMascota(mascota);
                          },
                          mascotasRecientes: _mascotasRecientes,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sección: menú flotante del home
            // Muestra el botón "+" y el panel animado de acciones del cliente.
            HomeClienteMenuFlotante(
              onRegistrarMascota: _accionRegistrarMascota,
              onCrearCita: _accionCrearCita,
            ),
          ],
        ),
      ),
    );
  }

  // Sección: header local del home
  // Se movió desde widgets para mantener esta vista autocontenida como solicitaste.
  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColores.base22FFFFFF,
              child: Text(
                _inicialCliente,
                style: const TextStyle(
                  color: AppColores.blanco,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColores.baseFFDCE8FF,
                  ),
                ),
                Text(
                  _nombreCliente,
                  style: TextStyle(
                    color: AppColores.blanco,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColores.base22FFFFFF,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColores.base55FFFFFF),
          ),
          child: IconButton(
            onPressed: _irABienvenida,
            icon: const Icon(Icons.logout, color: AppColores.blanco),
            tooltip: 'Salir',
          ),
        ),
      ],
    );
  }
}

// Sección: clipper local de curva inferior
// Se movió desde widgets para consolidar la forma del fondo en esta pantalla.
class _CurvaHomeClienteClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Sección: arranque de curva tipo arco
    // Se sube el inicio y se reduce la profundidad total del arco.
    path.moveTo(0, size.height * 0.40);

    // Sección: arco principal redondeado
    // Curva única amplia con menor altura para que no baje hasta el botón.
    path.cubicTo(
      size.width * 0.14,
      size.height * 0.58,
      size.width * 0.60,
      size.height * 0.78,
      size.width,
      size.height * 0.62,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
