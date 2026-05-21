import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/core/di/app_dependencies.dart';
import 'package:petcontrol_limpio/features/admin/models/personal_medico_view_data.dart';
import 'package:petcontrol_limpio/features/admin/utils/correo_medico_helper.dart';
import 'package:petcontrol_limpio/application/services/catalogos_json_service.dart';

// Seccion: formulario de nuevo medico
// Dialogo visual para capturar datos y emitir input validado.
class FormularioNuevoMedico extends StatefulWidget {
  const FormularioNuevoMedico({
    super.key,
    required this.onCerrar,
    required this.onGuardar,
  });

  final VoidCallback onCerrar;
  final ValueChanged<NuevoMedicoInput> onGuardar;

  @override
  State<FormularioNuevoMedico> createState() => _FormularioNuevoMedicoState();
}

class _FormularioNuevoMedicoState extends State<FormularioNuevoMedico> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _documento = TextEditingController();
  final _otraEspecialidad = TextEditingController();
  final CatalogosJsonService _catalogosService =
      AppDependencies.catalogosJsonService;

  // Seccion: estado local del formulario
  // Controla valores seleccionados y visibilidad de campos condicionales.
  static const String _opcionOtraEspecialidad = 'Otro';

  bool _cargandoCatalogos = true;
  List<String> _especialidades = const <String>[];
  List<String> _jornadas = const <String>[];
  List<String> _estados = const <String>[];
  String? _especialidad;
  String? _jornada;
  String? _estado;

  @override
  void initState() {
    super.initState();
    _cargarCatalogosFormulario();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _documento.dispose();
    _otraEspecialidad.dispose();
    super.dispose();
  }

  // Seccion: carga de catalogos
  // Lee las opciones del formulario desde JSON antes de renderizar dropdowns.
  Future<void> _cargarCatalogosFormulario() async {
    final catalogos = await _catalogosService.obtenerCatalogosPersonalMedico();
    if (!mounted) {
      return;
    }

    setState(() {
      _especialidades = catalogos.especialidades;
      _jornadas = catalogos.jornadas;
      _estados = catalogos.estados;
      // Usa la primera opción como valor inicial para evitar dropdowns sin selección.
      _especialidad = catalogos.especialidades.first;
      _jornada = catalogos.jornadas.first;
      _estado = catalogos.estados.first;
      _cargandoCatalogos = false;
    });
  }

  // Seccion: estilos del formulario
  // Define decoracion uniforme para inputs y dropdowns.
  InputDecoration _decoracionCampo(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColores.baseFF6E7A78,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppColores.blanco,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColores.baseFFCAD9D0, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColores.baseFF2A6F4D,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColores.baseFFB53939,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColores.baseFFB53939,
          width: 1.7,
        ),
      ),
      errorStyle: const TextStyle(height: 0.01),
    );
  }

  // Seccion: validadores
  // Valida campos requeridos y formato basico de correo.
  String? _validarRequerido(String? v) =>
      (v == null || v.trim().isEmpty) ? '' : null;

  // Seccion: validador especialidad personalizada
  // Exige texto solo cuando el usuario selecciona la opcion "Otro".
  String? _validarOtraEspecialidad(String? v) {
    if (_especialidad != _opcionOtraEspecialidad) {
      return null;
    }
    return (v == null || v.trim().isEmpty) ? '' : null;
  }

  String get _correoPreview {
    // Vista previa solamente: la creación real puede pedir alias si este correo ya existe.
    return CorreoMedicoHelper.correoDesdeNombre(_nombre.text.trim());
  }

  // Seccion: accion guardar
  // Construye el input validado y lo entrega al callback.
  void _guardar() {
    if (!(_formKey.currentState?.validate() == true) ||
        _especialidad == null ||
        _jornada == null ||
        _estado == null) {
      setState(() {});
      return;
    }

    // "Otro" reemplaza el valor del catálogo por el texto ingresado manualmente.
    final especialidadFinal = _especialidad == _opcionOtraEspecialidad
        ? _otraEspecialidad.text.trim()
        : _especialidad!;

    widget.onGuardar(
      NuevoMedicoInput(
        nombreCompleto: _nombre.text.trim(),
        telefono: _telefono.text.trim(),
        documento: _documento.text.trim(),
        especialidad: especialidadFinal,
        jornada: _jornada!,
        estado: _estado!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height * 0.86;
    return Container(
      constraints: BoxConstraints(maxHeight: h),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColores.baseFFF2F7F4,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColores.baseFFC6D7CE, width: 1.2),
      ),
      child: Form(
        key: _formKey,
        child: _cargandoCatalogos
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2.3),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Registrar nuevo medico',
                            style: TextStyle(
                              color: AppColores.baseFF22362C,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        // Botón: cierra el formulario de nuevo médico.
                        IconButton(
                          onPressed: widget.onCerrar,
                          icon: const Icon(Icons.close),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const _EtiquetaTexto('Nombre completo'),
                    TextFormField(
                      controller: _nombre,
                      validator: _validarRequerido,
                      onChanged: (_) => setState(() {}),
                      decoration: _decoracionCampo('Nombre y apellidos'),
                    ),
                    const SizedBox(height: 10),
                    const _EtiquetaTexto('Correo institucional'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: AppColores.baseFFEAF3EE,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColores.baseFFCAD9D0,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _correoPreview,
                        style: const TextStyle(
                          color: AppColores.baseFF22362C,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 2),
                      child: Text(
                        'Se genera automaticamente. Si ya existe, se solicitara alias.',
                        style: TextStyle(
                          color: AppColores.baseFF5A6B63,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _EtiquetaTexto('Telefono'),
                    TextFormField(
                      controller: _telefono,
                      validator: _validarRequerido,
                      keyboardType: TextInputType.phone,
                      decoration: _decoracionCampo('Telefono de contacto'),
                    ),
                    const SizedBox(height: 10),
                    const _EtiquetaTexto('Documento'),
                    TextFormField(
                      controller: _documento,
                      validator: _validarRequerido,
                      decoration: _decoracionCampo('Numero'),
                    ),
                    const SizedBox(height: 10),
                    const _EtiquetaTexto('Especialidad'),
                    DropdownButtonFormField<String>(
                      initialValue: _especialidad,
                      validator: (v) => v == null ? '' : null,
                      decoration: _decoracionCampo('Seleccionar especialidad'),
                      items: _especialidades
                          .map(
                            (v) => DropdownMenuItem<String>(
                              value: v,
                              child: Text(v),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _especialidad = v;
                          if (_especialidad != _opcionOtraEspecialidad) {
                            _otraEspecialidad.clear();
                          }
                        });
                      },
                    ),
                    if (_especialidad == _opcionOtraEspecialidad) ...[
                      const SizedBox(height: 10),
                      const _EtiquetaTexto('Otra especialidad'),
                      TextFormField(
                        controller: _otraEspecialidad,
                        validator: _validarOtraEspecialidad,
                        decoration: _decoracionCampo('Escribe la especialidad'),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _EtiquetaTexto('Jornada'),
                              DropdownButtonFormField<String>(
                                initialValue: _jornada,
                                validator: (v) => v == null ? '' : null,
                                decoration: _decoracionCampo('Jornada'),
                                items: _jornadas
                                    .map(
                                      (v) => DropdownMenuItem<String>(
                                        value: v,
                                        child: Text(v),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() => _jornada = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _EtiquetaTexto('Estado'),
                              DropdownButtonFormField<String>(
                                initialValue: _estado,
                                validator: (v) => v == null ? '' : null,
                                decoration: _decoracionCampo('Estado'),
                                items: _estados
                                    .map(
                                      (v) => DropdownMenuItem<String>(
                                        value: v,
                                        child: Text(v),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() => _estado = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      // Botón: valida y guarda el nuevo médico.
                      child: ElevatedButton(
                        onPressed: _guardar,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColores.baseFF1E6246,
                          foregroundColor: AppColores.blanco,
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Guardar medico',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// Seccion: etiqueta de campo
// Texto auxiliar para titulos de cada campo en formulario.
class _EtiquetaTexto extends StatelessWidget {
  const _EtiquetaTexto(this.t);

  final String t;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 5),
      child: Text(
        t,
        style: const TextStyle(
          color: AppColores.baseFF4A5B58,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
