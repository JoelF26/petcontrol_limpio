import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/domain/entities/mascota.dart';
import 'package:petcontrol_limpio/domain/entities/personal_medico.dart';

class DetalleCitaAdminContent extends StatelessWidget {
  const DetalleCitaAdminContent({
    super.key,
    required this.formKey,
    required this.fechaHoraController,
    required this.motivoController,
    required this.descripcionController,
    required this.bloqueAgenda,
    required this.mascotasDisponibles,
    required this.medicosPorId,
    required this.nombreMascotaVisible,
    required this.especieVisible,
    required this.duenoVisible,
    required this.medicoVisible,
    required this.estadosDisponibles,
    required this.idMascotaSeleccionada,
    required this.idMedicoSeleccionado,
    required this.estadoSeleccionado,
    required this.modoEdicion,
    required this.guardando,
    required this.confirmando,
    required this.cargandoCatalogos,
    required this.citaConfirmada,
    required this.validarRequerido,
    required this.onCerrar,
    required this.onSeleccionarFechaHora,
    required this.onActivarEdicion,
    required this.onConfirmarCita,
    required this.onCancelarEdicion,
    required this.onGuardarCambios,
    required this.onMascotaChanged,
    required this.onEstadoChanged,
    required this.onMedicoChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fechaHoraController;
  final TextEditingController motivoController;
  final TextEditingController descripcionController;
  final String bloqueAgenda;
  final List<Mascota> mascotasDisponibles;
  final Map<String, PersonalMedico> medicosPorId;
  final String nombreMascotaVisible;
  final String especieVisible;
  final String duenoVisible;
  final String medicoVisible;
  final List<String> estadosDisponibles;
  final String? idMascotaSeleccionada;
  final String idMedicoSeleccionado;
  final String? estadoSeleccionado;
  final bool modoEdicion;
  final bool guardando;
  final bool confirmando;
  final bool cargandoCatalogos;
  final bool citaConfirmada;
  final String? Function(String?) validarRequerido;
  final VoidCallback onCerrar;
  final VoidCallback onSeleccionarFechaHora;
  final VoidCallback onActivarEdicion;
  final VoidCallback onConfirmarCita;
  final VoidCallback onCancelarEdicion;
  final VoidCallback onGuardarCambios;
  final ValueChanged<String?> onMascotaChanged;
  final ValueChanged<String?> onEstadoChanged;
  final ValueChanged<String?> onMedicoChanged;
  // Seccion: contenedor base de campo
  // Reutiliza estilo del bloque para cada etiqueta y control.
  Widget _campoBase({required String etiqueta, required Widget child}) {
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
          child,
        ],
      ),
    );
  }

  // Seccion: build principal
  // Renderiza ficha completa y acciones de edicion/guardado.
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
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Seccion: encabezado
                // Muestra icono, titulo y boton de cierre.
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
                        Icons.calendar_month_rounded,
                        color: AppColores.baseFF2F7D68,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombreMascotaVisible,
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
                            'Detalle completo de la cita',
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
                    // Botón: cierra el popup de detalle admin.
                    IconButton(
                      onPressed: () => onCerrar(),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColores.baseFFCFE5DD,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        estadoSeleccionado ?? 'proxima',
                        style: const TextStyle(
                          color: AppColores.baseFF2D8A6C,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColores.baseFFCFE5DD,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        bloqueAgenda,
                        style: const TextStyle(
                          color: AppColores.baseFF2D8A6C,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Seccion: campos de ficha
                // Cambian a controles editables cuando el usuario activa edicion.
                _campoBase(
                  etiqueta: 'Mascota',
                  child: !modoEdicion
                      ? Text(
                          nombreMascotaVisible,
                          style: const TextStyle(
                            color: AppColores.baseFF1F2A35,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          initialValue: idMascotaSeleccionada,
                          validator: (value) => value == null ? '' : null,
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: false,
                            fillColor: AppColores.transparente,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            errorStyle: TextStyle(height: 0.01, fontSize: 0),
                            contentPadding: EdgeInsets.zero,
                          ),
                          items: mascotasDisponibles
                              .map(
                                (mascota) => DropdownMenuItem<String>(
                                  value: mascota.idMascota,
                                  child: Text(mascota.nombreVisible),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            onMascotaChanged(value);
                          },
                        ),
                ),
                const SizedBox(height: 10),
                _campoBase(
                  etiqueta: 'Especie',
                  child: Text(
                    especieVisible,
                    style: const TextStyle(
                      color: AppColores.baseFF1F2A35,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _campoBase(
                  etiqueta: 'Dueno',
                  child: Text(
                    duenoVisible,
                    style: const TextStyle(
                      color: AppColores.baseFF1F2A35,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _campoBase(
                  etiqueta: 'Fecha y hora',
                  child: !modoEdicion
                      ? Text(
                          fechaHoraController.text.trim(),
                          style: const TextStyle(
                            color: AppColores.baseFF1F2A35,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : InkWell(
                          // Botón/campo: abre el selector de fecha y hora.
                          onTap: onSeleccionarFechaHora,
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  fechaHoraController.text.trim().isEmpty
                                      ? 'Seleccionar fecha y hora'
                                      : fechaHoraController.text.trim(),
                                  style: const TextStyle(
                                    color: AppColores.baseFF1F2A35,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: AppColores.baseFF34434A,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                _campoBase(
                  etiqueta: 'Estado',
                  child: !modoEdicion
                      ? Text(
                          estadoSeleccionado ?? 'proxima',
                          style: const TextStyle(
                            color: AppColores.baseFF1F2A35,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          initialValue: estadoSeleccionado,
                          validator: (value) => value == null ? '' : null,
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: false,
                            fillColor: AppColores.transparente,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            errorStyle: TextStyle(height: 0.01, fontSize: 0),
                            contentPadding: EdgeInsets.zero,
                          ),
                          items: estadosDisponibles
                              .map(
                                (estado) => DropdownMenuItem<String>(
                                  value: estado,
                                  child: Text(estado),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            onEstadoChanged(value);
                          },
                        ),
                ),
                const SizedBox(height: 10),
                _campoBase(
                  etiqueta: 'Motivo',
                  child: TextFormField(
                    controller: motivoController,
                    validator: validarRequerido,
                    readOnly: !modoEdicion,
                    maxLines: 1,
                    style: const TextStyle(
                      color: AppColores.baseFF1F2A35,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      filled: false,
                      fillColor: AppColores.transparente,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      errorStyle: TextStyle(height: 0.01, fontSize: 0),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _campoBase(
                  etiqueta: 'Descripcion',
                  child: TextFormField(
                    controller: descripcionController,
                    readOnly: !modoEdicion,
                    maxLines: 2,
                    style: const TextStyle(
                      color: AppColores.baseFF1F2A35,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      filled: false,
                      fillColor: AppColores.transparente,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      errorStyle: TextStyle(height: 0.01, fontSize: 0),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _campoBase(
                  etiqueta: 'Doctor',
                  child: !modoEdicion
                      ? Text(
                          medicoVisible,
                          style: const TextStyle(
                            color: AppColores.baseFF1F2A35,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          initialValue: idMedicoSeleccionado,
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: false,
                            fillColor: AppColores.transparente,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            errorStyle: TextStyle(height: 0.01, fontSize: 0),
                            contentPadding: EdgeInsets.zero,
                          ),
                          items: <DropdownMenuItem<String>>[
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('Sin medico'),
                            ),
                            ...medicosPorId.values.map(
                              (medico) => DropdownMenuItem<String>(
                                value: medico.idMedico,
                                child: Text(medico.nombreCompleto),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            onMedicoChanged(value);
                          },
                        ),
                ),
                const SizedBox(height: 12),

                // Seccion: acciones inferiores
                // Muestra boton de editar o acciones de cancelar/guardar.
                if (!modoEdicion)
                  Row(
                    children: [
                      Expanded(
                        // Botón: habilita la edición de la cita desde admin.
                        child: ElevatedButton(
                          onPressed: cargandoCatalogos || confirmando
                              ? null
                              : onActivarEdicion,
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
                      const SizedBox(width: 10),
                      Expanded(
                        // Botón: confirma la cita desde el detalle admin.
                        child: ElevatedButton(
                          onPressed:
                              cargandoCatalogos || confirmando || citaConfirmada
                              ? null
                              : onConfirmarCita,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColores.baseFF2D8A6C,
                            foregroundColor: AppColores.blanco,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: confirmando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColores.blanco,
                                  ),
                                )
                              : const Text(
                                  'Confirmar cita',
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
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        // Botón: cancela la edición admin y restaura valores.
                        child: OutlinedButton(
                          onPressed: guardando ? null : onCancelarEdicion,
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
                        // Botón: guarda los cambios de la cita desde admin.
                        child: ElevatedButton(
                          onPressed: guardando ? null : onGuardarCambios,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColores.baseFF1E6246,
                            foregroundColor: AppColores.blanco,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: guardando
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
}
