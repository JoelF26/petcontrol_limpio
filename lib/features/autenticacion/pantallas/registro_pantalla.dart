// Sección: imports
// Se importan rutas, paleta, formulario y servicio de autenticación.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/routes/rutas.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/core/widgets/boton_atras.dart';
import 'package:petcontrol_limpio/features/autenticacion/widgets/formulario_registro.dart';
import 'package:petcontrol_limpio/services/auth_service.dart';

// Sección: pantalla de registro
// Mantiene el diseño visual y delega la persistencia al servicio de auth.
class RegistroPantalla extends StatefulWidget {
  const RegistroPantalla({super.key});

  @override
  State<RegistroPantalla> createState() => _RegistroPantallaState();
}

// Sección: estado de RegistroPantalla
// Gestiona registro, loading y navegación posterior al alta.
class _RegistroPantallaState extends State<RegistroPantalla> {
  // Sección: dependencias y estado local
  // Servicio de autenticación y bandera para bloquear acciones duplicadas.
  final AuthService _authService = AuthService();
  bool _cargando = false;

  // Sección: acción principal de registro
  // Crea usuario en autenticación local y perfil en JSON local.
  Future<void> _registrar(DatosFormularioRegistro datos) async {
    if (_cargando) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      await _authService.registrarCliente(
        DatosRegistroCliente(
          nombreCompleto: datos.nombreCompleto,
          numeroDocumento: datos.numeroDocumento,
          telefono: datos.telefono,
          correo: datos.correo,
          contrasena: datos.contrasena,
        ),
      );

      if (!mounted) {
        return;
      }

      _mostrarMensaje('Registro exitoso.');
      Navigator.pushNamedAndRemoveUntil(
        context,
        Rutas.homeCliente,
        (_) => false,
      );
    } on AuthException catch (error) {
      _mostrarMensaje(error.mensaje);
    } catch (_) {
      _mostrarMensaje('No se pudo completar el registro en este momento.');
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  // Sección: navegación a login
  // Permite volver al flujo de inicio de sesión.
  void _irALogin() {
    Navigator.pushReplacementNamed(context, Rutas.login);
  }

  // Sección: feedback visual
  // Muestra errores y estados de operación al usuario.
  void _mostrarMensaje(String mensaje) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // Sección: construcción de UI
  // Conserva estructura de header, panel curvo y formulario de registro.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.blanco,
      body: Stack(
        children: [
          // Sección: fondo base
          // Capa blanca de respaldo para toda la pantalla.
          Container(color: AppColores.blanco),

          // Sección: header con logo
          // Franja superior degradada con logo principal.
          SizedBox(
            height: 260,
            width: double.infinity,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColores.secundarioOscuro,
                    AppColores.secundarioOscuro,
                    AppColores.secundario,
                  ],
                  stops: [0.0, 0.001, 1.0],
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 298.79,
                  height: 122.67,
                  child: Image.asset(
                    'assets/img/Logo BN.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // Sección: contenedor inferior principal
          // Panel visual donde vive el formulario de registro.
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.77,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColores.secundarioOscuro,
                    AppColores.secundarioOscuro,
                    AppColores.secundario,
                  ],
                  stops: [0.0, 0.001, 1.0],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: AppColores.blanco,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: FormularioRegistro(
                    cargando: _cargando,
                    onRegistrar: _registrar,
                    onIrALogin: _irALogin,
                  ),
                ),
              ),
            ),
          ),

          // Sección: botón atrás
          // Permite regresar de forma segura a la pantalla anterior.
          const BotonAtras(
            rutaFallback: Rutas.bienvenida,
            colorIcono: AppColores.blanco,
          ),
        ],
      ),
    );
  }
}

