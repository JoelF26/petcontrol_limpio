// Sección: imports
// Se importa material para construir el popup reutilizable de detalle.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';

// Sección: campo de detalle
// Representa una fila de etiqueta y valor dentro del popup.
class DetalleCampo {
  const DetalleCampo({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;
}

// Sección: configuración del popup
// Agrupa los datos visuales y de contenido para el detalle contextual.
class ConfigPopupDetalle {
  const ConfigPopupDetalle({
    required this.titulo,
    this.subtitulo = '',
    this.icono = Icons.info_outline,
    this.colorAcento = AppColores.secundarioOscuro,
    this.chips = const <String>[],
    this.campos = const <DetalleCampo>[],
  });

  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color colorAcento;
  final List<String> chips;
  final List<DetalleCampo> campos;
}

// Sección: helper público de apertura
// Muestra un diálogo modal con información de detalle de forma consistente.
Future<void> mostrarPopupDetalle(
  BuildContext context,
  ConfigPopupDetalle config,
) async {
  await showDialog<void>(
    context: context,
    barrierColor: AppColores.negro54,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: AppColores.transparente,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Container(
          decoration: BoxDecoration(
            color: AppColores.baseFFE0E3E2,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColores.baseFF2E3331, width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: config.colorAcento.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(config.icono, color: config.colorAcento),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config.titulo,
                          style: const TextStyle(
                            color: AppColores.baseFF1F2D3A,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                          ),
                        ),
                        if (config.subtitulo.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            config.subtitulo,
                            style: const TextStyle(
                              color: AppColores.baseFF586778,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppColores.baseFF66717C,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              if (config.chips.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: config.chips
                      .where((chip) => chip.trim().isNotEmpty)
                      .map(
                        (chip) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: config.colorAcento.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            chip,
                            style: TextStyle(
                              color: config.colorAcento,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
              const SizedBox(height: 12),
              ...config.campos.map(
                (campo) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColores.baseFFF6F7F8,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campo.etiqueta,
                          style: const TextStyle(
                            color: AppColores.baseFF788390,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          campo.valor,
                          style: const TextStyle(
                            color: AppColores.baseFF1C252E,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
