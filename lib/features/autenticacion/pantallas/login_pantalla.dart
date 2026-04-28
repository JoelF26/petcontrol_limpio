// Sección: imports
// Se importan rutas, paleta, formulario y servicio de autenticación.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/routes/rutas.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/core/widgets/boton_atras.dart';
import 'package:petcontrol_limpio/features/autenticacion/widgets/login/formulario_login.dart';
import 'package:petcontrol_limpio/features/autenticacion/widgets/shared/popup_configurar_contrasena_inicial.dart';
import 'package:petcontrol_limpio/models/usuario.dart';
import 'package:petcontrol_limpio/services/auth_service.dart';

// Sección: pantalla de login
// Mantiene el diseño visual original y centraliza la lógica de autenticación.
class LoginPantalla extends StatefulWidget {
  const LoginPantalla({super.key});

  @override
  State<LoginPantalla> createState() => _LoginPantallaState();
}

// Sección: estado de LoginPantalla
// Maneja autenticación, loading y navegación por rol sin alterar el diseño.
class _LoginPantallaState extends State<LoginPantalla> {
  // Sección: dependencias y estado local
  // Servicio de auth y bandera para bloquear acciones durante la petición.
  final AuthService _authService = AuthService();
  bool _cargando = false;

  // Sección: acción principal de login
  // Ejecuta login real con persistencia local y redirige según rol.
  Future<void> _iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    if (_cargando) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      final estadoAcceso = await _authService.evaluarAccesoPorCorreo(correo);

      if (!mounted) {
        return;
      }

      if (estadoAcceso.correoNoRegistrado) {
        _mostrarMensaje('Correo o contraseña incorrectos.');
        return;
      }

      if (estadoAcceso.requiereContrasenaInicial) {
        final nuevaContrasena = await mostrarPopupConfigurarContrasenaInicial(
          context,
          correo: correo.trim().toLowerCase(),
        );

        if (!mounted || nuevaContrasena == null) {
          return;
        }

        final usuario = await _authService.configurarContrasenaInicialYEntrar(
          correo: correo,
          nuevaContrasena: nuevaContrasena,
        );

        if (!mounted) {
          return;
        }

        _navegarPorRol(usuario);
        return;
      }

      if (contrasena.trim().isEmpty) {
        _mostrarMensaje('Ingresa tu contraseña.');
        return;
      }

      final usuario = await _authService.iniciarSesion(
        correo: correo,
        contrasena: contrasena,
      );

      if (!mounted) {
        return;
      }

      _navegarPorRol(usuario);
    } on AuthException catch (error) {
      _mostrarMensaje(error.mensaje);
    } catch (_) {
      _mostrarMensaje('Ocurrió un error inesperado al iniciar sesión.');
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  // Sección: navegación por rol
  // Redirige al panel correspondiente del usuario autenticado.
  void _navegarPorRol(Usuario usuario) {
    final ruta = usuario.esAdmin ? Rutas.homeAdmin : Rutas.homeCliente;
    Navigator.pushNamedAndRemoveUntil(context, ruta, (_) => false);
  }

  // Sección: feedback visual
  // Muestra mensajes de error
  void _mostrarMensaje(String mensaje) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // Sección: navegación a registro
  // Conserva el flujo visual original hacia pantalla de registro.
  void _irARegistro() {
    Navigator.pushNamed(context, Rutas.registro);
  }

  // Sección: construcción de UI
  // Conserva la misma estructura visual (header degradado + panel curvo).
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
          // Franja superior con degradado y logo central.
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
          // Panel visual donde vive el formulario.
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
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: FormularioLogin(
                    cargando: _cargando,
                    onIniciarSesion: _iniciarSesion,
                    onIrARegistro: _irARegistro,
                  ),
                ),
              ),
            ),
          ),

          // Sección: botón atrás
          // Botón flotante superior para volver a la pantalla anterior.
          const BotonAtras(
            rutaFallback: Rutas.bienvenida,
            colorIcono: AppColores.blanco,
          ),
        ],
      ),
    );
  }
}
