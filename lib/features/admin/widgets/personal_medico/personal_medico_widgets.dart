// Seccion: imports
// Se importan recursos visuales y modelos de la vista de personal medico.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/admin/models/personal_medico_view_data.dart';
import 'package:petcontrol_limpio/features/admin/utils/correo_medico_helper.dart';
import 'package:petcontrol_limpio/features/admin/widgets/shared/admin_base_widgets.dart';

// Seccion: fondo de pantalla
// Renderiza el gradiente superior y base clara de la vista.
class PersonalMedicoFondo extends StatelessWidget {
  const PersonalMedicoFondo({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminFondoDecorativo(
      colores: [
        AppColores.baseFF1B664A,
        AppColores.verdepacientes,
        AppColores.baseFF6EBC89,
      ],
    );
  }
}

// Seccion: encabezado principal
// Muestra volver, contador y textos de contexto.
class PersonalMedicoEncabezado extends StatelessWidget {
  const PersonalMedicoEncabezado({
    super.key,
    required this.onVolver,
    required this.totalResultados,
  });

  final VoidCallback onVolver;
  final int totalResultados;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _BotonEncabezadoIcono(onTap: onVolver),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColores.base2FFFFFFF,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColores.base55FFFFFF),
              ),
              child: Text(
                '$totalResultados resultados',
                style: const TextStyle(
                  color: AppColores.blanco,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Personal medico',
          style: TextStyle(
            color: AppColores.blanco,
            fontSize: 33,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Gestiona especialistas, jornadas y disponibilidad del equipo clinico.',
          style: TextStyle(
            color: AppColores.baseFFE8F8EE,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Seccion: boton de encabezado
// Boton reutilizable para accion de volver.
class _BotonEncabezadoIcono extends StatelessWidget {
  const _BotonEncabezadoIcono({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AdminBotonEncabezadoIcono(onTap: onTap);
  }
}

// Seccion: buscador
// Campo de texto para filtrar personal medico en tiempo real.
class PersonalMedicoBuscador extends StatelessWidget {
  const PersonalMedicoBuscador({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: AppColores.negro,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, especialidad o correo...',
          hintStyle: const TextStyle(
            color: AppColores.baseFF627269,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColores.baseFF5F7066,
          ),
          suffixIcon: const Icon(
            Icons.local_hospital_outlined,
            size: 20,
            color: AppColores.baseFF5F7066,
          ),
          filled: true,
          fillColor: AppColores.blanco,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColores.baseFFCAD9D0,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColores.baseFF2A6F4D,
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

// Seccion: caja de resumen
// Tarjeta compacta para mostrar metricas rapidas.
class PersonalMedicoResumenBox extends StatelessWidget {
  const PersonalMedicoResumenBox({
    super.key,
    required this.valor,
    required this.etiqueta,
    required this.icono,
  });

  final String valor;
  final String etiqueta;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return AdminTarjetaResumenCompacta(
      valor: valor,
      etiqueta: etiqueta,
      icono: icono,
    );
  }
}

// Seccion: tarjeta de medico
// Renderiza un item del listado principal de personal.
class PersonalMedicoTarjeta extends StatelessWidget {
  const PersonalMedicoTarjeta({
    super.key,
    required this.medico,
    required this.iniciales,
    required this.colorBg,
    required this.colorText,
    required this.onTap,
  });

  final MedicoVista medico;
  final String iniciales;
  final Color colorBg;
  final Color colorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColores.transparente,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 122),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColores.blanco, AppColores.baseFFF0F7F3],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColores.baseFFC7D8CE, width: 1),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColores.baseFFD7E5DE,
                      child: Text(
                        iniciales,
                        style: const TextStyle(
                          color: AppColores.baseFF1D4E3E,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medico.nombreCompleto,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColores.baseFF1F3028,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              PersonalMedicoChip(
                                color: AppColores.baseFFDAEFE4,
                                textColor: AppColores.baseFF2F7452,
                                texto: medico.especialidad,
                              ),
                              PersonalMedicoChip(
                                color: colorBg,
                                textColor: colorText,
                                texto: medico.estado,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColores.baseFF6A7D72,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PersonalMedicoChipInfo(
                      icono: Icons.mail_outline_rounded,
                      valor: medico.correo,
                    ),
                    PersonalMedicoChipInfo(
                      icono: Icons.phone_outlined,
                      valor: medico.telefono,
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
}

// Seccion: chip de estado/especialidad
// Etiqueta compacta para mostrar informacion del medico.
class PersonalMedicoChip extends StatelessWidget {
  const PersonalMedicoChip({
    super.key,
    required this.color,
    required this.textColor,
    required this.texto,
  });

  final Color color;
  final Color textColor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: textColor,
          height: 1,
        ),
      ),
    );
  }
}

// Seccion: chip de contacto
// Muestra informacion de correo o telefono.
class PersonalMedicoChipInfo extends StatelessWidget {
  const PersonalMedicoChipInfo({
    super.key,
    required this.icono,
    required this.valor,
  });

  final IconData icono;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColores.baseFFE6F1EB,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: AppColores.baseFF3A7157),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 195),
            child: Text(
              valor,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColores.baseFF416955,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Seccion: estado vacio
// Mensaje mostrado cuando no hay personal para renderizar.
class PersonalMedicoVacio extends StatelessWidget {
  const PersonalMedicoVacio({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminEstadoVacioBase(
      mensaje: 'No hay personal medico registrado.',
      icono: Icons.medical_services_outlined,
    );
  }
}

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

  // Seccion: estado local del formulario
  // Controla valores seleccionados y visibilidad de campos condicionales.
  static const String _opcionOtraEspecialidad = 'Otro';

  String? _especialidad;
  String? _jornada;
  String? _estado;

  @override
  void initState() {
    super.initState();
    _especialidad = especialidadesMedicas.first;
    _jornada = jornadasMedicas.first;
    _estado = estadosMedico.first;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _documento.dispose();
    _otraEspecialidad.dispose();
    super.dispose();
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
        child: SingleChildScrollView(
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
                items: especialidadesMedicas
                    .map(
                      (v) => DropdownMenuItem<String>(value: v, child: Text(v)),
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
                          items: jornadasMedicas
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
                          items: estadosMedico
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
