import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/citas/creacion/medico_cita_item.dart';
import 'package:petcontrol_limpio/models/mascota.dart';

class FormularioCreacionCitaContent extends StatelessWidget {
  const FormularioCreacionCitaContent({
    super.key,
    required this.cargandoDatos,
    required this.guardando,
    required this.formKey,
    required this.fechaHoraController,
    required this.descripcionController,
    required this.mascotasDisponibles,
    required this.medicosDisponibles,
    required this.motivosDisponibles,
    required this.idMascotaSeleccionada,
    required this.motivoSeleccionado,
    required this.idMedicoSeleccionado,
    required this.fechaHoraSeleccionada,
    required this.onCerrar,
    required this.onSeleccionarFechaHora,
    required this.onRegistrarCita,
    required this.onMascotaChanged,
    required this.onMotivoChanged,
    required this.onMedicoChanged,
  });

  final bool cargandoDatos;
  final bool guardando;
  final GlobalKey<FormState> formKey;
  final TextEditingController fechaHoraController;
  final TextEditingController descripcionController;
  final List<Mascota> mascotasDisponibles;
  final List<MedicoCitaItem> medicosDisponibles;
  final List<String> motivosDisponibles;
  final String? idMascotaSeleccionada;
  final String? motivoSeleccionado;
  final String? idMedicoSeleccionado;
  final DateTime? fechaHoraSeleccionada;
  final VoidCallback onCerrar;
  final VoidCallback onSeleccionarFechaHora;
  final VoidCallback onRegistrarCita;
  final ValueChanged<String?> onMascotaChanged;
  final ValueChanged<String?> onMotivoChanged;
  final ValueChanged<String?> onMedicoChanged;

  @override
  Widget build(BuildContext context) {
    final alturaMaxima = MediaQuery.of(context).size.height * 0.82;

    return Material(
      color: AppColores.transparente,
      child: Container(
        constraints: BoxConstraints(maxHeight: alturaMaxima),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: AppColores.baseFFDCDDDB,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColores.baseFF1A95F7, width: 2),
        ),
        child: cargandoDatos
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              )
            : Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Registrar Cita',
                              style: TextStyle(
                                color: AppColores.baseFF223633,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                          // Botón: cierra el formulario de creación de cita.
                          GestureDetector(
                            onTap: onCerrar,
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
                      const SizedBox(height: 10),
                      const EtiquetaCampo('Mascota registrada'),
                      DropdownButtonFormField<String>(
                        initialValue: idMascotaSeleccionada,
                        validator: (value) => value == null ? '' : null,
                        isExpanded: true,
                        menuMaxHeight: 260,
                        decoration: _decoracionCampo('Seleccionar mascota'),
                        items: mascotasDisponibles
                            .map(
                              (mascota) => DropdownMenuItem<String>(
                                value: mascota.idMascota,
                                child: Text(
                                  '${mascota.nombreVisible} (${mascota.especieVisible})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: mascotasDisponibles.isEmpty
                            ? null
                            : onMascotaChanged,
                      ),
                      const SizedBox(height: 4),
                      const Padding(
                        padding: EdgeInsets.only(left: 2),
                        child: Text(
                          'Se muestran las mascotas asociadas a tu cuenta.',
                          style: TextStyle(
                            color: AppColores.baseFF6A7674,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const EtiquetaCampo('Fecha y hora de la cita'),
                      TextFormField(
                        controller: fechaHoraController,
                        readOnly: true,
                        validator: _validadorRequerido,
                        decoration: _decoracionCampo('Seleccionar fecha y hora')
                            .copyWith(
                              // Botón: abre el selector de fecha y hora.
                              suffixIcon: IconButton(
                                onPressed: onSeleccionarFechaHora,
                                icon: const Icon(
                                  Icons.event_available_outlined,
                                  size: 20,
                                ),
                              ),
                            ),
                        onTap: onSeleccionarFechaHora,
                      ),
                      const SizedBox(height: 10),
                      const EtiquetaCampo('Motivo de la cita'),
                      DropdownButtonFormField<String>(
                        initialValue: motivoSeleccionado,
                        validator: (value) => value == null ? '' : null,
                        isExpanded: true,
                        menuMaxHeight: 300,
                        decoration: _decoracionCampo('Seleccionar motivo'),
                        items: motivosDisponibles
                            .map(
                              (motivo) => DropdownMenuItem<String>(
                                value: motivo,
                                child: Text(
                                  motivo,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: onMotivoChanged,
                      ),
                      const SizedBox(height: 10),
                      const EtiquetaCampo('Médico asignado (opcional)'),
                      DropdownButtonFormField<String?>(
                        initialValue: idMedicoSeleccionado,
                        isExpanded: true,
                        menuMaxHeight: 260,
                        decoration: _decoracionCampo('Seleccionar médico'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Sin preferencia'),
                          ),
                          ...medicosDisponibles.map(
                            (medico) => DropdownMenuItem<String?>(
                              value: medico.id,
                              child: Text(
                                medico.nombreVisible,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: onMedicoChanged,
                      ),
                      if (fechaHoraSeleccionada != null &&
                          medicosDisponibles.isEmpty) ...[
                        const SizedBox(height: 4),
                        const Padding(
                          padding: EdgeInsets.only(left: 2),
                          child: Text(
                            'No hay médicos disponibles en esa hora. Puedes elegir otra hora o dejar sin preferencia.',
                            style: TextStyle(
                              color: AppColores.baseFF7F3A3A,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      const EtiquetaCampo('Descripción de la cita'),
                      TextFormField(
                        controller: descripcionController,
                        maxLines: 6,
                        minLines: 4,
                        textInputAction: TextInputAction.newline,
                        decoration: _decoracionCampo(
                          'Describe con detalle lo que se evaluará o realizará.',
                        ).copyWith(alignLabelWithHint: true),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        // Botón: confirma y registra la nueva cita.
                        child: ElevatedButton(
                          onPressed: guardando ? null : onRegistrarCita,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColores.secundarioOscuro,
                            foregroundColor: AppColores.blanco,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: guardando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.1,
                                    color: AppColores.blanco,
                                  ),
                                )
                              : const Text(
                                  'Crear Cita',
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
      ),
    );
  }

  InputDecoration _decoracionCampo(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColores.baseFF6E7A78,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppColores.baseFFE8EBEA,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColores.baseFFCDD4D1,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColores.baseFF5ABF9A,
          width: 1.7,
        ),
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
          width: 1.7,
        ),
      ),
      errorStyle: const TextStyle(height: 0.01),
    );
  }

  String? _validadorRequerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }
    return null;
  }
}

class EtiquetaCampo extends StatelessWidget {
  const EtiquetaCampo(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 5),
      child: Text(
        texto,
        style: const TextStyle(
          color: AppColores.baseFF4A5B58,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
