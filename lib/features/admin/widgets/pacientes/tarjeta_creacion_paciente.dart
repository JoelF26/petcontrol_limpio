// Seccion: imports
// Se importa Material para construir formulario y controles de seleccion.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/core/di/app_dependencies.dart';
import 'package:petcontrol_limpio/application/services/catalogos_json_service.dart';

// Seccion: modelo de usuario para formulario
// Define los usuarios disponibles en el selector obligatorio del popup.
class UsuarioRegistroPaciente {
  const UsuarioRegistroPaciente({
    required this.idUsuario,
    required this.nombreCompleto,
  });

  final String idUsuario;
  final String nombreCompleto;
}

// Seccion: payload del formulario
// Expone todos los valores necesarios para registrar la mascota desde Admin.
class PacienteCreacionData {
  const PacienteCreacionData({
    required this.idUsuario,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.edad,
    required this.peso,
    required this.sexo,
  });

  final String idUsuario;
  final String nombre;
  final String especie;
  final String raza;
  final String edad;
  final String peso;
  final String sexo;
}

// Seccion: tarjeta de registro
// Popup de alta de pacientes para Admin con seleccion de usuario obligatoria.
class TarjetaCreacionPaciente extends StatefulWidget {
  const TarjetaCreacionPaciente({
    super.key,
    this.onCerrar,
    this.onRegistrar,
    this.usuariosRegistrados = const <UsuarioRegistroPaciente>[],
  });

  final VoidCallback? onCerrar;
  final ValueChanged<PacienteCreacionData>? onRegistrar;
  final List<UsuarioRegistroPaciente> usuariosRegistrados;

  @override
  State<TarjetaCreacionPaciente> createState() =>
      _TarjetaCreacionPacienteState();
}

class _TarjetaCreacionPacienteState extends State<TarjetaCreacionPaciente> {
  // Seccion: estado y controladores
  // Mantienen los valores del formulario y validaciones locales.
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _especieController = TextEditingController();
  final _razaController = TextEditingController();
  final _edadController = TextEditingController();
  final _pesoController = TextEditingController();
  final CatalogosJsonService _catalogosService =
      AppDependencies.catalogosJsonService;

  bool _cargandoCatalogos = true;
  List<String> _opcionesSexo = const <String>[];
  String? _usuarioSeleccionadoId;
  String? _sexoSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
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

  // Seccion: carga de catalogos
  // Lee las opciones de sexo desde el JSON de assets.
  Future<void> _cargarCatalogos() async {
    final opcionesSexo = await _catalogosService.obtenerOpcionesMascotaSexo();
    if (!mounted) {
      return;
    }

    setState(() {
      _opcionesSexo = opcionesSexo;
      _cargandoCatalogos = false;
    });
  }

  // Seccion: decoracion base de campo
  // Uniforma bordes, relleno y tipografia de todos los inputs y dropdowns.
  InputDecoration _decoracionCampo({
    required String hintText,
    Color colorBorde = AppColores.baseFFCDD4D1,
    Color colorFondo = AppColores.baseFFE8EBEA,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColores.baseFF6E7A78,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: colorFondo,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorBorde, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorBorde, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColores.baseFFB53939,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColores.baseFFB53939,
          width: 1.8,
        ),
      ),
      errorStyle: const TextStyle(height: 0.01),
    );
  }

  // Seccion: validacion comun
  // Marca como requerido cualquier campo de texto vacio.
  String? _validadorRequerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }
    return null;
  }

  // Seccion: accion registrar
  // Valida formulario y emite payload con idUsuario obligatorio.
  void _registrar() {
    final esValido =
        _formKey.currentState?.validate() == true &&
        _usuarioSeleccionadoId != null &&
        _sexoSeleccionado != null;
    if (!esValido) {
      setState(() {});
      return;
    }

    widget.onRegistrar?.call(
      PacienteCreacionData(
        idUsuario: _usuarioSeleccionadoId!,
        nombre: _nombreController.text.trim(),
        especie: _especieController.text.trim(),
        raza: _razaController.text.trim(),
        edad: _edadController.text.trim(),
        peso: _pesoController.text.trim(),
        sexo: _sexoSeleccionado!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColores.baseFFDCDDDB,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColores.baseFF1A95F7, width: 2),
      ),
      child: _cargandoCatalogos
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.3)),
            )
          : Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Registrar Paciente',
                          style: TextStyle(
                            color: AppColores.baseFF223633,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onCerrar,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Icon(
                            Icons.close,
                            color: AppColores.baseFF5E6A68,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const _EtiquetaCampo('Usuario registrado'),
                  DropdownButtonFormField<String>(
                    initialValue: _usuarioSeleccionadoId,
                    validator: (value) => value == null ? '' : null,
                    decoration: _decoracionCampo(
                      hintText: 'Seleccionar usuario',
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    borderRadius: BorderRadius.circular(12),
                    items: widget.usuariosRegistrados
                        .map(
                          (usuario) => DropdownMenuItem<String>(
                            value: usuario.idUsuario,
                            child: Text(usuario.nombreCompleto),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      setState(() {
                        _usuarioSeleccionadoId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  const _EtiquetaCampo('Nombre'),
                  TextFormField(
                    controller: _nombreController,
                    validator: _validadorRequerido,
                    decoration: _decoracionCampo(
                      hintText: 'Nombre de la mascota',
                      colorBorde: AppColores.baseFF5ABF9A,
                      colorFondo: AppColores.baseFFE5E8E7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _EtiquetaCampo('Especie'),
                  TextFormField(
                    controller: _especieController,
                    validator: _validadorRequerido,
                    decoration: _decoracionCampo(hintText: 'Ej: Perro'),
                  ),
                  const SizedBox(height: 10),
                  const _EtiquetaCampo('Sexo'),
                  DropdownButtonFormField<String>(
                    initialValue: _sexoSeleccionado,
                    validator: (value) => value == null ? '' : null,
                    decoration: _decoracionCampo(hintText: 'Seleccionar sexo'),
                    hint: const Text(
                      'Seleccionar sexo',
                      style: TextStyle(
                        color: AppColores.baseFF6E7A78,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    borderRadius: BorderRadius.circular(12),
                    items: _opcionesSexo
                        .map(
                          (sexo) => DropdownMenuItem<String>(
                            value: sexo,
                            child: Text(sexo),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      setState(() {
                        _sexoSeleccionado = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  const _EtiquetaCampo('Raza'),
                  TextFormField(
                    controller: _razaController,
                    validator: _validadorRequerido,
                    decoration: _decoracionCampo(hintText: 'Raza'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _EtiquetaCampo('Edad'),
                            TextFormField(
                              controller: _edadController,
                              validator: _validadorRequerido,
                              decoration: _decoracionCampo(
                                hintText: 'Ej: 3 anos',
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
                            const _EtiquetaCampo('Peso'),
                            TextFormField(
                              controller: _pesoController,
                              validator: _validadorRequerido,
                              decoration: _decoracionCampo(
                                hintText: 'Ej: 12 kg',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _registrar,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColores.baseFF0E8D63,
                        foregroundColor: AppColores.blanco,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Registrar Paciente',
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
    );
  }
}

// Seccion: etiqueta reutilizable
// Estilo unico para titulos de campos dentro del formulario.
class _EtiquetaCampo extends StatelessWidget {
  const _EtiquetaCampo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        texto,
        style: const TextStyle(
          color: AppColores.baseFF2D3D3B,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
