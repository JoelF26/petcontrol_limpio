// Seccion: imports
// Se importan servicios, funciones y widgets para la vista de personal medico.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/widgets/popup_detalle.dart';
import 'package:petcontrol_limpio/features/admin/models/personal_medico_view_data.dart';
import 'package:petcontrol_limpio/features/admin/widgets/admin_base_widgets.dart';
import 'package:petcontrol_limpio/features/admin/widgets/personal_medico_content.dart';
import 'package:petcontrol_limpio/features/admin/widgets/personal_medico_widgets.dart';
import 'package:petcontrol_limpio/services/personal_medico_service.dart';
import 'package:petcontrol_limpio/services/usuario_service.dart';

// Seccion: pantalla personal medico
// Presenta la IU del modulo y coordina eventos de carga y registro.
class PersonalMedicoAdmin extends StatefulWidget {
  const PersonalMedicoAdmin({super.key});

  @override
  State<PersonalMedicoAdmin> createState() => _PersonalMedicoAdminState();
}

class _PersonalMedicoAdminState extends State<PersonalMedicoAdmin> {
  // Seccion: dependencias y estado local
  // Manejan busqueda, servicios y estado de carga.
  final TextEditingController _busquedaCtrl = TextEditingController();
  final PersonalMedicoService _personalMedicoService = PersonalMedicoService();
  final UsuarioService _usuarioService = UsuarioService();

  final List<MedicoVista> _personal = <MedicoVista>[];
  bool _cargando = true;
  String? _errorCarga;

  @override
  void initState() {
    super.initState();
    _cargarPersonalMedico();
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  // Seccion: listado filtrado
  // Retorna la lista visual segun texto de busqueda.
  List<MedicoVista> get _personalFiltrado {
    return PersonalMedicoFunciones.filtrarPersonal(
      personal: _personal,
      busqueda: _busquedaCtrl.text,
    );
  }

  // Seccion: conteo por estado
  // Calcula metricas de resumen segun estado de medico.
  int _conteoEstado(String estado) {
    return PersonalMedicoFunciones.conteoEstado(_personal, estado);
  }

  // Seccion: carga de backend
  // Consulta datos desde servicios y actualiza estado visual.
  Future<void> _cargarPersonalMedico() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });

    try {
      final lista = await PersonalMedicoFunciones.cargarPersonalMedico(
        personalMedicoService: _personalMedicoService,
        usuarioService: _usuarioService,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _personal
          ..clear()
          ..addAll(lista);
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorCarga = 'No se pudo cargar el personal medico.';
        _cargando = false;
      });
    }
  }

  // Seccion: popup detalle
  // Muestra informacion completa del medico seleccionado.
  void _verDetalle(MedicoVista medico) {
    mostrarPopupDetalle(
      context,
      ConfigPopupDetalle(
        titulo: medico.nombreCompleto,
        subtitulo: medico.especialidad,
        icono: Icons.medical_services_outlined,
        colorAcento: PersonalMedicoFunciones.estadoText(medico.estado),
        chips: <String>[medico.estado, medico.jornada],
        campos: <DetalleCampo>[
          DetalleCampo(etiqueta: 'Correo', valor: medico.correo),
          DetalleCampo(etiqueta: 'Telefono', valor: medico.telefono),
          DetalleCampo(etiqueta: 'Documento', valor: medico.documento),
          DetalleCampo(etiqueta: 'Especialidad', valor: medico.especialidad),
          DetalleCampo(
            etiqueta: 'Fecha de ingreso',
            valor: PersonalMedicoFunciones.fecha(medico.fechaIngreso),
          ),
        ],
      ),
    );
  }

  // Seccion: apertura de formulario
  // Lanza el dialogo para capturar datos de nuevo medico.
  Future<void> _abrirFormularioNuevoMedico() async {
    final input = await showGeneralDialog<NuevoMedicoInput>(
      context: context,
      barrierLabel: 'nuevo_medico',
      barrierDismissible: true,
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Material(
                type: MaterialType.transparency,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: FormularioNuevoMedico(
                    onCerrar: () => Navigator.of(dialogContext).pop(),
                    onGuardar: (value) =>
                        Navigator.of(dialogContext).pop(value),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curva = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curva,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(curva),
            child: child,
          ),
        );
      },
    );

    if (input == null || !mounted) {
      return;
    }

    await _registrarPersonalMedico(input);
  }

  // Seccion: registro de medico
  // Persiste el medico y sincroniza su usuario con rol admin.
  Future<void> _registrarPersonalMedico(NuevoMedicoInput input) async {
    try {
      await PersonalMedicoFunciones.registrarPersonalMedico(
        input: input,
        personalActual: _personal,
        personalMedicoService: _personalMedicoService,
        usuarioService: _usuarioService,
      );

      await _cargarPersonalMedico();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal medico registrado con rol admin.')),
      );
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message.toString())),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo registrar el personal medico.')),
      );
    }
  }

  // Seccion: composicion de pantalla
  // Construye la UI principal usando widgets reutilizables.
  @override
  Widget build(BuildContext context) {
    final lista = _personalFiltrado;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F2),
      floatingActionButton: SizedBox(
        width: 62,
        height: 62,
        child: FloatingActionButton(
          onPressed: _abrirFormularioNuevoMedico,
          backgroundColor: const Color(0xFF1E6246),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 34),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: PersonalMedicoFondo()),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PersonalMedicoEncabezado(
                    onVolver: () => Navigator.of(context).pop(),
                    totalResultados: lista.length,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      PersonalMedicoResumenBox(
                        valor: '${_personal.length}',
                        etiqueta: 'Total',
                        icono: Icons.badge_outlined,
                      ),
                      const SizedBox(width: 10),
                      PersonalMedicoResumenBox(
                        valor: '${_conteoEstado('Activo')}',
                        etiqueta: 'Activos',
                        icono: Icons.check_circle_outline,
                      ),
                      const SizedBox(width: 10),
                      PersonalMedicoResumenBox(
                        valor: '${_conteoEstado('Vacaciones')}',
                        etiqueta: 'Vacaciones',
                        icono: Icons.beach_access_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FBF9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFC0D2C8),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A183325),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Equipo medico',
                          style: TextStyle(
                            color: Color(0xFF22362C),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${lista.length} profesionales visibles',
                          style: const TextStyle(
                            color: Color(0xFF617468),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        PersonalMedicoBuscador(
                          controller: _busquedaCtrl,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        if (_cargando)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: CircularProgressIndicator(strokeWidth: 2.3),
                            ),
                          )
                        else if (_errorCarga != null)
                          AdminEstadoVacioBase(
                            mensaje: _errorCarga!,
                            icono: Icons.error_outline_rounded,
                          )
                        else if (lista.isEmpty)
                          const PersonalMedicoVacio()
                        else
                          for (var i = 0; i < lista.length; i++) ...[
                            PersonalMedicoTarjeta(
                              medico: lista[i],
                              iniciales: PersonalMedicoFunciones.iniciales(
                                lista[i].nombreCompleto,
                              ),
                              colorBg: PersonalMedicoFunciones.estadoBg(
                                lista[i].estado,
                              ),
                              colorText: PersonalMedicoFunciones.estadoText(
                                lista[i].estado,
                              ),
                              onTap: () => _verDetalle(lista[i]),
                            ),
                            if (i < lista.length - 1)
                              const SizedBox(height: 12),
                          ],
                      ],
                    ),
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
