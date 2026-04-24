// Sección: imports
// Se importan rutas y paleta para mantener el diseño original del formulario.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';

// Sección: formulario de login
// Conserva el diseño original y delega autenticación al callback externo.
class FormularioLogin extends StatefulWidget {
  const FormularioLogin({
    required this.cargando,
    required this.onIniciarSesion,
    required this.onIrARegistro,
    super.key,
  });

  final bool cargando;
  final Future<void> Function({
    required String correo,
    required String contrasena,
  })
  onIniciarSesion;
  final VoidCallback onIrARegistro;

  @override
  State<FormularioLogin> createState() => _FormularioLoginState();
}

// Sección: estado del formulario login
// Gestiona campos, validaciones manuales y comportamiento visual.
class _FormularioLoginState extends State<FormularioLogin> {
  // Sección: controladores y estado de campos
  // Guarda texto ingresado y estado de visibilidad de contraseña.
  final _correoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  bool _ocultarContrasena = true;

  // Sección: estado de errores en UI
  // Se muestran debajo de cada campo sin alterar la estructura visual.
  String? _errorCorreo;
  String? _errorContrasena;

  // Sección: limpieza de recursos
  // Libera controladores al destruir el widget.
  @override
  void dispose() {
    _correoCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  // Sección: envío de formulario
  // Valida campos y ejecuta callback de login real.
  Future<void> _iniciarSesion() async {
    final errorCorreo = _validarCorreo(_correoCtrl.text);
    final errorContrasena = _validarContrasena(_contrasenaCtrl.text);

    setState(() {
      _errorCorreo = errorCorreo;
      _errorContrasena = errorContrasena;
    });

    if (errorCorreo != null || errorContrasena != null) {
      return;
    }

    await widget.onIniciarSesion(
      correo: _correoCtrl.text.trim().toLowerCase(),
      contrasena: _contrasenaCtrl.text,
    );
  }

  // Sección: validación de correo
  // Revisa vacío y formato general de email.
  String? _validarCorreo(String value) {
    final correo = value.trim();
    if (correo.isEmpty) {
      return 'Ingresa tu correo';
    }

    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(correo)) {
      return 'Correo no válido';
    }
    return null;
  }

  // Sección: validación de contraseña
  // Revisa campo obligatorio y longitud mínima.
  String? _validarContrasena(String value) {
    if (value.isEmpty) {
      return 'Ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  // Sección: decoración compartida de inputs
  // Mantiene el estilo visual original en ambos campos.
  InputDecoration _decoracionCampo({required String hint, Widget? suffixIcon}) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(36),
      borderSide: const BorderSide(color: AppColores.negro, width: 1),
    );

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColores.grisSuave,
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      enabledBorder: borde,
      focusedBorder: borde,
      suffixIcon: suffixIcon,
    );
  }

  // Sección: etiqueta de campo
  // Componente pequeño para textos "Correo" y "Contraseña".
  Widget _etiqueta(String texto) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColores.negro,
        ),
      ),
    );
  }

  // Sección: mensaje de error bajo campo
  // Reserva alto fijo para evitar saltos de layout al validar.
  Widget _mensajeError(String? mensaje) {
    return SizedBox(
      height: 20,
      child: mensaje == null
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Text(
                mensaje,
                style: const TextStyle(
                  color: AppColores.rojoMaterial,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }

  // Sección: construcción de UI
  // Renderiza el mismo diseño original del formulario.
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Bienvenido a\nVetManager',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.1,
            color: AppColores.negro,
          ),
        ),
        const SizedBox(height: 36),
        _etiqueta('Correo Electronico'),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: const [
              BoxShadow(
                color: AppColores.base40000000,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _correoCtrl,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              if (_errorCorreo != null) {
                setState(() {
                  _errorCorreo = _validarCorreo(value);
                });
              }
            },
            decoration: _decoracionCampo(hint: ''),
          ),
        ),
        _mensajeError(_errorCorreo),
        const SizedBox(height: 12),
        _etiqueta('Contraseña'),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: const [
              BoxShadow(
                color: AppColores.base40000000,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _contrasenaCtrl,
            obscureText: _ocultarContrasena,
            onChanged: (value) {
              if (_errorContrasena != null) {
                setState(() {
                  _errorContrasena = _validarContrasena(value);
                });
              }
            },
            decoration: _decoracionCampo(
              hint: '',
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
        ),
        _mensajeError(_errorContrasena),
        const SizedBox(height: 24),
        SizedBox(
          height: 64,
          child: ElevatedButton(
            onPressed: widget.cargando ? null : _iniciarSesion,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColores.secundarioOscuro,
              foregroundColor: AppColores.negro,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
                side: const BorderSide(color: AppColores.negro, width: 1),
              ),
            ),
            child: widget.cargando
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'INICIAR SESIÓN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColores.blanco,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        // Sección: acción secundaria de registro
        // Fuerza estilo transparente para que solo se muestre el texto sin fondo.
        TextButton(
          onPressed: widget.cargando ? null : widget.onIrARegistro,
          style: TextButton.styleFrom(
            backgroundColor: AppColores.transparente,
            shadowColor: AppColores.transparente,
            surfaceTintColor: AppColores.transparente,
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Registrate',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColores.negro,
            ),
          ),
        ),
      ],
    );
  }
}
