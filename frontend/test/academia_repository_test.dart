import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piuttec_app/features/academia/data/academia_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Materias y clases persisten en el almacenamiento de vista previa', () async {
    final store = AcademiaRepository();
    final materia = await store.guardarMateria(const MateriaAcademica(
      id: 0, nombre: 'Física', docente: 'Docente de prueba', calificacion: 9.0));
    expect(materia.id, 1);
    final horario = await store.guardarHorario(ClaseHorario(
      id: 0, materiaId: materia.id, diaSemana: 1, inicio: '08:00', fin: '10:00'));
    expect(horario.id, 1);

    final second = AcademiaRepository();
    expect((await second.listarMaterias()).single.nombre, 'Física');
    expect((await second.listarHorarios()).single.materiaNombre, 'Física');
    expect((await second.listarHorarios()).single.ocurreEnFecha(DateTime(2026, 11, 23)), isTrue);
    expect((await second.listarHorarios()).single.ocurreEnFecha(DateTime(2026, 11, 24)), isFalse);
    store.dispose(); second.dispose();
  });

  test('No permite horarios traslapados en la vista previa', () async {
    final repo = AcademiaRepository();
    final materia = await repo.guardarMateria(const MateriaAcademica(id: 0, nombre: 'Química'));
    await repo.guardarHorario(ClaseHorario(id: 0, materiaId: materia.id,
      diaSemana: 2, inicio: '09:00', fin: '11:00'));
    await expectLater(repo.guardarHorario(ClaseHorario(id: 0, materiaId: materia.id,
      diaSemana: 2, inicio: '10:00', fin: '12:00')), throwsFormatException);
    expect((await repo.listarHorarios()).length, 1);
    repo.dispose();
  });

  test('Eliminar materia quita sus horarios locales', () async {
    final repo = AcademiaRepository();
    final materia = await repo.guardarMateria(const MateriaAcademica(id: 0, nombre: 'Redes'));
    await repo.guardarHorario(ClaseHorario(id: 0, materiaId: materia.id,
      diaSemana: 3, inicio: '09:00', fin: '10:00'));
    await repo.eliminarMateria(materia.id);
    expect(await repo.listarMaterias(), isEmpty);
    expect(await repo.listarHorarios(), isEmpty);
    repo.dispose();
  });

  test('La API remota utiliza JWT y no cae al almacenamiento demo ante fallo', () async {
    final client = MockClient((request) async {
      expect(request.headers['Authorization'], 'Bearer token-ejemplo');
      if (request.url.path.endsWith('/materias/')) {
        return http.Response(jsonEncode([
          {'id': 8, 'nombre': 'Base de datos', 'docente': '', 'grupo': '',
           'aula': '', 'calificacion': '9.00'}]), 200);
      }
      return http.Response('{}', 500);
    });
    final repo = AcademiaRepository(accessToken: 'token-ejemplo', client: client);
    expect((await repo.listarMaterias()).single.id, 8);
    await expectLater(repo.listarHorarios(), throwsFormatException);
    repo.dispose(); client.close();
  });
}
