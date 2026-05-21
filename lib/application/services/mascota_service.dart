// Sección: imports
// Se importan utilidades de fecha, UUID, constantes y storage local JSON.
import 'package:intl/intl.dart';
import 'package:petcontrol_limpio/domain/entities/mascota.dart';
import 'package:petcontrol_limpio/domain/repositories/mascota_repository.dart';
import 'package:uuid/uuid.dart';

// Sección: servicio de mascotas
// Encapsula consultas y mutaciones de mascotas sobre persistencia JSON local.
class MascotaService {
  MascotaService({required MascotaRepository mascotaRepository, Uuid? uuid})
    : _mascotaRepository = mascotaRepository,
      _uuid = uuid ?? const Uuid();

  final MascotaRepository _mascotaRepository;
  final Uuid _uuid;

  // Sección: listado completo
  // Retorna todas las mascotas almacenadas en la entidad local.
  Future<List<Mascota>> obtenerMascotas() async {
    return _mascotaRepository.obtenerMascotas();
  }

  Stream<List<Mascota>> observarMascotas() {
    return _mascotaRepository.observarMascotas();
  }

  // Sección: consulta de mascotas por usuario
  // Obtiene todas las mascotas de un cliente y las ordena de más reciente a más antigua.
  Future<List<Mascota>> obtenerMascotasPorUsuario(String idUsuario) async {
    final idLimpio = idUsuario.trim();
    if (idLimpio.isEmpty) {
      return const <Mascota>[];
    }

    final mascotas = await obtenerMascotas();
    // La relación con usuario se mantiene por id_usuario dentro de cada mascota.
    final filtradas = mascotas
        .where((mascota) => mascota.idUsuario == idLimpio)
        .toList(growable: false);

    final ordenadas = filtradas.toList(growable: false)
      ..sort((a, b) => b.fechaOrden.compareTo(a.fechaOrden));
    return ordenadas;
  }

  // Sección: conteo por usuario
  // Retorna cuántas mascotas tiene registradas un usuario por id_usuario.
  Future<int> contarMascotasPorUsuario(String idUsuario) async {
    final mascotas = await obtenerMascotasPorUsuario(idUsuario);
    return mascotas.length;
  }

  // Sección: creación de mascota de cliente
  // Registra una nueva mascota con id único y la asocia al id_usuario autenticado.
  Future<String> crearMascotaCliente({
    required String idUsuario,
    required String nombre,
    required String especie,
    required String raza,
    required String sexo,
    required int edadAnios,
    required double pesoKg,
  }) async {
    final idUsuarioLimpio = idUsuario.trim();
    if (idUsuarioLimpio.isEmpty) {
      throw ArgumentError('El id de usuario es obligatorio.');
    }

    final ahora = DateTime.now();
    final nueva = Mascota(
      idMascota: _uuid.v4(),
      idUsuario: idUsuarioLimpio,
      nombre: nombre.trim(),
      especie: especie.trim(),
      raza: raza.trim(),
      sexo: sexo.trim(),
      edadAnios: edadAnios,
      pesoKg: pesoKg,
      fechaCreacion: DateFormat('yyyy-MM-dd').format(ahora),
      createdAt: ahora,
    );

    final mascotas = await obtenerMascotas();
    // Se agrega al final y luego las consultas ordenan por fecha según la pantalla.
    final actualizadas = <Mascota>[...mascotas, nueva];
    await _mascotaRepository.guardarMascotas(actualizadas);

    return nueva.idMascota;
  }

  // Sección: actualización de mascota
  // Modifica los datos editables de una mascota existente.
  Future<void> actualizarMascotaCliente({
    required String idMascota,
    required String nombre,
    required String especie,
    required String raza,
    required int edadAnios,
    required double pesoKg,
  }) async {
    final idMascotaLimpio = idMascota.trim();
    if (idMascotaLimpio.isEmpty) {
      throw ArgumentError('El id de mascota es obligatorio.');
    }

    final mascotas = await obtenerMascotas();
    final indice = mascotas.indexWhere(
      (item) => item.idMascota == idMascotaLimpio,
    );
    if (indice < 0) {
      throw StateError('No existe la mascota a actualizar.');
    }

    final actual = mascotas[indice];
    // Mantiene id, dueño y fechas originales; solo reemplaza campos editables.
    final editada = actual.copyWith(
      nombre: nombre.trim(),
      especie: especie.trim(),
      raza: raza.trim(),
      edadAnios: edadAnios,
      pesoKg: pesoKg,
    );

    final actualizadas = <Mascota>[...mascotas];
    actualizadas[indice] = editada;
    await _mascotaRepository.guardarMascotas(actualizadas);
  }
}
