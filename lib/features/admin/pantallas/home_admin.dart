// Sección: imports
// Se importan rutas y servicio de sesión para logout.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/routes/rutas.dart';
import 'package:petcontrol_limpio/services/auth_service.dart';

// Sección: home de administrador
// Pantalla inicial mínima para validar flujo por rol admin.
class HomeAdminPantalla extends StatelessWidget {
  const HomeAdminPantalla({super.key});

  // Sección: construcción de UI
  // Muestra cabecera, cierre de sesión y mensaje de estado.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel administrador'),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().cerrarSesion();
              if (!context.mounted) {
                return;
              }
              Navigator.pushNamedAndRemoveUntil(
                context,
                Rutas.bienvenida,
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Text('Inicio admin listo para continuar con gestión clínica.'),
      ),
    );
  }
}
