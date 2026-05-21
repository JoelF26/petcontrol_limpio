// Seccion: imports
// Se importan modelos y servicios usados por la logica de pacientes admin.
import 'package:petcontrol_limpio/features/admin/models/vista_pacientes_admin_view_data.dart';
import 'package:petcontrol_limpio/features/admin/widgets/pacientes/tarjeta_creacion_paciente.dart';
import 'package:petcontrol_limpio/domain/entities/mascota.dart';
import 'package:petcontrol_limpio/domain/entities/usuario.dart';
import 'package:petcontrol_limpio/application/services/mascota_service.dart';
import 'package:petcontrol_limpio/application/services/usuario_service.dart';

// Seccion: funciones de funcionamiento
// Centraliza carga, mapeo, filtros y registro de pacientes para la vista admin.
class VistaPacientesAdminFunciones {
  VistaPacientesAdminFunciones._();

  // Seccion: carga de pacientes
  // Consulta mascotas y usuarios, y devuelve una lista visual ordenada.
  static Future<List<PacienteVistaAdmin>> cargarPacientes({
    required MascotaService mascotaService,
    required UsuarioService usuarioService,
  }) async {
    final mascotas = await mascotaService.obtenerMascotas();
    final usuarios = await usuarioService.obtenerUsuarios();

    // Indexa usuarios una vez para resolver dueño sin buscar en la lista por cada mascota.
    final usuariosPorId = <String, Usuario>{
      for (final usuario in usuarios) usuario.idUsuario: usuario,
    };

    final pacientes =
        mascotas
            .map((mascota) => _mapearPacienteVista(mascota, usuariosPorId))
            .toList(growable: false)
          ..sort(
            (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
          );

    return pacientes;
  }

  // Seccion: mapeo a vista
  // Convierte Mascota + Usuario a modelo visual para tarjetas admin.
  static PacienteVistaAdmin _mapearPacienteVista(
    Mascota mascota,
    Map<String, Usuario> usuariosPorId,
  ) {
    // Si la mascota quedó huérfana de usuario, la tarjeta sigue renderizando con fallback.
    final dueno = usuariosPorId[mascota.idUsuario]?.nombreCompleto.trim() ?? '';
    final peso = mascota.pesoKg == null ? 0 : mascota.pesoKg!.round();
    final edad = mascota.edadAnios ?? 0;

    return PacienteVistaAdmin(
      idMascota: mascota.idMascota,
      nombre: mascota.nombreVisible,
      especie: mascota.especieVisible,
      raza: mascota.razaVisible,
      edad: edad,
      peso: peso,
      dueno: dueno.isEmpty ? 'Sin dueno' : dueno,
    );
  }

  // Seccion: filtro en memoria
  // Filtra por nombre, especie, raza o duenio segun el termino de busqueda.
  static List<PacienteVistaAdmin> filtrarPacientes({
    required List<PacienteVistaAdmin> pacientes,
    required String termino,
  }) {
    final q = termino.trim().toLowerCase();
    if (q.isEmpty) {
      return pacientes;
    }

    return pacientes
        .where((paciente) {
          return paciente.nombre.toLowerCase().contains(q) ||
              paciente.especie.toLowerCase().contains(q) ||
              paciente.raza.toLowerCase().contains(q) ||
              paciente.dueno.toLowerCase().contains(q);
        })
        .toList(growable: false);
  }

  // Seccion: total de especies
  // Cuenta especies unicas para el resumen superior.
  static int totalEspecies(List<PacienteVistaAdmin> pacientes) {
    return pacientes
        .map((paciente) => paciente.especie.toLowerCase())
        .toSet()
        .length;
  }

  // Seccion: parseo numerico
  // Acepta textos con unidades para no exigir entrada estrictamente numérica.
  static int? parsearEntero(String texto) {
    final coincidencia = RegExp(r'\d+').firstMatch(texto);
    return int.tryParse(coincidencia?.group(0) ?? '');
  }

  static double? parsearDouble(String texto) {
    final normalizado = texto.replaceAll(',', '.');
    final coincidencia = RegExp(r'\d+(\.\d+)?').firstMatch(normalizado);
    return double.tryParse(coincidencia?.group(0) ?? '');
  }

  // Seccion: registro de paciente
  // Valida entrada y persiste una mascota asociada al usuario seleccionado.
  static Future<void> registrarPacienteDesdeDialogo({
    required PacienteCreacionData data,
    required MascotaService mascotaService,
  }) async {
    // El formulario entrega texto; aquí se convierte al tipo que espera MascotaService.
    final edad = parsearEntero(data.edad);
    final peso = parsearDouble(data.peso);
    if (edad == null || peso == null) {
      throw const FormatException(
        'Edad y peso deben contener un valor numerico valido.',
      );
    }

    final idUsuario = data.idUsuario.trim();
    if (idUsuario.isEmpty) {
      throw StateError('Debes seleccionar un usuario registrado.');
    }

    await mascotaService.crearMascotaCliente(
      idUsuario: idUsuario,
      nombre: data.nombre,
      especie: data.especie,
      raza: data.raza,
      sexo: data.sexo,
      edadAnios: edad,
      pesoKg: peso,
    );
  }
}
