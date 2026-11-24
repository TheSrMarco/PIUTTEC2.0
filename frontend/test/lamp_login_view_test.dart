import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piuttec_app/features/auth/ui/lamp_login_view.dart';

void main() {
  testWidgets('La pantalla abre demostración sin sesión real', (tester) async {
    var requested = false;
    await tester.pumpWidget(MaterialApp(home: LampLoginView(
      onAuthenticated: (_) {}, onDemo: () => requested = true,
    )));
    await tester.drag(find.byKey(const Key('lamp-pull-switch')), const Offset(0, 95));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vista previa'));
    expect(requested, isTrue);
  });

  testWidgets('El login ofrece registro real sin perder la cuerda', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LampLoginView(
      onAuthenticated: (_) {}, onDemo: () {},
    )));
    await tester.drag(find.byKey(const Key('lamp-pull-switch')), const Offset(0, 95));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('auth-open-registration')), findsOneWidget);
    await tester.tap(find.byKey(const Key('auth-open-registration')));
    await tester.pumpAndSettle();
    expect(find.text('Registro de estudiante'), findsOneWidget);
  });

  testWidgets('Al jalar la cuerda aparece el formulario', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LampLoginView(
      onAuthenticated: (_) {}, onDemo: () {},
    )));
    await tester.drag(find.byKey(const Key('lamp-pull-switch')), const Offset(0, 95));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Iniciar sesión'), findsOneWidget);
  });
}
