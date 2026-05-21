import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/domain/entities/mascota.dart';
import 'package:petcontrol_limpio/domain/entities/personal_medico.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/citas/detalle_cliente/detalle_cita_cliente_fields.dart';

class DetalleCitaClienteContent extends StatelessWidget {
  const DetalleCitaClienteContent({
    super.key,
    required this.formKey,
    required this.nombreMascotaController,
    required this.especieController,
    required this.fechaHoraController,
    required this.motivoController,
    required this.descripcionController,
    required this.modoEdicion,
    required this.guardando,
    required this.cancelandoCita,
    required this.cargandoMascotas,
    required this.cargandoMedicos,
    required this.cargandoMotivos,
    required this.mascotasDisponibles,
    required this.medicosDisponibles,
    required this.motivosDisponibles,
    required this.idMascotaSeleccionada,
    required this.idMedicoSeleccionado,
    required this.medicoSeleccionado,
    required this.onCerrar,
    required this.onActivarEdicion,
    required this.onCancelarCita,
    required this.onCancelarEdicion,
    required this.onGuardarCambios,
    required this.onSeleccionarFechaHora,
    required this.onMascotaChanged,
    required this.onMedicoChanged,
    required this.onMotivoChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nombreMascotaController;
  final TextEditingController especieController;
  final TextEditingController fechaHoraController;
  final TextEditingController motivoController;
  final TextEditingController descripcionController;
  final bool modoEdicion;
  final bool guardando;
  final bool cancelandoCita;
  final bool cargandoMascotas;
  final bool cargandoMedicos;
  final bool cargandoMotivos;
  final List<Mascota>? mascotasDisponibles;
  final List<PersonalMedico> medicosDisponibles;
  final List<String> motivosDisponibles;
  final String? idMascotaSeleccionada;
  final String idMedicoSeleccionado;
  final PersonalMedico? medicoSeleccionado;
  final VoidCallback onCerrar;
  final VoidCallback onActivarEdicion;
  final VoidCallback onCancelarCita;
  final VoidCallback onCancelarEdicion;
  final VoidCallback onGuardarCambios;
  final VoidCallback onSeleccionarFechaHora;
  final ValueChanged<String> onMascotaChanged;
  final ValueChanged<String> onMedicoChanged;
  final ValueChanged<String> onMotivoChanged;
  // Sección: construcción del popup
  // Mantiene ficha en modo lectura y habilita edición sólo con botón.
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
                // Sección: encabezado del popup
                // Muestra icono, título y botón de cierre.
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
                            nombreMascotaController.text.trim().isEmpty
                                ? 'Detalle de cita'
                                : nombreMascotaController.text.trim(),
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
                            'Ficha completa de la cita',
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
                    // Botón: cierra el popup de detalle sin hacer cambios.
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

                // Sección: campos de la cita
                // Los controles de ficha viven en un módulo dedicado.
                DetalleCitaClienteCampos(
                  modoEdicion: modoEdicion,
                  cargandoMascotas: cargandoMascotas,
                  cargandoMedicos: cargandoMedicos,
                  cargandoMotivos: cargandoMotivos,
                  mascotasDisponibles: mascotasDisponibles,
                  medicosDisponibles: medicosDisponibles,
                  motivosDisponibles: motivosDisponibles,
                  idMascotaSeleccionada: idMascotaSeleccionada,
                  idMedicoSeleccionado: idMedicoSeleccionado,
                  medicoSeleccionado: medicoSeleccionado,
                  nombreMascotaController: nombreMascotaController,
                  especieController: especieController,
                  fechaHoraController: fechaHoraController,
                  motivoController: motivoController,
                  descripcionController: descripcionController,
                  onSeleccionarFechaHora: onSeleccionarFechaHora,
                  onMascotaChanged: onMascotaChanged,
                  onMedicoChanged: onMedicoChanged,
                  onMotivoChanged: onMotivoChanged,
                ),
                const SizedBox(height: 12),
                // Sección: acciones inferiores
                // Muestra editar o cancelar/guardar según modo actual.
                if (!modoEdicion)
                  Row(
                    children: [
                      Expanded(
                        // Botón: cambia la ficha de cita a modo edición.
                        child: ElevatedButton(
                          onPressed: cancelandoCita ? null : onActivarEdicion,
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
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        // Botón: solicita cancelar la cita completa.
                        child: OutlinedButton(
                          onPressed: cancelandoCita ? null : onCancelarCita,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColores.baseFFB53939,
                            side: const BorderSide(
                              color: AppColores.baseFFB53939,
                            ),
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: cancelandoCita
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColores.baseFFB53939,
                                  ),
                                )
                              : const Text(
                                  'Cancelar cita',
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5,
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
                        // Botón: sale del modo edición y restaura los datos previos.
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
                        // Botón: guarda los cambios editados de la cita.
                        child: ElevatedButton(
                          onPressed: guardando ? null : onGuardarCambios,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColores.baseFF143B5F,
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
