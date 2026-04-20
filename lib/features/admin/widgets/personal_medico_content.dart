// Seccion: imports
// Se importan utilidades y servicios para la logica de personal medico.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petcontrol_limpio/core/constants/roles_usuario.dart';
import 'package:petcontrol_limpio/features/admin/models/personal_medico_view_data.dart';
import 'package:petcontrol_limpio/models/personal_medico.dart';
import 'package:petcontrol_limpio/models/usuario.dart';
import 'package:petcontrol_limpio/services/personal_medico_service.dart';
import 'package:petcontrol_limpio/services/usuario_service.dart';
import 'package:uuid/uuid.dart';

// Seccion: funciones de funcionamiento
// Agrupa transformaciones, filtros y persistencia de personal medico.
class PersonalMedicoFunciones {
  PersonalMedicoFunciones._();

  // Seccion: carga desde backend
  // Consulta personal medico y usuarios para construir la lista visual.
  static Future<List<MedicoVista>> cargarPersonalMedico({
    required PersonalMedicoService personalMedicoService,
    required UsuarioService usuarioService,
  }) async {
    final personal = await personalMedicoService.obtenerPersonalMedico();
    final usuarios = await usuarioService.obtenerUsuarios();

    final usuarioPorCorreo = <String, Usuario>{
      for (final usuario in usuarios)
        usuario.correo.trim().toLowerCase(): usuario,
    };

    final lista = personal
        .map((medico) {
          final usuario = usuarioPorCorreo[medico.correo.trim().toLowerCase()];
          final estado = medico.estadoVisible;
          final fechaIngreso =
              DateTime.tryParse(medico.createdAt) ?? DateTime.now();
          final jornadaLimpia = medico.jornada.trim();
          final documentoLimpio = medico.documento.trim().isNotEmpty
              ? medico.documento.trim()
              : (usuario?.numeroDocumento.trim() ?? '');

          return MedicoVista(
            id: medico.idMedico,
            nombreCompleto: medico.nombreCompleto,
            correo: medico.correo,
            telefono: medico.telefono,
            documento: documentoLimpio.isEmpty ? 'Sin documento' : documentoLimpio,
            especialidad: medico.especialidad,
            jornada: jornadaLimpia.isEmpty ? 'Sin jornada' : jornadaLimpia,
            estado: estado,
            fechaIngreso: fechaIngreso,
          );
        })
        .toList(growable: false)
      ..sort((a, b) => a.nombreCompleto.compareTo(b.nombreCompleto));

    return lista;
  }

  // Seccion: filtrado por busqueda
  // Filtra por nombre, especialidad o correo y ordena alfabeticamente.
  static List<MedicoVista> filtrarPersonal({
    required List<MedicoVista> personal,
    required String busqueda,
  }) {
    final q = busqueda.trim().toLowerCase();
    final filtrada = personal.where((m) {
      final okTexto =
          q.isEmpty ||
          m.nombreCompleto.toLowerCase().contains(q) ||
          m.especialidad.toLowerCase().contains(q) ||
          m.correo.toLowerCase().contains(q);
      return okTexto;
    }).toList();

    filtrada.sort((a, b) => a.nombreCompleto.compareTo(b.nombreCompleto));
    return filtrada;
  }

  // Seccion: conteo por estado
  // Cuenta cuantos registros cumplen el estado solicitado.
  static int conteoEstado(List<MedicoVista> personal, String estado) {
    return personal.where((m) => m.estado == estado).length;
  }

  // Seccion: utilidades de presentacion
  // Calcula iniciales, colores de estado y fecha formateada.
  static String iniciales(String nombre) {
    final p = nombre.trim().split(RegExp(r'\s+'));
    if (p.isEmpty || p.first.isEmpty) {
      return 'M';
    }
    if (p.length == 1) {
      return p.first.substring(0, 1).toUpperCase();
    }
    return '${p[0][0]}${p[1][0]}'.toUpperCase();
  }

  static Color estadoBg(String estado) {
    switch (estado) {
      case 'Activo':
        return const Color(0xFFCFE5DD);
      case 'Vacaciones':
        return const Color(0xFFE9DBC7);
      default:
        return const Color(0xFFF1D1D1);
    }
  }

  static Color estadoText(String estado) {
    switch (estado) {
      case 'Activo':
        return const Color(0xFF2D8A6C);
      case 'Vacaciones':
        return const Color(0xFF8A6A40);
      default:
        return const Color(0xFF9D3B3B);
    }
  }

  static String fecha(DateTime f) {
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
    return '${f.day.toString().padLeft(2, '0')} ${meses[f.month - 1]} ${f.year}';
  }

  // Seccion: registro de personal medico
  // Crea/actualiza usuario admin y guarda medico en su entidad.
  static Future<void> registrarPersonalMedico({
    required NuevoMedicoInput input,
    required List<MedicoVista> personalActual,
    required PersonalMedicoService personalMedicoService,
    required UsuarioService usuarioService,
    Uuid uuid = const Uuid(),
  }) async {
    final correo = input.correo.trim().toLowerCase();
    final existeCorreoEnPersonal = personalActual.any(
      (medico) => medico.correo.trim().toLowerCase() == correo,
    );
    if (existeCorreoEnPersonal) {
      throw StateError('Ya existe personal medico con ese correo.');
    }

    final ahora = DateTime.now();
    final idMedico = uuid.v4();
    final contrasenaInicial =
        input.documento.trim().isEmpty ? 'Admin123456' : input.documento.trim();

    final personal = PersonalMedico(
      idMedico: idMedico,
      nombreCompleto: input.nombreCompleto.trim(),
      especialidad: input.especialidad.trim(),
      telefono: input.telefono.trim(),
      correo: correo,
      activo: input.estado != 'Inactivo',
      fechaCreacion: DateFormat('yyyy-MM-dd').format(ahora),
      createdAt: ahora.toIso8601String(),
      documento: input.documento.trim(),
      jornada: input.jornada.trim(),
      estado: input.estado.trim(),
    );

    final usuarioExistente = await usuarioService.obtenerUsuarioPorCorreo(correo);
    if (usuarioExistente == null) {
      await usuarioService.crearUsuario(
        Usuario(
          idUsuario: idMedico,
          nombreCompleto: input.nombreCompleto.trim(),
          numeroDocumento: input.documento.trim(),
          telefono: input.telefono.trim(),
          correo: correo,
          contrasena: contrasenaInicial,
          rol: RolesUsuario.admin,
          fechaCreacion: DateFormat('yyyy-MM-dd').format(ahora),
          createdAt: ahora.toIso8601String(),
        ),
      );
    } else {
      await usuarioService.actualizarUsuario(
        usuarioExistente.copyWith(
          nombreCompleto: input.nombreCompleto.trim(),
          numeroDocumento: input.documento.trim(),
          telefono: input.telefono.trim(),
          rol: RolesUsuario.admin,
        ),
      );
    }

    await personalMedicoService.crearMedico(personal);
  }
}
