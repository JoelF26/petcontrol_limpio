// Sección: imports
// Se importa Material y colores globales para el menú de acciones del home cliente.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';

// Sección: firma de callbacks asíncronos
// Permite que el menú espere la acción completa antes de continuar.
typedef AccionMenuHomeCliente = Future<void> Function();

// Sección: menú flotante de acciones del cliente
// Encapsula el botón "+" y el panel animado con opciones de creación.
class HomeClienteMenuFlotante extends StatefulWidget {
  const HomeClienteMenuFlotante({
    required this.onRegistrarMascota,
    required this.onCrearCita,
    super.key,
  });

  final AccionMenuHomeCliente onRegistrarMascota;
  final AccionMenuHomeCliente onCrearCita;

  @override
  State<HomeClienteMenuFlotante> createState() =>
      _HomeClienteMenuFlotanteState();
}

// Sección: estado del menú flotante
// Gestiona apertura/cierre con animación de desplazamiento hacia arriba.
class _HomeClienteMenuFlotanteState extends State<HomeClienteMenuFlotante>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _desplazamiento;
  late final Animation<double> _opacidad;
  bool _abierto = false;

  // Sección: inicialización de animación
  // Prepara transiciones de opacidad y movimiento para el panel.
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _desplazamiento = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _opacidad = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  // Sección: liberación de recursos
  // Libera el controller cuando el widget deja de existir.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Sección: toggle del menú
  // Alterna entre estado cerrado y abierto.
  Future<void> _alternar() async {
    if (_abierto) {
      await _cerrar();
      return;
    }
    await _abrir();
  }

  Future<void> _abrir() async {
    if (_abierto) {
      return;
    }
    setState(() {
      _abierto = true;
    });
    await _controller.forward();
  }

  Future<void> _cerrar() async {
    if (!_abierto) {
      return;
    }
    await _controller.reverse();
    if (!mounted) {
      return;
    }
    setState(() {
      _abierto = false;
    });
  }

  // Sección: acciones del panel
  // Ejecutan callback externo y cierran el menú.
  Future<void> _onRegistrarMascota() async {
    await _cerrar();
    if (!mounted) {
      return;
    }
    try {
      await widget.onRegistrarMascota();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el formulario de mascota.'),
        ),
      );
    }
  }

  Future<void> _onCrearCita() async {
    await _cerrar();
    if (!mounted) {
      return;
    }
    try {
      await widget.onCrearCita();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el formulario de cita.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sección: fondo táctil para cerrar menú
        // Captura toques fuera del panel cuando está abierto.
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !_abierto,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _cerrar,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _abierto ? 0.02 : 0,
                child: const ColoredBox(color: AppColores.negro),
              ),
            ),
          ),
        ),

        // Sección: panel de opciones
        // Muestra las dos acciones solicitadas con animación de subida.
        Positioned(
          right: 14,
          bottom: 88,
          child: IgnorePointer(
            ignoring: !_abierto,
            child: FadeTransition(
              opacity: _opacidad,
              child: SlideTransition(
                position: _desplazamiento,
                child: _panelAcciones(),
              ),
            ),
          ),
        ),

        // Sección: botón principal
        // Botón "+" fijo en esquina inferior derecha.
        Positioned(
          right: 14,
          bottom: 14,
          child: SizedBox(
            width: 62,
            height: 62,
            child: FloatingActionButton(
              onPressed: _alternar,
              backgroundColor: AppColores.secundarioOscuro,
              foregroundColor: AppColores.blanco,
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 220),
                turns: _abierto ? 0.125 : 0,
                child: const Icon(Icons.add, size: 34),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Sección: contenedor visual del menú
  // Replica el diseño de tarjeta con dos filas y separador central.
  Widget _panelAcciones() {
    return Material(
      color: AppColores.transparente,
      child: Container(
        width: 295,
        decoration: BoxDecoration(
          color: AppColores.baseFFDDE1E5,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColores.baseFF7A7E83, width: 1),
          boxShadow: const [
            BoxShadow(
              color: AppColores.base330E1C2F,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _filaAccion(
              icono: Icons.pets,
              texto: 'Registrar mascota',
              onTap: _onRegistrarMascota,
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColores.baseFFB9BDC1,
            ),
            _filaAccion(
              icono: Icons.calendar_month_outlined,
              texto: 'Registrar cita',
              onTap: _onCrearCita,
            ),
          ],
        ),
      ),
    );
  }

  // Sección: fila individual
  // Define icono, texto y callback táctil de cada opción.
  Widget _filaAccion({
    required IconData icono,
    required String texto,
    required AccionMenuHomeCliente onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        await onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icono, color: AppColores.baseFF2D695A, size: 28),
            const SizedBox(width: 12),
            Text(
              texto,
              style: const TextStyle(
                color: AppColores.baseFF3E454D,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
