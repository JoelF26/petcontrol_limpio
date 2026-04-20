// Seccion: modelo de datos cargados
// Agrupa la data necesaria para renderizar la vista de citas admin.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/models/cita.dart';
import 'package:petcontrol_limpio/models/mascota.dart';
import 'package:petcontrol_limpio/models/personal_medico.dart';
import 'package:petcontrol_limpio/models/usuario.dart';

class CitasAdminCargaData {
  const CitasAdminCargaData({
    required this.citas,
    required this.mascotas,
    required this.usuariosPorId,
    required this.medicosPorId,
  });

  final List<Cita> citas;
  final List<Mascota> mascotas;
  final Map<String, Usuario> usuariosPorId;
  final Map<String, PersonalMedico> medicosPorId;
}

// Seccion: modelo visual de cita admin
// Estructura usada por tarjetas y secciones de agenda.
class CitaVistaAdmin {
  const CitaVistaAdmin({
    required this.idCita,
    required this.nombreMascota,
    required this.hora,
    required this.estado,
    required this.procedimiento,
    required this.descripcion,
    required this.icono,
    required this.iconoColor,
    required this.horaColor,
    required this.cajaHoraColor,
    required this.estadoBgColor,
    required this.estadoTextColor,
  });

  final String idCita;
  final String nombreMascota;
  final String hora;
  final String estado;
  final String procedimiento;
  final String descripcion;
  final IconData icono;
  final Color iconoColor;
  final Color horaColor;
  final Color cajaHoraColor;
  final Color estadoBgColor;
  final Color estadoTextColor;
}

// Seccion: estilo por estado
// Encapsula icono y colores para un estado de cita.
class CitaEstadoEstilo {
  const CitaEstadoEstilo({
    required this.icono,
    required this.iconoColor,
    required this.horaColor,
    required this.cajaHoraColor,
    required this.estadoBgColor,
    required this.estadoTextColor,
  });

  final IconData icono;
  final Color iconoColor;
  final Color horaColor;
  final Color cajaHoraColor;
  final Color estadoBgColor;
  final Color estadoTextColor;
}
