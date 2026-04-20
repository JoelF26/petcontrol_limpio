import 'package:flutter/material.dart';
import 'package:petcontrol/hex/infraestructura/mock/citas_mock.dart';
import 'package:petcontrol/ui/core/rutas/rutas.dart';
import 'package:petcontrol/ui/core/tema/app_colores.dart';
import 'package:petcontrol/ui/core/widgets/popup_detalle.dart';

class HomeAdmin extends StatelessWidget {
  const HomeAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final alturaCurva = (size.height * 0.74).clamp(560.0, 860.0);

    return Scaffold(
      backgroundColor: const Color(0xFFECECEC),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Color(0xFFECECEC))),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [AppColores.verdeOscuro, AppColores.verde],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipPath(
                clipper: _CurvaHomeAdminClipper(),
                child: Container(
                  color: const Color(0xFFECECEC),
                  height: alturaCurva,
                  width: double.infinity,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 92),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  const SizedBox(height: 8),
                  const Text(
                    'Controla agenda, pacientes y equipo medico desde el panel principal.',
                    style: TextStyle(
                      color: Color(0xFFDDF6E5),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _filaEstadisticas(),
                  const SizedBox(height: 16),
                  _PanelSeccion(
                    titulo: 'Menu Principal',
                    icono: Icons.dashboard_customize_outlined,
                    child: _menuPrincipalGrid(context),
                  ),
                  const SizedBox(height: 14),
                  _PanelSeccion(
                    titulo: 'Proxima Cita',
                    icono: Icons.event_note_outlined,
                    child: _tarjetaProximaCita(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavbar(context),
    );
  }
}

class _CurvaHomeAdminClipper extends CustomClipper<Path> {
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

Widget _header(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0x22FFFFFF),
            child: Text(
              inicialDoctorHomeAdminMock,
              style: const TextStyle(
                color: Colors.white,
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
                style: TextStyle(fontSize: 14, color: Color(0xFFDDF6E5)),
              ),
              Text(
                nombreDoctorHomeAdminMock,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
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
          color: const Color(0x22FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x55FFFFFF)),
        ),
        child: IconButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Salir',
        ),
      ),
    ],
  );
}

Widget _filaEstadisticas() {
  final metricas = metricasHomeAdminMock;
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _tarjetaMetrica(
        icono: metricas[0].icono,
        numero: metricas[0].numero,
        etiqueta: metricas[0].etiqueta,
      ),
      const SizedBox(width: 12),
      _tarjetaMetrica(
        icono: metricas[1].icono,
        numero: metricas[1].numero,
        etiqueta: metricas[1].etiqueta,
      ),
      const SizedBox(width: 12),
      _tarjetaMetrica(
        icono: metricas[2].icono,
        numero: metricas[2].numero,
        etiqueta: metricas[2].etiqueta,
      ),
    ],
  );
}

Widget _tarjetaMetrica({
  required IconData icono,
  required String numero,
  required String etiqueta,
}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7FFF9), Color(0xFFE5F4E9)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF5B7B66), width: 1.05),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220E2A17),
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
              color: const Color(0xFF3F7A52),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 7),
          Icon(icono, size: 22, color: const Color(0xFF245A37)),
          const SizedBox(height: 6),
          Text(
            numero,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF20302A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5A6A62),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _menuPrincipalGrid(BuildContext context) {
  return Column(
    children: [
      Row(
        children: [
          _cardMenuPrincipal(
            icono: Icons.pets_outlined,
            titulo: 'Pacientes',
            subtitulo: 'Gestionar mascotas',
            onTap: () {
              Navigator.pushNamed(context, Rutas.adminPacientesPage);
            },
          ),
          const SizedBox(width: 15),

          _cardMenuPrincipal(
            icono: Icons.calendar_month_outlined,
            titulo: 'Citas',
            subtitulo: 'Agendar y consultar',
            onTap: () {
              Navigator.pushNamed(context, Rutas.adminCitasPage);
            },
          ),
        ],
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          _cardMenuPrincipal(
            icono: Icons.assignment_outlined,
            titulo: 'Historial de citas',
            subtitulo: 'Citas pasadas',
            onTap: () {
              Navigator.pushNamed(context, Rutas.adminHistorialCitasPage);
            },
          ),

          const SizedBox(width: 12),
          _cardMenuPrincipal(
            icono: Icons.medical_services_outlined,
            titulo: 'Personal medico',
            subtitulo: 'Equipo Veterinario',
            onTap: () {
              Navigator.pushNamed(context, Rutas.adminPersonalMedicoPage);
            },
          ),
        ],
      ),
    ],
  );
}

Widget _cardMenuPrincipal({
  required IconData icono,
  required String titulo,
  required String subtitulo,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FCF9), Color(0xFFE8F3EB)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF6A8674), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x220E2A17),
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
                  color: const Color(0xFFD8E9DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icono, size: 24, color: const Color(0xFF295B3B)),
              ),
              const SizedBox(height: 10),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF21342A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5A6B61),
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

class _PanelSeccion extends StatelessWidget {
  const _PanelSeccion({
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
        color: const Color(0xFFF2F8F3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF8AA391), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220E2A17),
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
                  color: const Color(0xFFDCEADF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icono, color: const Color(0xFF27563A), size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF1F3328),
                    fontSize: 19,
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

void _abrirDetalleProximaCitaHomeAdmin(
  BuildContext context,
  ProximaCitaHomeAdminMock cita,
) {
  final partesTitulo = cita.titulo.split(' - ');
  final nombreMascota = partesTitulo.isNotEmpty
      ? partesTitulo.first
      : cita.titulo;
  final motivo = partesTitulo.length > 1
      ? partesTitulo.sublist(1).join(' - ')
      : 'Sin especificar';

  final partesDetalle = cita.detalle.split(' - ');
  final agenda = partesDetalle.isNotEmpty ? partesDetalle.first : cita.detalle;
  final profesional = partesDetalle.length > 1
      ? partesDetalle.sublist(1).join(' - ')
      : 'Sin asignar';

  mostrarPopupDetalle(
    context,
    ConfigPopupDetalle(
      titulo: nombreMascota,
      subtitulo: 'Detalle de próxima cita',
      icono: Icons.event_note_outlined,
      colorAcento: AppColores.verdepacientes,
      chips: const <String>['Proxima', 'Home Admin'],
      campos: <DetalleCampo>[
        DetalleCampo(etiqueta: 'Mascota', valor: nombreMascota),
        DetalleCampo(etiqueta: 'Motivo', valor: motivo),
        DetalleCampo(etiqueta: 'Fecha y hora', valor: agenda),
        DetalleCampo(etiqueta: 'Profesional', valor: profesional),
        const DetalleCampo(etiqueta: 'Estado', valor: 'Programada'),
      ],
    ),
  );
}

Widget _tarjetaProximaCita(BuildContext context) {
  return Column(
    children: [
      for (var i = 0; i < proximasCitasHomeAdminMock.length; i++) ...[
        _ItemProximaCita(
          titulo: proximasCitasHomeAdminMock[i].titulo,
          detalle: proximasCitasHomeAdminMock[i].detalle,
          onTap: () => _abrirDetalleProximaCitaHomeAdmin(
            context,
            proximasCitasHomeAdminMock[i],
          ),
        ),
        if (i < proximasCitasHomeAdminMock.length - 1)
          const SizedBox(height: 10),
      ],
    ],
  );
}

class _ItemProximaCita extends StatelessWidget {
  final String titulo;
  final String detalle;
  final VoidCallback onTap;

  const _ItemProximaCita({
    required this.titulo,
    required this.detalle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FCF9), Color(0xFFE9F3EC)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF66806F), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColores.verde,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.favorite_border,
                  color: Colors.white,
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
                        color: Color(0xFF22352B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detalle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF607067),
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

Widget _bottomNavbar(BuildContext context) {
  return Container(
    height: 76,
    decoration: const BoxDecoration(
      color: AppColores.navbar,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, Rutas.adminPacientesPage);
          },
          icon: const Icon(
            Icons.pets,
            color: AppColores.negro,
            size: 30,
            fill: 0,
          ),
          tooltip: 'Pacientes',
        ),
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, Rutas.adminCitasPage);
          },
          icon: const Icon(
            Icons.calendar_month_outlined,
            color: AppColores.negro,
            size: 30,
          ),
          tooltip: 'Citas',
        ),

        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, Rutas.adminHistorialCitasPage);
          },
          icon: const Icon(
            Icons.assignment_outlined,
            color: AppColores.negro,
            size: 30,
          ),
          tooltip: 'Historial de citas',
        ),
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, Rutas.adminPersonalMedicoPage);
          },
          icon: const Icon(
            Icons.medical_services_outlined,
            color: AppColores.negro,
            size: 30,
          ),
          tooltip: 'Personal médico',
        ),
      ],
    ),
  );
}
