// Sección: helper de correos médicos
// Centraliza generación y normalización de correos con dominio institucional.
class CorreoMedicoHelper {
  CorreoMedicoHelper._();

  static const String dominioMedico = 'Vetcontrol.com';

  // Sección: correo automático desde nombre
  // Usa el nombre completo como alias institucional, sin espacios.
  static String correoDesdeNombre(String nombreCompleto) {
    final alias = _aliasDesdeNombre(nombreCompleto);
    return '$alias@$dominioMedico';
  }

  // Sección: correo desde alias manual
  // Normaliza el alias y construye el correo final del dominio médico.
  static String correoDesdeAlias(String alias) {
    final normalizado = normalizarAlias(alias);
    if (normalizado.isEmpty) {
      throw const FormatException('Ingresa un alias válido para el correo.');
    }
    return '$normalizado@$dominioMedico';
  }

  // Sección: normalización de alias
  // Elimina tildes/caracteres no permitidos y limpia separadores.
  static String normalizarAlias(String valor) {
    final textoBase = _quitarAcentos(valor).toLowerCase();
    final soloPermitido = textoBase.replaceAll(RegExp(r'[^a-z0-9._-]'), '');
    final sinDuplicados = soloPermitido
        .replaceAll(RegExp(r'[._-]{2,}'), '.')
        .replaceAll(RegExp(r'^[._-]+|[._-]+$'), '');
    return sinDuplicados.trim();
  }

  static String _aliasDesdeNombre(String nombreCompleto) {
    final textoBase = _quitarAcentos(nombreCompleto).toLowerCase();
    final soloTexto = textoBase.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    final bloques = soloTexto
        .split(RegExp(r'\s+'))
        .where((parte) => parte.trim().isNotEmpty)
        .toList(growable: false);

    if (bloques.isEmpty) {
      return 'medico';
    }

    final aliasCompleto = normalizarAlias(bloques.join());
    if (aliasCompleto.isEmpty) {
      return 'medico';
    }
    return aliasCompleto;
  }

  static String _quitarAcentos(String texto) {
    const mapa = <String, String>{
      'á': 'a',
      'à': 'a',
      'ä': 'a',
      'â': 'a',
      'Á': 'A',
      'À': 'A',
      'Ä': 'A',
      'Â': 'A',
      'é': 'e',
      'è': 'e',
      'ë': 'e',
      'ê': 'e',
      'É': 'E',
      'È': 'E',
      'Ë': 'E',
      'Ê': 'E',
      'í': 'i',
      'ì': 'i',
      'ï': 'i',
      'î': 'i',
      'Í': 'I',
      'Ì': 'I',
      'Ï': 'I',
      'Î': 'I',
      'ó': 'o',
      'ò': 'o',
      'ö': 'o',
      'ô': 'o',
      'Ó': 'O',
      'Ò': 'O',
      'Ö': 'O',
      'Ô': 'O',
      'ú': 'u',
      'ù': 'u',
      'ü': 'u',
      'û': 'u',
      'Ú': 'U',
      'Ù': 'U',
      'Ü': 'U',
      'Û': 'U',
      'ñ': 'n',
      'Ñ': 'N',
    };

    final buffer = StringBuffer();
    for (final char in texto.split('')) {
      buffer.write(mapa[char] ?? char);
    }
    return buffer.toString();
  }
}
