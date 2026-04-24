// Sección: imports
// Se importan Material y utilidades de normalización del correo institucional.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/features/admin/utils/correo_medico_helper.dart';

// Sección: apertura del popup de alias
// Solicita alias manual cuando el correo generado automáticamente colisiona.
Future<String?> mostrarPopupAliasCorreoMedico(
  BuildContext context, {
  required String correoEnUso,
}) async {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _PopupAliasCorreoMedico(correoEnUso: correoEnUso),
  );
}

// Sección: diálogo de alias
// Permite ingresar un alias para formar un correo único en @Vetcontrol.com.
class _PopupAliasCorreoMedico extends StatefulWidget {
  const _PopupAliasCorreoMedico({required this.correoEnUso});

  final String correoEnUso;

  @override
  State<_PopupAliasCorreoMedico> createState() =>
      _PopupAliasCorreoMedicoState();
}

class _PopupAliasCorreoMedicoState extends State<_PopupAliasCorreoMedico> {
  final TextEditingController _aliasCtrl = TextEditingController();
  String? _errorAlias;

  @override
  void dispose() {
    _aliasCtrl.dispose();
    super.dispose();
  }

  // Sección: validación de alias
  // Asegura que el alias tenga contenido utilizable tras normalización.
  String? _validarAlias(String valor) {
    final normalizado = CorreoMedicoHelper.normalizarAlias(valor);
    if (normalizado.isEmpty) {
      return 'Ingresa un alias válido';
    }
    return null;
  }

  // Sección: confirmación de alias
  // Normaliza y retorna el alias para reintentar registro de médico.
  void _confirmarAlias() {
    final error = _validarAlias(_aliasCtrl.text);
    setState(() {
      _errorAlias = error;
    });
    if (error != null) {
      return;
    }
    final aliasNormalizado = CorreoMedicoHelper.normalizarAlias(
      _aliasCtrl.text,
    );
    Navigator.of(context).pop(aliasNormalizado);
  }

  @override
  Widget build(BuildContext context) {
    final aliasPreview = CorreoMedicoHelper.normalizarAlias(_aliasCtrl.text);
    final correoPreview = aliasPreview.isEmpty
        ? 'alias@${CorreoMedicoHelper.dominioMedico}'
        : '$aliasPreview@${CorreoMedicoHelper.dominioMedico}';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Correo en uso',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'El correo generado ya existe. Ingresa un alias para crear uno nuevo.',
              style: TextStyle(fontSize: 13.5, color: AppColores.baseFF4B5563),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColores.baseFFF4F7FA,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColores.baseFFDEE5ED),
              ),
              child: Text(
                widget.correoEnUso,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColores.baseFF334155,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _aliasCtrl,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Alias (ej: maria.castro)',
                filled: true,
                fillColor: AppColores.blanco,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColores.baseFFC8D2DC),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColores.secundarioOscuro,
                  ),
                ),
                errorText: _errorAlias,
              ),
              onSubmitted: (_) => _confirmarAlias(),
              onChanged: (_) {
                if (_errorAlias != null) {
                  setState(() {
                    _errorAlias = _validarAlias(_aliasCtrl.text);
                  });
                } else {
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Correo final: $correoPreview',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColores.baseFF334155,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _confirmarAlias,
          child: const Text('Usar alias'),
        ),
      ],
    );
  }
}
