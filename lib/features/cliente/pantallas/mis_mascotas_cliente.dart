// Sección: imports
// Se importan modelos, servicios y formulario para conectar la vista con backend.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/detalle_mascota_cliente_popup.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/tarjeta creacion paciente.dart';
import 'package:petcontrol_limpio/models/mascota.dart';
import 'package:petcontrol_limpio/services/auth_service.dart';
import 'package:petcontrol_limpio/services/mascota_service.dart';

// Sección: pantalla de mascotas del cliente
// Muestra todas las mascotas del usuario autenticado y permite registrar nuevas.
class MisMascotasCliente extends StatefulWidget {
  const MisMascotasCliente({super.key});

  @override
  State<MisMascotasCliente> createState() => _MisMascotasClienteState();
}

// Sección: estado de Mis Mascotas
// Gestiona carga desde Firestore y apertura del formulario de registro.
class _MisMascotasClienteState extends State<MisMascotasCliente> {
  // Sección: servicios de backend
  // Permiten resolver usuario autenticado y consultar la colección mascotas.
  final AuthService _authService = AuthService();
  final MascotaService _mascotaService = MascotaService();

  // Sección: estado principal de la vista
  // Guarda datos de sesión y listado de mascotas para render dinámico.
  bool _cargando = true;
  String _nombreCliente = 'Cliente';
  List<Mascota> _mascotas = const <Mascota>[];

  // Sección: inicialización
  // Carga datos del usuario y sus mascotas al abrir la pantalla.
  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Sección: carga de datos desde backend
  // Consulta Firestore para traer todas las mascotas del usuario logueado.
  Future<void> _cargarDatos() async {
    try {
      final usuario = await _authService.obtenerUsuarioActual();
      final idUsuario = _resolverIdUsuario(usuario?.idUsuario);
      final nombre = _resolverNombreVisible(usuario?.nombreCompleto);

      if (idUsuario.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() {
          _nombreCliente = nombre;
          _mascotas = const <Mascota>[];
          _cargando = false;
        });
        return;
      }

      final mascotas = await _mascotaService.obtenerMascotasPorUsuario(idUsuario);
      if (!mounted) {
        return;
      }
      setState(() {
        _nombreCliente = nombre;
        _mascotas = mascotas;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _nombreCliente = _resolverNombreVisible(null);
        _mascotas = const <Mascota>[];
        _cargando = false;
      });
    }
  }

  // Sección: id de usuario para consultas
  // Prioriza id del perfil y usa uid de Firebase Auth como respaldo.
  String _resolverIdUsuario(String? idPerfil) {
    final idLimpio = (idPerfil ?? '').trim();
    if (idLimpio.isNotEmpty) {
      return idLimpio;
    }
    return (_authService.usuarioFirebaseActual?.uid ?? '').trim();
  }

  // Sección: nombre visible del cliente
  // Usa nombre del perfil y, como fallback, alias derivado del correo.
  String _resolverNombreVisible(String? nombrePerfil) {
    final nombreLimpio = (nombrePerfil ?? '').trim();
    if (nombreLimpio.isNotEmpty) {
      return nombreLimpio;
    }

    final correo = (_authService.usuarioFirebaseActual?.email ?? '').trim();
    if (correo.isEmpty) {
      return 'Cliente';
    }

    final alias = correo
        .split('@')
        .first
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .trim();
    if (alias.isEmpty) {
      return 'Cliente';
    }

    return _capitalizarAlias(alias);
  }

  // Sección: helper de texto para alias
  // Convierte alias de correo en nombre con formato legible.
  String _capitalizarAlias(String texto) {
    return texto
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .map(
          (parte) =>
              '${parte.substring(0, 1).toUpperCase()}${parte.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  // Sección: apertura de formulario de mascota
  // Muestra popup centrado con fondo oscuro y recarga al registrar.
  Future<void> _abrirRegistroMascota() async {
    if (!mounted) {
      return;
    }

    final creada = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      barrierDismissible: true,
      builder: (context) {
        final teclado = MediaQuery.of(context).viewInsets;
        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + teclado.bottom),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: const TarjetaCreacionPaciente(),
            ),
          ),
        );
      },
    );

    if (creada == true) {
      await _cargarDatos();
    }
  }

  // Sección: apertura de detalle de mascota
  // Muestra ficha extendida y, si hay cambios, recarga el listado.
  Future<void> _abrirDetalleMascota(Mascota mascota) async {
    if (!mounted) {
      return;
    }
    final actualizada = await mostrarDetalleMascotaCliente(context, mascota);
    if (actualizada) {
      await _cargarDatos();
    }
  }

  // Sección: texto dinámico de resumen
  // Construye frase "n registradas a nombre de ..." con singular/plural.
  String get _resumenRegistroMascotas {
    final total = _mascotas.length;
    final palabra = total == 1 ? 'registrada' : 'registradas';
    return '$total $palabra a nombre de $_nombreCliente';
  }

  // Sección: construcción de la pantalla
  // Mantiene el diseño visual y lista todas las mascotas del usuario.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FA),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
        width: 62,
        height: 62,
        child: FloatingActionButton(
          onPressed: _abrirRegistroMascota,
          backgroundColor: const Color(0xFF153A5F),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 34),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: _FondoMisMascotas()),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EncabezadoMisMascotas(
                    onVolver: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 16),
                  _PanelMisMascotas(
                    cargando: _cargando,
                    resumenTexto: _resumenRegistroMascotas,
                    mascotas: _mascotas,
                    onTapMascota: _abrirDetalleMascota,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sección: fondo visual superior
// Conserva el gradiente y círculos decorativos de la vista.
class _FondoMisMascotas extends StatelessWidget {
  const _FondoMisMascotas();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 286,
          child: Stack(
            children: const [
              _GradienteFondoMisMascotas(),
              Positioned(
                top: -34,
                right: -22,
                child: _CirculoDecorativoMascotas(diametro: 126, opacidad: 0.2),
              ),
              Positioned(
                bottom: 18,
                left: -24,
                child: _CirculoDecorativoMascotas(diametro: 98, opacidad: 0.14),
              ),
            ],
          ),
        ),
        const Expanded(child: ColoredBox(color: Color(0xFFF2F5FA))),
      ],
    );
  }
}

// Sección: gradiente de cabecera
// Define banda azul superior con bordes redondeados.
class _GradienteFondoMisMascotas extends StatelessWidget {
  const _GradienteFondoMisMascotas();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F3457),
            AppColores.secundarioOscuro,
            AppColores.secundario,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
      ),
    );
  }
}

// Sección: círculo decorativo de cabecera
// Se utiliza para profundidad visual en el fondo.
class _CirculoDecorativoMascotas extends StatelessWidget {
  const _CirculoDecorativoMascotas({
    required this.diametro,
    required this.opacidad,
  });

  final double diametro;
  final double opacidad;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diametro,
      height: diametro,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacidad),
        shape: BoxShape.circle,
      ),
    );
  }
}

// Sección: encabezado principal
// Muestra botón atrás, título y descripción de la sección.
class _EncabezadoMisMascotas extends StatelessWidget {
  const _EncabezadoMisMascotas({required this.onVolver});

  final VoidCallback onVolver;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _BotonEncabezadoIcono(onTap: onVolver),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Mis mascotas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 33,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Consulta sus datos clinicos, vacunas y estado general en un solo lugar.',
          style: TextStyle(
            color: Color(0xFFDCE9FF),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Sección: botón circular del encabezado
// Permite volver a la pantalla anterior.
class _BotonEncabezadoIcono extends StatelessWidget {
  const _BotonEncabezadoIcono({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0x22FFFFFF),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0x55FFFFFF)),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// Sección: panel principal de mascotas
// Renderiza subtítulo dinámico y listado completo de mascotas del usuario.
class _PanelMisMascotas extends StatelessWidget {
  const _PanelMisMascotas({
    required this.cargando,
    required this.resumenTexto,
    required this.mascotas,
    required this.onTapMascota,
  });

  final bool cargando;
  final String resumenTexto;
  final List<Mascota> mascotas;
  final ValueChanged<Mascota> onTapMascota;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFB8C8DC), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis mascotas',
            style: TextStyle(
              color: Color(0xFF233F6C),
              fontSize: 56 / 2, // 28
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resumenTexto,
            style: const TextStyle(
              color: Color(0xFF667896),
              fontSize: 42 / 3, // 14
              fontWeight: FontWeight.w500,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 14),
          if (cargando)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
            )
          else if (mascotas.isEmpty)
            const _EstadoVacioMascotas()
          else
            Column(
              children: [
                for (var i = 0; i < mascotas.length; i++) ...[
                  _TarjetaMascotaListado(
                    mascota: mascotas[i],
                    onTap: () => onTapMascota(mascotas[i]),
                  ),
                  if (i != mascotas.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

// Sección: estado vacío del listado
// Muestra mensaje cuando no existen mascotas en la cuenta.
class _EstadoVacioMascotas extends StatelessWidget {
  const _EstadoVacioMascotas();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC9D8E7), width: 1),
      ),
      child: const Text(
        'No tienes mascotas registradas.',
        style: TextStyle(
          color: Color(0xFF5B7187),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Sección: tarjeta individual de mascota
// Presenta nombre de mascota y especie en formato compacto como referencia.
class _TarjetaMascotaListado extends StatelessWidget {
  const _TarjetaMascotaListado({
    required this.mascota,
    required this.onTap,
  });

  final Mascota mascota;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE9EDF4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFB8C8DC), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E1F0),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: Color(0xFF3290B4),
                  size: 34,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  mascota.nombreVisible,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF233F6C),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E1F0),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  mascota.especieVisible,
                  style: const TextStyle(
                    color: Color(0xFF2E5C8A),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF66796F),
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
