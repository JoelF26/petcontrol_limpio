// Sección: imports
// Se importan las pantallas que se resuelven por nombre de ruta.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/routes/rutas.dart';
import 'package:petcontrol_limpio/features/admin/pantallas/historial_citas.dart';
import 'package:petcontrol_limpio/features/admin/pantallas/home_admin.dart';
import 'package:petcontrol_limpio/features/admin/pantallas/personal_medico.dart';
import 'package:petcontrol_limpio/features/admin/pantallas/vista_cita_admin.dart';
import 'package:petcontrol_limpio/features/admin/pantallas/vista_pacientes_admin.dart';
import 'package:petcontrol_limpio/features/autenticacion/pantallas/bienvenida_pantalla.dart';
import 'package:petcontrol_limpio/features/autenticacion/pantallas/login_pantalla.dart';
import 'package:petcontrol_limpio/features/autenticacion/pantallas/registro_pantalla.dart';
import 'package:petcontrol_limpio/features/cliente/pantallas/home_cliente.dart';

// Sección: router central
// Traduce cada nombre de ruta en la pantalla correspondiente.
class AppRouter {
  AppRouter._();

  // Sección: resolución de rutas
  // Evalúa el nombre de ruta y retorna la pantalla adecuada.
  static Route<dynamic> generarRuta(RouteSettings settings) {
    switch (settings.name) {
      case Rutas.bienvenida:
        return _ruta(const BienvenidaPantalla(), settings);
      case Rutas.login:
        return _ruta(const LoginPantalla(), settings);
      case Rutas.registro:
        return _ruta(const RegistroPantalla(), settings);
      case Rutas.homeCliente:
        return _ruta(const HomeClientePantalla(), settings);
      case Rutas.homeAdmin:
        return _ruta(const HomeAdminPantalla(), settings);
      case Rutas.adminPacientes:
        return _ruta(const VistaPacientesAdmin(), settings);
      case Rutas.adminCitas:
        return _ruta(const VistaCitaAdmin(), settings);
      case Rutas.adminHistorialCitas:
        return _ruta(const HistorialMedicoAdmin(), settings);
      case Rutas.adminPersonalMedico:
        return _ruta(const PersonalMedicoAdmin(), settings);
      default:
        return _ruta(
          const BienvenidaPantalla(),
          const RouteSettings(name: Rutas.bienvenida),
        );
    }
  }

  // Sección: helper de navegación
  // Crea una ruta Material conservando RouteSettings para sincronizar URL.
  static MaterialPageRoute<dynamic> _ruta(
    Widget pantalla,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => pantalla,
      settings: settings,
    );
  }
}
