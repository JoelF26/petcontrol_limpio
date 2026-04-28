import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/admin/models/personal_medico_view_data.dart';
import 'package:petcontrol_limpio/features/admin/widgets/shared/admin_base_widgets.dart';

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
      // Botón/tarjeta: abre el detalle o edición del médico seleccionado.
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
