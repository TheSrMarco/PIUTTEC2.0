import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piuttec_app/app.dart';
import 'package:piuttec_app/features/learning/ui/learning_graph_view.dart';

void main() {
  testWidgets('Mi Neurona: muestra los doce temas y permite navegar por el mapa', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: LearningGraphView())));
    expect(find.text('Mi Neurona UTTEC'), findsOneWidget);
    expect(find.text('Redes neuronales'), findsWidgets);
    expect(find.byKey(const ValueKey('topic-heading')), findsOneWidget);
    await tester.tap(find.byTooltip('Ver mapa'));
    await tester.pumpAndSettle();
    expect(find.text('12 temas · 4 materias · 0 marcados como dominados'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Abrir Funciones matemáticas'));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const ValueKey('topic-heading'))).data,
        'Funciones matemáticas');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mi Neurona: los apuntes se conservan entre temas mientras está abierta', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: LearningGraphView())));
    final reader = find.descendant(
      of: find.byKey(const ValueKey('topic-reader')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('notes-9')), 350, scrollable: reader.first,
    );
    await tester.enterText(find.byKey(const ValueKey('notes-9')), 'Mis apuntes de prueba');
    await tester.tap(find.byKey(const ValueKey('topic-6')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('topic-9')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('notes-9')), 350, scrollable: reader.first,
    );
    final notes = tester.widget<TextField>(find.byKey(const ValueKey('notes-9')));
    expect(notes.controller!.text, 'Mis apuntes de prueba');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ruta original /neurona sigue disponible', (tester) async {
    await tester.pumpWidget(const PiuttecApp());
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/neurona');
    await tester.pumpAndSettle();
    expect(find.text('Mi Neurona UTTEC'), findsOneWidget);
    expect(find.byTooltip('Ver mapa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
