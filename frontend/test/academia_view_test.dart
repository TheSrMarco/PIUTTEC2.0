import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piuttec_app/features/academia/ui/academia_view.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Se puede registrar una materia desde Flutter', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AcademiaView())));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('academia-crear-materia')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('materia-nombre')), 'Bases de datos');
    await tester.tap(find.byKey(const Key('materia-guardar')));
    await tester.pumpAndSettle();
    expect(find.text('Bases de datos'), findsOneWidget);
  });
}
