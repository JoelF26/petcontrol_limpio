// Sección: utilidades de validación
// Contiene validaciones reutilizables para formularios de autenticación.
class Validadores {
  Validadores._();

  // Sección: validación genérica
  // Verifica que un campo obligatorio no llegue vacío.
  static String? campoRequerido(String? valor, {String nombreCampo = 'Campo'}) {
    if (valor == null || valor.trim().isEmpty) {
      return '$nombreCampo es obligatorio.';
    }
    return null;
  }

  // Sección: validación de correo
  // Verifica formato básico de email.
  static String? correo(String? valor) {
    final requerido = campoRequerido(valor, nombreCampo: 'Correo');
    if (requerido != null) {
      return requerido;
    }

    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!regex.hasMatch(valor!.trim())) {
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  // Sección: validación de contraseña
  // Exige longitud mínima para reducir contraseñas débiles.
  static String? contrasena(String? valor) {
    final requerido = campoRequerido(valor, nombreCampo: 'Contraseña');
    if (requerido != null) {
      return requerido;
    }

    if (valor!.trim().length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }
    return null;
  }

  // Sección: validación de documento
  // Permite solo números en un rango razonable de longitud.
  static String? documento(String? valor) {
    final requerido = campoRequerido(valor, nombreCampo: 'Número de documento');
    if (requerido != null) {
      return requerido;
    }

    final regex = RegExp(r'^\d{6,20}$');
    if (!regex.hasMatch(valor!.trim())) {
      return 'El documento debe contener solo números.';
    }
    return null;
  }

  // Sección: validación de teléfono
  // Permite únicamente dígitos con tamaño válido.
  static String? telefono(String? valor) {
    final requerido = campoRequerido(valor, nombreCampo: 'Teléfono');
    if (requerido != null) {
      return requerido;
    }

    final regex = RegExp(r'^\d{7,15}$');
    if (!regex.hasMatch(valor!.trim())) {
      return 'Ingresa un teléfono válido.';
    }
    return null;
  }
}
