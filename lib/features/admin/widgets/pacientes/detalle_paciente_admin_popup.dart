// Seccion: imports
// Se importan Material, modelo visual admin y servicio de mascotas para editar.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/admin/models/vista_pacientes_admin_view_data.dart';
import 'package:petcontrol_limpio/services/mascota_service.dart';

// Seccion: helper de apertura
// Muestra la ficha admin centrada y retorna true cuando se actualiza el paciente.
Future<bool> mostrarDetallePacienteAdmin(
  BuildContext context,
  PacienteVistaAdmin paciente,
) async {
  final actualizado = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColores.negro.withValues(alpha: 0.55),
    builder: (context) {
      final teclado = MediaQuery.of(context).viewInsets;
      return AnimatedPadding(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOut,
        padding: EdgeInsets.fromLTRB(12, 16, 12, 16 + teclado.bottom),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: _DetallePacienteAdminPopup(paciente: paciente),
          ),
        ),
      );
    },
  );
  return actualizado == true;
}

// Seccion: popup de detalle admin
// Conserva ficha de paciente y habilita edicion al pulsar el boton inferior.
class _DetallePacienteAdminPopup extends StatefulWidget {
  const _DetallePacienteAdminPopup({required this.paciente});

  final PacienteVistaAdmin paciente;

  @override
  State<_DetallePacienteAdminPopup> createState() =>
      _DetallePacienteAdminPopupState();
}

// Seccion: estado del popup
// Gestiona modo lectura/edicion y persistencia de cambios.
class _DetallePacienteAdminPopupState
    extends State<_DetallePacienteAdminPopup> {
  // Seccion: dependencias y controladores
  // Preparan validacion de campos y guardado contra JSON local.
  final MascotaService _mascotaService = MascotaService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _especieController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();

  // Seccion: estado visual
  // Controla si el formulario esta editable y si hay guardado en curso.
  bool _modoEdicion = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _resetearControladores();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _especieController.dispose();
    _razaController.dispose();
    _edadController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  // Seccion: carga inicial
  // Copia los valores del paciente a los controladores del formulario.
  void _resetearControladores() {
    _nombreController.text = widget.paciente.nombre;
    _especieController.text = widget.paciente.especie;
    _razaController.text = widget.paciente.raza;
    _edadController.text = widget.paciente.edad.toString();
    _pesoController.text = widget.paciente.peso.toString();
  }

  // Seccion: validadores y parseo
  // Garantizan datos minimos antes de guardar.
  String? _validarRequerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }
    return null;
  }

  int? _parsearEdad(String texto) {
    final match = RegExp(r'\d+').firstMatch(texto);
    return int.tryParse(match?.group(0) ?? '');
  }

  double? _parsearPeso(String texto) {
    final normalizado = texto.replaceAll(',', '.');
    final match = RegExp(r'\d+(\.\d+)?').firstMatch(normalizado);
    return double.tryParse(match?.group(0) ?? '');
  }

  // Seccion: acciones de edicion
  // Habilitan y cancelan modo editable sin perder consistencia visual.
  void _activarEdicion() {
    setState(() {
      _modoEdicion = true;
    });
  }

  void _cancelarEdicion() {
    _resetearControladores();
    setState(() {
      _modoEdicion = false;
    });
  }

  // Seccion: guardado
  // Persiste la mascota editada y cierra popup devolviendo true.
  Future<void> _guardarCambios() async {
    if (_guardando) {
      return;
    }
    final valido = _formKey.currentState?.validate() == true;
    if (!valido) {
      return;
    }

    final edad = _parsearEdad(_edadController.text.trim());
    if (edad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La edad debe contener un numero valido.'),
        ),
      );
      return;
    }

    final peso = _parsearPeso(_pesoController.text.trim());
    if (peso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El peso debe contener un numero valido.'),
        ),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      await _mascotaService.actualizarMascotaCliente(
        idMascota: widget.paciente.idMascota,
        nombre: _nombreController.text.trim(),
        especie: _especieController.text.trim(),
        raza: _razaController.text.trim(),
        edadAnios: edad,
        pesoKg: peso,
      );

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente actualizado correctamente.')),
      );
      _cerrar(context, true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar el paciente.')),
      );
      setState(() {
        _guardando = false;
      });
    }
  }

  // Seccion: cierre seguro
  // Evita pop cuando no hay ruta disponible.
  void _cerrar(BuildContext context, [bool? resultado]) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (!navigator.canPop()) {
      return;
    }
    navigator.pop(resultado);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColores.transparente,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: AppColores.baseFFDCDDDE,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Seccion: encabezado
                // Muestra icono, nombre, subtitulo y boton de cierre.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColores.baseFFC6DACC,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        color: AppColores.baseFF6BA26E,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.paciente.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColores.baseFF1F2A35,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Ficha completa del paciente',
                            style: TextStyle(
                              color: AppColores.baseFF6B737E,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _cerrar(context),
                      splashRadius: 18,
                      icon: const Icon(
                        Icons.close,
                        color: AppColores.baseFF6B737E,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Seccion: campos de ficha
                // Se visualizan como texto y pasan a input al editar.
                _campoFicha(
                  etiqueta: 'Nombre',
                  controller: _nombreController,
                  habilitado: _modoEdicion,
                  validator: _validarRequerido,
                ),
                const SizedBox(height: 10),
                _campoFicha(
                  etiqueta: 'Especie',
                  controller: _especieController,
                  habilitado: _modoEdicion,
                  validator: _validarRequerido,
                ),
                const SizedBox(height: 10),
                _campoFicha(
                  etiqueta: 'Raza',
                  controller: _razaController,
                  habilitado: _modoEdicion,
                ),
                const SizedBox(height: 10),
                _campoFicha(
                  etiqueta: 'Edad',
                  controller: _edadController,
                  habilitado: _modoEdicion,
                  keyboardType: TextInputType.number,
                  validator: _validarRequerido,
                  sufijoLectura: ' anos',
                ),
                const SizedBox(height: 10),
                _campoFicha(
                  etiqueta: 'Peso',
                  controller: _pesoController,
                  habilitado: _modoEdicion,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _validarRequerido,
                  sufijoLectura: ' kg',
                ),
                const SizedBox(height: 10),
                _campoSoloLectura(
                  etiqueta: 'Dueno',
                  valor: widget.paciente.dueno,
                ),
                const SizedBox(height: 12),

                // Seccion: acciones inferiores
                // Muestra boton de editar o acciones de cancelar/guardar.
                if (!_modoEdicion)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _activarEdicion,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColores.baseFF1E6246,
                        foregroundColor: AppColores.blanco,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Editar informacion',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _guardando ? null : _cancelarEdicion,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColores.baseFF5A616A,
                            side: const BorderSide(
                              color: AppColores.baseFFA4ABB3,
                            ),
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _guardando ? null : _guardarCambios,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColores.baseFF1E6246,
                            foregroundColor: AppColores.blanco,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _guardando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColores.blanco,
                                  ),
                                )
                              : const Text(
                                  'Guardar cambios',
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Seccion: campo editable/lectura
  // Reutiliza el mismo bloque visual para mostrar texto o input.
  Widget _campoFicha({
    required String etiqueta,
    required TextEditingController controller,
    required bool habilitado,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String sufijoLectura = '',
  }) {
    final texto = controller.text.trim();
    final textoLectura = texto.isEmpty ? '-' : '$texto$sufijoLectura';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColores.baseFFE9EAEB,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
              color: AppColores.baseFF7A8088,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          if (!habilitado)
            Text(
              textoLectura,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColores.baseFF1F2A35,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            )
          else
            TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: AppColores.baseFF1F2A35,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                errorStyle: TextStyle(height: 0.01, fontSize: 0),
              ),
            ),
        ],
      ),
    );
  }

  // Seccion: campo fijo
  // Renderiza un bloque de solo lectura que nunca entra en edicion.
  Widget _campoSoloLectura({required String etiqueta, required String valor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColores.baseFFE9EAEB,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
              color: AppColores.baseFF7A8088,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            valor.trim().isEmpty ? '-' : valor.trim(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColores.baseFF1F2A35,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
