// Seccion: imports
// Se importan modelos, servicios y helpers de formulario para logica de citas admin.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/core/constants/roles_usuario.dart';
import 'package:petcontrol_limpio/features/admin/models/vista_cita_admin_view_data.dart';
import 'package:petcontrol_limpio/features/admin/widgets/citas/tarjeta_creacion_cita.dart';
import 'package:petcontrol_limpio/models/cita.dart';
import 'package:petcontrol_limpio/models/mascota.dart';
import 'package:petcontrol_limpio/models/personal_medico.dart';
import 'package:petcontrol_limpio/models/usuario.dart';
import 'package:petcontrol_limpio/services/cita_service.dart';
import 'package:petcontrol_limpio/services/mascota_service.dart';
import 'package:petcontrol_limpio/services/personal_medico_service.dart';
import 'package:petcontrol_limpio/services/usuario_service.dart';

// Seccion: funciones de funcionamiento
// Centraliza carga, mapeos, filtros y estilos para la vista de citas admin.
class VistaCitaAdminFunciones {
  VistaCitaAdminFunciones._();

  // Seccion: carga integral de datos
  // Trae citas, mascotas, usuarios y medicos para construir la vista.
  static Future<CitasAdminCargaData> cargarDatos({
    required CitaService citaService,
    required MascotaService mascotaService,
    required UsuarioService usuarioService,
    required PersonalMedicoService personalMedicoService,
  }) async {
    final citas = await citaService.obtenerCitas();
    final mascotas = await mascotaService.obtenerMascotas();
    final usuarios = await usuarioService.obtenerUsuarios();
    final medicos = await personalMedicoService.obtenerPersonalMedico();

    final citasOrdenadas = citas.toList(growable: false)
      ..sort((a, b) => a.fechaOrden.compareTo(b.fechaOrden));

    final usuariosPorId = <String, Usuario>{
      for (final usuario in usuarios) usuario.idUsuario: usuario,
    };

    final medicosPorId = <String, PersonalMedico>{
      for (final medico in medicos) medico.idMedico: medico,
    };

    return CitasAdminCargaData(
      citas: citasOrdenadas,
      mascotas: mascotas,
      usuariosPorId: usuariosPorId,
      medicosPorId: medicosPorId,
    );
  }

  // Seccion: bloques de agenda
  // Separa citas en hoy y proximas para mantener la estructura visual.
  static List<Cita> citasHoy(List<Cita> citas) {
    final ahora = DateTime.now();
    final inicioDia = DateTime(ahora.year, ahora.month, ahora.day);
    final finDia = inicioDia.add(const Duration(days: 1));
    return citas
        .where((cita) {
          final fecha = cita.fechaHora;
          if (fecha == null) {
            return false;
          }
          return !fecha.isBefore(inicioDia) && fecha.isBefore(finDia);
        })
        .toList(growable: false);
  }

  static List<Cita> citasProximas(List<Cita> citas) {
    final ahora = DateTime.now();
    final finDia = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
    ).add(const Duration(days: 1));
    return citas
        .where((cita) {
          final fecha = cita.fechaHora;
          if (fecha == null) {
            return true;
          }
          return !fecha.isBefore(finDia);
        })
        .toList(growable: false);
  }

  static int contarConfirmadas(List<Cita> citas) {
    return citas
        .where((cita) => cita.estadoVisible.toLowerCase() == 'confirmada')
        .length;
  }

  // Seccion: opciones para formulario
  // Convierte usuarios/mascotas de dominio a modelos del formulario admin.
  static List<UsuarioRegistradoMock> construirUsuariosFormulario(
    Map<String, Usuario> usuariosPorId,
  ) {
    final usuariosCliente =
        usuariosPorId.values
            .where((usuario) => usuario.rol != RolesUsuario.admin)
            .toList(growable: false)
          ..sort(
            (a, b) => a.nombreCompleto.toLowerCase().compareTo(
              b.nombreCompleto.toLowerCase(),
            ),
          );

    return usuariosCliente
        .map(
          (usuario) => UsuarioRegistradoMock(
            id: usuario.idUsuario,
            nombre: usuario.nombreCompleto,
          ),
        )
        .toList(growable: false);
  }

  static List<MascotaRegistradaMock> construirMascotasFormulario(
    List<Mascota> mascotas,
  ) {
    return mascotas
        .map(
          (mascota) => MascotaRegistradaMock(
            id: mascota.idMascota,
            nombre: mascota.nombreVisible,
            especie: mascota.especieVisible,
            usuarioId: mascota.idUsuario,
          ),
        )
        .toList(growable: false);
  }

  static List<MedicoRegistradoMock> construirMedicosFormulario(
    Map<String, PersonalMedico> medicosPorId,
  ) {
    final medicos = medicosPorId.values.toList(growable: false)
      ..sort(
        (a, b) => a.nombreCompleto.toLowerCase().compareTo(
          b.nombreCompleto.toLowerCase(),
        ),
      );

    return medicos
        .map(
          (medico) => MedicoRegistradoMock(
            id: medico.idMedico,
            nombre: medico.nombreCompleto,
          ),
        )
        .toList(growable: false);
  }

  // Seccion: busquedas puntuales
  // Busca entidad por id para detalles y creacion.
  static Mascota? buscarMascotaPorId(List<Mascota> mascotas, String idMascota) {
    for (final mascota in mascotas) {
      if (mascota.idMascota == idMascota) {
        return mascota;
      }
    }
    return null;
  }

  static Cita? buscarCitaPorId(List<Cita> citas, String idCita) {
    for (final cita in citas) {
      if (cita.idCita == idCita) {
        return cita;
      }
    }
    return null;
  }

  // Seccion: mapeo de visualizacion
  // Convierte una cita de dominio al modelo usado por tarjetas.
  static CitaVistaAdmin mapearCitaVista(Cita cita) {
    final estilo = estiloEstado(cita.estadoVisible);
    return CitaVistaAdmin(
      idCita: cita.idCita,
      nombreMascota: cita.nombreMascotaVisible,
      hora: resolverHora(cita),
      estado: cita.estadoVisible,
      procedimiento: cita.motivoVisible,
      descripcion: cita.descripcionVisible,
      icono: estilo.icono,
      iconoColor: estilo.iconoColor,
      horaColor: estilo.horaColor,
      cajaHoraColor: estilo.cajaHoraColor,
      estadoBgColor: estilo.estadoBgColor,
      estadoTextColor: estilo.estadoTextColor,
    );
  }

  static String resolverHora(Cita cita) {
    if (cita.fechaHora != null) {
      final fecha = cita.fechaHora!;
      final hora = fecha.hour.toString().padLeft(2, '0');
      final minuto = fecha.minute.toString().padLeft(2, '0');
      return '$hora:$minuto';
    }
    final horaTexto = cita.horaTexto.trim();
    if (horaTexto.isEmpty) {
      return '--:--';
    }
    return horaTexto;
  }

  // Seccion: estilo por estado
  // Define paleta visual e icono segun estado textual.
  static CitaEstadoEstilo estiloEstado(String estadoRaw) {
    final estado = estadoRaw.toLowerCase();
    if (estado.contains('cancel')) {
      return const CitaEstadoEstilo(
        icono: Icons.cancel_outlined,
        iconoColor: AppColores.baseFF9D3B3B,
        horaColor: AppColores.baseFF7F3A3A,
        cajaHoraColor: AppColores.baseFFF3E2E2,
        estadoBgColor: AppColores.baseFFF1D1D1,
        estadoTextColor: AppColores.baseFF9D3B3B,
      );
    }
    if (estado.contains('confirm')) {
      return const CitaEstadoEstilo(
        icono: Icons.verified_outlined,
        iconoColor: AppColores.baseFF2A6A4F,
        horaColor: AppColores.baseFF2A6A4F,
        cajaHoraColor: AppColores.baseFFE3F1E7,
        estadoBgColor: AppColores.baseFFD5E9DA,
        estadoTextColor: AppColores.baseFF2A6A4F,
      );
    }
    if (estado.contains('reprogram')) {
      return const CitaEstadoEstilo(
        icono: Icons.event_repeat_outlined,
        iconoColor: AppColores.baseFF8A6A40,
        horaColor: AppColores.baseFF8A6A40,
        cajaHoraColor: AppColores.baseFFF0E7DA,
        estadoBgColor: AppColores.baseFFE9DBC7,
        estadoTextColor: AppColores.baseFF8A6A40,
      );
    }
    return const CitaEstadoEstilo(
      icono: Icons.calendar_today_rounded,
      iconoColor: AppColores.baseFF2D8A6C,
      horaColor: AppColores.baseFF315449,
      cajaHoraColor: AppColores.baseFFDDEDE5,
      estadoBgColor: AppColores.baseFFCFE5DD,
      estadoTextColor: AppColores.baseFF2D8A6C,
    );
  }
}
