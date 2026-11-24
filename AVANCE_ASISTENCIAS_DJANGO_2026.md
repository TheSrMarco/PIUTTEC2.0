# Avance: pase de lista con persistencia Django y cálculo en el dashboard

## Alcance real

El pase de lista ahora distingue **dos modos**:

- **Vista previa (sin JWT):** conserva el componente Flutter anterior, sus seis materias de ejemplo, botones P/R/J/F, historial y datos en `shared_preferences`. **No se migra ni se mezcla** con Django. El prototipo HTML original tampoco se modificó.
- **Cuenta autenticada en Django:** usa materias **reales de esa cuenta** registradas en Academia, guarda una única marca por materia y fecha, permite corregir o borrar y muestra historial. Los cambios persisten en la base Django.

**Importante:** es un **registro personal de práctica**; no existe verificación institucional ni un flujo de aprobación docente, por lo que no debe presentarse como pase de lista oficial de la UTTEC.

## Endpoint nuevo

JWT en `Authorization: Bearer <access_token>`:

- `GET /api/asistencias/` — historial propio; admite `?materia=ID` y `?fecha=AAAA-MM-DD`.
- `POST /api/asistencias/` — `{"materia": 1, "fecha": "2026-11-22", "estado": "P"}`.
- `PATCH /api/asistencias/{id}/` — p. ej. `{"estado": "J"}` para corregir una marca existente.
- `DELETE /api/asistencias/{id}/` — elimina una marca propia.
- `POST /api/asistencias/marcar-todas/` — `{"fecha":"2026-11-22", "materias":[1,2,3]}`; registra o actualiza **todas a P** dentro de una transacción atómica. Rechaza lotes con materias ajenas.

Reglas del servidor: JWT obligatorio; acceso exclusivo a registros y materias del usuario; estados `P`, `R`, `J`, `F`; fechas futuras rechazadas; una fila por usuario/materia/fecha (restricción única de base de datos). El servidor también impide duplicaciones por API.

## RF-01: asistencia personal en el panel

`GET /api/dashboard/resumen/` devuelve:

- `attendance`: porcentaje **solo si hay registros**, en caso contrario `null`.
- `attendance_records`: total de registros de materia-día de la cuenta.

Se preserva la **misma fórmula del pase de lista Flutter original**:

`equivalentes = P + J + R - floor(R/3)`

`porcentaje = redondear(100 * equivalentes / (P+R+J+F))`

Es una métrica de práctica, **no un indicador académico institucional validado**. El Dashboard en Vista previa mantiene N/D porque su historial local de ejemplo no es fiable como dato académico.

## Actualizar en Windows sin borrar datos

1. Detén Flutter con `q` y Django con `Ctrl+C`.
2. **Haz una copia de seguridad** de `backend/db.sqlite3` y `backend/.env` antes de sobrescribir el proyecto.
3. Extrae el ZIP completo en tu carpeta de prueba; no borres `.venv`, `.env` ni `db.sqlite3`.
4. En `backend/` ejecuta:

```powershell
.\.venv\Scripts\python.exe manage.py migrate
.\.venv\Scripts\python.exe manage.py check
.\.venv\Scripts\python.exe manage.py makemigrations --check --dry-run
.\.venv\Scripts\python.exe manage.py test asistencias dashboard -v 2
.\.venv\Scripts\python.exe manage.py runserver
```

5. En otra terminal, `frontend/`:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port 5173
```

6. Inicia sesión con la cuenta Django, registra una materia, entra en **Academia → Pase de lista y asistencias**, selecciona una fecha y guarda P/R/J/F. Revisa **Inicio → Panel académico → Actualizar datos**. Comprueba que, con otra cuenta, los registros no aparezcan.

## Pruebas

Incluye `backend/asistencias/tests.py`, `frontend/test/attendance_repository_test.dart` y `frontend/test/attendance_local_compatibility_test.dart`. Son **pruebas escritas, pendientes de ejecución** en un entorno con Django y Flutter instalados. La sintaxis de los archivos Python y la integridad ZIP se revisaron por separado; no implican que todas las pruebas hayan pasado.

## Conservación

No se eliminan archivos originales. Se mantienen lámpara verde y sonido, login JWT, aviso de privacidad, calendario, RF-01, RF-02, RF-03, RF-04, RF-12, refuerzo, backend, Flutter y prototipo HTML. El pase local y las asistencias Django **son almacenes distintos**, deliberadamente.
