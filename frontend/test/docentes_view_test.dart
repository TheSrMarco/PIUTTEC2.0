import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piuttec_app/features/docentes/ui/docentes_view.dart';

void main() {
  testWidgets('Directorio usa docentes registrados; no inventa contactos', (tester) async {
    SharedPreferences.setMockInitialValues({
      'piuttec_rf02_materias_demo_v1': jsonEncode([
        {'id': 1, 'nombre': 'Programación', 'docente': 'Profesora Demo',
         'grupo': '9IDS', 'aula': 'A', 'calificacion': null},
        {'id': 2, 'nombre': 'SQL', 'docente': 'Profesora Demo',
         'grupo': '9IDS', 'aula': 'B', 'calificacion': null},
      ]),
    });
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DocentesView())));
    await tester.pumpAndSettle();
    expect(find.text('Profesora Demo'), findsOneWidget);
    expect(find.text('Materias: Programación, SQL'), findsOneWidget);
  });
}
