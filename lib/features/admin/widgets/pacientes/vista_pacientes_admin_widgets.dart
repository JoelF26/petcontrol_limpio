// Seccion: imports
// Se importan utilidades visuales y modelo de vista para pacientes admin.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/admin/models/vista_pacientes_admin_view_data.dart';
import 'package:petcontrol_limpio/features/admin/widgets/shared/admin_base_widgets.dart';

// Seccion: fondo decorativo
// Dibuja gradiente superior y base clara de la pantalla de pacientes.
class VistaPacientesAdminFondo extends StatelessWidget {
  const VistaPacientesAdminFondo({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminFondoDecorativo(
      colores: [
        AppColores.baseFF1F6C4C,
        AppColores.verdepacientes,
        AppColores.baseFF73C08F,
      ],
    );
  }
}

// Seccion: encabezado
// Renderiza boton volver y textos principales de la vista.
class VistaPacientesAdminEncabezado extends StatelessWidget {
  const VistaPacientesAdminEncabezado({super.key, required this.onVolver});

  final VoidCallback onVolver;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BotonEncabezadoIcono(onTap: onVolver),
        const SizedBox(height: 12),
        const Text(
          'Pacientes',
          style: TextStyle(
            color: AppColores.blanco,
            fontSize: 33,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Gestiona el historial, datos de contacto y seguimiento de tus mascotas.',
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
// Boton reutilizable para navegacion de regreso.
class _BotonEncabezadoIcono extends StatelessWidget {
  const _BotonEncabezadoIcono({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AdminBotonEncabezadoIcono(onTap: onTap);
  }
}

// Seccion: resumen de pacientes
// Muestra totales de pacientes y especies en dos tarjetas.
class VistaPacientesAdminResumen extends StatelessWidget {
  const VistaPacientesAdminResumen({
    super.key,
    required this.totalPacientes,
    required this.totalEspecies,
  });

  final int totalPacientes;
  final int totalEspecies;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TarjetaResumen(
            etiqueta: 'Pacientes',
            valor: '$totalPacientes',
            icono: Icons.pets_outlined,
          ),
          const SizedBox(width: 10),
          _TarjetaResumen(
            etiqueta: 'Especies',
            valor: '$totalEspecies',
            icono: Icons.category_outlined,
          ),
        ],
      ),
    );
  }
}

// Seccion: tarjeta de resumen
// Item compacto para bloque de metricas.
class _TarjetaResumen extends StatelessWidget {
  const _TarjetaResumen({
    required this.etiqueta,
    required this.valor,
    required this.icono,
  });

  final String etiqueta;
  final String valor;
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

// Seccion: buscador
// Campo de texto para filtrar pacientes por distintos atributos.
class VistaPacientesAdminBuscador extends StatelessWidget {
  const VistaPacientesAdminBuscador({
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
          hintText: 'Buscar por nombre, dueno o raza...',
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
            Icons.tune_rounded,
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

// Seccion: tarjeta de paciente
// Renderiza la informacion principal de cada mascota.
class VistaPacientesAdminTarjeta extends StatelessWidget {
  const VistaPacientesAdminTarjeta({
    super.key,
    required this.paciente,
    required this.onTap,
  });

  final PacienteVistaAdmin paciente;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconoEspecie = _iconoEspecie(paciente.especie);

    return Material(
      color: AppColores.transparente,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 114),
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
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColores.baseFFD6E8DE,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        iconoEspecie,
                        color: AppColores.baseFF2A6F4D,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  paciente.nombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColores.baseFF1F3028,
                                    height: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              VistaPacientesAdminChipEspecie(
                                especie: paciente.especie,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            paciente.raza,
                            style: const TextStyle(
                              color: AppColores.baseFF637268,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
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
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    VistaPacientesAdminChipDato(
                      icono: Icons.cake_outlined,
                      valor: '${paciente.edad} anos',
                    ),
                    VistaPacientesAdminChipDato(
                      icono: Icons.monitor_weight_outlined,
                      valor: '${paciente.peso} kg',
                    ),
                    VistaPacientesAdminChipDato(
                      icono: Icons.person_outline_rounded,
                      valor: paciente.dueno,
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

  IconData _iconoEspecie(String especie) {
    switch (especie.toLowerCase()) {
      case 'gato':
        return Icons.pets_rounded;
      case 'conejo':
        return Icons.cruelty_free_outlined;
      case 'ave':
        return Icons.flutter_dash_rounded;
      default:
        return Icons.pets_outlined;
    }
  }
}

// Seccion: chip de especie
// Etiqueta visual para especie principal de la mascota.
class VistaPacientesAdminChipEspecie extends StatelessWidget {
  const VistaPacientesAdminChipEspecie({super.key, required this.especie});

  final String especie;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColores.baseFFDAEFE4,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        especie,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: AppColores.baseFF2F7452,
          height: 1,
        ),
      ),
    );
  }
}

// Seccion: chip de dato
// Renderiza un dato secundario de la mascota con icono.
class VistaPacientesAdminChipDato extends StatelessWidget {
  const VistaPacientesAdminChipDato({
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
          Text(
            valor,
            style: const TextStyle(
              color: AppColores.baseFF416955,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
