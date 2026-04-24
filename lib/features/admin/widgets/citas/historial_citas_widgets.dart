// Seccion: imports
// Se importan utilidades visuales y modelo de datos para la UI de historial.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/admin/models/historial_citas_view_data.dart';
import 'package:petcontrol_limpio/features/admin/widgets/shared/admin_base_widgets.dart';

// Seccion: decoracion de campos de filtro
// Centraliza el estilo de los dropdowns para mantener consistencia visual.
InputDecoration decoracionFiltroHistorial() {
  return InputDecoration(
    filled: true,
    fillColor: AppColores.blanco,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColores.baseFFCAD9D0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColores.baseFF2D8A6C, width: 1.4),
    ),
  );
}

// Seccion: fondo decorativo historial
// Dibuja el gradiente superior y la base clara de la pantalla.
class HistorialFondo extends StatelessWidget {
  const HistorialFondo({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminFondoDecorativo(
      colores: [
        AppColores.baseFF1B664A,
        AppColores.verdepacientes,
        AppColores.baseFF6EBC89,
      ],
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
                backgroundColor: AppColores.baseFF143B2A,
                foregroundColor: AppColores.blanco,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: const BorderSide(color: AppColores.base88FFFFFF),
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
            color: AppColores.blanco,
            fontSize: 33,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Consulta el historial clinico y filtra eventos por estado, fecha y especie.',
          style: TextStyle(
            color: AppColores.baseFFE8F8EE,
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
    return AdminBotonEncabezadoIcono(onTap: onTap);
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
    return AdminTarjetaResumenCompacta(
      valor: valor,
      etiqueta: etiqueta,
      icono: icono,
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
        color: AppColores.baseFFE6F1EB,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: AppColores.baseFF3C6651,
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
      color: AppColores.transparente,
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
                colors: [AppColores.blanco, AppColores.baseFFF0F7F3],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColores.baseFFC7D8CE, width: 1),
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
                              color: AppColores.baseFF1F3028,
                              height: 1,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColores.baseFFDAEFE4,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              cita.especie,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColores.baseFF2F7452,
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
                          color: AppColores.baseFF4B5F55,
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
                          color: AppColores.baseFFE8F2ED,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Text(
                          '$fechaFormateada | ${cita.doctor}\nDueno: ${cita.dueno}',
                          style: const TextStyle(
                            color: AppColores.baseFF587066,
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
              color: AppColores.baseFF3C4A47,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
