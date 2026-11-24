# PIUTTEC 2.0 · Avance de RF-03: Agenda y tareas

## Funcionalidades nuevas

1. **Agenda**: crear, consultar, editar, marcar como completadas, filtrar y eliminar tareas, evaluaciones y eventos. Permite materia, descripción, fecha y hora opcional.
2. **Calendario**: muestra las actividades registradas en las vistas de mes, semana y día. El icono de actualizar recarga los datos. En vista previa conserva los tres eventos ilustrativos anteriores, identificados como ejemplos. Al iniciar sesión en Django muestra solo las actividades del usuario autenticado.
3. **Persistencia**: con JWT los datos se guardan en la API Django (`/api/agenda/`); en vista previa se guardan **solo en ese navegador** con `shared_preferences`. Si falla Django no se guardan silenciosamente en modo demo.
4. **Privacidad**: cada usuario autenticado puede consultar, actualizar y borrar únicamente sus actividades. No se incorporan materias/calificaciones institucionales reales ni notificaciones automáticas.

## Archivos añadidos

- `backend/agenda/models.py`: modelo `Actividad`, asociado al usuario institucional.
- `backend/agenda/serializers.py`, `views.py`, `urls.py`, `admin.py`: REST y panel Django.
- `backend/agenda/migrations/0001_initial.py`: migración de agenda.
- `backend/agenda/tests.py`: 15 pruebas de autenticación, privacidad, CRUD y filtros.
- `frontend/lib/features/agenda/data/agenda_repository.dart`: cliente REST y almacenamiento de demostración.
- `frontend/lib/features/agenda/ui/agenda_view.dart`: interfaz Flutter de agenda.
- `frontend/test/agenda_repository_test.dart`: tres pruebas de persistencia local y JWT.

## Archivos modificados

- `backend/config/settings.py`: se registra la aplicación `agenda`.
- `backend/config/urls.py`: se publica `/api/agenda/`.
- `frontend/lib/features/shell/ui/app_shell.dart`: el menú Agenda abre la nueva interfaz y pasa el JWT; el calendario comparte el JWT.
- `frontend/lib/features/calendar/ui/calendar_view.dart`: incluye las actividades guardadas por el usuario.

## Puesta en marcha (en tu instalación existente)

Con Django detenido temporalmente y desde `backend`:

```powershell
.\.venv\Scripts\python.exe manage.py migrate
.\.venv\Scripts\python.exe manage.py check
.\.venv\Scripts\python.exe manage.py test agenda solicitudes -v 2
.\.venv\Scripts\python.exe manage.py runserver
```

En otra terminal, desde `frontend`:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port 5173
```

Abre **Agenda, tareas y evaluaciones → Nueva actividad**. Prueba crear una tarea para una fecha futura, marcarla como completada y comprobar su aparición en **Calendario**. En modo autenticado verifica también el historial del usuario en la API con la sesión JWT.

## Estado de validación

- Código Python: **sintaxis verificada** mediante `compileall`.
- Integridad de carpetas y ZIP: **verificación estructural**.
- Pruebas Django y Flutter: **pendientes de ejecución real en Windows**. Este entorno no tenía acceso a dependencias Django ni al SDK Flutter. Las pruebas incluidas no se consideran aprobadas sin ejecución.

## Requisitos que siguen abiertos

- **RF-01/RF-02**: obtener materias, asistencias y horarios desde datos institucionales; todavía son demos o guardado local.
- **RF-05/RF-06/RF-12**: verificación integral de solicitudes con los permisos correctos; el backend RF-12 no se modificó en este avance.
- **RNF-04**: PostgreSQL efectivo, si se decide migrar del SQLite local.
- **RNF-11**: evidencias de ejecución de pruebas.
- **RNF-12**: despliegue y HTTPS.
