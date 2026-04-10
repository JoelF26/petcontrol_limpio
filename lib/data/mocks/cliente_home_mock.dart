// Sección: imports
// Se importa Material para usar IconData en los modelos de tarjetas y acciones.
import 'package:flutter/material.dart';

// Sección: modelo de acción rápida
// Representa cada opción visible en el menú flotante del home del cliente.
class AccionRapidaClienteHomeMock {
  const AccionRapidaClienteHomeMock({
    required this.id,
    required this.titulo,
    required this.icono,
  });

  final String id;
  final String titulo;
  final IconData icono;
}

// Sección: modelo de resumen
// Define los datos de las tarjetas de resumen de mascotas y citas.
class ResumenClienteMock {
  const ResumenClienteMock({
    required this.id,
    required this.etiqueta,
    required this.valor,
    required this.icono,
  });

  final String id;
  final String etiqueta;
  final String valor;
  final IconData icono;
}

// Sección: modelo de cita del cliente
// Agrupa la información visible en tarjetas y detalle de cita.
class CitaClienteMock {
  const CitaClienteMock({
    required this.nombreMascota,
    required this.especieMascota,
    required this.fecha,
    required this.hora,
    required this.motivo,
    required this.estado,
    required this.veterinario,
    required this.sede,
    required this.descripcion,
  });

  final String nombreMascota;
  final String especieMascota;
  final String fecha;
  final String hora;
  final String motivo;
  final String estado;
  final String veterinario;
  final String sede;
  final String descripcion;
}

// Sección: modelo de mascota del cliente
// Agrupa la información visible en tarjetas y detalle de mascota.
class MascotaClienteMock {
  const MascotaClienteMock({
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.edad,
    required this.peso,
    required this.sexo,
    required this.color,
    required this.proximaVacuna,
  });

  final String nombre;
  final String especie;
  final String raza;
  final String edad;
  final String peso;
  final String sexo;
  final String color;
  final String proximaVacuna;
}

// Sección: datos base de cliente
// Valores usados para saludo y detalle de propietario.
const String nombreClienteHomeMock = 'Joel Ferrer';
const String inicialClienteHomeMock = 'J';

// Sección: acciones rápidas mock
// Lista estática de acciones del botón flotante.
const List<AccionRapidaClienteHomeMock> accionesRapidasClienteHomeMock = <
    AccionRapidaClienteHomeMock>[
  AccionRapidaClienteHomeMock(
    id: 'registrar_mascota',
    titulo: 'Registrar mascota',
    icono: Icons.pets_outlined,
  ),
  AccionRapidaClienteHomeMock(
    id: 'crear_cita',
    titulo: 'Crear cita',
    icono: Icons.calendar_month_outlined,
  ),
];

// Sección: resumen mock
// Datos iniciales para las tarjetas de estado del home.
const List<ResumenClienteMock> resumenesClienteHomeMock = <ResumenClienteMock>[
  ResumenClienteMock(
    id: 'mis_mascotas',
    etiqueta: 'Mis mascotas',
    valor: '3',
    icono: Icons.pets_outlined,
  ),
  ResumenClienteMock(
    id: 'mis_citas',
    etiqueta: 'Mis citas',
    valor: '2',
    icono: Icons.calendar_month_outlined,
  ),
];

// Sección: citas mock
// Registros de ejemplo para la sección de próximas citas.
const List<CitaClienteMock> citasClienteMock = <CitaClienteMock>[
  CitaClienteMock(
    nombreMascota: 'Luna',
    especieMascota: 'Canino',
    fecha: '2026-04-12',
    hora: '10:30 a.m.',
    motivo: 'Control general',
    estado: 'Confirmada',
    veterinario: 'Dra. Camila Gómez',
    sede: 'Sede Norte',
    descripcion: 'Revisión de rutina y control de vacunas.',
  ),
  CitaClienteMock(
    nombreMascota: 'Milo',
    especieMascota: 'Felino',
    fecha: '2026-04-15',
    hora: '03:00 p.m.',
    motivo: 'Chequeo dermatológico',
    estado: 'Pendiente',
    veterinario: 'Dr. Andrés Ruiz',
    sede: 'Sede Centro',
    descripcion: 'Evaluación por irritación en piel.',
  ),
];

// Sección: mascotas mock
// Registros de ejemplo para la sección de mascotas registradas.
const List<MascotaClienteMock> mascotasClienteMock = <MascotaClienteMock>[
  MascotaClienteMock(
    nombre: 'Luna',
    especie: 'Canino',
    raza: 'Labrador',
    edad: '4 años',
    peso: '24 kg',
    sexo: 'Hembra',
    color: 'Dorado',
    proximaVacuna: '2026-06-10',
  ),
  MascotaClienteMock(
    nombre: 'Milo',
    especie: 'Felino',
    raza: 'Criollo',
    edad: '2 años',
    peso: '5 kg',
    sexo: 'Macho',
    color: 'Gris',
    proximaVacuna: '2026-05-03',
  ),
  MascotaClienteMock(
    nombre: 'Nala',
    especie: 'Canino',
    raza: 'Pug',
    edad: '1 año',
    peso: '8 kg',
    sexo: 'Hembra',
    color: 'Beige',
    proximaVacuna: '2026-07-21',
  ),
];
