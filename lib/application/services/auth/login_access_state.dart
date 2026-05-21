// Sección: imports
// Se importa el modelo de usuario para exponer datos del correo consultado.
import 'package:petcontrol_limpio/domain/entities/usuario.dart';

// Sección: tipos de acceso en login
// Describe el estado del correo antes de intentar autenticación por contraseña.
enum TipoAccesoLogin {
  correoNoRegistrado,
  requiereContrasenaInicial,
  requiereContrasenaExistente,
}

// Sección: resultado de pre-chequeo de login
// Encapsula el tipo de acceso y el usuario encontrado cuando aplica.
class EstadoAccesoLogin {
  const EstadoAccesoLogin({required this.tipo, this.usuario});

  final TipoAccesoLogin tipo;
  final Usuario? usuario;

  // Sección: helpers de lectura
  // Simplifican condiciones en la pantalla de login.
  bool get correoNoRegistrado => tipo == TipoAccesoLogin.correoNoRegistrado;
  bool get requiereContrasenaInicial =>
      tipo == TipoAccesoLogin.requiereContrasenaInicial;
  bool get requiereContrasenaExistente =>
      tipo == TipoAccesoLogin.requiereContrasenaExistente;
}
