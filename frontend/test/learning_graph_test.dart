import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piuttec_app/app.dart';

void main() {
  for (final width in [1280.0, 390.0]) {
    testWidgets('apuntes por tema y navegación conectada a $width px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(const PiuttecApp());
        tester
            .state<NavigatorState>(find.byType(Navigator))
            .pushNamed('/neurona');
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel('Logo PIUTTEC II'), findsOneWidget);
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('topic-heading'))).data,
          'Redes neuronales',
        );
        final reader = find.descendant(
          of: find.byKey(const ValueKey('topic-reader')),
          matching: find.byType(Scrollable),
        );
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('notes-9')),
          400,
          scrollable: reader.first,
        );
        await tester.enterText(
          find.byKey(const ValueKey('notes-9')),
          'Mis conexiones tienen pesos.',
        );
        await tester.ensureVisible(find.byType(Switch));
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Ver mapa'));
        await tester.pumpAndSettle();
        expect(
          find.text('12 temas · 4 materias · 1 marcados como dominados'),
          findsOneWidget,
        );
        await tester.tap(find.bySemanticsLabel('Abrir Funciones matemáticas'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('topic-heading'))).data,
          'Funciones matemáticas',
        );
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('notes-6')),
          400,
          scrollable: reader.first,
        );
        expect(
          tester
              .widget<TextField>(find.byKey(const ValueKey('notes-6')))
              .controller!
              .text,
          isEmpty,
        );
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('related-11')),
          -300,
          scrollable: reader.first,
        );
        await tester.ensureVisible(find.byKey(const ValueKey('related-11')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('related-11')));
        await tester.pumpAndSettle();
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('topic-heading'))).data,
          'Función de activación',
        );
        await tester.tap(find.byTooltip('Ver mapa'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Abrir Redes neuronales'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('notes-9')),
          400,
          scrollable: reader.first,
        );
        expect(
          tester
              .widget<TextField>(find.byKey(const ValueKey('notes-9')))
              .controller!
              .text,
          'Mis conexiones tienen pesos.',
        );
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    });
  }
}
