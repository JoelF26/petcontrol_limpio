import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:petcontrol_limpio/app.dart';

void main() {
  testWidgets('muestra pantalla de bienvenida', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const PetControlApp());

    expect(find.text('Bienvenido a VetManager'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
