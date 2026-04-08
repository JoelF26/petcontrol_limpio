import 'package:flutter_test/flutter_test.dart';
import 'package:petcontrol_limpio/app.dart';

void main() {
  testWidgets('muestra pantalla de bienvenida', (WidgetTester tester) async {
    await tester.pumpWidget(const PetControlApp());

    expect(find.text('PetControl'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
