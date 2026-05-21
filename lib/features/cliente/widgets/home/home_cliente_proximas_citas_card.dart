// Sección: imports
// Se importan componentes base para construir la sección de próximas citas.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/shared/home_cliente_mensaje_vacio.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/home/home_cliente_panel_seccion.dart';
import 'package:petcontrol_limpio/domain/entities/cita.dart';

// Sección: tarjeta de próximas citas
// Encapsula el panel completo manteniendo diseño y estado inicial vacío.
class HomeClienteProximasCitasCard extends StatelessWidget {
  const HomeClienteProximasCitasCard({
    required this.onVerTodo,
    this.onTapCita,
    List<Cita>? proximasCitas,
    super.key,
  }) : proximasCitas = proximasCitas ?? const <Cita>[];

  final VoidCallback onVerTodo;
  final ValueChanged<Cita>? onTapCita;

  // Sección: lista segura de citas
  // Se normaliza a lista vacía para evitar errores si llega null en reconstrucciones.
  final List<Cita> proximasCitas;

  // Sección: construcción del panel
  // Renderiza cabecera y contenido vacío cuando aún no hay citas.
  @override
  Widget build(BuildContext context) {
    return HomeClientePanelSeccion(
      titulo: 'Mis proximas citas',
      icono: Icons.calendar_month_outlined,
      onVerTodo: onVerTodo,
      child: _contenido(),
    );
  }

  // Sección: contenido dinámico
  // Muestra mensaje vacío o máximo de citas cargadas desde JSON local.
  Widget _contenido() {
    if (proximasCitas.isEmpty) {
      return const HomeClienteMensajeVacio(
        texto: 'No tienes citas programadas.',
      );
    }

    return Column(
      children: [
        for (var i = 0; i < proximasCitas.length; i++) ...[
          _tarjetaCita(proximasCitas[i]),
          if (i != proximasCitas.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  // Sección: tarjeta individual de cita
  // Replica el diseño pedido para nombre, especie, fecha-hora, estado y motivo.
  Widget _tarjetaCita(Cita cita) {
    return Material(
      color: AppColores.transparente,
      // Botón/tarjeta: abre el detalle de la cita seleccionada.
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => onTapCita?.call(cita),
        child: Container(
          width: double.infinity,
          // Sección: ajuste de grosor visual
          // Reduce alto general de la tarjeta para acercarla al diseño del SVG.
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColores.baseFFE9E8E8,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColores.baseFF2F2F2F, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Sección: bloque de icono izquierdo
              // Centra el ícono del calendario dentro del contenedor como en la referencia.
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColores.baseFFD8E7E1,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: AppColores.baseFF2E8769,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Sección: contenido principal de la cita
              // Organiza el texto en tres filas para replicar proporciones del diseño.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección: fila superior (nombre + estado)
                    // Se separa el chip de estado para no quitar espacio a la fecha/hora.
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cita.nombreMascotaVisible,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColores.baseFF1F2937,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColores.baseFFD4E9DE,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            cita.estadoVisible,
                            style: const TextStyle(
                              color: AppColores.baseFF2E8769,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Sección: fila media (especie + fecha/hora)
                    // Muestra la especie en chip y la fecha completa en la misma línea.
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColores.baseFFDCE8D9,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            cita.especieMascotaVisible,
                            style: const TextStyle(
                              color: AppColores.baseFF4D685C,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cita.fechaHoraVisible,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColores.baseFF58616B,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Sección: fila inferior (motivo)
                    // Mantiene una línea como en la maqueta del SVG.
                    Text(
                      cita.motivoVisible,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColores.baseFF2B2B2B,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
