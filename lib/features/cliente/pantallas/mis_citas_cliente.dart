// Sección: imports
// Se importan modelos, servicios y tarjeta de creación para conectar la vista con backend.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/core/di/app_dependencies.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/citas/detalle_cita_cliente_popup.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/citas/tarjeta_creacion_cita.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/citas/mis_citas/mis_citas_cliente_widgets.dart';
import 'package:petcontrol_limpio/domain/entities/cita.dart';
import 'package:petcontrol_limpio/application/services/auth_service.dart';
import 'package:petcontrol_limpio/application/services/cita_service.dart';
import 'package:petcontrol_limpio/application/services/mascota_service.dart';

// Sección: pantalla de citas del cliente
// Muestra todas las citas del usuario autenticado y permite registrar nuevas.
class MisCitasCliente extends StatefulWidget {
  const MisCitasCliente({super.key});

  @override
  State<MisCitasCliente> createState() => _MisCitasClienteState();
}

// Sección: estado de Mis Citas
// Gestiona consultas a JSON local, métricas dinámicas y apertura del formulario de cita.
class _MisCitasClienteState extends State<MisCitasCliente> {
  // Sección: servicios de backend
  // Se reutilizan para obtener usuario actual, citas y conteo de mascotas.
  final AuthService _authService = AppDependencies.authService;
  final CitaService _citaService = AppDependencies.citaService;
  final MascotaService _mascotaService = AppDependencies.mascotaService;

  // Sección: estado principal de la vista
  // Guarda datos del usuario y resultados para renderizar UI dinámica.
  bool _cargando = true;
  String _nombreCliente = 'Cliente';
  int _totalMascotas = 0;
  List<Cita> _citas = const <Cita>[];
  StreamSubscription<List<Cita>>? _citasSubscription;

  // Sección: inicialización de pantalla
  // Carga datos del usuario y su agenda al abrir la vista.
  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Sección: carga de datos de backend
  // Consulta citas y métricas del usuario autenticado desde JSON local.
  Future<void> _cargarDatos() async {
    try {
      final usuario = await _authService.obtenerUsuarioActual();
      final idUsuario = _resolverIdUsuario(usuario?.idUsuario);
      final nombre = _resolverNombreVisible(usuario?.nombreCompleto);

      if (idUsuario.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() {
          _nombreCliente = nombre;
          _totalMascotas = 0;
          _citas = const <Cita>[];
          _cargando = false;
        });
        return;
      }

      // Citas y conteo de mascotas no dependen entre sí, por eso se consultan juntas.
      final resultados = await Future.wait<dynamic>([
        _citaService.obtenerCitasPorUsuario(idUsuario),
        _mascotaService.contarMascotasPorUsuario(idUsuario),
      ]);
      final citas = (resultados[0] as List<Cita>).toList(growable: false);
      final totalMascotas = resultados[1] as int;

      if (!mounted) {
        return;
      }
      // Si falla la lectura local, la vista queda vacía y sin bloquear navegación.
      setState(() {
        _nombreCliente = nombre;
        _totalMascotas = totalMascotas;
        _citas = citas;
        _cargando = false;
      });
      _suscribirCitas(idUsuario);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _nombreCliente = _resolverNombreVisible(null);
        _totalMascotas = 0;
        _citas = const <Cita>[];
        _cargando = false;
      });
    }
  }

  void _suscribirCitas(String idUsuario) {
    _citasSubscription?.cancel();
    _citasSubscription = _citaService.observarCitas().listen((citas) {
      if (!mounted) {
        return;
      }
      final filtradas = _citaService.filtrarCitasVisiblesPorUsuario(
        citas,
        idUsuario,
      );
      setState(() {
        _citas = filtradas;
        _cargando = false;
      });
    });
  }

  @override
  void dispose() {
    _citasSubscription?.cancel();
    super.dispose();
  }

  // Sección: id de usuario para consultas
  // Prioriza id del perfil y usa uid de autenticación local como respaldo.
  String _resolverIdUsuario(String? idPerfil) {
    return (idPerfil ?? '').trim();
  }

  // Sección: nombre visible del cliente
  // Usa nombre de perfil y, si falta, construye un alias desde el correo.
  String _resolverNombreVisible(String? nombrePerfil) {
    final nombreLimpio = (nombrePerfil ?? '').trim();
    if (nombreLimpio.isNotEmpty) {
      return nombreLimpio;
    }
    return 'Cliente';
  }

  // Sección: resumen de citas próximas
  // Cuenta estados "proxima" y "pendiente" como próximas a atender.
  int get _totalProximas {
    return _citas.where((cita) {
      final estado = cita.estadoVisible.toLowerCase();
      return estado == 'proxima' || estado == 'pendiente';
    }).length;
  }

  // Sección: apertura de formulario de cita
  // Muestra popup centrado con fondo oscuro y refresca datos al guardar.
  Future<void> _abrirCreacionCita() async {
    if (!mounted) {
      return;
    }

    final creada = await showDialog<bool>(
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

    // El popup retorna true solo cuando CitaService terminó de guardar.
    if (creada == true) {
      await _cargarDatos();
    }
  }

  // Sección: apertura de detalle de cita
  // Muestra la ficha completa y recarga datos si hay edición guardada.
  Future<void> _abrirDetalleCita(Cita cita) async {
    if (!mounted) {
      return;
    }
    final actualizada = await mostrarDetalleCitaCliente(context, cita);
    // Recarga porque el detalle puede editar, cancelar o reprogramar la cita.
    if (actualizada) {
      await _cargarDatos();
    }
  }

  // Sección: construcción de la pantalla
  // Mantiene el diseño visual de cabecera y agenda con datos reales.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.baseFFF2F5FA,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
        width: 62,
        height: 62,
        // Botón: abre el formulario para crear una nueva cita del cliente.
        child: FloatingActionButton(
          onPressed: _abrirCreacionCita,
          backgroundColor: AppColores.baseFF153A5F,
          foregroundColor: AppColores.blanco,
          child: const Icon(Icons.add, size: 34),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: FondoMisCitas()),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EncabezadoMisCitas(
                    onVolver: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 14),
                  ResumenCitasCliente(
                    totalCitas: _citas.length,
                    totalProximas: _totalProximas,
                    totalMascotasConCita: _totalMascotas,
                  ),
                  const SizedBox(height: 20),
                  PanelAgendaPersonal(
                    cargando: _cargando,
                    citas: _citas,
                    nombreCliente: _nombreCliente,
                    onTapCita: _abrirDetalleCita,
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
