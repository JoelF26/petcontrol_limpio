// Sección: imports
// Se importan utilidades visuales para construir piezas base de vistas admin.
import 'package:flutter/material.dart';

// Sección: fondo decorativo admin
// Dibuja un encabezado con gradiente y círculos suaves reutilizable.
class AdminFondoDecorativo extends StatelessWidget {
  const AdminFondoDecorativo({
    super.key,
    required this.colores,
    this.altura = 280,
    this.colorFondo = const Color(0xFFF1F5F2),
  });

  final List<Color> colores;
  final double altura;
  final Color colorFondo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: altura,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colores,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(38),
                    bottomRight: Radius.circular(38),
                  ),
                ),
              ),
              const Positioned(
                top: -36,
                right: -24,
                child: _CirculoDecorativo(diametro: 126, opacidad: 0.2),
              ),
              const Positioned(
                bottom: 16,
                left: -28,
                child: _CirculoDecorativo(diametro: 104, opacidad: 0.14),
              ),
            ],
          ),
        ),
        Expanded(child: ColoredBox(color: colorFondo)),
      ],
    );
  }
}

// Sección: encabezado base admin
// Presenta título, descripción corta y botón de regreso.
class AdminEncabezadoBase extends StatelessWidget {
  const AdminEncabezadoBase({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.onVolver,
  });

  final String titulo;
  final String descripcion;
  final VoidCallback onVolver;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: onVolver,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                descripcion,
                style: const TextStyle(
                  color: Color(0xFFEAF4EF),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Sección: tarjeta resumen base
// Muestra un valor resumido con icono y etiqueta.
class AdminTarjetaResumenBase extends StatelessWidget {
  const AdminTarjetaResumenBase({
    super.key,
    required this.valor,
    required this.etiqueta,
    required this.icono,
  });

  final String valor;
  final String etiqueta;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
        decoration: BoxDecoration(
          color: const Color(0x1FFFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x44FFFFFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: Colors.white, size: 18),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              etiqueta,
              style: const TextStyle(
                color: Color(0xFFE6F2EC),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sección: estado vacío base
// Unifica el mensaje cuando no hay elementos para mostrar en la lista.
class AdminEstadoVacioBase extends StatelessWidget {
  const AdminEstadoVacioBase({
    super.key,
    required this.mensaje,
    this.icono = Icons.inbox_outlined,
  });

  final String mensaje;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF5F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC6D6CD)),
      ),
      child: Column(
        children: [
          Icon(icono, color: const Color(0xFF60786C), size: 32),
          const SizedBox(height: 12),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF5E756A),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Sección: círculo decorativo
// Soporte interno para el fondo decorativo reusable.
class _CirculoDecorativo extends StatelessWidget {
  const _CirculoDecorativo({required this.diametro, required this.opacidad});

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
