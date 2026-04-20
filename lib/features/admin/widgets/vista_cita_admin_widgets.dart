// Seccion: imports
// Se importan recursos visuales y modelos de la agenda admin.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/admin/models/vista_cita_admin_view_data.dart';
import 'package:petcontrol_limpio/features/admin/widgets/admin_base_widgets.dart';

// Seccion: fondo decorativo
// Dibuja gradiente superior y base clara de la pantalla de citas.
class VistaCitaAdminFondo extends StatelessWidget {
  const VistaCitaAdminFondo({super.key});

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
                      Color(0xFF1A6549),
                      AppColores.verdepacientes,
                      Color(0xFF72BE8D),
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
                child: _CirculoDecorativoCitas(diametro: 126, opacidad: 0.2),
              ),
              const Positioned(
                bottom: 18,
                left: -24,
                child: _CirculoDecorativoCitas(diametro: 96, opacidad: 0.14),
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
// Acento visual para el fondo de citas.
class _CirculoDecorativoCitas extends StatelessWidget {
  const _CirculoDecorativoCitas({
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

// Seccion: encabezado
// Renderiza boton volver y textos principales de la vista.
class VistaCitaAdminEncabezado extends StatelessWidget {
  const VistaCitaAdminEncabezado({
    super.key,
    required this.onVolver,
  });

  final VoidCallback onVolver;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BotonEncabezadoIcono(onTap: onVolver),
        const SizedBox(height: 12),
        const Text(
          'Citas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 33,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Visualiza programacion diaria y seguimiento de agenda en tiempo real.',
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

// Seccion: boton encabezado
// Boton reutilizable para regresar a la pantalla anterior.
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
// Muestra totales de hoy, proximas y confirmadas.
class VistaCitaAdminResumen extends StatelessWidget {
  const VistaCitaAdminResumen({
    super.key,
    required this.totalHoy,
    required this.totalProximas,
    required this.confirmadas,
  });

  final int totalHoy;
  final int totalProximas;
  final int confirmadas;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TarjetaResumen(
          etiqueta: 'Hoy',
          valor: '$totalHoy',
          icono: Icons.today_outlined,
        ),
        const SizedBox(width: 10),
        _TarjetaResumen(
          etiqueta: 'Proximas',
          valor: '$totalProximas',
          icono: Icons.event_note_outlined,
        ),
        const SizedBox(width: 10),
        _TarjetaResumen(
          etiqueta: 'Confirmadas',
          valor: '$confirmadas',
          icono: Icons.check_circle_outline,
        ),
      ],
    );
  }
}

// Seccion: tarjeta de resumen
// Item visual para cada contador del resumen.
class _TarjetaResumen extends StatelessWidget {
  const _TarjetaResumen({
    required this.etiqueta,
    required this.valor,
    required this.icono,
  });

  final String etiqueta;
  final String valor;
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

// Seccion: seccion de agenda
// Renderiza bloque de citas con contador y lista.
class VistaCitaAdminSeccionAgenda extends StatelessWidget {
  const VistaCitaAdminSeccionAgenda({
    super.key,
    required this.titulo,
    required this.cantidad,
    required this.citas,
    required this.onTap,
  });

  final String titulo;
  final int cantidad;
  final List<CitaVistaAdmin> citas;
  final ValueChanged<CitaVistaAdmin> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  color: Color(0xFF2A3F34),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDDEDE5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$cantidad',
                style: const TextStyle(
                  color: Color(0xFF2D7C62),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (citas.isEmpty)
          const AdminEstadoVacioBase(
            mensaje: 'No hay citas registradas en esta seccion.',
            icono: Icons.event_busy_outlined,
          )
        else
          for (var i = 0; i < citas.length; i++) ...[
            VistaCitaAdminTarjetaCita(cita: citas[i], onTap: () => onTap(citas[i])),
            if (i < citas.length - 1) const SizedBox(height: 12),
          ],
      ],
    );
  }
}

// Seccion: tarjeta de cita
// Muestra resumen visual de una cita en agenda.
class VistaCitaAdminTarjetaCita extends StatelessWidget {
  const VistaCitaAdminTarjetaCita({
    super.key,
    required this.cita,
    required this.onTap,
  });

  final CitaVistaAdmin cita;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 118),
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
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: cita.cajaHoraColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cita.icono, color: cita.iconoColor, size: 19),
                      const SizedBox(height: 4),
                      Text(
                        cita.hora,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: cita.horaColor,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cita.nombreMascota,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF1E3027),
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          VistaCitaAdminChipEstado(cita: cita),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F2ED),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Text(
                          cita.descripcion,
                          style: const TextStyle(
                            color: Color(0xFF587066),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
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

// Seccion: chip de estado
// Renderiza estado textual con color segun estilo de la cita.
class VistaCitaAdminChipEstado extends StatelessWidget {
  const VistaCitaAdminChipEstado({
    super.key,
    required this.cita,
  });

  final CitaVistaAdmin cita;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: cita.estadoBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        cita.estado,
        style: TextStyle(
          color: cita.estadoTextColor,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
