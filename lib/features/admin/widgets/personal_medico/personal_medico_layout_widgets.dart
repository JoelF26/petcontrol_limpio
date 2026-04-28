import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
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
