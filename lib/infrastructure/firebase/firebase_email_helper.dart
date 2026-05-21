import 'dart:convert';

import 'package:crypto/crypto.dart';

class FirebaseEmailHelper {
  FirebaseEmailHelper._();

  static String normalizarCorreo(String correo) {
    return correo.trim().toLowerCase();
  }

  static String hashCorreo(String correo) {
    final normalizado = normalizarCorreo(correo);
    return sha256.convert(utf8.encode(normalizado)).toString();
  }
}
