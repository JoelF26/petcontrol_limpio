// Sección: imports
// Se importan Material, modelo Mascota y servicio para actualizar datos.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/models/mascota.dart';
import 'package:petcontrol_limpio/services/mascota_service.dart';

// Sección: helper de apertura de detalle
// Muestra el popup centrado y retorna true cuando la mascota se actualiza.
Future<bool> mostrarDetalleMascotaCliente(
  BuildContext context,
  Mascota mascota,
) async {
  final actualizada = await showDialog<bool>(
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
            child: _DetalleMascotaClientePopup(mascota: mascota),
          ),
        ),
      );
    },
  );
  return actualizada == true;
}

// Sección: popup de detalle de mascota
// Conserva el diseño original de ficha y agrega edición solo al presionar botón.
class _DetalleMascotaClientePopup extends StatefulWidget {
  const _DetalleMascotaClientePopup({required this.mascota});

  final Mascota mascota;

  @override
  State<_DetalleMascotaClientePopup> createState() =>
      _DetalleMascotaClientePopupState();
}

// Sección: estado del popup de detalle
// Gestiona el modo edición y el guardado de cambios en JSON local.
class _DetalleMascotaClientePopupState
    extends State<_DetalleMascotaClientePopup> {
  // Sección: dependencias y formularios
  // Se preparan para validar y persistir los campos de la mascota.
  final MascotaService _mascotaService = MascotaService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _especieController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();

  // Sección: estado visual
  // Controla si el popup está en edición y si hay guardado en progreso.
  bool _modoEdicion = false;
  bool _guardando = false;

  // Sección: inicialización
  // Carga los datos actuales de la mascota dentro de los controladores.
  @override
  void initState() {
    super.initState();
    _resetearControladores();
  }

  // Sección: liberación de recursos
  // Evita fugas de memoria al cerrar el popup.
  @override
  void dispose() {
    _nombreController.dispose();
    _especieController.dispose();
    _razaController.dispose();
    _edadController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  // Sección: reset de datos del formulario
  // Restablece campos a la información original de la mascota.
  void _resetearControladores() {
    _nombreController.text = widget.mascota.nombreVisible;
    _especieController.text = widget.mascota.especieVisible;
    _razaController.text = widget.mascota.raza.trim().isEmpty
        ? ''
        : widget.mascota.raza;
    _edadController.text = widget.mascota.edadAnios?.toString() ?? '';
    _pesoController.text = _pesoEditableInicial(widget.mascota.pesoKg);
  }

  // Sección: helper de peso inicial
  // Convierte el valor numérico a texto amigable para edición.
  String _pesoEditableInicial(double? peso) {
    if (peso == null) {
      return '';
    }
    if (peso.truncateToDouble() == peso) {
      return peso.toInt().toString();
    }
    return peso.toStringAsFixed(1);
  }

  // Sección: validadores básicos
  // Asegura que los campos requeridos no estén vacíos.
  String? _validarRequerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }
    return null;
  }

  // Sección: parseo de edad
  // Extrae un entero desde texto para guardar en JSON local.
  int? _parsearEdad(String texto) {
    final match = RegExp(r'\d+').firstMatch(texto);
    if (match == null) {
      return null;
    }
    return int.tryParse(match.group(0) ?? '');
  }

  // Sección: parseo de peso
  // Acepta coma o punto como separador decimal.
  double? _parsearPeso(String texto) {
    final normalizado = texto.replaceAll(',', '.');
    final match = RegExp(r'\d+(\.\d+)?').firstMatch(normalizado);
    if (match == null) {
      return null;
    }
    return double.tryParse(match.group(0) ?? '');
  }

  // Sección: activación de edición
  // Habilita campos solamente cuando el usuario pulsa el botón.
  void _activarEdicion() {
    setState(() {
      _modoEdicion = true;
    });
  }

  // Sección: cancelación de edición
  // Vuelve al modo lectura y recupera valores originales.
  void _cancelarEdicion() {
    _resetearControladores();
    setState(() {
      _modoEdicion = false;
    });
  }

  // Sección: guardado de cambios
  // Actualiza JSON local y cierra el popup devolviendo true si guardó.
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
          content: Text('La edad debe contener un número válido.'),
        ),
      );
      return;
    }

    final peso = _parsearPeso(_pesoController.text.trim());
    if (peso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El peso debe contener un número válido.'),
        ),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      await _mascotaService.actualizarMascotaCliente(
        idMascota: widget.mascota.idMascota,
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
        const SnackBar(content: Text('Información de mascota actualizada.')),
      );
      _cerrar(context, true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar la mascota.')),
      );
      setState(() {
        _guardando = false;
      });
    }
  }

  // Sección: cierre seguro del popup
  // Evita hacer pop cuando no hay rutas apiladas.
  void _cerrar(BuildContext context, [bool? resultado]) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (!navigator.canPop()) {
      return;
    }
    navigator.pop(resultado);
  }

  // Sección: construcción del popup
  // Mantiene diseño anterior y agrega acciones de edición al pie.
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
                // Sección: encabezado del popup
                // Muestra icono, nombre, subtítulo y botón de cierre.
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
                            widget.mascota.nombreVisible,
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

                // Sección: campos de la ficha
                // Se ven en modo texto y cambian a inputs al activar edición.
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
                ),
                const SizedBox(height: 12),

                // Sección: acciones inferiores
                // Muestra botón de editar o acciones de cancelar/guardar.
                if (!_modoEdicion)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _activarEdicion,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColores.baseFF143B5F,
                        foregroundColor: AppColores.blanco,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Editar información',
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
                            backgroundColor: AppColores.baseFF143B5F,
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

  // Sección: campo de ficha reutilizable
  // Mantiene el bloque visual anterior y alterna entre texto e input sin cambiar diseño.
  Widget _campoFicha({
    required String etiqueta,
    required TextEditingController controller,
    required bool habilitado,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
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
              controller.text.trim().isEmpty ? '-' : controller.text.trim(),
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
}
