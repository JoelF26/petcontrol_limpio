// Seccion: imports
// Se importan recursos visuales y modelos de la vista de personal medico.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/admin/models/personal_medico_view_data.dart';
import 'package:petcontrol_limpio/features/admin/widgets/admin_base_widgets.dart';

// Seccion: fondo de pantalla
// Renderiza el gradiente superior y base clara de la vista.
class PersonalMedicoFondo extends StatelessWidget {
  const PersonalMedicoFondo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 280,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1B664A),
                      AppColores.verdepacientes,
                      Color(0xFF6EBC89),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(38),
                    bottomRight: Radius.circular(38),
                  ),
                ),
              ),
              const Positioned(
                top: -34,
                right: -24,
                child: _CirculoDecorativoPersonal(diametro: 126, opacidad: 0.2),
              ),
              const Positioned(
                bottom: 18,
                left: -24,
                child: _CirculoDecorativoPersonal(diametro: 96, opacidad: 0.14),
              ),
            ],
          ),
        ),
        const Expanded(child: ColoredBox(color: Color(0xFFF1F5F2))),
      ],
    );
  }
}

// Seccion: circulo decorativo
// Soporte visual para acentos del fondo.
class _CirculoDecorativoPersonal extends StatelessWidget {
  const _CirculoDecorativoPersonal({
    required this.diametro,
    required this.opacidad,
  });

  final double diametro;
  final double opacidad;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diametro,
      height: diametro,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacidad),
        shape: BoxShape.circle,
      ),
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
                color: const Color(0x2FFFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x55FFFFFF)),
              ),
              child: Text(
                '$totalResultados resultados',
                style: const TextStyle(
                  color: Colors.white,
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
            color: Colors.white,
            fontSize: 33,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Gestiona especialistas, jornadas y disponibilidad del equipo clinico.',
          style: TextStyle(
            color: Color(0xFFE8F8EE),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0x22FFFFFF),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0x55FFFFFF)),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
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
          hintStyle: const TextStyle(color: Color(0xFF627269), fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: Color(0xFF5F7066),
          ),
          suffixIcon: const Icon(
            Icons.local_hospital_outlined,
            size: 20,
            color: Color(0xFF5F7066),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFCAD9D0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2A6F4D), width: 1.3),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x2FFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x54FFFFFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: Colors.white, size: 18),
            const SizedBox(height: 8),
            Text(
              valor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: const TextStyle(
                color: Color(0xDBF4FFF7),
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
      color: Colors.transparent,
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
                colors: [Color(0xFFFFFFFF), Color(0xFFF0F7F3)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFC7D8CE), width: 1),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFD7E5DE),
                      child: Text(
                        iniciales,
                        style: const TextStyle(
                          color: Color(0xFF1D4E3E),
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
                              color: Color(0xFF1F3028),
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              PersonalMedicoChip(
                                color: const Color(0xFFDAEFE4),
                                textColor: const Color(0xFF2F7452),
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
                      color: Color(0xFF6A7D72),
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
        color: const Color(0xFFE6F1EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: const Color(0xFF3A7157)),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 195),
            child: Text(
              valor,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF416955),
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
  final _correo = TextEditingController();
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
    _correo.dispose();
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
        color: Color(0xFF6E7A78),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCAD9D0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2A6F4D), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB53939), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB53939), width: 1.7),
      ),
      errorStyle: const TextStyle(height: 0.01),
    );
  }

  // Seccion: validadores
  // Valida campos requeridos y formato basico de correo.
  String? _validarRequerido(String? v) =>
      (v == null || v.trim().isEmpty) ? '' : null;

  String? _validarCorreo(String? v) {
    final correo = v?.trim() ?? '';
    if (correo.isEmpty) return '';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(correo) ? null : '';
  }

  // Seccion: validador especialidad personalizada
  // Exige texto solo cuando el usuario selecciona la opcion "Otro".
  String? _validarOtraEspecialidad(String? v) {
    if (_especialidad != _opcionOtraEspecialidad) {
      return null;
    }
    return (v == null || v.trim().isEmpty) ? '' : null;
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
        correo: _correo.text.trim(),
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
        color: const Color(0xFFF2F7F4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFC6D7CE), width: 1.2),
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
                        color: Color(0xFF22362C),
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
                decoration: _decoracionCampo('Nombre y apellidos'),
              ),
              const SizedBox(height: 10),
              const _EtiquetaTexto('Correo'),
              TextFormField(
                controller: _correo,
                validator: _validarCorreo,
                keyboardType: TextInputType.emailAddress,
                decoration: _decoracionCampo('correo@dominio.com'),
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
                    backgroundColor: const Color(0xFF1E6246),
                    foregroundColor: Colors.white,
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
          color: Color(0xFF4A5B58),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
