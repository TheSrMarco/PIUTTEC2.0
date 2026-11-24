import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piuttec_app/features/auth/ui/registration_view.dart';

void main() {
  testWidgets('El formulario de registro muestra aviso y consentimiento obligatorio', (tester) async {
    await tester.pumpWidget(MaterialApp(home: RegistrationView(onRegistered: (_) {})));
    expect(find.text('Registro de estudiante'), findsOneWidget);
    expect(find.byKey(const Key('register-username')), findsOneWidget);
    expect(find.byKey(const Key('register-password')), findsOneWidget);
    expect(find.text('Leer información de privacidad'), findsOneWidget);
    expect(find.byKey(const Key('register-privacy')), findsOneWidget);
  });
}
