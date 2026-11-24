import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piuttec_app/features/dashboard/ui/dashboard_view.dart';

void main() {
  testWidgets('Panel sin datos muestra N/D, nunca métricas de ejemplo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1440, 1250);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DashboardView())));
    await tester.pumpAndSettle();
    expect(find.text('Tu actividad académica'), findsOneWidget);
    expect(find.text('No hay materias registradas. Añádelas en Academia → Materias y calificaciones.'),
      findsOneWidget);
    expect(find.text('9.1'), findsNothing);
    expect(find.text('91%'), findsNothing);
    expect(find.text('N/D'), findsWidgets);
  });
}
