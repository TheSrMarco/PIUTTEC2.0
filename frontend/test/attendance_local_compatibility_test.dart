import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piuttec_app/features/attendance/ui/attendance_view.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Vista previa conserva el pase de lista original y estados P/R/J/F', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AttendanceView())));
    await tester.pumpAndSettle();
    expect(find.text('Pase de lista'), findsOneWidget);
    expect(find.text('Bases de Datos Distribuidas'), findsOneWidget);
    expect(find.byKey(const Key('attendance-P-0')), findsOneWidget);
    expect(find.byKey(const Key('attendance-R-0')), findsOneWidget);
    expect(find.byKey(const Key('attendance-J-0')), findsOneWidget);
    expect(find.byKey(const Key('attendance-F-0')), findsOneWidget);
  });
}
