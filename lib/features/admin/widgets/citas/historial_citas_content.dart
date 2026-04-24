// Seccion: imports
// Se importan modelos y servicios para resolver la logica de historial admin.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/admin/models/historial_citas_view_data.dart';
import 'package:petcontrol_limpio/models/personal_medico.dart';
import 'package:petcontrol_limpio/models/usuario.dart';
import 'package:petcontrol_limpio/services/cita_service.dart';
import 'package:petcontrol_limpio/services/personal_medico_service.dart';
import 'package:petcontrol_limpio/services/usuario_service.dart';

// Seccion: funciones de funcionamiento de historial
// Centraliza carga, filtros y utilidades para que la pantalla quede enfocada en IU.
class HistorialCitasFunciones {
  HistorialCitasFunciones._();

  // Seccion: carga de historial
  // Consulta citas, usuarios y medicos para construir la lista visual final.
  static Future<List<HistorialCitaVista>> cargarHistorial({
    required CitaService citaService,
    required UsuarioService usuarioService,
    required PersonalMedicoService personalMedicoService,
  }) async {
    final citas = await citaService.obtenerCitas();
    final usuarios = await usuarioService.obtenerUsuarios();
    final medicos = await personalMedicoService.obtenerPersonalMedico();

    final usuariosPorId = <String, Usuario>{
      for (final usuario in usuarios) usuario.idUsuario: usuario,
    };
    final medicosPorId = <String, PersonalMedico>{
      for (final medico in medicos) medico.idMedico: medico,
    };

    final historial =
        citas
            .map((cita) {
              final fechaBase = cita.fechaHora ?? cita.fechaOrden;
              final dueno =
                  usuariosPorId[cita.idUsuario]?.nombreCompleto.trim() ??
                  'Sin dueno';
              final doctor =
                  medicosPorId[cita.idMedico]?.nombreCompleto.trim() ??
                  'Sin doctor';
              final estado = cita.estadoVisible.toLowerCase();

              return HistorialCitaVista(
                nombreMascota: cita.nombreMascotaVisible,
                especie: cita.especieMascotaVisible,
                estado: estado,
                procedimiento: cita.motivoVisible,
                fechaHora: fechaBase,
                doctor: doctor,
                dueno: dueno,
                descripcion: cita.descripcionVisible,
              );
            })
            .toList(growable: false)
          ..sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

    return historial;
  }

  // Seccion: filtro por rango
  // Convierte el texto del filtro de fecha en numero de dias.
  static int? diasParaRango(String rango) {
    switch (rango) {
      case 'Ultimos 7 dias':
        return 7;
      case 'Ultimos 30 dias':
        return 30;
      case 'Ultimos 90 dias':
        return 90;
      default:
        return null;
    }
  }

  // Seccion: filtrado de historial
  // Aplica filtros activos y ordena por fecha descendente.
  static List<HistorialCitaVista> filtrarHistorial({
    required List<HistorialCitaVista> historial,
    required String estadoSeleccionado,
    required String especieSeleccionada,
    required String fechaSeleccionada,
    required String estadoTodos,
    required String especieTodas,
  }) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final diasFiltro = diasParaRango(fechaSeleccionada);

    final filtradas = historial
        .where((cita) {
          final coincideEstado =
              estadoSeleccionado == estadoTodos ||
              cita.estado == estadoSeleccionado;
          final coincideEspecie =
              especieSeleccionada == especieTodas ||
              cita.especie == especieSeleccionada;
          final coincideFecha = diasFiltro == null
              ? true
              : !cita.fechaHora.isBefore(
                  hoy.subtract(Duration(days: diasFiltro)),
                );
          return coincideEstado && coincideEspecie && coincideFecha;
        })
        .toList(growable: false);

    final ordenadas = filtradas.toList(growable: false)
      ..sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
    return ordenadas;
  }

  // Seccion: conteo por estado
  // Cuenta elementos con estado exacto dentro de una lista filtrada.
  static int contarEstado(List<HistorialCitaVista> citas, String estado) {
    return citas.where((cita) => cita.estado == estado).length;
  }

  // Seccion: formato de fecha
  // Convierte DateTime a texto corto para tarjetas y popup de detalle.
  static String formatearFecha(DateTime fecha) {
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
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = meses[fecha.month - 1];
    final anio = fecha.year.toString();
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$dia $mes $anio - $hora:$minuto';
  }

  // Seccion: color de fondo por estado
  // Define el color de fondo del badge segun estado de la cita.
  static Color colorFondoEstado(String estado) {
    switch (estado) {
      case 'finalizada':
        return AppColores.baseFFCFE5DD;
      case 'cancelada':
        return AppColores.baseFFF1D1D1;
      case 'reprogramada':
        return AppColores.baseFFE9DBC7;
      default:
        return AppColores.baseFFD8DEE2;
    }
  }

  // Seccion: color de texto por estado
  // Define el color de texto del badge segun estado de la cita.
  static Color colorTextoEstado(String estado) {
    switch (estado) {
      case 'finalizada':
        return AppColores.baseFF2D8A6C;
      case 'cancelada':
        return AppColores.baseFF9D3B3B;
      case 'reprogramada':
        return AppColores.baseFF8A6A40;
      default:
        return AppColores.baseFF4E5A62;
    }
  }

  // Seccion: icono por estado
  // Selecciona el icono a renderizar segun estado de la cita.
  static IconData iconoEstado(String estado) {
    switch (estado) {
      case 'finalizada':
        return Icons.check_circle_outline_rounded;
      case 'cancelada':
        return Icons.cancel_outlined;
      case 'reprogramada':
        return Icons.event_repeat_outlined;
      default:
        return Icons.event_note_outlined;
    }
  }
}
