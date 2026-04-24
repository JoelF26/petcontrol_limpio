// Seccion: imports
// Se importan rutas y modelos visuales para construir widgets del home admin.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/admin/models/home_admin_view_data.dart';
import 'package:petcontrol_limpio/features/admin/widgets/shared/admin_base_widgets.dart';

// Seccion: clipper de curva
// Mantiene la forma ondulada inferior del fondo admin.
class HomeAdminCurvaClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.17,
      size.height * 0.36,
      size.width * 0.46,
      size.height * 0.43,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.52,
      size.width,
      size.height * 0.39,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Seccion: encabezado
// Muestra inicial del doctor, nombre y boton de salir.
class HomeAdminHeader extends StatelessWidget {
  const HomeAdminHeader({
    super.key,
    required this.inicialDoctor,
    required this.nombreDoctor,
    required this.onSalir,
  });

  final String inicialDoctor;
  final String nombreDoctor;
  final VoidCallback onSalir;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColores.base22FFFFFF,
              child: Text(
                inicialDoctor,
                style: const TextStyle(
                  color: AppColores.blanco,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColores.baseFFDDF6E5,
                  ),
                ),
                Text(
                  nombreDoctor,
                  style: const TextStyle(
                    color: AppColores.blanco,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColores.base22FFFFFF,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColores.base55FFFFFF),
          ),
          child: IconButton(
            onPressed: onSalir,
            icon: const Icon(Icons.logout, color: AppColores.blanco),
            tooltip: 'Salir',
          ),
        ),
      ],
    );
  }
}

// Seccion: fila de metricas
// Renderiza las tarjetas resumen del panel admin.
class HomeAdminMetricasRow extends StatelessWidget {
  const HomeAdminMetricasRow({super.key, required this.metricas});

  final List<HomeAdminMetricaVista> metricas;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        HomeAdminTarjetaMetrica(
          icono: metricas[0].icono,
          numero: metricas[0].numero,
          etiqueta: metricas[0].etiqueta,
        ),
        const SizedBox(width: 12),
        HomeAdminTarjetaMetrica(
          icono: metricas[1].icono,
          numero: metricas[1].numero,
          etiqueta: metricas[1].etiqueta,
        ),
        const SizedBox(width: 12),
        HomeAdminTarjetaMetrica(
          icono: metricas[2].icono,
          numero: metricas[2].numero,
          etiqueta: metricas[2].etiqueta,
        ),
      ],
    );
  }
}

// Seccion: tarjeta de metrica
// Componente visual reutilizable para cada contador.
class HomeAdminTarjetaMetrica extends StatelessWidget {
  const HomeAdminTarjetaMetrica({
    super.key,
    required this.icono,
    required this.numero,
    required this.etiqueta,
  });

  final IconData icono;
  final String numero;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColores.baseFFF7FFF9, AppColores.baseFFE5F4E9],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColores.baseFF5B7B66, width: 1.05),
          boxShadow: const [
            BoxShadow(
              color: AppColores.base220E2A17,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 3,
              decoration: BoxDecoration(
                color: AppColores.baseFF3F7A52,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 7),
            Icon(icono, size: 22, color: AppColores.baseFF245A37),
            const SizedBox(height: 6),
            Text(
              numero,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColores.baseFF20302A,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 14,
                color: AppColores.baseFF5A6A62,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Seccion: panel de seccion
// Contenedor visual con icono/titulo para agrupar bloques.
class HomeAdminPanelSeccion extends StatelessWidget {
  const HomeAdminPanelSeccion({
    super.key,
    required this.titulo,
    required this.icono,
    required this.child,
  });

  final String titulo;
  final IconData icono;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColores.baseFFF2F8F3,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColores.baseFF8AA391, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColores.base220E2A17,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColores.baseFFDCEADF,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icono, color: AppColores.baseFF27563A, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColores.baseFF1F3328,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// Seccion: menu principal
// Grid de accesos a modulos del panel admin.
class HomeAdminMenuPrincipalGrid extends StatelessWidget {
  const HomeAdminMenuPrincipalGrid({
    super.key,
    required this.onPacientes,
    required this.onCitas,
    required this.onHistorial,
    required this.onPersonal,
  });

  final VoidCallback onPacientes;
  final VoidCallback onCitas;
  final VoidCallback onHistorial;
  final VoidCallback onPersonal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            HomeAdminCardMenuPrincipal(
              icono: Icons.pets_outlined,
              titulo: 'Pacientes',
              subtitulo: 'Gestionar mascotas',
              onTap: onPacientes,
            ),
            const SizedBox(width: 15),
            HomeAdminCardMenuPrincipal(
              icono: Icons.calendar_month_outlined,
              titulo: 'Citas',
              subtitulo: 'Agendar y consultar',
              onTap: onCitas,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            HomeAdminCardMenuPrincipal(
              icono: Icons.assignment_outlined,
              titulo: 'Historial de citas',
              subtitulo: 'Citas pasadas',
              onTap: onHistorial,
            ),
            const SizedBox(width: 12),
            HomeAdminCardMenuPrincipal(
              icono: Icons.medical_services_outlined,
              titulo: 'Personal medico',
              subtitulo: 'Equipo Veterinario',
              onTap: onPersonal,
            ),
          ],
        ),
      ],
    );
  }
}

// Seccion: tarjeta de menu
// Card individual para cada acceso del menu principal.
class HomeAdminCardMenuPrincipal extends StatelessWidget {
  const HomeAdminCardMenuPrincipal({
    super.key,
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColores.transparente,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColores.baseFFF8FCF9, AppColores.baseFFE8F3EB],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColores.baseFF6A8674, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: AppColores.base220E2A17,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColores.baseFFD8E9DD,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icono, size: 24, color: AppColores.baseFF295B3B),
                ),
                const SizedBox(height: 10),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColores.baseFF21342A,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColores.baseFF5A6B61,
                    fontWeight: FontWeight.w600,
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

// Seccion: bloque de proximas citas
// Lista vertical de la tarjeta destacada de proxima cita.
class HomeAdminProximaCitaLista extends StatelessWidget {
  const HomeAdminProximaCitaLista({
    super.key,
    required this.citas,
    required this.onTap,
  });

  final List<HomeAdminProximaCitaVista> citas;
  final ValueChanged<HomeAdminProximaCitaVista> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (citas.isEmpty)
          const AdminEstadoVacioBase(
            mensaje: 'No hay citas programadas por ahora.',
            icono: Icons.event_busy_outlined,
          )
        else
          for (var i = 0; i < citas.length; i++) ...[
            HomeAdminItemProximaCita(
              titulo: citas[i].tituloTarjeta,
              detalle: citas[i].detalleTarjeta,
              onTap: () => onTap(citas[i]),
            ),
            if (i < citas.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }
}

// Seccion: item de proxima cita
// Card compacta de cita para el panel principal.
class HomeAdminItemProximaCita extends StatelessWidget {
  const HomeAdminItemProximaCita({
    super.key,
    required this.titulo,
    required this.detalle,
    required this.onTap,
  });

  final String titulo;
  final String detalle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColores.transparente,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColores.baseFFF8FCF9, AppColores.baseFFE9F3EC],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColores.baseFF66806F, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColores.baseFF2FA74D,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.favorite_border,
                  color: AppColores.blanco,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColores.baseFF22352B,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detalle,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColores.baseFF607067,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Seccion: navbar inferior
// Navegacion rapida entre las vistas administrativas.
class HomeAdminBottomNavbar extends StatelessWidget {
  const HomeAdminBottomNavbar({
    super.key,
    required this.onPacientes,
    required this.onCitas,
    required this.onHistorial,
    required this.onPersonal,
  });

  final VoidCallback onPacientes;
  final VoidCallback onCitas;
  final VoidCallback onHistorial;
  final VoidCallback onPersonal;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: AppColores.baseFF38A34B,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: onPacientes,
            icon: const Icon(
              Icons.pets,
              color: AppColores.negro,
              size: 30,
              fill: 0,
            ),
            tooltip: 'Pacientes',
          ),
          IconButton(
            onPressed: onCitas,
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: AppColores.negro,
              size: 30,
            ),
            tooltip: 'Citas',
          ),
          IconButton(
            onPressed: onHistorial,
            icon: const Icon(
              Icons.assignment_outlined,
              color: AppColores.negro,
              size: 30,
            ),
            tooltip: 'Historial de citas',
          ),
          IconButton(
            onPressed: onPersonal,
            icon: const Icon(
              Icons.medical_services_outlined,
              color: AppColores.negro,
              size: 30,
            ),
            tooltip: 'Personal medico',
          ),
        ],
      ),
    );
  }
}
