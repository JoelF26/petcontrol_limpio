// Seccion: imports
// Se importan utilidades visuales y modelo de datos para la UI de historial.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/admin/models/historial_citas_view_data.dart';
import 'package:petcontrol_limpio/features/admin/widgets/admin_base_widgets.dart';

// Seccion: decoracion de campos de filtro
// Centraliza el estilo de los dropdowns para mantener consistencia visual.
InputDecoration decoracionFiltroHistorial() {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFCAD9D0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF2D8A6C), width: 1.4),
    ),
  );
}

// Seccion: fondo decorativo historial
// Dibuja el gradiente superior y la base clara de la pantalla.
class HistorialFondo extends StatelessWidget {
  const HistorialFondo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 280,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1B664A),
                      AppColores.verdepacientes,
                      Color(0xFF6EBC89),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(38),
                    bottomRight: Radius.circular(38),
                  ),
                ),
              ),
              const Positioned(
                top: -34,
                right: -24,
                child: _CirculoDecorativoHistorial(
                  diametro: 126,
                  opacidad: 0.2,
                ),
              ),
              const Positioned(
                bottom: 18,
                left: -24,
                child: _CirculoDecorativoHistorial(
                  diametro: 96,
                  opacidad: 0.14,
                ),
              ),
            ],
          ),
        ),
        const Expanded(child: ColoredBox(color: Color(0xFFF1F5F2))),
      ],
    );
  }
}

// Seccion: circulo decorativo
// Soporte interno para los acentos del fondo.
class _CirculoDecorativoHistorial extends StatelessWidget {
  const _CirculoDecorativoHistorial({
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

// Seccion: encabezado historial
// Muestra volver, boton de filtros y textos principales.
class HistorialEncabezado extends StatelessWidget {
  const HistorialEncabezado({
    super.key,
    required this.onVolver,
    required this.onFiltrar,
  });

  final VoidCallback onVolver;
  final VoidCallback onFiltrar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _BotonEncabezadoIcono(onTap: onVolver),
            const Spacer(),
            FilledButton.icon(
              onPressed: onFiltrar,
              style: FilledButton.styleFrom(
                minimumSize: const Size(108, 40),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                backgroundColor: const Color(0xFF143B2A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: const BorderSide(color: Color(0x88FFFFFF)),
              ),
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: const Text(
                'Filtros',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Historial de citas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 33,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Consulta el historial clinico y filtra eventos por estado, fecha y especie.',
          style: TextStyle(
            color: Color(0xFFE8F8EE),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Seccion: boton de encabezado
// Boton reutilizable para acciones de navegacion en el header.
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

// Seccion: resumen superior
// Presenta metricas rapidas del historial filtrado.
class HistorialResumen extends StatelessWidget {
  const HistorialResumen({
    super.key,
    required this.total,
    required this.finalizadas,
    required this.canceladas,
  });

  final int total;
  final int finalizadas;
  final int canceladas;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ItemResumen(
          valor: '$total',
          etiqueta: 'Total',
          icono: Icons.inventory_2_outlined,
        ),
        const SizedBox(width: 10),
        _ItemResumen(
          valor: '$finalizadas',
          etiqueta: 'Finalizadas',
          icono: Icons.check_circle_outline,
        ),
        const SizedBox(width: 10),
        _ItemResumen(
          valor: '$canceladas',
          etiqueta: 'Canceladas',
          icono: Icons.cancel_outlined,
        ),
      ],
    );
  }
}

// Seccion: item de resumen
// Tarjeta compacta usada dentro del bloque de metricas.
class _ItemResumen extends StatelessWidget {
  const _ItemResumen({
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
          color: const Color(0x2FFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x54FFFFFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: Colors.white, size: 18),
            const SizedBox(height: 8),
            Text(
              valor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
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
                color: Color(0xDBF4FFF7),
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

// Seccion: chip de filtro activo
// Etiqueta visual para indicar filtros aplicados.
class HistorialChipFiltroActivo extends StatelessWidget {
  const HistorialChipFiltroActivo({super.key, required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F1EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF3C6651),
          height: 1,
        ),
      ),
    );
  }
}

// Seccion: tarjeta de cita en historial
// Renderiza cada registro filtrado con sus datos clave.
class HistorialTarjetaCita extends StatelessWidget {
  const HistorialTarjetaCita({
    super.key,
    required this.cita,
    required this.fechaFormateada,
    required this.colorFondoEstado,
    required this.colorTextoEstado,
    required this.iconoEstado,
    required this.onTap,
  });

  final HistorialCitaVista cita;
  final String fechaFormateada;
  final Color colorFondoEstado;
  final Color colorTextoEstado;
  final IconData iconoEstado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 124),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFF0F7F3)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFC7D8CE), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colorFondoEstado,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(iconoEstado, color: colorTextoEstado, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Text(
                            cita.nombreMascota,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F3028),
                              height: 1,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDAEFE4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              cita.especie,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2F7452),
                                height: 1,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorFondoEstado,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              cita.estado,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: colorTextoEstado,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cita.procedimiento,
                        style: const TextStyle(
                          color: Color(0xFF4B5F55),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F2ED),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Text(
                          '$fechaFormateada | ${cita.doctor}\nDueno: ${cita.dueno}',
                          style: const TextStyle(
                            color: Color(0xFF587066),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Seccion: estado vacio historial
// Mensaje cuando no hay resultados para el filtro aplicado.
class HistorialEstadoVacio extends StatelessWidget {
  const HistorialEstadoVacio({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminEstadoVacioBase(
      mensaje: 'No hay citas que coincidan con los filtros.',
      icono: Icons.search_off_rounded,
    );
  }
}

// Seccion: campo de filtro
// Estructura uniforme etiqueta + control para cada dropdown.
class HistorialCampoFiltro extends StatelessWidget {
  const HistorialCampoFiltro({
    super.key,
    required this.etiqueta,
    required this.child,
  });

  final String etiqueta;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3C4A47),
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
