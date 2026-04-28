import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/models/mascota.dart';
import 'package:petcontrol_limpio/models/personal_medico.dart';

class DetalleCitaClienteCampos extends StatelessWidget {
  const DetalleCitaClienteCampos({
    super.key,
    required this.modoEdicion,
    required this.cargandoMascotas,
    required this.cargandoMedicos,
    required this.cargandoMotivos,
    required this.mascotasDisponibles,
    required this.medicosDisponibles,
    required this.motivosDisponibles,
    required this.idMascotaSeleccionada,
    required this.idMedicoSeleccionado,
    required this.medicoSeleccionado,
    required this.nombreMascotaController,
    required this.especieController,
    required this.fechaHoraController,
    required this.motivoController,
    required this.descripcionController,
    required this.onSeleccionarFechaHora,
    required this.onMascotaChanged,
    required this.onMedicoChanged,
    required this.onMotivoChanged,
  });

  final bool modoEdicion;
  final bool cargandoMascotas;
  final bool cargandoMedicos;
  final bool cargandoMotivos;
  final List<Mascota>? mascotasDisponibles;
  final List<PersonalMedico> medicosDisponibles;
  final List<String> motivosDisponibles;
  final String? idMascotaSeleccionada;
  final String idMedicoSeleccionado;
  final PersonalMedico? medicoSeleccionado;
  final TextEditingController nombreMascotaController;
  final TextEditingController especieController;
  final TextEditingController fechaHoraController;
  final TextEditingController motivoController;
  final TextEditingController descripcionController;
  final VoidCallback onSeleccionarFechaHora;
  final ValueChanged<String> onMascotaChanged;
  final ValueChanged<String> onMedicoChanged;
  final ValueChanged<String> onMotivoChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _campoMascotaSeleccion(),
        const SizedBox(height: 10),
        _campoEspecieSoloLectura(),
        const SizedBox(height: 10),
        _campoFechaHora(),
        const SizedBox(height: 10),
        _campoMedicoSoloLectura(),
        const SizedBox(height: 10),
        _campoMotivo(),
        const SizedBox(height: 10),
        _campoFicha(
          etiqueta: 'Descripción',
          controller: descripcionController,
          habilitado: modoEdicion,
          minLines: 2,
          maxLines: 3,
        ),
      ],
    );
  }

  // Sección: campo visual reutilizable
  // Mantiene bloque de ficha y alterna entre texto o input según modo edición.
  Widget _campoMascotaSeleccion() {
    final mascotas = mascotasDisponibles ?? const <Mascota>[];
    final existeSeleccion = mascotas.any(
      (mascota) => mascota.idMascota == idMascotaSeleccionada,
    );
    final valorSeleccionado = existeSeleccion ? idMascotaSeleccionada : null;

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
          const Text(
            'Mascota',
            style: TextStyle(
              color: AppColores.baseFF7A8088,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          if (!modoEdicion)
            Text(
              nombreMascotaController.text.trim().isEmpty
                  ? '-'
                  : nombreMascotaController.text.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColores.baseFF1F2A35,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            )
          else if (cargandoMascotas)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: valorSeleccionado,
              isExpanded: true,
              icon: const Icon(
                Icons.expand_more_rounded,
                color: AppColores.baseFF5F6772,
                size: 20,
              ),
              dropdownColor: AppColores.baseFFE9EAEB,
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
                fillColor: AppColores.transparente,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
              hint: const Text(
                'Seleccionar mascota',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColores.baseFF6B737E,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
              items: mascotas
                  .map(
                    (mascota) => DropdownMenuItem<String>(
                      value: mascota.idMascota,
                      child: Text(
                        mascota.nombreVisible,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (idSeleccionado) {
                if (idSeleccionado == null) {
                  return;
                }
                onMascotaChanged(idSeleccionado);
              },
            ),
        ],
      ),
    );
  }

  // Sección: campo de especie solo lectura
  // La especie se deriva de la mascota seleccionada y no se edita manualmente.
  Widget _campoEspecieSoloLectura() {
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
          const Text(
            'Especie',
            style: TextStyle(
              color: AppColores.baseFF7A8088,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            especieController.text.trim().isEmpty
                ? '-'
                : especieController.text.trim(),
            maxLines: 1,
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

  // Sección: campo de médico seleccionado
  // Permite cambiar el doctor en edición usando médicos con usuario admin.
  Widget _campoMedicoSoloLectura() {
    final texto = cargandoMedicos
        ? 'Cargando médico...'
        : idMedicoSeleccionado.isEmpty
        ? 'Sin preferencia'
        : medicoSeleccionado?.nombreVisible ?? 'Médico no disponible';
    final existeSeleccion = medicosDisponibles.any(
      (medico) => medico.idMedico == idMedicoSeleccionado,
    );

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
          const Text(
            'Doctor',
            style: TextStyle(
              color: AppColores.baseFF7A8088,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          if (!modoEdicion)
            Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColores.baseFF1F2A35,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            )
          else if (cargandoMedicos)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: existeSeleccion ? idMedicoSeleccionado : '',
              isExpanded: true,
              icon: const Icon(
                Icons.expand_more_rounded,
                color: AppColores.baseFF5F6772,
                size: 20,
              ),
              dropdownColor: AppColores.baseFFE9EAEB,
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
                fillColor: AppColores.transparente,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                errorStyle: TextStyle(height: 0.01, fontSize: 0),
              ),
              items: <DropdownMenuItem<String>>[
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text(
                    'Sin preferencia',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ...medicosDisponibles.map(
                  (medico) => DropdownMenuItem<String>(
                    value: medico.idMedico,
                    child: Text(
                      medico.nombreVisible,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (idMedico) {
                onMedicoChanged((idMedico ?? '').trim());
              },
            ),
        ],
      ),
    );
  }

  // Sección: campo motivo
  // En edición muestra la lista de motivos cargada desde JSON.
  Widget _campoMotivo() {
    final motivoActual = motivoController.text.trim();
    final motivos = <String>[
      ...motivosDisponibles,
      if (motivoActual.isNotEmpty && !motivosDisponibles.contains(motivoActual))
        motivoActual,
    ];
    final valorSeleccionado = motivos.contains(motivoActual)
        ? motivoActual
        : null;

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
          const Text(
            'Motivo',
            style: TextStyle(
              color: AppColores.baseFF7A8088,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          if (!modoEdicion)
            Text(
              motivoActual.isEmpty ? '-' : motivoActual,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColores.baseFF1F2A35,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            )
          else if (cargandoMotivos)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: valorSeleccionado,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? '' : null,
              isExpanded: true,
              icon: const Icon(
                Icons.expand_more_rounded,
                color: AppColores.baseFF5F6772,
                size: 20,
              ),
              dropdownColor: AppColores.baseFFE9EAEB,
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
                fillColor: AppColores.transparente,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                errorStyle: TextStyle(height: 0.01, fontSize: 0),
              ),
              hint: const Text(
                'Seleccionar motivo',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColores.baseFF6B737E,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
              items: motivos
                  .map(
                    (motivo) => DropdownMenuItem<String>(
                      value: motivo,
                      child: Text(
                        motivo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                onMotivoChanged(value ?? '');
              },
            ),
        ],
      ),
    );
  }

  // Sección: campo visual reutilizable
  // Mantiene bloque de ficha y alterna entre texto o input según modo edición.
  Widget _campoFicha({
    required String etiqueta,
    required TextEditingController controller,
    required bool habilitado,
    String? Function(String?)? validator,
    int minLines = 1,
    int maxLines = 1,
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
              maxLines: maxLines + 1,
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
              minLines: minLines,
              maxLines: maxLines,
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

  // Sección: campo fecha y hora
  // En modo edición abre selector; en lectura solo muestra el texto actual.
  Widget _campoFechaHora() {
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
          const Text(
            'Fecha y hora',
            style: TextStyle(
              color: AppColores.baseFF7A8088,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          if (!modoEdicion)
            Text(
              fechaHoraController.text.trim().isEmpty
                  ? 'Fecha por definir'
                  : fechaHoraController.text.trim(),
              style: const TextStyle(
                color: AppColores.baseFF1F2A35,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            )
          else
            // Botón/campo: abre el selector de fecha y hora en modo edición.
            InkWell(
              onTap: onSeleccionarFechaHora,
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
                        height: 1.1,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColores.baseFF1F2A35,
                    size: 18,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
