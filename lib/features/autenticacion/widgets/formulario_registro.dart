// Sección: imports
// Se importan Material y la paleta para mantener el diseño original del formulario.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';

// Sección: DTO del formulario
// Agrupa los datos capturados en UI antes de enviarlos al backend.
class DatosFormularioRegistro {
  const DatosFormularioRegistro({
    required this.nombreCompleto,
    required this.numeroDocumento,
    required this.telefono,
    required this.correo,
    required this.contrasena,
  });

  final String nombreCompleto;
  final String numeroDocumento;
  final String telefono;
  final String correo;
  final String contrasena;
}

// Sección: widget de formulario de registro
// Conserva el diseño y delega la lógica de backend por callbacks.
class FormularioRegistro extends StatefulWidget {
  const FormularioRegistro({
    required this.cargando,
    required this.onRegistrar,
    required this.onIrALogin,
    super.key,
  });

  final bool cargando;
  final Future<void> Function(DatosFormularioRegistro datos) onRegistrar;
  final VoidCallback onIrALogin;

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

// Sección: estado del formulario de registro
// Administra campos, validaciones y estados visuales.
class _FormularioRegistroState extends State<FormularioRegistro> {
  // Sección: controladores de campos
  // Gestionan los valores digitados por el usuario.
  final _nombresCtrl = TextEditingController();
  final _numeroDocumentoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  final _confirmarContrasenaCtrl = TextEditingController();

  // Sección: estado de visibilidad de contraseñas
  // Permite alternar mostrar/ocultar en cada campo de contraseña.
  bool _ocultarContrasena = true;
  bool _ocultarConfirmacion = true;

  // Sección: estado de errores
  // Guarda mensajes de error fuera del TextField para evitar saltos de tamaño.
  String? _errorNombres;
  String? _errorNumeroDocumento;
  String? _errorTelefono;
  String? _errorCorreo;
  String? _errorContrasena;
  String? _errorConfirmacion;

  // Sección: limpieza de recursos
  // Libera los controladores al desmontar el widget.
  @override
  void dispose() {
    _nombresCtrl.dispose();
    _numeroDocumentoCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    _contrasenaCtrl.dispose();
    _confirmarContrasenaCtrl.dispose();
    super.dispose();
  }

  // Sección: envío del formulario
  // Valida todos los campos y delega el registro a la pantalla.
  Future<void> _registrarse() async {
    if (widget.cargando) {
      return;
    }

    final errorNombres = _validarNombres(_nombresCtrl.text);
    final errorNumeroDocumento = _validarNumeroDocumento(
      _numeroDocumentoCtrl.text,
    );
    final errorTelefono = _validarTelefono(_telefonoCtrl.text);
    final errorCorreo = _validarCorreo(_correoCtrl.text);
    final errorContrasena = _validarContrasena(_contrasenaCtrl.text);
    final errorConfirmacion = _validarConfirmacion(
      _confirmarContrasenaCtrl.text,
      _contrasenaCtrl.text,
    );

    setState(() {
      _errorNombres = errorNombres;
      _errorNumeroDocumento = errorNumeroDocumento;
      _errorTelefono = errorTelefono;
      _errorCorreo = errorCorreo;
      _errorContrasena = errorContrasena;
      _errorConfirmacion = errorConfirmacion;
    });

    final hayErrores = [
      errorNombres,
      errorNumeroDocumento,
      errorTelefono,
      errorCorreo,
      errorContrasena,
      errorConfirmacion,
    ].any((error) => error != null);

    if (hayErrores) {
      return;
    }

    final datos = DatosFormularioRegistro(
      nombreCompleto: _nombresCtrl.text.trim(),
      numeroDocumento: _numeroDocumentoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      correo: _correoCtrl.text.trim().toLowerCase(),
      contrasena: _contrasenaCtrl.text,
    );

    await widget.onRegistrar(datos);
  }

  // Sección: validación de nombres
  // Exige un texto no vacío con longitud mínima razonable.
  String? _validarNombres(String value) {
    final nombres = value.trim();
    if (nombres.isEmpty) {
      return 'Ingresa tus nombres y apellidos';
    }
    if (nombres.length < 3) {
      return 'Nombre muy corto';
    }
    return null;
  }

  // Sección: validación de documento
  // Acepta solo dígitos para el número de documento.
  String? _validarNumeroDocumento(String value) {
    final numero = value.trim();
    if (numero.isEmpty) {
      return 'Campo requerido';
    }
    final regex = RegExp(r'^\d+$');
    if (!regex.hasMatch(numero)) {
      return 'Solo números';
    }
    return null;
  }

  // Sección: validación de teléfono
  // Acepta solo dígitos y un tamaño típico de teléfono móvil.
  String? _validarTelefono(String value) {
    final telefono = value.trim();
    if (telefono.isEmpty) {
      return 'Ingresa tu teléfono';
    }
    final regex = RegExp(r'^\d{7,15}$');
    if (!regex.hasMatch(telefono)) {
      return 'Teléfono no válido';
    }
    return null;
  }

  // Sección: validación de correo
  // Verifica formato básico de correo electrónico.
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
  // Requiere longitud mínima para fortalecer credenciales.
  String? _validarContrasena(String value) {
    if (value.isEmpty) {
      return 'Ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  // Sección: validación de confirmación
  // Comprueba que la confirmación coincida con la contraseña.
  String? _validarConfirmacion(String confirmacion, String contrasena) {
    if (confirmacion.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (confirmacion != contrasena) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  // Sección: decoración de inputs
  // Reutiliza el mismo estilo visual en todos los campos.
  InputDecoration _decoracionCampo({Widget? suffixIcon}) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(36),
      borderSide: const BorderSide(color: Colors.black, width: 1),
    );

    return InputDecoration(
      filled: true,
      fillColor: AppColores.grisSuave,
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      enabledBorder: borde,
      focusedBorder: borde,
      suffixIcon: suffixIcon,
    );
  }

  // Sección: etiqueta de campo
  // Dibuja el título encima de cada input.
  Widget _etiqueta(String texto) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  // Sección: contenedor con sombra
  // Mantiene el relieve visual del diseño original.
  Widget _campoConSombra({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // Sección: texto de error
  // Reserva alto fijo para que el layout no cambie al validar.
  Widget _mensajeError(String? mensaje, {double leftPadding = 12}) {
    return SizedBox(
      height: 16,
      child: mensaje == null
          ? const SizedBox.shrink()
          : Padding(
              padding: EdgeInsets.only(left: leftPadding, top: 2),
              child: Text(
                mensaje,
                style: const TextStyle(
                  color: AppColores.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }

  // Sección: UI del formulario
  // Construye la vista completa con campos, validaciones y acciones.
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _etiqueta('Nombres y Apellidos'),
        _campoConSombra(
          child: TextField(
            controller: _nombresCtrl,
            onChanged: (value) {
              if (_errorNombres != null) {
                setState(() {
                  _errorNombres = _validarNombres(value);
                });
              }
            },
            decoration: _decoracionCampo(),
          ),
        ),
        _mensajeError(_errorNombres),
        const SizedBox(height: 4),
        _etiqueta('Número de documento'),
        _campoConSombra(
          child: TextField(
            controller: _numeroDocumentoCtrl,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (_errorNumeroDocumento != null) {
                setState(() {
                  _errorNumeroDocumento = _validarNumeroDocumento(value);
                });
              }
            },
            decoration: _decoracionCampo(),
          ),
        ),
        _mensajeError(_errorNumeroDocumento),
        const SizedBox(height: 4),
        _etiqueta('Teléfono'),
        _campoConSombra(
          child: TextField(
            controller: _telefonoCtrl,
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              if (_errorTelefono != null) {
                setState(() {
                  _errorTelefono = _validarTelefono(value);
                });
              }
            },
            decoration: _decoracionCampo(),
          ),
        ),
        _mensajeError(_errorTelefono),
        const SizedBox(height: 4),
        _etiqueta('Correo Electronico'),
        _campoConSombra(
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
            decoration: _decoracionCampo(),
          ),
        ),
        _mensajeError(_errorCorreo),
        const SizedBox(height: 4),
        _etiqueta('Contraseña'),
        _campoConSombra(
          child: TextField(
            controller: _contrasenaCtrl,
            obscureText: _ocultarContrasena,
            onChanged: (value) {
              if (_errorContrasena != null || _errorConfirmacion != null) {
                setState(() {
                  _errorContrasena = _validarContrasena(value);
                  _errorConfirmacion = _validarConfirmacion(
                    _confirmarContrasenaCtrl.text,
                    value,
                  );
                });
              }
            },
            decoration: _decoracionCampo(
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
        const SizedBox(height: 4),
        _etiqueta('Confirmar Contraseña'),
        _campoConSombra(
          child: TextField(
            controller: _confirmarContrasenaCtrl,
            obscureText: _ocultarConfirmacion,
            onChanged: (value) {
              if (_errorConfirmacion != null) {
                setState(() {
                  _errorConfirmacion = _validarConfirmacion(
                    value,
                    _contrasenaCtrl.text,
                  );
                });
              }
            },
            decoration: _decoracionCampo(
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
        ),
        _mensajeError(_errorConfirmacion),
        const SizedBox(height: 12),
        SizedBox(
          height: 64,
          child: ElevatedButton(
            onPressed: widget.cargando ? null : _registrarse,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColores.secundarioOscuro,
              foregroundColor: Colors.black,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
                side: const BorderSide(color: Colors.black, width: 1),
              ),
            ),
            child: widget.cargando
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'REGISTRARSE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColores.blanco
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: widget.cargando ? null : widget.onIrALogin,
          child: const Text(
            'Ya tengo cuenta',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColores.negro,
            ),
          ),
        ),
      ],
    );
  }
}
