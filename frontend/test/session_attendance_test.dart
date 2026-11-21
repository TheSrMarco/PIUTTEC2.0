import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:piuttec_app/core/network/api_client.dart';
import 'package:piuttec_app/features/auth/data/session_controller.dart';
import 'package:piuttec_app/features/auth/ui/login_view.dart';
import 'package:piuttec_app/features/attendance/ui/attendance_view.dart';
import 'package:piuttec_app/features/attendance/ui/attendance_view_model.dart';

http.Response reply(Map<String, dynamic> body, [int status = 200]) =>
    http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

const courses = {
  'courses': [
    {'id': 1, 'name': 'Redes', 'group': 'DEMO', 'period': '2026-3'},
  ],
};

Map<String, dynamic> day({String? firstStatus, int version = 0}) => {
  'can_edit': true,
  'students': [
    {
      'enrollment_id': 1,
      'name': 'Estudiante Uno',
      'student_code': 'E01',
      'status': firstStatus,
      'note': '',
      'time_in': null,
      'version': version,
    },
    {
      'enrollment_id': 2,
      'name': 'Estudiante Dos',
      'student_code': 'E02',
      'status': 'absent',
      'note': 'Avisó al docente',
      'time_in': null,
      'version': 1,
    },
  ],
};

void main() {
  test(
    'cerrar la sesión cancela un inicio de sesión que sigue en curso',
    () async {
      final pending = Completer<http.Response>();
      final session = SessionController(
        client: MockClient((_) => pending.future),
      );
      addTearDown(session.dispose);
      final login = session.login('docente', 'Test-only-984!');
      final canceled = expectLater(login, throwsStateError);
      session.logout();
      pending.complete(reply({'access': 'old', 'refresh': 'old-refresh'}));
      await canceled;
      expect(session.user, isNull);
    },
  );
  test(
    'renueva el token y deja de enviar credenciales al cerrar la sesión',
    () async {
      var refreshes = 0;
      String? lastAuthorization;
      final client = MockClient((request) async {
        if (request.url.path.endsWith('/auth/refresh/')) {
          refreshes++;
          return reply({'access': 'fresh'});
        }
        lastAuthorization = request.headers['Authorization'];
        if (lastAuthorization == 'Bearer expired') {
          return reply({'detail': 'expired'}, 401);
        }
        return reply({'ok': true});
      });
      addTearDown(client.close);
      final api = ApiClient(client)..setSession('expired', 'refresh');
      expect(await api.get('courses/'), {'ok': true});
      expect(refreshes, 1);
      expect(lastAuthorization, 'Bearer fresh');
      api.clearSession();
      await api.get('courses/');
      expect(lastAuthorization, isNull);
    },
  );

  test(
    'el marcado masivo conserva faltas y un conflicto conserva la edición',
    () async {
      var conflict = true;
      Map<String, dynamic>? saved;
      final client = MockClient((request) async {
        if (request.url.path.endsWith('/courses/')) return reply(courses);
        if (request.method == 'POST') {
          saved = jsonDecode(request.body) as Map<String, dynamic>;
          if (conflict) return reply({'detail': 'La lista cambió.'}, 409);
          return reply(day(firstStatus: 'present', version: 1));
        }
        return reply(day());
      });
      addTearDown(client.close);
      final model = AttendanceViewModel(ApiClient(client));
      addTearDown(model.dispose);
      await model.loadCourses();
      model.markPendingPresent();
      expect(model.rows.map((row) => row.status), ['present', 'absent']);
      expect(model.rows[1].note, 'Avisó al docente');
      await model.save();
      expect(model.dirty, true);
      expect(model.error, 'La lista cambió.');
      expect((saved!['records'] as List).last['status'], 'absent');
      conflict = false;
      await model.save();
      expect(model.dirty, false);
      expect(model.error, isNull);
      expect(model.rows.first.version, 1);
    },
  );

  testWidgets('inicia sesión y guarda asistencia desde una pantalla móvil', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var loggedIn = false;
    Map<String, dynamic>? saved;
    final session = SessionController(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/auth/login/')) {
          expect(jsonDecode(request.body)['username'], 'docente');
          return reply({'access': 'access', 'refresh': 'refresh'});
        }
        expect(request.headers['Authorization'], 'Bearer access');
        if (request.url.path.endsWith('/auth/me/')) {
          return reply({'id': 1, 'name': 'Docente', 'role': 'teacher'});
        }
        if (request.url.path.endsWith('/courses/')) return reply(courses);
        if (request.method == 'POST') {
          saved = jsonDecode(request.body) as Map<String, dynamic>;
          return reply(day(firstStatus: 'present', version: 1));
        }
        return reply(day());
      }),
    );
    addTearDown(session.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: LoginView(
          session: session,
          onLoggedIn: () => loggedIn = true,
          onBack: () {},
        ),
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Usuario'),
      'docente',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      'Test-only-984!',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(loggedIn, true);
    expect(session.user!.name, 'Docente');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AttendanceView(
            api: session.api,
            authenticated: true,
            onSignIn: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marcar pendientes como presentes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar asistencias'));
    await tester.pumpAndSettle();
    expect(saved, isNotNull);
    expect((saved!['records'] as List).first['status'], 'present');
    expect((saved!['records'] as List).last['status'], 'absent');
    expect(find.text('Asistencias guardadas'), findsOneWidget);
    session.logout();
    expect(session.user, isNull);
  });
}
