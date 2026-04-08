// Sección: imports
// Se importan las pantallas que se resuelven por nombre de ruta.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/routes/rutas.dart';
import 'package:petcontrol_limpio/features/admin/pantallas/home_admin.dart';
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
        return _ruta(const BienvenidaPantalla());
      case Rutas.login:
        return _ruta(const LoginPantalla());
      case Rutas.registro:
        return _ruta(const RegistroPantalla());
      case Rutas.homeCliente:
        return _ruta(const HomeClientePantalla());
      case Rutas.homeAdmin:
        return _ruta(const HomeAdminPantalla());
      default:
        return _ruta(const BienvenidaPantalla());
    }
  }

  // Sección: helper de navegación
  // Crea una ruta Material estándar para mantener uniforme la navegación.
  static MaterialPageRoute<dynamic> _ruta(Widget pantalla) {
    return MaterialPageRoute<dynamic>(builder: (_) => pantalla);
  }
}
