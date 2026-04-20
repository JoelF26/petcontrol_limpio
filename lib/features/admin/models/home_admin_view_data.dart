// Seccion: imports
// Se importa material para usar IconData en modelos visuales.
import 'package:flutter/material.dart';

// Seccion: modelo de metrica
// Representa cada tarjeta de resumen del home admin.
class HomeAdminMetricaVista {
  const HomeAdminMetricaVista({
    required this.icono,
    required this.numero,
    required this.etiqueta,
  });

  final IconData icono;
  final String numero;
  final String etiqueta;
}

// Seccion: modelo de proxima cita
// Define la estructura de la cita destacada en home admin.
class HomeAdminProximaCitaVista {
  const HomeAdminProximaCitaVista({
    required this.idCita,
    required this.nombreMascota,
    required this.motivo,
    required this.fechaHoraTexto,
    required this.profesional,
    required this.estado,
  });

  final String idCita;
  final String nombreMascota;
  final String motivo;
  final String fechaHoraTexto;
  final String profesional;
  final String estado;

  // Seccion: texto de tarjeta
  // Provee strings listos para dibujar en card del home.
  String get tituloTarjeta => '$nombreMascota - $motivo';
  String get detalleTarjeta => '$fechaHoraTexto - $profesional';
}

// Seccion: modelo de dashboard admin
// Agrupa datos dinamicos que consume la pantalla home admin.
class HomeAdminDashboardData {
  const HomeAdminDashboardData({
    required this.idAdmin,
    required this.inicialDoctor,
    required this.nombreDoctor,
    required this.metricas,
    required this.proximasCitas,
  });

  final String idAdmin;
  final String inicialDoctor;
  final String nombreDoctor;
  final List<HomeAdminMetricaVista> metricas;
  final List<HomeAdminProximaCitaVista> proximasCitas;
}
