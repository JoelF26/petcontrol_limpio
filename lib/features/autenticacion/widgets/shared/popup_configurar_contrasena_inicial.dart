// Sección: imports
// Se importan widgets de Flutter y colores del proyecto.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';

// Sección: apertura del popup
// Muestra diálogo de primer acceso y retorna contraseña nueva al confirmar.
Future<String?> mostrarPopupConfigurarContrasenaInicial(
  BuildContext context, {
  required String correo,
}) async {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _PopupConfigurarContrasenaInicial(correo: correo),
  );
}

// Sección: popup de configuración inicial
// Solicita contraseña y confirmación para cuentas sin clave previa.
class _PopupConfigurarContrasenaInicial extends StatefulWidget {
  const _PopupConfigurarContrasenaInicial({required this.correo});

  final String correo;

  @override
  State<_PopupConfigurarContrasenaInicial> createState() =>
      _PopupConfigurarContrasenaInicialState();
}

class _PopupConfigurarContrasenaInicialState
    extends State<_PopupConfigurarContrasenaInicial> {
  final TextEditingController _contrasenaCtrl = TextEditingController();
  final TextEditingController _confirmacionCtrl = TextEditingController();
  bool _ocultarContrasena = true;
  bool _ocultarConfirmacion = true;
  String? _errorContrasena;
  String? _errorConfirmacion;

  @override
  void dispose() {
    _contrasenaCtrl.dispose();
    _confirmacionCtrl.dispose();
    super.dispose();
  }

  // Sección: validadores de campos
  // Aseguran formato mínimo y coincidencia entre ambas entradas.
  String? _validarContrasena(String value) {
    final limpia = value.trim();
    if (limpia.isEmpty) {
      return 'Ingresa una contraseña';
    }
    if (limpia.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  String? _validarConfirmacion(String value) {
    final limpia = value.trim();
    if (limpia.isEmpty) {
      return 'Confirma la contraseña';
    }
    if (limpia != _contrasenaCtrl.text.trim()) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  // Sección: confirmar guardado
  // Valida y cierra retornando la contraseña final al login.
  void _confirmar() {
    final errorContrasena = _validarContrasena(_contrasenaCtrl.text);
    final errorConfirmacion = _validarConfirmacion(_confirmacionCtrl.text);

    setState(() {
      _errorContrasena = errorContrasena;
      _errorConfirmacion = errorConfirmacion;
    });

    if (errorContrasena != null || errorConfirmacion != null) {
      return;
    }

    Navigator.of(context).pop(_contrasenaCtrl.text.trim());
  }

  InputDecoration _decoracionCampo({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColores.baseFF64748B, fontSize: 13),
      filled: true,
      fillColor: AppColores.blanco,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColores.baseFFC8D2DC),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColores.secundarioOscuro),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColores.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColores.error),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      contentPadding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      title: const Text(
        'Primer acceso',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta cuenta aún no tiene contraseña. Configúrala para continuar.',
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
                widget.correo,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColores.baseFF334155,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contrasenaCtrl,
              obscureText: _ocultarContrasena,
              onChanged: (_) {
                if (_errorContrasena != null || _errorConfirmacion != null) {
                  setState(() {
                    _errorContrasena = _validarContrasena(_contrasenaCtrl.text);
                    _errorConfirmacion = _validarConfirmacion(
                      _confirmacionCtrl.text,
                    );
                  });
                }
              },
              decoration: _decoracionCampo(
                hint: 'Nueva contraseña',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _ocultarContrasena = !_ocultarContrasena;
                    });
                  },
                  icon: Icon(
                    _ocultarContrasena
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
            if (_errorContrasena != null) ...[
              const SizedBox(height: 4),
              Text(
                _errorContrasena!,
                style: const TextStyle(color: AppColores.error, fontSize: 12),
              ),
            ],
            const SizedBox(height: 10),
            TextField(
              controller: _confirmacionCtrl,
              obscureText: _ocultarConfirmacion,
              onChanged: (_) {
                if (_errorConfirmacion != null) {
                  setState(() {
                    _errorConfirmacion = _validarConfirmacion(
                      _confirmacionCtrl.text,
                    );
                  });
                }
              },
              decoration: _decoracionCampo(
                hint: 'Confirmar contraseña',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _ocultarConfirmacion = !_ocultarConfirmacion;
                    });
                  },
                  icon: Icon(
                    _ocultarConfirmacion
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
            if (_errorConfirmacion != null) ...[
              const SizedBox(height: 4),
              Text(
                _errorConfirmacion!,
                style: const TextStyle(color: AppColores.error, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _confirmar,
          child: const Text('Guardar y entrar'),
        ),
      ],
    );
  }
}
