import 'package:flutter/material.dart';
import 'package:petcontrol_limpio/core/theme/app_colores.dart';

import 'package:petcontrol_limpio/core/routes/rutas.dart';

class BienvenidaPantalla extends StatelessWidget {
  const BienvenidaPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.blanco,
      body: SafeArea(
        child: Column(
          children: [
            //Header
            SizedBox(
              height: 400, //Cambiar tamaño del fondo gradiante
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColores.secundarioOscuro, AppColores.secundario],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipPath(
                      clipper: CurvaClipper(),
                      child: Container(
                        color: AppColores.blanco,
                        height: 120,
                        width: double.infinity,
                      ),
                    ),
                  ),

                  Center(
                    child: SizedBox(
                      width: 320.79,
                      height: 190.67,
                      child: Image.asset(
                        'assets/img/Logo BN.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // BODY
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Text(
                    "Bienvenido a VetManager",
                    style: TextStyle(fontSize: 15, color: AppColores.negro),
                  ),
                  const SizedBox(height: 15),
                  //Boton
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Rutas.login );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColores.grisSuave,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Iniciar Sesión",
                        style: TextStyle(
                          //fontFamily: , //preguntar a jero
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColores.negro,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "¿No tienes cuenta?",
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 13),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Rutas.registro);
                    },
                    child: const Text(
                      'Registrate',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColores.textoPrincipal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurvaClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Línea vertical hasta donde empieza la curva en el lado izquierdo
    path.lineTo(0, size.height * 0.85);

    // Curva que sube hacia la derecha, generando un arco tipo “cuarto de círculo”
    // como en la referencia: más baja a la izquierda y más alta en la derecha.
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.0,
      size.width,
      size.height * 0.10,
    );

    // Cerramos el camino por la parte inferior
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
