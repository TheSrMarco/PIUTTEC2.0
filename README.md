# PIUTTEC (2.0)

[Historial de cambios](CHANGELOG.md)

<p align="center">
  <img src="docs/assets/piuttec-ii-logo.png" alt="Logo principal de PIUTTEC II" width="820">
</p>

<p align="center">
  <strong>Ícono para Android</strong><br>
  <img src="docs/assets/piuttec-ii-android.png" alt="Ícono de PIUTTEC II para Android" width="240">
</p>

Prototipo web de una plataforma de gestión académica, trámites institucionales y refuerzo del aprendizaje para la Universidad Tecnológica de Tecámac. El proyecto propone ampliar PIUTTEC para que estudiantes, docentes y personal administrativo puedan consultar información académica y gestionar solicitudes desde un mismo lugar.

## Cuentas reales y CRUD (nueva integración)

- **Registro de estudiante** desde la lámpara Flutter: se crea un usuario Django con contraseña hasheada, validación de datos y aceptación obligatoria del aviso.
- **Login JWT** real; renovación, cierre de sesión con revocación de refresh y control de permisos.
- **Mi perfil (CRUD)**: consultar, editar datos personales, cambiar contraseña y eliminar/anonimizar cuenta.
- **Gestión de usuarios** para administradores: crear, consultar, editar rol/estado y eliminar cuentas.
- La pantalla de privacidad, el pase de lista, el calendario y los módulos existentes se conservan.
- [Guía de autenticación, endpoints y pruebas](docs/guias/GUIA_LOGIN_REGISTRO_CRUD.md).
- **Pendiente de certificar:** ejecutar pruebas Django y Flutter en Windows; no se ha realizado push a GitHub.

## Entrega integral del prototipo — noviembre de 2026

Esta versión parte de la última entrega de asistencias Django e incorpora catálogo de recursos, revisión administrativa y devolución, justificantes asociados a faltas, gestor privado de archivos, progreso y bancos de refuerzo, perfil JWT y renovación, pruebas por módulo, CI y configuración local con Docker/PostgreSQL. **La integración es código del prototipo académico: faltan validación Flutter/Django en Windows, PostgreSQL real y despliegue público.**

- [Guía exacta para Windows](docs/guias/GUIA_EJECUCION_FINAL.md)
- [Matriz de cierre RF-01 a RF-13 y RNF-01 a RNF-12](docs/guias/CIERRE_ACADEMICO_RF_RNF.md)
- Ejecutar pruebas y guardar evidencia: `powershell -ExecutionPolicy Bypass -File .\VERIFICAR_PIUTTEC.ps1`.
- Las funciones de directorio docente y avisos programados siguen siendo demostrativas/parciales. No introducir datos institucionales reales sin autorización.

---

## Qué incluye el prototipo

- Panel con indicadores académicos, materias inscritas, asistencias y clases del día.
- Agenda de entregas y evaluaciones.
- Simulación de reservas de salones y laboratorios y de préstamos de equipos.
- Gestor de archivos simulado, directorio docente y calculadora de promedio.
- **Refuerzo Académico** con una práctica de tres preguntas sobre fundamentos de redes digitales, puntuación y explicación de cada respuesta.

## Cómo probarlo

Abre [el archivo HTML](portal_de_gesti_n_acad_mica_e_institucional.html) en un navegador. La página carga Tailwind CSS, Font Awesome e Inter desde internet. Usa datos de demostración y guarda los cambios de los módulos existentes en el almacenamiento local del navegador. La práctica de refuerzo se puede reiniciar en cualquier momento.

## Alcance documentado

La propuesta contempla un panel de rendimiento académico, horarios y calendario, comparación del rendimiento del estudiante con el promedio grupal y seguimiento de solicitudes de laboratorios, equipos y justificantes. El módulo de refuerzo contempla ejercicios organizados por carrera, cuatrimestre y parcial, seguimiento del progreso, retos, logros y recordatorios.

La arquitectura prevista usa **Flutter y Dart** para web, Android e iOS, **Django y Django REST Framework** para la API y **PostgreSQL** para los datos. El acceso institucional contempla autenticación con JWT y permisos para estudiantes, docentes y administradores. El repositorio conserva el prototipo HTML e incorpora una primera base local de Flutter y Django.

## Desarrollo local

La demo HTML se abre como antes desde la raíz. La base de la aplicación está en frontend/ y la API en backend/.

La API incluye autenticación JWT con usuario y contraseña, renovación del token, un usuario con campo de rol institucional y un panel de demostración disponible durante el desarrollo. La interfaz Flutter ahora incluye pantalla de acceso con lámpara, calendario y navegación adaptable. La autenticación JWT básica está conectada al acceso y a solicitudes RF-12; otras operaciones y permisos institucionales siguen incompletos.

### Servidor en Windows

~~~powershell
cd backend
python -m venv .venv
.venv/Scripts/python.exe -m pip install -r requirements.txt
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
.venv/Scripts/python.exe manage.py migrate
.venv/Scripts/python.exe manage.py runserver
~~~

El entorno usa SQLite de forma predeterminada para iniciar el desarrollo. Para usar PostgreSQL, crea una base y configura DB_ENGINE=postgres y las variables PG* en backend/.env antes de ejecutar las migraciones. Configura una DJANGO_SECRET_KEY estable en ese archivo si vas a trabajar con sesiones entre reinicios. El archivo .env y la base local quedan excluidos de Git.

Para crear una cuenta local usa .venv/Scripts/python.exe manage.py createsuperuser. El administrador de Django está en http://127.0.0.1:8000/admin/. Los roles institucionales se asignan allí, mientras que los permisos específicos de negocio se incorporarán al implementar los módulos.

### Aplicación en otra terminal

~~~powershell
cd frontend
flutter pub get
flutter run -d chrome --web-port 5173
~~~

El panel académico Flutter autenticado consulta `/api/dashboard/resumen/` mediante JWT y muestra datos registrados en materias, agenda, horarios y solicitudes. En Vista previa resume únicamente los registros locales del navegador. La antigua ruta `/api/demo/dashboard/` se conserva solo en `DEBUG` por compatibilidad, pero el panel Flutter ya no la consulta. La API de autenticación está en `/api/auth/login/` y `/api/auth/refresh/`. Los módulos RF-02, RF-03, RF-04 y RF-12 tienen endpoints propios protegidos; los demás servicios siguen sujetos a desarrollo.

### Verificación

~~~powershell
cd backend
.venv/Scripts/python.exe manage.py check
.venv/Scripts/python.exe manage.py makemigrations --check --dry-run
cd ../frontend
flutter analyze
flutter build web
~~~

## Equipo

- Marco Antonio Vázquez López
- Yoshiro Pablo Armando Riaño Ishiuara
- Gabriel Arturo Najera Esparza
- Luis Felipe Ambrosio Velazquez
- Francisco Hernandez Antonio

Este es un documento para buenas practicas


## Versión integral de interfaces (consolidación local, 23/11/2026)

Esta carpeta incluye **todo el repositorio original** más las integraciones de interfaz y RF-12 descritas a continuación. No es un instalador de parches y no representa un push a GitHub.

- **Acceso Flutter:** jala la cuerda de la lámpara para mostrar el formulario; usa el sonido original de `https://assets.codepen.io/605876/click.mp3` (requiere conexión y disponibilidad del servicio), sin sustituirlo por otro efecto. El acceso con usuario/contraseña llama a `POST /api/auth/login/` (JWT de Django); también existe un modo de presentación sin autenticación.
- **Marca local:** `frontend/assets/branding/piuttec-ii-logo.png`, copiada de `docs/assets/piuttec-ii-logo.png`. El propio logo incluye el nombre, por eso no se duplica en el encabezado.
- **Privacidad:** al ingresar se solicita aceptación explícita del aviso antes del calendario. No sustituye un proceso de consentimiento validado por la universidad.
- **Calendario:** vista Mes/Semana/Día al iniciar. Actualmente muestra eventos de ejemplo y no hay sincronización institucional.
- **Menú:** agrupaciones desplegables solo para módulos contemplados en la memoria del proyecto. No se incluyen páginas ni redirecciones de Educación Dual, titulación, adeudos, encuestas, etc.
- **Interfaces Flutter:** materias, asistencia, agenda, archivos, recursos, justificantes, comparativo y refuerzo académico. Las que no usan endpoints reales son demostraciones de interfaz.
- **RF-12:** `backend/solicitudes/` incluye modelos, migración, serializers, vistas, permisos, pruebas y rutas REST protegidas. La pantalla Flutter usa el **mismo JWT del login general**, sin pedir segunda contraseña. La cuenta de demostración no puede crear solicitudes reales.
- **WebGL:** `frontend/web/bienvenida-fluid.html` contiene una página opcional para navegadores y no reemplaza Flutter.

### Ejecutar el backend en Windows

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
.\.venv\Scripts\python.exe manage.py migrate
.\.venv\Scripts\python.exe manage.py test solicitudes -v 2
.\.venv\Scripts\python.exe manage.py runserver
```

Si `.env` ya existe, **conserva su contenido** y no lo sobrescribas. SQLite se usa por defecto; la configuración PostgreSQL se incluye, pero falta validarla contra una instancia real.

### Ejecutar Flutter en una segunda terminal

```powershell
cd frontend
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port 5173
```

El acceso de prueba necesita un usuario Django (puedes crear uno con `python manage.py createsuperuser`). Para Android Emulator, configura `--dart-define=API_BASE_URL=http://10.0.2.2:8000/api/`.

### Vista previa

Abre `VISTA_PREVIA.html` desde esta misma carpeta, con sus recursos locales en `docs/assets/`. La vista previa es independiente de la app Flutter y no autentica usuarios.

### Límites de verificación

Este paquete se integró y se revisó de forma estática, pero **no se ejecutaron** `flutter analyze`, `flutter test` ni los tests Django en el entorno de generación. Ver [Estado historico de integracion](CHANGELOG.md#estado-pruebas).


## Avance RF-03: Agenda y calendario integrados

La vista **Agenda, tareas y evaluaciones** ahora tiene CRUD de tareas, evaluaciones y eventos, marcación de completadas y filtros. Las actividades se muestran también en el **Calendario**. En modo autenticado se persisten por usuario en la API Django `/api/agenda/`; en modo demostración el almacenamiento es local al navegador.

Después de actualizar el proyecto, ejecuta `python manage.py migrate` en `backend` y `flutter pub get` en `frontend`. Consulta [AVANCE_RF03_AGENDA_2026.md](CHANGELOG.md#rf-03-agenda) para pruebas y estado técnico.

## RF-02 — Materias y horarios semanales (23/11/2026)

- Django: endpoints JWT `GET/POST /api/materias/` y `GET/POST /api/horarios/`,
  con `GET/PATCH/DELETE /api/{recurso}/{id}/` para registros propios.
- Flutter: **Academia → Materias y calificaciones / Horario de clases**.
  Permite crear, editar, eliminar y consultar materias, calificación opcional (0–10),
  horarios recurrentes por día, horas y aula. El calendario muestra las clases semanales.
- Vista previa: persiste en el almacenamiento local del navegador, no en la base Django.
  Autenticación: la información se guarda en la cuenta mediante JWT.
- La regla de colisiones impide registrar clases traslapadas del mismo usuario.
- Las clases se repiten semanalmente sin un periodo escolar configurado. Este módulo
  **no modifica** los datos académicos institucionales ni las asistencias existentes.
- Verifica desde backend: `python manage.py migrate`, `python manage.py test academia -v 2`.
- Verifica desde frontend: `flutter analyze`, `flutter test`, `flutter run -d chrome --web-port 5173`.
- Consulta [RF-02: materias y horarios](CHANGELOG.md#rf-02-materias-horarios) para el detalle y límites.

## RF-04 — Comparativo de rendimiento académico

- En Flutter: **Academia → Comparativo académico**, con promedio personal, notas por materia y media grupal cuando existen al menos cinco cuentas de estudiante registradas en el mismo grupo/materia.
- En Django: `GET /api/rendimiento/` con JWT. Reutiliza `Materia` de RF-02, sin migración nueva.
- La vista previa solo utiliza notas personales del almacenamiento local. **No se inventa una media grupal**.
- Las notas y grupos registrados son de prueba, no calificaciones oficiales validadas por UTTEC. No consultar información real de estudiantes sin autorización institucional.
- Para los comandos y límites: [AVANCE_RF04_RENDIMIENTO_ACADEMICO_2026.md](CHANGELOG.md#rf-04-rendimiento).


## RF-01 — Panel académico con datos registrados (23/11/2026)

El menú **Inicio → Panel académico** muestra materias, promedio de las notas disponibles, tareas y evaluaciones pendientes/completadas, clases semanales y estados de solicitudes (solo con cuenta de Django). Las próximas cinco actividades se obtienen de la agenda. En **Vista previa**, se calculan promedios y recuentos usando el almacenamiento local; los estados de solicitudes no se inventan. **Asistencia** y **Archivos** muestran `N/D` porque sus módulos actuales no tienen fuente sincronizada en Django.

- API: `GET /api/dashboard/resumen/` (JWT obligatorio, registros del usuario).
- No requiere migración adicional.
- Ver detalles y pruebas pendientes en [[RF-01: panel academico](CHANGELOG.md#rf-01-panel)](CHANGELOG.md#rf-01-panel).


## Pase de lista persistente en Django (integración posterior a RF-01)

Con sesión JWT, **Academia → Pase de lista y asistencias** muestra las materias registradas en RF-02 y guarda P/R/J/F por materia y fecha mediante `/api/asistencias/`. Puede corregir o eliminar marcas, consultar historial y marcar todas las materias como presentes. Los registros se aíslan por cuenta; Django exige una única marca por materia y día. **No son asistencias oficiales verificadas por la UTTEC**, sino registros personales para probar el sistema.

El panel RF-01 puede calcular el porcentaje a partir de esos registros; sin registros muestra `N/D`. En Vista previa se conserva el pase de lista local anterior, sin importar sus ejemplos a la cuenta Django. Consulta [Asistencias y dashboard Django](CHANGELOG.md#asistencias-django) para endpoints, migración y pruebas.


## Mi Neurona UTTEC (restaurada de la rama feature/neurona-uttec-demo)

Está disponible en **Aprendizaje → Mi Neurona UTTEC** y en la ruta Flutter `/neurona`.
Contiene doce temas conectados de Redes digitales, Programación, Matemáticas e Inteligencia artificial,
con explicaciones, ejemplos, mapa interactivo, apuntes personales temporales y autoevaluación.
**No es una red neuronal entrenada ni usa TensorFlow**: es un mapa conceptual de aprendizaje.
Los apuntes se conservan mientras la vista permanezca abierta y se reinician al salir o recargar.
Más información y pruebas: [Recuperacion de Mi Neurona UTTEC](CHANGELOG.md#mi-neurona).


## Privacidad específica del prototipo (23/11/2026)

La información de privacidad que aparece en Flutter y en el portal HTML distingue
la instancia académica de los sistemas oficiales de UTTEC. No utilizar datos
personales reales hasta identificar un responsable del despliegue y validar
el aviso aplicable. Consulta [Privacidad del prototipo](CHANGELOG.md#privacidad)
y `docs/guias/PLAN_DESPLIEGUE_PIUTTEC_2026.md` antes de publicar.
