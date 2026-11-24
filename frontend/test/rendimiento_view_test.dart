import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piuttec_app/features/rendimiento/ui/rendimiento_view.dart';

void main() {
  testWidgets('La vista de rendimiento muestra estado sin materias', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: RendimientoView())));
    await tester.pumpAndSettle();
    expect(find.text('Mi rendimiento'), findsOneWidget);
    expect(find.textContaining('Aún no registras materias'), findsOneWidget);
    expect(find.text('Promedio personal'), findsOneWidget);
  });
}
