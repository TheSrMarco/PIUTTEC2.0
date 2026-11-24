import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piuttec_app/features/privacy/ui/privacy_gate_view.dart';

void main() {
  testWidgets('No se puede entrar antes de aceptar el aviso', (tester) async {
    var allowed = false;
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: PrivacyGateView(onAccepted: () => allowed = true, onBack: () {}),
    )));
    expect(tester.widget<FilledButton>(find.byKey(const Key('privacy-continue'))).onPressed, isNull);
    expect(allowed, isFalse);
  });

  testWidgets('La casilla habilita continuar al calendario', (tester) async {
    var allowed = false;
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: PrivacyGateView(onAccepted: () => allowed = true, onBack: () {}),
    )));
    await tester.tap(find.text('He leído la información de privacidad y comprendo que utilizo un prototipo académico.'));
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byKey(const Key('privacy-continue'))).onPressed, isNotNull);
    await tester.tap(find.byKey(const Key('privacy-continue')));
    expect(allowed, isTrue);
  });

  testWidgets('Volver al acceso no concede autorización', (tester) async {
    var cancelled = false;
    var allowed = false;
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: PrivacyGateView(onAccepted: () => allowed = true, onBack: () => cancelled = true),
    )));
    await tester.tap(find.widgetWithText(TextButton, 'Volver'));
    expect(cancelled, isTrue);
    expect(allowed, isFalse);
  });
}
