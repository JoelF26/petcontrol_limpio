// Seccion: imports
// Se importan servicios, funciones y widgets de apoyo para la vista de pacientes admin.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/constants/roles_usuario.dart';
import 'package:petcontrol_limpio/features/admin/models/vista_pacientes_admin_view_data.dart';
import 'package:petcontrol_limpio/features/admin/widgets/admin_base_widgets.dart';
import 'package:petcontrol_limpio/features/admin/widgets/detalle_paciente_admin_popup.dart';
import 'package:petcontrol_limpio/features/admin/widgets/tarjeta_creacion_paciente.dart';
import 'package:petcontrol_limpio/features/admin/widgets/vista_pacientes_admin_content.dart';
import 'package:petcontrol_limpio/features/admin/widgets/vista_pacientes_admin_widgets.dart';
import 'package:petcontrol_limpio/services/mascota_service.dart';
import 'package:petcontrol_limpio/services/usuario_service.dart';

// Seccion: pantalla de pacientes admin
// Muestra mascotas registradas y permite crear nuevas desde el modulo admin.
class VistaPacientesAdmin extends StatefulWidget {
  const VistaPacientesAdmin({super.key});

  @override
  State<VistaPacientesAdmin> createState() => _VistaPacientesAdminState();
}

class _VistaPacientesAdminState extends State<VistaPacientesAdmin> {
  // Seccion: dependencias y estado local
  // Manejan carga de datos, busqueda y persistencia desde formulario.
  final MascotaService _mascotaService = MascotaService();
  final UsuarioService _usuarioService = UsuarioService();
  final TextEditingController _busquedaCtrl = TextEditingController();

  bool _cargando = true;
  String? _errorCarga;
  List<PacienteVistaAdmin> _pacientes = const <PacienteVistaAdmin>[];

  @override
  void initState() {
    super.initState();
    _cargarPacientes();
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  // Seccion: carga de backend
  // Recupera pacientes y actualiza estado visual.
  Future<void> _cargarPacientes() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });

    try {
      final pacientes = await VistaPacientesAdminFunciones.cargarPacientes(
        mascotaService: _mascotaService,
        usuarioService: _usuarioService,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _pacientes = pacientes;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorCarga = 'No se pudieron cargar los pacientes.';
        _cargando = false;
      });
    }
  }

  // Seccion: filtros y metricas
  // Derivan lista visible y resumen de especies.
  List<PacienteVistaAdmin> get _pacientesFiltrados {
    return VistaPacientesAdminFunciones.filtrarPacientes(
      pacientes: _pacientes,
      termino: _busquedaCtrl.text,
    );
  }

  int get _totalEspecies {
    return VistaPacientesAdminFunciones.totalEspecies(_pacientes);
  }

  // Seccion: formulario de alta
  // Abre popup con usuarios finales (rol cliente/usuario) y delega guardado.
  Future<void> _abrirRegistroPaciente() async {
    final usuarios = await _usuarioService.obtenerUsuarios();
    if (!mounted) {
      return;
    }

    final usuariosFinales = usuarios.where((usuario) {
      final rol = usuario.rol.trim().toLowerCase();
      return rol == RolesUsuario.cliente || rol == 'usuario';
    });

    final usuariosRegistrados = usuariosFinales
        .map(
          (usuario) => UsuarioRegistroPaciente(
            idUsuario: usuario.idUsuario,
            nombreCompleto: usuario.nombreCompleto,
          ),
        )
        .toList(growable: false)
      ..sort(
        (a, b) => a.nombreCompleto.toLowerCase().compareTo(
          b.nombreCompleto.toLowerCase(),
        ),
      );

    if (usuariosRegistrados.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay usuarios con rol de usuario para asignar.'),
        ),
      );
      return;
    }

    await showGeneralDialog<void>(
      context: context,
      barrierLabel: 'registro_paciente',
      barrierColor: Colors.black38,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Material(
                type: MaterialType.transparency,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: TarjetaCreacionPaciente(
                    onCerrar: () => Navigator.of(dialogContext).pop(),
                    usuariosRegistrados: usuariosRegistrados,
                    onRegistrar: (data) {
                      _registrarPacienteDesdeDialogo(data: data);
                    },
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
  }

  // Seccion: guardado de paciente
  // Persiste la mascota y refresca listado con feedback visual.
  Future<void> _registrarPacienteDesdeDialogo({
    required PacienteCreacionData data,
  }) async {
    try {
      await VistaPacientesAdminFunciones.registrarPacienteDesdeDialogo(
        data: data,
        mascotaService: _mascotaService,
      );

      if (!mounted) {
        return;
      }
      final navigator = Navigator.of(context, rootNavigator: true);
      if (navigator.canPop()) {
        navigator.pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente registrado correctamente.')),
      );
      await _cargarPacientes();
    } on FormatException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
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
        const SnackBar(content: Text('No se pudo registrar el paciente.')),
      );
    }
  }

  // Seccion: detalle del paciente
  // Abre ficha editable y recarga lista si se guarda informacion.
  Future<void> _abrirDetallePacientePreview(PacienteVistaAdmin paciente) async {
    final actualizado = await mostrarDetallePacienteAdmin(context, paciente);
    if (!mounted || !actualizado) {
      return;
    }
    await _cargarPacientes();
  }

  // Seccion: composicion principal
  // Construye la UI llamando widgets separados y estado de la pantalla.
  @override
  Widget build(BuildContext context) {
    final pacientes = _pacientesFiltrados;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F2),
      floatingActionButton: SizedBox(
        width: 62,
        height: 62,
        child: FloatingActionButton(
          onPressed: _abrirRegistroPaciente,
          backgroundColor: const Color(0xFF1E6246),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 34),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: VistaPacientesAdminFondo()),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VistaPacientesAdminEncabezado(
                    onVolver: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 14),
                  VistaPacientesAdminResumen(
                    totalPacientes: _pacientes.length,
                    totalEspecies: _totalEspecies,
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
                          'Listado de pacientes',
                          style: TextStyle(
                            color: Color(0xFF22362C),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pacientes.length} registros visibles',
                          style: const TextStyle(
                            color: Color(0xFF617468),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        VistaPacientesAdminBuscador(
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
                        else if (pacientes.isEmpty)
                          const AdminEstadoVacioBase(
                            mensaje: 'No hay pacientes registrados.',
                            icono: Icons.pets_outlined,
                          )
                        else
                          for (var i = 0; i < pacientes.length; i++) ...[
                            VistaPacientesAdminTarjeta(
                              paciente: pacientes[i],
                              onTap: () => _abrirDetallePacientePreview(
                                pacientes[i],
                              ),
                            ),
                            if (i < pacientes.length - 1)
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
