// Sección: constantes de navegación
// Centraliza los nombres de rutas para evitar strings duplicados en la app.
class Rutas {
  Rutas._();

  // Sección: rutas públicas de autenticación
  // Define bienvenida, login y registro.
  static const String bienvenida = '/';
  static const String login = '/login';
  static const String registro = '/registro';

  // Sección: rutas por rol
  // Define panel principal de cliente y administrador.
  static const String homeCliente = '/home-cliente';
  static const String homeAdmin = '/home-admin';
}
