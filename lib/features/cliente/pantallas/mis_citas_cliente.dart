// Sección: imports
// Se importan modelos, servicios y tarjeta de creación para conectar la vista con backend.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/citas/detalle_cita_cliente_popup.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/citas/tarjeta_creacion_cita.dart';
import 'package:petcontrol_limpio/models/cita.dart';
import 'package:petcontrol_limpio/services/auth_service.dart';
import 'package:petcontrol_limpio/services/cita_service.dart';
import 'package:petcontrol_limpio/services/mascota_service.dart';

// Sección: pantalla de citas del cliente
// Muestra todas las citas del usuario autenticado y permite registrar nuevas.
class MisCitasCliente extends StatefulWidget {
  const MisCitasCliente({super.key});

  @override
  State<MisCitasCliente> createState() => _MisCitasClienteState();
}

// Sección: estado de Mis Citas
// Gestiona consultas a JSON local, métricas dinámicas y apertura del formulario de cita.
class _MisCitasClienteState extends State<MisCitasCliente> {
  // Sección: servicios de backend
  // Se reutilizan para obtener usuario actual, citas y conteo de mascotas.
  final AuthService _authService = AuthService();
  final CitaService _citaService = CitaService();
  final MascotaService _mascotaService = MascotaService();

  // Sección: estado principal de la vista
  // Guarda datos del usuario y resultados para renderizar UI dinámica.
  bool _cargando = true;
  String _nombreCliente = 'Cliente';
  int _totalMascotas = 0;
  List<Cita> _citas = const <Cita>[];

  // Sección: inicialización de pantalla
  // Carga datos del usuario y su agenda al abrir la vista.
  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Sección: carga de datos de backend
  // Consulta citas y métricas del usuario autenticado desde JSON local.
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
          _totalMascotas = 0;
          _citas = const <Cita>[];
          _cargando = false;
        });
        return;
      }

      final resultados = await Future.wait<dynamic>([
        _citaService.obtenerCitasPorUsuario(idUsuario),
        _mascotaService.contarMascotasPorUsuario(idUsuario),
      ]);
      final citas = (resultados[0] as List<Cita>).toList(growable: false);
      final totalMascotas = resultados[1] as int;

      if (!mounted) {
        return;
      }
      setState(() {
        _nombreCliente = nombre;
        _totalMascotas = totalMascotas;
        _citas = citas;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _nombreCliente = _resolverNombreVisible(null);
        _totalMascotas = 0;
        _citas = const <Cita>[];
        _cargando = false;
      });
    }
  }

  // Sección: id de usuario para consultas
  // Prioriza id del perfil y usa uid de autenticación local como respaldo.
  String _resolverIdUsuario(String? idPerfil) {
    return (idPerfil ?? '').trim();
  }

  // Sección: nombre visible del cliente
  // Usa nombre de perfil y, si falta, construye un alias desde el correo.
  String _resolverNombreVisible(String? nombrePerfil) {
    final nombreLimpio = (nombrePerfil ?? '').trim();
    if (nombreLimpio.isNotEmpty) {
      return nombreLimpio;
    }
    return 'Cliente';
  }

  // Sección: resumen de citas próximas
  // Cuenta estados "proxima" y "pendiente" como próximas a atender.
  int get _totalProximas {
    return _citas.where((cita) {
      final estado = cita.estadoVisible.toLowerCase();
      return estado == 'proxima' || estado == 'pendiente';
    }).length;
  }

  // Sección: apertura de formulario de cita
  // Muestra popup centrado con fondo oscuro y refresca datos al guardar.
  Future<void> _abrirCreacionCita() async {
    if (!mounted) {
      return;
    }

    final creada = await showDialog<bool>(
      context: context,
      barrierColor: AppColores.negro.withValues(alpha: 0.62),
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
              child: const TarjetaCreacionCita(),
            ),
          ),
        );
      },
    );

    if (creada == true) {
      await _cargarDatos();
    }
  }

  // Sección: apertura de detalle de cita
  // Muestra la ficha completa y recarga datos si hay edición guardada.
  Future<void> _abrirDetalleCita(Cita cita) async {
    if (!mounted) {
      return;
    }
    final actualizada = await mostrarDetalleCitaCliente(context, cita);
    if (actualizada) {
      await _cargarDatos();
    }
  }

  // Sección: construcción de la pantalla
  // Mantiene el diseño visual de cabecera y agenda con datos reales.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.baseFFF2F5FA,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
        width: 62,
        height: 62,
        child: FloatingActionButton(
          onPressed: _abrirCreacionCita,
          backgroundColor: AppColores.baseFF153A5F,
          foregroundColor: AppColores.blanco,
          child: const Icon(Icons.add, size: 34),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: _FondoMisCitas()),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EncabezadoMisCitas(
                    onVolver: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 14),
                  _ResumenCitasCliente(
                    totalCitas: _citas.length,
                    totalProximas: _totalProximas,
                    totalMascotasConCita: _totalMascotas,
                  ),
                  const SizedBox(height: 20),
                  _PanelAgendaPersonal(
                    cargando: _cargando,
                    citas: _citas,
                    nombreCliente: _nombreCliente,
                    onTapCita: _abrirDetalleCita,
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
// Conserva degradado y círculos decorativos de la vista.
class _FondoMisCitas extends StatelessWidget {
  const _FondoMisCitas();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 286,
          child: Stack(
            children: const [
              _GradienteFondoMisCitas(),
              Positioned(
                top: -34,
                right: -22,
                child: _CirculoDecorativo(diametro: 126, opacidad: 0.2),
              ),
              Positioned(
                bottom: 18,
                left: -24,
                child: _CirculoDecorativo(diametro: 98, opacidad: 0.14),
              ),
            ],
          ),
        ),
        const Expanded(child: ColoredBox(color: AppColores.baseFFF2F5FA)),
      ],
    );
  }
}

// Sección: gradiente de cabecera
// Define la banda azul con bordes inferiores redondeados.
class _GradienteFondoMisCitas extends StatelessWidget {
  const _GradienteFondoMisCitas();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColores.baseFF112F4F,
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

// Sección: círculo decorativo
// Añade profundidad visual al fondo superior.
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

// Sección: encabezado de la vista
// Muestra botón atrás, título y subtítulo de la sección de citas.
class _EncabezadoMisCitas extends StatelessWidget {
  const _EncabezadoMisCitas({required this.onVolver});

  final VoidCallback onVolver;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [_BotonEncabezadoIcono(onTap: onVolver)]),
        const SizedBox(height: 12),
        const Text(
          'Mis citas',
          style: TextStyle(
            color: AppColores.blanco,
            fontSize: 45,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Organiza tus citas veterinarias y revisa el detalle de\ncada atencion.',
          style: TextStyle(
            color: AppColores.baseFFDCE9FF,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

// Sección: botón circular del encabezado
// Se usa para regresar a la pantalla anterior.
class _BotonEncabezadoIcono extends StatelessWidget {
  const _BotonEncabezadoIcono({required this.onTap});

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

// Sección: resumen superior de métricas
// Renderiza contadores dinámicos de citas, próximas y mascotas.
class _ResumenCitasCliente extends StatelessWidget {
  const _ResumenCitasCliente({
    required this.totalCitas,
    required this.totalProximas,
    required this.totalMascotasConCita,
  });

  final int totalCitas;
  final int totalProximas;
  final int totalMascotasConCita;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TarjetaResumen(
          etiqueta: 'Citas',
          valor: '$totalCitas',
          icono: Icons.calendar_month_outlined,
        ),
        const SizedBox(width: 10),
        _TarjetaResumen(
          etiqueta: 'Proximas',
          valor: '$totalProximas',
          icono: Icons.watch_later_outlined,
        ),
        const SizedBox(width: 10),
        _TarjetaResumen(
          etiqueta: 'Mascotas',
          valor: '$totalMascotasConCita',
          icono: Icons.pets_outlined,
        ),
      ],
    );
  }
}

// Sección: tarjeta de resumen individual
// Define estilo compacto para cada métrica del encabezado.
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
                color: AppColores.baseD9E6F1FF,
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

// Sección: panel de agenda personal
// Lista todas las citas del usuario o muestra estado vacío/cargando.
class _PanelAgendaPersonal extends StatelessWidget {
  const _PanelAgendaPersonal({
    required this.cargando,
    required this.citas,
    required this.nombreCliente,
    required this.onTapCita,
  });

  final bool cargando;
  final List<Cita> citas;
  final String nombreCliente;
  final ValueChanged<Cita> onTapCita;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: AppColores.baseFFF8FAFD,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColores.baseFFB8C8DC, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agenda personal',
            style: TextStyle(
              color: AppColores.baseFF213D6A,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${citas.length} ${citas.length == 1 ? 'cita registrada' : 'citas registradas'} a nombre de $nombreCliente',
            style: const TextStyle(
              color: AppColores.baseFF6A7E98,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          if (cargando)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 26),
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
            )
          else if (citas.isEmpty)
            const _EstadoVacioCitas()
          else
            Column(
              children: [
                for (var i = 0; i < citas.length; i++) ...[
                  _TarjetaAgendaCita(
                    cita: citas[i],
                    onTap: () => onTapCita(citas[i]),
                  ),
                  if (i != citas.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

// Sección: estado vacío de agenda
// Muestra mensaje cuando el usuario aún no tiene citas creadas.
class _EstadoVacioCitas extends StatelessWidget {
  const _EstadoVacioCitas();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColores.baseFFF0F4F9,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColores.baseFFC9D8E7, width: 1),
      ),
      child: const Text(
        'No tienes citas registradas.',
        style: TextStyle(
          color: AppColores.baseFF5B7187,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Sección: tarjeta de cita individual
// Replica el diseño solicitado: hora bajo icono, especie/fecha y motivo.
class _TarjetaAgendaCita extends StatelessWidget {
  const _TarjetaAgendaCita({required this.cita, required this.onTap});

  final Cita cita;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fechaChip = _fechaTextoCorta(cita);
    final horaVisible = _horaTextoCorta(cita);

    return Material(
      color: AppColores.transparente,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
          decoration: BoxDecoration(
            color: AppColores.baseFFE9EDF4,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColores.baseFFB8C8DC, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 78,
                decoration: BoxDecoration(
                  color: AppColores.baseFFD6E4F2,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: AppColores.baseFF2D5C8C,
                      size: 24,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      horaVisible,
                      style: const TextStyle(
                        color: AppColores.baseFF2E5683,
                        fontSize: 16 / 1.1, // 14.54 aprox
                        fontWeight: FontWeight.w600,
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
                    Text(
                      cita.nombreMascotaVisible,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColores.baseFF203E6D,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _ChipDato(
                          texto: cita.especieMascotaVisible,
                          fondo: AppColores.baseFFD7E4F5,
                          colorTexto: AppColores.baseFF315D8A,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _ChipDato(
                              texto: fechaChip,
                              fondo: AppColores.baseFFD7E4F5,
                              colorTexto: AppColores.baseFF315D8A,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColores.baseFFDCE6F6,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        cita.motivoVisible,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColores.baseFF233F69,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColores.baseFF61766D,
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sección: fecha corta para chip
  // Formatea la fecha al estilo "08 mar 2026".
  String _fechaTextoCorta(Cita cita) {
    if (cita.fechaHora != null) {
      const meses = <String>[
        'ene',
        'feb',
        'mar',
        'abr',
        'may',
        'jun',
        'jul',
        'ago',
        'sep',
        'oct',
        'nov',
        'dic',
      ];
      final fecha = cita.fechaHora!;
      final dia = fecha.day.toString().padLeft(2, '0');
      final mes = meses[fecha.month - 1];
      return '$dia $mes ${fecha.year}';
    }

    final fechaTexto = cita.fechaTexto.trim();
    if (fechaTexto.isEmpty) {
      return 'Fecha por definir';
    }

    final parseada = DateTime.tryParse(fechaTexto);
    if (parseada == null) {
      return fechaTexto;
    }

    const meses = <String>[
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final dia = parseada.day.toString().padLeft(2, '0');
    final mes = meses[parseada.month - 1];
    return '$dia $mes ${parseada.year}';
  }

  // Sección: hora visible para bloque izquierdo
  // Prioriza fecha_hora y usa hora_texto como respaldo.
  String _horaTextoCorta(Cita cita) {
    if (cita.fechaHora != null) {
      final hora = cita.fechaHora!.hour.toString().padLeft(2, '0');
      final minuto = cita.fechaHora!.minute.toString().padLeft(2, '0');
      return '$hora:$minuto';
    }

    final horaTexto = cita.horaTexto.trim();
    if (horaTexto.isEmpty) {
      return '--:--';
    }
    return horaTexto;
  }
}

// Sección: chip visual de datos
// Se usa para especie y fecha dentro de cada tarjeta de cita.
class _ChipDato extends StatelessWidget {
  const _ChipDato({
    required this.texto,
    required this.fondo,
    required this.colorTexto,
  });

  final String texto;
  final Color fondo;
  final Color colorTexto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: colorTexto,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
      ),
    );
  }
}
