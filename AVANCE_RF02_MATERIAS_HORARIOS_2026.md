# RF-02: Materias y horarios de clase · 23 de noviembre de 2026

## Alcance implementado en código

- [x] `Materia` asociada al usuario: nombre, docente, grupo, aula y calificación opcional 0–10.
- [x] `Horario` asociado a materia: día lunes–domingo, inicio, fin y aula.
- [x] CRUD protegido con JWT: `/api/materias/` y `/api/horarios/`.
- [x] Filtrado por usuario autenticado, con bloqueo de referencias a materias ajenas.
- [x] Validación de hora de inicio/fin y choques de clases del mismo usuario.
- [x] Migración `academia.0001_initial` y administración Django.
- [x] Interfaz Flutter editable para materias y horario semanal.
- [x] Modo vista previa con almacenamiento local; sin degradación silenciosa desde la API.
- [x] Calendario con clases recurrentes en vistas mes/semana/día.
- [x] Casos de prueba de API y repositorio Flutter **escritos**.

## Verificación pendiente

- [ ] `python manage.py check` y `python manage.py makemigrations --check --dry-run`.
- [ ] `python manage.py migrate` y `python manage.py test academia -v 2`.
- [ ] `flutter analyze` y `flutter test` sin errores.
- [ ] Crear materia, agregar clase, editar, borrar, recargar y confirmar persistencia.
- [ ] Probar permisos con dos usuarios y revisar que uno no consulte los datos del otro.
- [ ] Compilar la versión web y Android en los dispositivos elegidos.

## Restricciones explícitas

- Se muestran clases **semanales recurrentes**, sin calendario de inicio/fin de cuatrimestre,
  feriados ni suspensión de actividades. Esas reglas requieren otro avance.
- Las calificaciones son registros manuales de prueba, no información oficial de UTTEC.
- No se sincronizan los datos demo con cuentas autenticadas ni con el prototipo HTML heredado.
- No se alteraron los módulos anteriores de pase de lista, agenda, solicitudes, privacidad,
  lámpara, sonido, refuerzo académico o backend existente, salvo el menú y el calendario para
  conectar esta funcionalidad.
