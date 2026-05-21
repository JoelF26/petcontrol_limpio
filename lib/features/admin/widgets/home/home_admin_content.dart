// Seccion: imports
// Se importan rutas, popup, roles, modelos y servicios para el home admin dinamico.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/core/di/app_dependencies.dart';
import 'package:petcontrol_limpio/domain/constants/roles_usuario.dart';
import 'package:petcontrol_limpio/core/routes/rutas.dart';
import 'package:petcontrol_limpio/core/widgets/popup_detalle.dart';
import 'package:petcontrol_limpio/features/admin/models/home_admin_view_data.dart';
import 'package:petcontrol_limpio/domain/entities/cita.dart';
import 'package:petcontrol_limpio/domain/entities/mascota.dart';
import 'package:petcontrol_limpio/domain/entities/personal_medico.dart';
import 'package:petcontrol_limpio/application/services/auth_service.dart';
import 'package:petcontrol_limpio/application/services/cita_service.dart';
import 'package:petcontrol_limpio/application/services/mascota_service.dart';
import 'package:petcontrol_limpio/application/services/personal_medico_service.dart';

// Seccion: funciones de home admin
// Agrupa carga dinamica, logout, navegacion y popup de detalle.
class HomeAdminFunciones {
  HomeAdminFunciones._();

  // Seccion: carga de dashboard admin
  // Resuelve usuario de sesion, valida rol admin y construye metricas reales.
  static Future<HomeAdminDashboardData> cargarDashboardAdmin({
    AuthService? authService,
    MascotaService? mascotaService,
    CitaService? citaService,
    PersonalMedicoService? personalMedicoService,
  }) async {
    final auth = authService ?? AppDependencies.authService;
    final mascotasSrv = mascotaService ?? AppDependencies.mascotaService;
    final citasSrv = citaService ?? AppDependencies.citaService;
    final personalSrv =
        personalMedicoService ?? AppDependencies.personalMedicoService;

    final usuarioActual = await auth.obtenerUsuarioActual();
    if (usuarioActual == null) {
      throw StateError('No hay sesión activa.');
    }

    if (usuarioActual.rol != RolesUsuario.admin) {
      throw StateError('El usuario actual no tiene rol admin.');
    }

    // Las métricas son independientes, así que se consultan en paralelo.
    final resultados = await Future.wait<dynamic>(<Future<dynamic>>[
      mascotasSrv.obtenerMascotas(),
      citasSrv.obtenerCitas(),
      personalSrv.obtenerPersonalMedico(),
    ]);

    final mascotas = resultados[0] as List<Mascota>;
    final citas = resultados[1] as List<Cita>;
    final personal = resultados[2] as List<PersonalMedico>;

    final metricas = <HomeAdminMetricaVista>[
      HomeAdminMetricaVista(
        icono: Icons.pets,
        numero: '${mascotas.length}',
        etiqueta: 'Pacientes',
      ),
      HomeAdminMetricaVista(
        icono: Icons.receipt_long_outlined,
        numero: '${citas.length}',
        etiqueta: 'Citas',
      ),
      HomeAdminMetricaVista(
        icono: Icons.people_outline,
        numero: '${personal.length}',
        etiqueta: 'Personal',
      ),
    ];

    // Sirve para resolver el nombre del profesional en las próximas citas.
    final medicosPorId = <String, PersonalMedico>{
      for (final medico in personal) medico.idMedico: medico,
    };
    final proximasCitas = _construirProximasCitas(
      citas: citasSrv.filtrarCitasActivas(citas),
      medicosPorId: medicosPorId,
    );

    return HomeAdminDashboardData(
      idAdmin: usuarioActual.idUsuario,
      inicialDoctor: _resolverInicial(usuarioActual.nombreCompleto),
      nombreDoctor: usuarioActual.nombreCompleto.trim().isEmpty
          ? 'Administrador'
          : usuarioActual.nombreCompleto.trim(),
      metricas: metricas,
      proximasCitas: proximasCitas,
    );
  }

  // Seccion: construccion de proximas citas
  // Selecciona hasta 2 citas proximas del sistema para el panel principal.
  static List<HomeAdminProximaCitaVista> _construirProximasCitas({
    required List<Cita> citas,
    required Map<String, PersonalMedico> medicosPorId,
  }) {
    final ahora = DateTime.now();
    final ordenadas = citas.toList(growable: false)
      ..sort((a, b) => a.fechaOrden.compareTo(b.fechaOrden));

    // Solo muestra citas futuras; las pasadas quedan para historial.
    final futuras = ordenadas
        .where((cita) {
          final fecha = cita.fechaHora;
          if (fecha == null) {
            return false;
          }
          return !fecha.isBefore(ahora);
        })
        .toList(growable: false);

    if (futuras.isEmpty) {
      return const <HomeAdminProximaCitaVista>[];
    }

    // Seccion: limite visual de proximas citas
    // Restringe el bloque del home admin a un maximo de 2 elementos.
    return futuras
        .take(2)
        .map((cita) {
          final profesional =
              medicosPorId[cita.idMedico]?.nombreCompleto.trim() ?? '';
          return HomeAdminProximaCitaVista(
            idCita: cita.idCita,
            nombreMascota: cita.nombreMascotaVisible,
            motivo: cita.motivoVisible,
            fechaHoraTexto: _resolverFechaHoraCorta(cita),
            profesional: profesional.isEmpty ? 'Sin profesional' : profesional,
            estado: cita.estadoVisible,
          );
        })
        .toList(growable: false);
  }

  // Seccion: formato breve de fecha
  // Genera texto compacto para el subtitulo de la proxima cita.
  static String _resolverFechaHoraCorta(Cita cita) {
    // Si el registro no tiene DateTime parseado, delega al texto visible del modelo.
    final fechaHora = cita.fechaHora;
    if (fechaHora == null) {
      return cita.fechaHoraVisible;
    }

    final ahora = DateTime.now();
    final esMismoDia =
        fechaHora.year == ahora.year &&
        fechaHora.month == ahora.month &&
        fechaHora.day == ahora.day;

    final hora =
        '${_dosDigitos(fechaHora.hour)}:${_dosDigitos(fechaHora.minute)}';
    if (esMismoDia) {
      return 'Hoy $hora';
    }

    return '${_dosDigitos(fechaHora.day)}/${_dosDigitos(fechaHora.month)} $hora';
  }

  static String _dosDigitos(int valor) {
    return valor.toString().padLeft(2, '0');
  }

  static String _resolverInicial(String nombreCompleto) {
    final limpio = nombreCompleto.trim();
    if (limpio.isEmpty) {
      return 'A';
    }

    final partes = limpio.split(RegExp(r'\s+'));
    return partes.first.substring(0, 1).toUpperCase();
  }

  // Seccion: logout
  // Cierra sesion y redirige a bienvenida limpiando stack.
  static Future<void> cerrarSesionYSalir(BuildContext context) async {
    await AppDependencies.authService.cerrarSesion();
    if (!context.mounted) {
      return;
    }
    // Limpia el stack para impedir volver al panel con el botón atrás.
    Navigator.pushNamedAndRemoveUntil(context, Rutas.bienvenida, (_) => false);
  }

  // Seccion: navegacion de modulos
  // Redirige a las vistas principales del panel admin.
  static void irPacientes(BuildContext context) {
    Navigator.pushNamed(context, Rutas.adminPacientes);
  }

  static void irCitas(BuildContext context) {
    Navigator.pushNamed(context, Rutas.adminCitas);
  }

  static void irHistorial(BuildContext context) {
    Navigator.pushNamed(context, Rutas.adminHistorialCitas);
  }

  static void irPersonalMedico(BuildContext context) {
    Navigator.pushNamed(context, Rutas.adminPersonalMedico);
  }

  // Seccion: detalle de proxima cita
  // Abre popup de detalle usando el modelo dinamico de la cita destacada.
  static void abrirDetalleProximaCita(
    BuildContext context,
    HomeAdminProximaCitaVista cita,
  ) {
    mostrarPopupDetalle(
      context,
      ConfigPopupDetalle(
        titulo: cita.nombreMascota,
        subtitulo: 'Detalle de proxima cita',
        icono: Icons.event_note_outlined,
        colorAcento: AppColores.baseFF2D8A6C,
        chips: <String>[cita.estado, 'Home Admin'],
        campos: <DetalleCampo>[
          DetalleCampo(etiqueta: 'Mascota', valor: cita.nombreMascota),
          DetalleCampo(etiqueta: 'Motivo', valor: cita.motivo),
          DetalleCampo(etiqueta: 'Fecha y hora', valor: cita.fechaHoraTexto),
          DetalleCampo(etiqueta: 'Profesional', valor: cita.profesional),
          DetalleCampo(etiqueta: 'Estado', valor: cita.estado),
        ],
      ),
    );
  }
}
