// Sección: imports
// Se importan utilidades visuales para construir piezas base de vistas admin.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';

// Sección: fondo decorativo admin
// Dibuja un encabezado con gradiente y círculos suaves reutilizable.
class AdminFondoDecorativo extends StatelessWidget {
  const AdminFondoDecorativo({
    super.key,
    required this.colores,
    this.altura = 280,
    this.colorFondo = AppColores.baseFFF1F5F2,
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

// Sección: botón de encabezado reutilizable
// Unifica el estilo del botón de regreso en las vistas admin.
class AdminBotonEncabezadoIcono extends StatelessWidget {
  const AdminBotonEncabezadoIcono({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColores.transparente,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColores.base22FFFFFF,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColores.base55FFFFFF),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColores.blanco,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// Sección: tarjeta resumen compacta
// Variante compacta para métricas de cabecera en vistas admin.
class AdminTarjetaResumenCompacta extends StatelessWidget {
  const AdminTarjetaResumenCompacta({
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColores.base2FFFFFFF,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColores.base54FFFFFF),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: AppColores.blanco, size: 18),
            const SizedBox(height: 8),
            Text(
              valor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColores.blanco,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColores.baseDBF4FFF7,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
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
          color: AppColores.blanco,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: AppColores.blanco,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                descripcion,
                style: const TextStyle(
                  color: AppColores.baseFFEAF4EF,
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
          color: AppColores.base1FFFFFFF,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColores.base44FFFFFF),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: AppColores.blanco, size: 18),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(
                color: AppColores.blanco,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              etiqueta,
              style: const TextStyle(
                color: AppColores.baseFFE6F2EC,
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
        color: AppColores.baseFFEEF5F1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColores.baseFFC6D6CD),
      ),
      child: Column(
        children: [
          Icon(icono, color: AppColores.baseFF60786C, size: 32),
          const SizedBox(height: 12),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColores.baseFF5E756A,
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
        color: AppColores.blanco.withValues(alpha: opacidad),
        shape: BoxShape.circle,
      ),
    );
  }
}
