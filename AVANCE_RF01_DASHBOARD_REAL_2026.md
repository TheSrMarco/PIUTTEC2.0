# PIUTTEC 2.0 — RF-01: Panel académico con indicadores registrados

## Implementación

- Django: `GET /api/dashboard/resumen/`, protegido por JWT. Aísla todos los
  indicadores al usuario autenticado. Reutiliza los modelos de `academia`,
  `agenda` y `solicitudes`; **no necesita nuevas migraciones**.
- Flutter: el menú **Inicio → Panel académico** recibe el `accessToken` de la
  sesión, consume el nuevo endpoint y ofrece actualización manual/deslizar.
- Vista previa: promedia las materias locales existentes (RF-02), lee la agenda
  local (RF-03) y contabiliza los horarios semanales; no conecta una API sin sesión.
- Notas sin calificación: quedan excluidas de la media. Si no hay ninguna,
  el promedio se muestra como `N/D`.
- Solicitudes: se muestran **pendientes** y **aprobadas**; no se afirma que
  una aprobación sea un préstamo activo.
- Próximas actividades: máximo cinco eventos/tareas/evaluaciones sin completar,
  con fecha de hoy en adelante. La cifra de actividades pendientes cuenta solo
  tareas y evaluaciones, sin mezclar eventos.
- Asistencia y archivos: `N/D`, porque el pase de lista y gestor actuales son
  locales y no tienen un backend de sincronización en Django. No se falsifican
  sus métricas.
- La API antigua de demostración permanece disponible solo en modo `DEBUG`
  para no romper integraciones anteriores, pero el dashboard nuevo **no la usa**.

## Pruebas añadidas (pendientes de ejecución en Windows)

- Backend: `backend/dashboard/tests.py`, ocho pruebas de autenticación,
  estadísticas, privacidad, filtros y orden temporal.
- Frontend: `dashboard_repository_test.dart` (cuatro pruebas),
  `dashboard_view_test.dart` (una prueba).

Desde `backend/`:

```powershell
.\.venv\Scripts\python.exe manage.py check
.\.venv\Scripts\python.exe manage.py test dashboard -v 2
.\.venv\Scripts\python.exe manage.py test -v 1
.\.venv\Scripts\python.exe manage.py runserver
```

Desde `frontend/`, en otra terminal:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port 5173
```

**No sobrescribir la instalación de Windows eliminando `.env`, `.venv` o
`db.sqlite3`.** Respaldar la carpeta actual primero y actualizar solo
archivos de código.

## Estado de validación

- ✅ Archivos fuente preservados; Python compila sintácticamente.
- ✅ No requiere nuevas migraciones.
- ⏳ Pruebas Django pendientes de ejecución en entorno con dependencias.
- ⏳ Análisis, pruebas y arranque Flutter pendientes de ejecutar con SDK.
- ⏳ Integración con asistencia y archivos sigue pendiente por carecer de API.
- ⏳ GitHub no se ha modificado en este avance.


> **Actualización posterior:** se integró el módulo de asistencias Django. La observación anterior sobre asistencia `N/D` corresponde a la versión RF-01 inicial; en la versión actual el dashboard calcula un porcentaje desde registros personales (si existen). La integración posterior **sí añade una migración**. Ver `AVANCE_ASISTENCIAS_DJANGO_2026.md`.
