import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:petcontrol_limpio/domain/repositories/catalogos_repository.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firebase_paths.dart';
import 'package:petcontrol_limpio/infrastructure/firebase/firestore_mapper.dart';

class FirebaseCatalogosRepository implements CatalogosRepository {
  FirebaseCatalogosRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<Map<String, dynamic>> leerCatalogos() async {
    final doc = await _firestore
        .collection(FirebasePaths.catalogos)
        .doc(FirebasePaths.catalogosConfig)
        .get();
    final data = doc.data();
    if (data != null && data.isNotEmpty) {
      return FirestoreMapper.normalizarLectura(data);
    }
    return _leerCatalogosAsset();
  }

  Future<Map<String, dynamic>> _leerCatalogosAsset() async {
    try {
      final contenido = await rootBundle.loadString(
        'assets/data/catalogos.json',
      );
      final decoded = jsonDecode(contenido);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}
    return <String, dynamic>{};
  }
}
