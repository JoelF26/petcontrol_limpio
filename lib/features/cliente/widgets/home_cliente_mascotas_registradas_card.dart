// Sección: imports
// Se importan componentes base para construir la sección de mascotas registradas.
import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/models/mascota.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/home_cliente_mensaje_vacio.dart';
import 'package:petcontrol_limpio/features/cliente/widgets/home_cliente_panel_seccion.dart';

// Sección: tarjeta de mascotas registradas
// Encapsula el panel completo manteniendo diseño y estado inicial vacío.
class HomeClienteMascotasRegistradasCard extends StatelessWidget {
  const HomeClienteMascotasRegistradasCard({
    required this.onVerTodo,
    this.onTapMascota,
    List<Mascota>? mascotasRecientes,
    super.key,
  }) : mascotasRecientes = mascotasRecientes ?? const <Mascota>[];

  final VoidCallback onVerTodo;
  final ValueChanged<Mascota>? onTapMascota;

  // Sección: lista segura de mascotas
  // Se normaliza a lista vacía para evitar errores si llega null en reconstrucciones.
  final List<Mascota> mascotasRecientes;

  // Sección: construcción del panel
  // Renderiza cabecera y contenido vacío cuando aún no hay mascotas.
  @override
  Widget build(BuildContext context) {
    return HomeClientePanelSeccion(
      titulo: 'Mis mascotas registradas',
      icono: Icons.pets_outlined,
      onVerTodo: onVerTodo,
      child: _contenido(),
    );
  }

  // Sección: contenido dinámico
  // Muestra estado vacío o hasta tres mascotas en formato de tarjeta compacta.
  Widget _contenido() {
    if (mascotasRecientes.isEmpty) {
      return const HomeClienteMensajeVacio(
        texto: 'No tienes mascotas registradas.',
      );
    }

    return Column(
      children: [
        for (var i = 0; i < mascotasRecientes.length; i++) ...[
          _tarjetaMascota(mascotasRecientes[i]),
          if (i != mascotasRecientes.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  // Sección: tarjeta individual de mascota
  // Replica el diseño solicitado con icono, datos principales y chip de especie.
  Widget _tarjetaMascota(Mascota mascota) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => onTapMascota?.call(mascota),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF3D3D3D), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFCAD8D4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: Color(0xFF2E816B),
                  size: 29,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mascota.nombreVisible,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      mascota.razaVisible,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF566273),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${mascota.edadVisible} | ${mascota.pesoVisible}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B7684),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4E0D2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  mascota.especieVisible,
                  style: const TextStyle(
                    color: Color(0xFF4E6F60),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
