// Sección: imports
// Se importan servicios de sesión y mascotas para registrar en JSON local.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';
import 'package:petcontrol_limpio/services/auth_service.dart';
import 'package:petcontrol_limpio/services/mascota_service.dart';

// Sección: tarjeta de registro de mascota
// Renderiza el formulario popup y guarda la mascota con id único en JSON local.
class TarjetaCreacionPaciente extends StatefulWidget {
  const TarjetaCreacionPaciente({
    super.key,
    this.onCerrar,
    this.onMascotaCreada,
  });

  final VoidCallback? onCerrar;
  final VoidCallback? onMascotaCreada;

  @override
  State<TarjetaCreacionPaciente> createState() =>
      _TarjetaCreacionPacienteState();
}

// Sección: estado del formulario de mascota
// Gestiona validación, parseo de datos y guardado en backend.
class _TarjetaCreacionPacienteState extends State<TarjetaCreacionPaciente> {
  // Sección: controladores y clave de formulario
  // Mantienen el estado de los inputs requeridos para crear mascota.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _especieController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();

  // Sección: servicios de dominio
  // Resuelven usuario autenticado y persistencia de mascotas.
  final AuthService _authService = AuthService();
  final MascotaService _mascotaService = MascotaService();

  // Sección: estado de UI y selección
  // Controla bloqueo del botón durante guardado y valor de sexo.
  bool _guardando = false;
  String? _sexoSeleccionado;

  // Sección: liberación de recursos
  // Evita fugas de memoria al cerrar la tarjeta.
  @override
  void dispose() {
    _nombreController.dispose();
    _especieController.dispose();
    _razaController.dispose();
    _edadController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  // Sección: decoración reutilizable de campos
  // Mantiene estilo consistente con el diseño actual del popup.
  InputDecoration _decoracionCampo({
    required String hintText,
    Color colorBorde = AppColores.baseFFCDD4D1,
    Color colorFondo = AppColores.baseFFE8EBEA,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColores.baseFF6E7A78,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: colorFondo,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorBorde, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorBorde, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColores.baseFFB53939,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColores.baseFFB53939,
          width: 1.8,
        ),
      ),
      errorStyle: const TextStyle(height: 0.01),
    );
  }

  // Sección: validación requerida de campos
  // Evita registros incompletos devolviendo error invisible para conservar diseño.
  String? _validadorRequerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }
    return null;
  }

  // Sección: resolución de id de usuario
  // Usa id del perfil persistido en sesión local.
  String _resolverIdUsuario(String? idPerfil) {
    return (idPerfil ?? '').trim();
  }

  // Sección: parseo de edad
  // Extrae número de texto como "3 años" y retorna entero válido.
  int? _parsearEdad(String texto) {
    final match = RegExp(r'\d+').firstMatch(texto);
    if (match == null) {
      return null;
    }
    return int.tryParse(match.group(0) ?? '');
  }

  // Sección: parseo de peso
  // Extrae decimal de texto como "12.5 kg" o "12,5 kg".
  double? _parsearPeso(String texto) {
    final normalizado = texto.replaceAll(',', '.');
    final match = RegExp(r'\d+(\.\d+)?').firstMatch(normalizado);
    if (match == null) {
      return null;
    }
    return double.tryParse(match.group(0) ?? '');
  }

  // Sección: cierre controlado del popup
  // Ejecuta callback externo y cierra el diálogo con resultado falso.
  void _cerrar() {
    widget.onCerrar?.call();
    _cerrarDialogoSeguro(false);
  }

  // Sección: cierre seguro del diálogo
  // Evita hacer pop cuando ya no hay rutas disponibles en el Navigator.
  void _cerrarDialogoSeguro([bool? resultado]) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (!navigator.canPop()) {
      return;
    }
    navigator.pop(resultado);
  }

  // Sección: registro de mascota
  // Valida, transforma datos y crea documento en JSON local.
  Future<void> _registrarMascota() async {
    final formularioValido = _formKey.currentState?.validate() == true;
    final sexoValido = _sexoSeleccionado != null;
    if (!formularioValido || !sexoValido || _guardando) {
      setState(() {});
      return;
    }

    final edad = _parsearEdad(_edadController.text.trim());
    if (edad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La edad debe contener un número válido.'),
        ),
      );
      return;
    }

    final peso = _parsearPeso(_pesoController.text.trim());
    if (peso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El peso debe contener un número válido.'),
        ),
      );
      return;
    }

    // Sección: bloqueo anticipado de envío
    // Se activa antes del primer await para evitar dobles registros por taps rápidos.
    setState(() {
      _guardando = true;
    });

    try {
      final usuario = await _authService.obtenerUsuarioActual();
      final idUsuario = _resolverIdUsuario(usuario?.idUsuario);
      if (idUsuario.isEmpty) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró el usuario autenticado.'),
          ),
        );
        setState(() {
          _guardando = false;
        });
        return;
      }

      await _mascotaService.crearMascotaCliente(
        idUsuario: idUsuario,
        nombre: _nombreController.text.trim(),
        especie: _especieController.text.trim(),
        raza: _razaController.text.trim(),
        sexo: _sexoSeleccionado!,
        edadAnios: edad,
        pesoKg: peso,
      );

      if (!mounted) {
        return;
      }
      widget.onMascotaCreada?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mascota registrada correctamente.')),
      );
      _cerrarDialogoSeguro(true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo registrar la mascota.')),
      );
      setState(() {
        _guardando = false;
      });
    }
  }

  // Sección: construcción de la tarjeta
  // Presenta el formulario manteniendo el diseño original.
  @override
  Widget build(BuildContext context) {
    final alturaMaxima = MediaQuery.of(context).size.height * 0.82;

    return Material(
      color: AppColores.transparente,
      child: Container(
        constraints: BoxConstraints(maxHeight: alturaMaxima),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: AppColores.baseFFDCDDDB,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColores.baseFF1A95F7, width: 2),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Registrar mascota',
                        style: TextStyle(
                          color: AppColores.baseFF223633,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _cerrar,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Icon(
                          Icons.close,
                          color: AppColores.baseFF5E6A68,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const _EtiquetaCampo('Nombre'),
                TextFormField(
                  controller: _nombreController,
                  validator: _validadorRequerido,
                  decoration: _decoracionCampo(
                    hintText: 'Nombre de la mascota',
                    colorBorde: AppColores.baseFF5ABF9A,
                    colorFondo: AppColores.baseFFE5E8E7,
                  ),
                ),
                const SizedBox(height: 10),
                const _EtiquetaCampo('Especie'),
                TextFormField(
                  controller: _especieController,
                  validator: _validadorRequerido,
                  decoration: _decoracionCampo(hintText: 'Ej: Perro'),
                ),
                const SizedBox(height: 10),
                const _EtiquetaCampo('Sexo'),
                DropdownButtonFormField<String>(
                  initialValue: _sexoSeleccionado,
                  validator: (value) => value == null ? '' : null,
                  decoration: _decoracionCampo(hintText: 'Seleccionar sexo'),
                  hint: const Text(
                    'Seleccionar sexo',
                    style: TextStyle(
                      color: AppColores.baseFF6E7A78,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  borderRadius: BorderRadius.circular(12),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem(value: 'Hembra', child: Text('Hembra')),
                    DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sexoSeleccionado = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                const _EtiquetaCampo('Raza'),
                TextFormField(
                  controller: _razaController,
                  // Sección: campo opcional
                  // La raza no es obligatoria para permitir registrar mascotas sin ese dato.
                  decoration: _decoracionCampo(hintText: 'Raza'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _EtiquetaCampo('Edad'),
                          TextFormField(
                            controller: _edadController,
                            keyboardType: TextInputType.number,
                            validator: _validadorRequerido,
                            decoration: _decoracionCampo(
                              hintText: 'Ej: 3 años',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _EtiquetaCampo('Peso'),
                          TextFormField(
                            controller: _pesoController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: _validadorRequerido,
                            decoration: _decoracionCampo(hintText: 'Ej: 12 kg'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _registrarMascota,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColores.secundarioOscuro,
                      foregroundColor: AppColores.blanco,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _guardando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.1,
                              color: AppColores.blanco,
                            ),
                          )
                        : const Text(
                            'Registrar mascota',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sección: etiqueta visual de campos
// Reutiliza tipografía y espaciado para títulos de input.
class _EtiquetaCampo extends StatelessWidget {
  const _EtiquetaCampo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        texto,
        style: const TextStyle(
          color: AppColores.baseFF2D3D3B,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
