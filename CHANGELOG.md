# Historial de cambios de PIUTTEC 2.0

Este documento consolida las bitacoras de implementacion, avances, ajustes visuales y correcciones del prototipo academico.
Los registros originales reflejan su momento de redaccion; una nota historica de 'pruebas pendientes' no invalida verificaciones posteriores.

## Integracion de noviembre de 2026

- Pull Request #4 fusionado a `main` el 23 de noviembre de 2026 (hora de Mexico) / 24 de noviembre UTC, commit `92de98f`.
- Ultimo commit de correcciones antes de la fusion: `c57fb63`.
- Validacion local: 115 pruebas Django y 45 pruebas Flutter aprobadas; analisis Flutter sin problemas.
- Las cinco comprobaciones de GitHub Actions del PR #4 finalizaron satisfactoriamente.
- Esta evidencia valida el prototipo en CI, no implica autorizacion institucional de la UTTEC ni auditoria de seguridad de produccion.

## Registro consolidado por area

<a id="integracion-original"></a>
## Inventario de la integracion

_Documento original: [Inventario de la integracion](CHANGELOG.md#integracion-original). Conservado en el historial Git._

### Inventario de cambios respecto al ZIP recibido

Base: `PIUTTEC2.0-main.zip`, con la estructura original de GitHub. Este paquete consolidado **no incluye la carpeta `.git`**, porque un ZIP descargado de GitHub no contiene el historial.

Se aplicaron los componentes UI y RF-12 **directamente a una copia** de la base original. No es necesario ejecutar instaladores anteriores.

#### Archivos originales modificados

- `README.md`
- `backend/config/settings.py`
- `backend/config/urls.py`
- `frontend/README.md`
- `frontend/lib/app.dart`
- `frontend/lib/features/shell/ui/app_shell.dart`
- `frontend/pubspec.yaml`

#### Archivos nuevos

- `.github/workflows/rf12-backend.yml`
- [Estado historico de integracion](CHANGELOG.md#estado-pruebas)
- `VISTA_PREVIA.html`
- `backend/solicitudes/__init__.py`
- `backend/solicitudes/admin.py`
- `backend/solicitudes/migrations/0001_initial.py`
- `backend/solicitudes/migrations/__init__.py`
- `backend/solicitudes/models.py`
- `backend/solicitudes/serializers.py`
- `backend/solicitudes/tests.py`
- `backend/solicitudes/urls.py`
- `backend/solicitudes/views.py`
- `frontend/assets/branding/piuttec-ii-logo.png`
- `frontend/lib/features/auth/data/auth_session.dart`
- `frontend/lib/features/auth/ui/lamp_login_view.dart`
- `frontend/lib/features/calendar/ui/calendar_view.dart`
- `frontend/lib/features/demo/ui/demo_modules.dart`
- `frontend/lib/features/privacy/ui/privacy_gate_view.dart`
- `frontend/lib/features/solicitudes/data/solicitudes_repository.dart`
- `frontend/lib/features/solicitudes/ui/solicitudes_view.dart`
- `frontend/test/lamp_login_view_test.dart`
- `frontend/test/privacy_gate_view_test.dart`
- `frontend/web/assets/piuttec-ii-logo.png`
- `frontend/web/bienvenida-fluid.html`
- `frontend/web/fluid/LICENSE`
- `frontend/web/fluid/webgl-fluid.global.js`
- `frontend/web/fluid/webgl-fluid.js`

#### Archivos originales eliminados

(ninguno)

**Limitaciones:** no se ejecutó Flutter ni Django; sonido remoto original no distribuido localmente; la web `VISTA_PREVIA.html` es maqueta, no app Flutter; no se hizo push a GitHub.

---

<a id="rf-01-panel"></a>
## RF-01: panel academico

_Documento original: [RF-01: panel academico](CHANGELOG.md#rf-01-panel). Conservado en el historial Git._

### PIUTTEC 2.0 — RF-01: Panel académico con indicadores registrados

#### Implementación

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

#### Pruebas añadidas (pendientes de ejecución en Windows)

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

#### Estado de validación

- ✅ Archivos fuente preservados; Python compila sintácticamente.
- ✅ No requiere nuevas migraciones.
- ⏳ Pruebas Django pendientes de ejecución en entorno con dependencias.
- ⏳ Análisis, pruebas y arranque Flutter pendientes de ejecutar con SDK.
- ⏳ Integración con asistencia y archivos sigue pendiente por carecer de API.
- ⏳ GitHub no se ha modificado en este avance.


> **Actualización posterior:** se integró el módulo de asistencias Django. La observación anterior sobre asistencia `N/D` corresponde a la versión RF-01 inicial; en la versión actual el dashboard calcula un porcentaje desde registros personales (si existen). La integración posterior **sí añade una migración**. Ver [Asistencias y dashboard Django](CHANGELOG.md#asistencias-django).

---

<a id="rf-02-materias-horarios"></a>
## RF-02: materias y horarios

_Documento original: [RF-02: materias y horarios](CHANGELOG.md#rf-02-materias-horarios). Conservado en el historial Git._

### RF-02: Materias y horarios de clase · 23 de noviembre de 2026

#### Alcance implementado en código

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

#### Verificación pendiente

- [ ] `python manage.py check` y `python manage.py makemigrations --check --dry-run`.
- [ ] `python manage.py migrate` y `python manage.py test academia -v 2`.
- [ ] `flutter analyze` y `flutter test` sin errores.
- [ ] Crear materia, agregar clase, editar, borrar, recargar y confirmar persistencia.
- [ ] Probar permisos con dos usuarios y revisar que uno no consulte los datos del otro.
- [ ] Compilar la versión web y Android en los dispositivos elegidos.

#### Restricciones explícitas

- Se muestran clases **semanales recurrentes**, sin calendario de inicio/fin de cuatrimestre,
  feriados ni suspensión de actividades. Esas reglas requieren otro avance.
- Las calificaciones son registros manuales de prueba, no información oficial de UTTEC.
- No se sincronizan los datos demo con cuentas autenticadas ni con el prototipo HTML heredado.
- No se alteraron los módulos anteriores de pase de lista, agenda, solicitudes, privacidad,
  lámpara, sonido, refuerzo académico o backend existente, salvo el menú y el calendario para
  conectar esta funcionalidad.

---

<a id="rf-03-agenda"></a>
## RF-03: agenda y calendario

_Documento original: [RF-03: agenda y calendario](CHANGELOG.md#rf-03-agenda). Conservado en el historial Git._

### PIUTTEC 2.0 · Avance de RF-03: Agenda y tareas

#### Funcionalidades nuevas

1. **Agenda**: crear, consultar, editar, marcar como completadas, filtrar y eliminar tareas, evaluaciones y eventos. Permite materia, descripción, fecha y hora opcional.
2. **Calendario**: muestra las actividades registradas en las vistas de mes, semana y día. El icono de actualizar recarga los datos. En vista previa conserva los tres eventos ilustrativos anteriores, identificados como ejemplos. Al iniciar sesión en Django muestra solo las actividades del usuario autenticado.
3. **Persistencia**: con JWT los datos se guardan en la API Django (`/api/agenda/`); en vista previa se guardan **solo en ese navegador** con `shared_preferences`. Si falla Django no se guardan silenciosamente en modo demo.
4. **Privacidad**: cada usuario autenticado puede consultar, actualizar y borrar únicamente sus actividades. No se incorporan materias/calificaciones institucionales reales ni notificaciones automáticas.

#### Archivos añadidos

- `backend/agenda/models.py`: modelo `Actividad`, asociado al usuario institucional.
- `backend/agenda/serializers.py`, `views.py`, `urls.py`, `admin.py`: REST y panel Django.
- `backend/agenda/migrations/0001_initial.py`: migración de agenda.
- `backend/agenda/tests.py`: 15 pruebas de autenticación, privacidad, CRUD y filtros.
- `frontend/lib/features/agenda/data/agenda_repository.dart`: cliente REST y almacenamiento de demostración.
- `frontend/lib/features/agenda/ui/agenda_view.dart`: interfaz Flutter de agenda.
- `frontend/test/agenda_repository_test.dart`: tres pruebas de persistencia local y JWT.

#### Archivos modificados

- `backend/config/settings.py`: se registra la aplicación `agenda`.
- `backend/config/urls.py`: se publica `/api/agenda/`.
- `frontend/lib/features/shell/ui/app_shell.dart`: el menú Agenda abre la nueva interfaz y pasa el JWT; el calendario comparte el JWT.
- `frontend/lib/features/calendar/ui/calendar_view.dart`: incluye las actividades guardadas por el usuario.

#### Puesta en marcha (en tu instalación existente)

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

#### Estado de validación

- Código Python: **sintaxis verificada** mediante `compileall`.
- Integridad de carpetas y ZIP: **verificación estructural**.
- Pruebas Django y Flutter: **pendientes de ejecución real en Windows**. Este entorno no tenía acceso a dependencias Django ni al SDK Flutter. Las pruebas incluidas no se consideran aprobadas sin ejecución.

#### Requisitos que siguen abiertos

- **RF-01/RF-02**: obtener materias, asistencias y horarios desde datos institucionales; todavía son demos o guardado local.
- **RF-05/RF-06/RF-12**: verificación integral de solicitudes con los permisos correctos; el backend RF-12 no se modificó en este avance.
- **RNF-04**: PostgreSQL efectivo, si se decide migrar del SQLite local.
- **RNF-11**: evidencias de ejecución de pruebas.
- **RNF-12**: despliegue y HTTPS.

---

<a id="rf-04-rendimiento"></a>
## RF-04: rendimiento academico

_Documento original: [RF-04: rendimiento academico](CHANGELOG.md#rf-04-rendimiento). Conservado en el historial Git._

### RF-04: Rendimiento académico individual y comparativo grupal

**Base:** PIUTTEC 2.0 completo con RF-02 y RF-03. Este paquete añade código y pruebas, no representa un push a GitHub ni una aprobación de ejecución.

#### Funcionalidades implementadas en código

- [x] Endpoint `GET /api/rendimiento/` protegido con JWT (solo lectura).
- [x] Promedio **personal** calculado a partir de `Materia.calificacion` (escala 0–10).
- [x] Las materias sin calificación no se cuentan en el promedio.
- [x] Comparación **por materia y grupo** cuando existen **5 estudiantes distintos** con calificación registrada para ese grupo y nombre de materia.
- [x] Los registros duplicados del mismo estudiante cuentan **una vez**, mediante su promedio interno.
- [x] No se incluyen notas de docentes en la muestra estudiantil.
- [x] En la API no se devuelven calificaciones ni identificadores de otros estudiantes; con menos de 5 participantes tampoco se revela el tamaño del grupo.
- [x] Vista Flutter: **Academia → Comparativo académico**, con barra de la nota propia, barra de media grupal cuando procede y diferencia en puntos.
- [x] Vista previa: calcula únicamente los promedios del almacenamiento local de RF-02; sin datos grupales artificiales.
- [x] Separación de directorio docente como entrada independiente en el menú, sin eliminar su pantalla previa.
- [x] Pruebas añadidas: **11 Django** + **4 Flutter**; escritas, no ejecutadas en el entorno de preparación.
- [x] Sin nuevos modelos ni migraciones: se aprovecha `Materia` ya creada en RF-02.

#### Qué se entiende por "promedio grupal"

Se agrupan por **nombre de materia y código de grupo** (ignorando diferencias de mayúsculas y espacios) los valores registrados en el sistema por estudiantes de prueba. Cada cuenta aporta una media, de modo que duplicar una materia en un solo usuario no infla el número de participantes. Los registros no tienen verificación institucional de matrícula/grupo: por eso esta comparación es **orientativa, no oficial**. La media incluye la calificación propia.

**No hay calificaciones oficiales de la universidad ni comparación grupal en la vista previa.** Para mostrar la comparación autenticada se requieren cinco usuarios estudiantes reales/de prueba en la misma materia y grupo, con calificaciones registradas en `/api/materias/`. Si no se alcanza el umbral, la interfaz presenta un estado claro sin inventar cifras.

#### Pruebas en Windows

Después de actualizar el proyecto, desde su carpeta `backend`:

```powershell
.\.venv\Scripts\python.exe manage.py check
.\.venv\Scripts\python.exe manage.py migrate
.\.venv\Scripts\python.exe manage.py test academia -v 2
.\.venv\Scripts\python.exe manage.py makemigrations --check --dry-run
.\.venv\Scripts\python.exe manage.py runserver
```

Desde `frontend`, en otra terminal:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port 5173
```

##### Comprobación funcional

1. Entra a Flutter con un usuario Django y abre **Academia → Materias y calificaciones**.
2. Añade dos materias y sus calificaciones, por ejemplo 8 y 10. Ve a **Comparativo académico** y comprueba promedio personal 9.00.
3. Edita una calificación, vuelve al comparativo y pulsa **Actualizar rendimiento** para validar el recálculo.
4. Para la comparación por grupo, registra la **misma materia** y el **mismo código de grupo** en al menos cinco cuentas con rol estudiante. Con menos de cinco el promedio permanece oculto.
5. Accede con otra cuenta y verifica que no pueda leer las materias personales de la primera en `/api/materias/` o `/api/rendimiento/`.
6. En **Vista previa**, registra materias, revisa el promedio personal y verifica que el grupal aparezca como no disponible.

#### Pendientes técnicos / RNF

- [ ] Ejecutar realmente las 11 pruebas Django y las 4 Flutter nuevas.
- [ ] Probar `flutter analyze`, `flutter test` y `flutter build web` sin incidencias.
- [ ] Validar el endpoint con credenciales y probar la muestra de cinco cuentas.
- [ ] Conectar **grupos oficiales y calificaciones verificadas** (actualmente son capturas voluntarias de prueba).
- [ ] Validar rendimiento con muchos estudiantes (la consulta de agrupación es apropiada para piloto; requiere optimización antes de producción).
- [ ] Migrar de SQLite a PostgreSQL y comprobar una instancia real.
- [ ] Despliegue con HTTPS y pruebas de seguridad/autorización completas.

#### Conservación del trabajo previo

No se sustituyen: el logo, login con lámpara, sonido original, aviso de privacidad, pase de lista, calendario, CRUD de agenda, CRUD de materias y horarios, RF-12 solicitudes, refuerzo, backend Django ni configuración PostgreSQL. La única navegación modificada es la entrada del comparativo, más la conservación explícita del directorio docente bajo una entrada separada.

---

<a id="asistencias-django"></a>
## Asistencias y dashboard Django

_Documento original: [Asistencias y dashboard Django](CHANGELOG.md#asistencias-django). Conservado en el historial Git._

### Avance: pase de lista con persistencia Django y cálculo en el dashboard

#### Alcance real

El pase de lista ahora distingue **dos modos**:

- **Vista previa (sin JWT):** conserva el componente Flutter anterior, sus seis materias de ejemplo, botones P/R/J/F, historial y datos en `shared_preferences`. **No se migra ni se mezcla** con Django. El prototipo HTML original tampoco se modificó.
- **Cuenta autenticada en Django:** usa materias **reales de esa cuenta** registradas en Academia, guarda una única marca por materia y fecha, permite corregir o borrar y muestra historial. Los cambios persisten en la base Django.

**Importante:** es un **registro personal de práctica**; no existe verificación institucional ni un flujo de aprobación docente, por lo que no debe presentarse como pase de lista oficial de la UTTEC.

#### Endpoint nuevo

JWT en `Authorization: Bearer <access_token>`:

- `GET /api/asistencias/` — historial propio; admite `?materia=ID` y `?fecha=AAAA-MM-DD`.
- `POST /api/asistencias/` — `{"materia": 1, "fecha": "2026-11-22", "estado": "P"}`.
- `PATCH /api/asistencias/{id}/` — p. ej. `{"estado": "J"}` para corregir una marca existente.
- `DELETE /api/asistencias/{id}/` — elimina una marca propia.
- `POST /api/asistencias/marcar-todas/` — `{"fecha":"2026-11-22", "materias":[1,2,3]}`; registra o actualiza **todas a P** dentro de una transacción atómica. Rechaza lotes con materias ajenas.

Reglas del servidor: JWT obligatorio; acceso exclusivo a registros y materias del usuario; estados `P`, `R`, `J`, `F`; fechas futuras rechazadas; una fila por usuario/materia/fecha (restricción única de base de datos). El servidor también impide duplicaciones por API.

#### RF-01: asistencia personal en el panel

`GET /api/dashboard/resumen/` devuelve:

- `attendance`: porcentaje **solo si hay registros**, en caso contrario `null`.
- `attendance_records`: total de registros de materia-día de la cuenta.

Se preserva la **misma fórmula del pase de lista Flutter original**:

`equivalentes = P + J + R - floor(R/3)`

`porcentaje = redondear(100 * equivalentes / (P+R+J+F))`

Es una métrica de práctica, **no un indicador académico institucional validado**. El Dashboard en Vista previa mantiene N/D porque su historial local de ejemplo no es fiable como dato académico.

#### Actualizar en Windows sin borrar datos

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

#### Pruebas

Incluye `backend/asistencias/tests.py`, `frontend/test/attendance_repository_test.dart` y `frontend/test/attendance_local_compatibility_test.dart`. Son **pruebas escritas, pendientes de ejecución** en un entorno con Django y Flutter instalados. La sintaxis de los archivos Python y la integridad ZIP se revisaron por separado; no implican que todas las pruebas hayan pasado.

#### Conservación

No se eliminan archivos originales. Se mantienen lámpara verde y sonido, login JWT, aviso de privacidad, calendario, RF-01, RF-02, RF-03, RF-04, RF-12, refuerzo, backend, Flutter y prototipo HTML. El pase local y las asistencias Django **son almacenes distintos**, deliberadamente.

---

<a id="login-registro-crud"></a>
## Login, registro y CRUD de cuentas

_Documento original: [Login, registro y CRUD de cuentas](CHANGELOG.md#login-registro-crud). Conservado en el historial Git._

### Cambios de acceso, registro y CRUD — versión integral

**Origen:** `PIUTTEC2.0_PROYECTO_INTEGRAL_CIERRE_ACADEMICO.zip` (253 archivos). Esta actualización no reemplaza los módulos académicos anteriores; agrega la administración de cuentas sobre la aplicación existente.

#### Nuevas funciones

- Registro público real en Django (solo estudiante) y formulario Flutter bajo la lámpara verde.
- Control de campos duplicados, confirmación de contraseña, validadores Django y consentimiento del aviso.
- Perfil autenticado: consultar, editar, cambiar contraseña, eliminar/anonimizar.
- Administración de usuarios: lista, alta, cambio de roles/estado y baja; protegida por permisos de servidor.
- JWT con refresh rotativo, lista de revocación, logout y revocación de credenciales ante cambio de contraseña.
- Tests Django en `backend/accounts/tests.py`; tests Flutter de llamadas HTTP y pantalla de registro.

#### Compatibilidad

No se editan las migraciones originales ni los modelos académicos. El modelo `accounts.User` permanece intacto. El aviso de privacidad original, el pase de lista, agenda, horarios, solicitudes, gestor de archivos, refuerzo, calendario y lámpara original no se reemplazan. Los archivos existentes editados corresponden solo a los enlaces de navegación/autenticación y a las pruebas preexistentes del login.

#### Estado de QA

- Validado: compilación sintáctica Python (`compileall`), integridad del ZIP, conservación de los archivos originales y balance de delimitadores de Dart modificados.
- **Pendiente de ejecución en Windows:** `manage.py migrate`, `manage.py test accounts -v 2`, `flutter analyze`, `flutter test`, `flutter build web --release`, recorrido integral.
- No se realizó push ni despliegue en GitHub.

Más información: [GUIA_LOGIN_REGISTRO_CRUD.md](GUIA_LOGIN_REGISTRO_CRUD.md).

---

<a id="login-verde"></a>
## Login: identidad verde

_Documento original: [Login: identidad verde](CHANGELOG.md#login-verde). Conservado en el historial Git._

### PIUTTEC 2.0 — Acceso con identidad verde

Esta versión parte del paquete completo `PIUTTEC2.0_COMPLETO_CORREGIDO_PRUEBAS_23NOV2026.zip`.

#### Cambio visual
- Lámpara encendida: iluminación verde suave y pantalla de fondo con matiz esmeralda.
- Botón principal `Iniciar sesión`: verde PIUTTEC con texto blanco.
- Botón `Vista previa`: contorno verde y texto verde claro.
- Entradas: bordes en verde discreto, indicadores verdes y foco de color verde.
- La pantalla continúa siendo oscura, sin subtítulos de marca adicionales.

#### Sin modificaciones funcionales
- Se conserva la interacción de jalar y soltar la cuerda.
- El sonido original `https://assets.codepen.io/605876/click.mp3` sigue referenciado.
- La sesión JWT, el aviso de privacidad, el pase de lista, el calendario, RF-12 y el backend no fueron modificados.
- El logo sigue siendo el recurso local `frontend/assets/branding/piuttec-ii-logo.png`.

#### Archivos alterados
1. `frontend/lib/features/auth/ui/lamp_login_view.dart`
2. `VISTA_PREVIA.html`

#### Pruebas pendientes de confirmación local
```powershell
cd frontend
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port 5173
```

Este entorno no dispone del SDK Flutter para ejecutar una compilación o los tests Flutter.

---

<a id="tema-verde"></a>
## Tema verde institucional

_Documento original: [Tema verde institucional](CHANGELOG.md#tema-verde). Conservado en el historial Git._

### Tema institucional verde de PIUTTEC II — 23/11/2026

#### Base y alcance

Esta entrega es el **proyecto completo**, no una captura ni un parche.
Se construyó sobre `PIUTTEC2.0_COMPLETO_CORREGIDO_COMPILACION_FLUTTER_23NOV2026.zip`.

La identidad verde se aplica desde las fuentes del proyecto a:

- Tema Material 3 de Flutter (modo claro y oscuro): botones, indicadores, entradas, diálogos, controles y elementos que heredan el tema.
- Pantallas de acceso, registro y perfil: botones verdes de marca con contraste adecuado.
- Pantalla **Mi Neurona UTTEC**: sustitución de violeta por acentos verdes/menta; sus cuatro áreas conservan tonos diferenciados.
- Calendario: reemplazo del evento violeta de demostración por verde.
- Portal HTML original: escala completa `brand-*` de Tailwind, degradados y estados interactivos.
- Hoja de estilos del portal original (`Style.css`): acentos de enfoque y resplandores.
- Gráficas y códigos de materias del prototipo (`Script_Main.js`): escala coherente con el verde institucional.

Los verdes de marca principales son `#087C49` (botones con texto blanco),
`#0FA958` (acento), `#8BE4B3` (acento sobre fondos oscuros) y
`#064A33` (verde profundo). Se preservan colores con significado específico:
rojo para error/falta, ámbar para retardo/advertencia y azules en categorías
con función de distinción. El login verde existente no pierde su lámpara.

#### Componentes preservados

- Backend Django completo, modelos, migraciones, permisos y API JWT.
- Pantallas Flutter existentes, sus repositorios y pruebas.
- Mapa de Mi Neurona UTTEC, doce temas, notas y conexiones.
- Recursos binarios originales, logotipos, sonidos y WebGL.
- HTML y JS originales del prototipo, sin reemplazar su lógica de negocio.

#### Validación necesaria

Los cambios son de identidad visual; no se afirma que las pruebas integrales
Django/Flutter ya estén aprobadas. En el registro de pruebas más reciente del
usuario se detectaron fallos previos de `TextEditingController` en
`academia_view_test.dart` y de liberación de `SemanticsHandle` en
`learning_graph_test.dart`, **ajenos al cambio de colores**. Deben resolverse
por separado antes de considerar aprobada la suite.

Ejecutar dentro de `frontend/`:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port 5173
```

No es necesario cambiar `.env`, la base SQLite ni volver a migrar Django
por esta actualización de apariencia.

---

<a id="mi-neurona"></a>
## Recuperacion de Mi Neurona UTTEC

_Documento original: [Recuperacion de Mi Neurona UTTEC](CHANGELOG.md#mi-neurona). Conservado en el historial Git._

### Restauración de Mi Neurona UTTEC — 23 de noviembre de 2026

#### Qué ocurrió

La integración inicial partió de `main` (`f8cb1b4f619e46636be59a0742ee758aa56ea5fa`), y no incorporó la rama `feature/neurona-uttec-demo` (`f92514657478e922bca74d016ee0ce1290515c79`). Por eso se omitió el cuaderno de aprendizaje de esa rama. La afirmación anterior de que «la neurona» era un sistema predictivo de demanda de equipos fue incorrecta: la función original es **Mi Neurona UTTEC**, un mapa de aprendizajes conectados, no un modelo TensorFlow entrenado.

#### Recuperación realizada

- Se restauró `frontend/lib/features/learning/ui/learning_graph_view.dart`, siguiendo el contenido de la rama original (12 temas, cuatro asignaturas, explicaciones, ejemplos, conexiones, apuntes y autoevaluación).
- Se añadió la entrada **Aprendizaje → Mi Neurona UTTEC** al menú Flutter existente, sin quitar **Refuerzo académico**.
- Se recuperó la navegación por la ruta `/neurona` de la rama original.
- Se adaptó exclusivamente la ruta del logo al recurso local vigente (`assets/branding/piuttec-ii-logo.png`).
- Se incorporaron tres pruebas Flutter de la pantalla, la persistencia temporal al navegar y la ruta original.
- Los apuntes y marcadores **solo persisten mientras permanece abierta la pantalla**. Esto reproduce el alcance original; no se ha creado una sincronización ficticia con Django o PostgreSQL.

#### Fuentes de recuperación

- Repositorio original: `https://github.com/TheSrMarco/PIUTTEC2.0`
- Rama: `https://github.com/TheSrMarco/PIUTTEC2.0/tree/feature/neurona-uttec-demo`
- Código original de Neurona: SHA del blob `3981dd8e81962435472015511b03ec0c05c4a485`
- Prueba original: SHA del blob `977a1f07d5519fcf036752201dc1f36f4349682c`

#### Pruebas pendientes en Windows

```powershell
cd "C:\Software Proyectos\PIUTTEC2_Prueba\PIUTTEC2.0\frontend"
flutter pub get
flutter analyze
flutter test test/learning_graph_test.dart
flutter test
flutter run -d chrome --web-port 5173
```

No hay Flutter SDK en el entorno donde se preparó el ZIP. Por ello las pruebas están escritas, pero **no certificadas como aprobadas**. No se realizó `git push` a GitHub.

---

<a id="privacidad"></a>
## Privacidad del prototipo

_Documento original: [Privacidad del prototipo](CHANGELOG.md#privacidad). Conservado en el historial Git._

### Corrección de privacidad — PIUTTEC 2.0 (23/11/2026)

#### Qué se corrigió

- El texto anterior afirmaba que la UTTEC era la operadora prevista. Ahora se identifica
  correctamente el carácter **académico y no oficial** del prototipo.
- Se distinguen **Vista previa** (almacenamiento local del navegador) y el acceso con
  cuenta (Django/SQLite o PostgreSQL y archivos privados).
- Se enumeran exclusivamente funcionalidades existentes; se retiraron encuestas,
  tutorías, campañas y preferencias opcionales que no están implementadas.
- Se indica expresamente que no deben proporcionarse datos sensibles ni documentos reales.
- Se conservaron los controles de lectura previa al acceso, registro y exportación/borrado
  local del prototipo HTML. La confirmación de lectura no es consentimiento jurídico general.
- Se retiró el formulario ARCO que enviaba a la Unidad de Transparencia de UTTEC un correo
  acerca de un prototipo no oficial. La documentación ahora distingue al operador de la
  instancia y el aviso institucional de UTTEC.
- Se incrementó la versión informativa a 2.0; la demo HTML solicita nueva lectura aun
  a quienes habían confirmado la versión 1.0.

#### Archivos modificados

- `frontend/lib/features/privacy/ui/privacy_notice_view.dart`
- `frontend/lib/features/privacy/ui/privacy_gate_view.dart`
- `frontend/lib/features/auth/ui/registration_view.dart`
- `frontend/lib/features/auth/ui/registration_preview.dart`
- `frontend/lib/features/shell/ui/app_shell.dart`
- `frontend/test/privacy_gate_view_test.dart`
- `frontend/test/registration_view_test.dart`
- `backend/accounts/serializers.py` (solo texto del mensaje de validación)
- `privacidad.js` (módulo original web: aviso, modal, exportación y borrado local)
- `portal_de_gesti_n_acad_mica_e_institucional.html` (descripción del documento)

#### Advertencias pendientes (NO resueltas por editar el texto)

1. Identificar a la persona o entidad administradora y contacto real antes de desplegar.
2. Completar el aviso jurídico para el tratamiento efectivamente realizado y los proveedores.
3. Revisar donde se almacena y cómo se documenta la confirmación de lectura del usuario.
   El campo interno `accepted_privacy` del backend solo valida el formulario, no
   sustituye un registro de consentimiento legalmente válido.
4. Revisar derecho de supresión, borrado efectivo, trazabilidad y ciclos de respaldo.
5. Ejecutar pruebas Flutter/Django en el sistema del desarrollador. Esta entrega no las
   marca como aprobadas cuando las herramientas no están presentes.
6. Permanece pendiente el problema de `TextEditingController` en tests de Academia
   detectado antes de esta revisión, pues es independiente del aviso de privacidad.

No se modificaron migraciones ni modelos de negocio. No ejecutar migraciones nuevas
por esta actualización textual, y conservar las bases de datos de la instalación previa.

---

<a id="sin-regresiones"></a>
## Conservacion de funcionalidades existentes

_Documento original: [Conservacion de funcionalidades existentes](CHANGELOG.md#sin-regresiones). Conservado en el historial Git._

### Corrección conservadora de PIUTTEC 2.0 — 23/11/2026

Base: ZIP completo preparado anteriormente a partir del ZIP `PIUTTEC2.0-main.zip` proporcionado por el equipo.

#### Hallazgos comparados contra el ZIP original

- `privacidad.js`, `frontend/lib/features/privacy/ui/privacy_notice_view.dart`, `Script_Main.js`, `portal_de_gesti_n_acad_mica_e_institucional.html`, el cuestionario de refuerzo y el dashboard original no han sido borrados ni alterados.
- El error estaba en `frontend/lib/features/shell/ui/app_shell.dart`: el dashboard original se desplazó a otra entrada y el pase de lista se sustituyó por una vista meramente informativa.
- En `frontend/lib/features/privacy/ui/privacy_gate_view.dart` existía un resumen del aviso y un botón que abría el texto original; en esta corrección el **aviso existente se muestra íntegro**, con la aceptación obligatoria inmediatamente después.

#### Correcciones aplicadas

1. Menú «Panel académico» vuelve a mostrar el `DashboardView` original conectado a Django en el entorno de demostración.
2. Menú «Pase de lista y asistencias» abre una vista Flutter que incorpora P/R/J/F, cálculo de porcentaje, selección de fecha, historial, confirmación de marcado masivo y almacenamiento local con `shared_preferences`.
3. El texto del aviso de privacidad original NO se editó. Se reutiliza su `PrivacyNoticeView` completo dentro de la pantalla de aceptación; no se duplica la redacción.
4. Se conservan `Script_Main.js`, `privacidad.js` y el portal HTML original byte por byte. El pase de lista HTML y sus datos almacenados en `localStorage` permanecen funcionalmente separados del nuevo pase de lista Flutter.
5. No se modificó la API Django adicional ni RF-12 con respecto al ZIP consolidado anterior.

#### Advertencias y verificación

- El módulo Flutter de pase de lista almacena datos **locales en el propio dispositivo/navegador** y **no sincroniza** con el localStorage del prototipo HTML ni con PostgreSQL. No simula un guardado institucional.
- Se añadió `shared_preferences: ^2.3.5` en `frontend/pubspec.yaml`. Ejecuta `flutter pub get` para actualizar el archivo lock de dependencias. **No se ha compilado Flutter en este entorno.**
- Para validar: `cd frontend`, `flutter pub get`, `flutter analyze`, `flutter test` y `flutter run -d chrome`. Ejecuta también Django si quieres el dashboard integrado.
- El efecto de lámpara y su URL de sonido original no se han modificado.
- No se hizo push a GitHub.

---

<a id="compilacion-flutter"></a>
## Compilacion Flutter

_Documento original: [Compilacion Flutter](CHANGELOG.md#compilacion-flutter). Conservado en el historial Git._

### PIUTTEC 2.0 — corrección de compilación Flutter (23 de noviembre de 2026)

#### Base de la actualización

`PIUTTEC2.0_COMPLETO_MI_NEURONA_RESTAURADA_23NOV2026.zip`, con Mi Neurona UTTEC, Django, Flutter, login, registro y CRUD. Esta entrega no cambia el backend ni las migraciones y no borra ningún archivo original.

#### Fallos corregidos del registro de PowerShell

1. Se sustituyeron por `Row(mainAxisSize: MainAxisSize.min)` los seis usos inválidos de `Wrap(mainAxisSize: ...)` en Academia (2), Agenda, Archivos, Solicitudes y Administración de usuarios.
2. En Agenda se protege el campo opcional `TimeOfDay?` con `time?.format(context) ?? 'Sin hora'` y se simplificó la lectura del horario guardado.
3. Los dobles signos de no-nulo en el constructor de hora fueron eliminados.
4. Se eliminó un `import` sin utilizar en el dashboard y se agregaron llaves a las condiciones indicadas por el analizador.
5. En pruebas HTTP, las respuestas simuladas con caracteres como «Biología» y «Primera práctica» declaran `charset=utf-8`. Se mantiene la decodificación estricta de UTF-8 en los repositorios, adecuada para el JSON de Django. También se ajustaron las simulaciones en las pruebas de autenticación, agenda y dashboard.

#### Validación disponible

- La integridad del archivo ZIP se verifica tras generarlo.
- Se verificó que los archivos originales no modificados sean byte por byte idénticos a la versión base.
- **No se ejecutaron `flutter analyze`, `flutter test` ni `flutter run` aquí**: el SDK Flutter no está instalado en este entorno. Las correcciones son específicas de los errores que enviaste, pero puede haber errores adicionales tras compilar.

#### Instalación segura del parche en Windows

Ejecutar en PowerShell, fuera de las carpetas `frontend` y `backend`:

```powershell
$base = 'C:\Software Proyectos\PIUTTEC2_Neurona_Prueba'
Copy-Item "$base\PIUTTEC2.0" "$base\PIUTTEC2.0_respaldo" -Recurse -Force
Expand-Archive -LiteralPath "$env:USERPROFILE\Downloads\PIUTTEC2.0_PARCHE_COMPILACION_FLUTTER_23NOV2026.zip" -DestinationPath $base -Force
cd "$base\PIUTTEC2.0\frontend"
flutter analyze
flutter test
flutter test test/learning_graph_test.dart
flutter run -d chrome --web-port 5173
```

No reinstalar Django, no ejecutar migraciones ni eliminar `backend/db.sqlite3` para este parche. Si el puerto 5173 está ocupado, detener antes el proceso anterior con `q`.

---

<a id="pruebas-flutter"></a>
## Analisis y pruebas Flutter

_Documento original: [Analisis y pruebas Flutter](CHANGELOG.md#pruebas-flutter). Conservado en el historial Git._

### PIUTTEC 2.0 — corrección de análisis y pruebas de Flutter

Base: PIUTTEC2.0_COMPLETO_CORREGIDO_23NOV2026.zip.

Estas correcciones respetan la interfaz visual, el pase de lista, el aviso de privacidad y la navegación existentes. No se modifican Django, el esquema de solicitudes, las credenciales ni el sonido de la lámpara.

Archivos corregidos:
- test/privacy_gate_view_test.dart: los botones actuales se llaman «Continuar» y «Volver», por lo que las pruebas utilizan el botón identificado por Key y el TextButton correcto.
- test/lamp_login_view_test.dart: «Iniciar sesión» aparece como título y como botón; se localiza específicamente FilledButton.
- lib/features/attendance/ui/attendance_view.dart: bloque entre llaves en un if.
- lib/features/demo/ui/demo_modules.dart: elimina _badge sin usar y pone entre llaves las ramas de if/else.
- lib/features/solicitudes/data/solicitudes_repository.dart: initializing formal del token.
- lib/features/solicitudes/ui/solicitudes_view.dart: usa initialValue en DropdownButtonFormField.

#### Aplicar el ZIP de corrección en PowerShell

En la carpeta raíz de tu proyecto (que contiene frontend y backend):

```powershell
cd "C:\Software Proyectos\PIUTTEC2_Prueba\PIUTTEC2.0"
Expand-Archive -LiteralPath "$env:USERPROFILE\Downloads\PIUTTEC2.0_CORRECCION_PRUEBAS_ANALISIS.zip" -DestinationPath . -Force
cd frontend
flutter analyze
flutter test
```

Si usas el ZIP completo en vez del parche, descomprime en una carpeta nueva para no reemplazar .venv, .env ni db.sqlite3 de tu instalación actual.

#### Alcance de la verificación
Se comprobó que los reemplazos son únicos y que solo cambian los archivos descritos. No hay SDK Flutter/Dart en este contenedor; por tanto, `flutter analyze` y `flutter test` requieren validación en tu computadora.

---

<a id="estado-pruebas"></a>
## Estado historico de integracion

_Documento original: [Estado historico de integracion](CHANGELOG.md#estado-pruebas). Conservado en el historial Git._

### Estado y pruebas de la versión consolidada — 23/11/2026

Origen: `PIUTTEC2.0-main.zip` aportado por el equipo. Se preservan los archivos originales salvo los ajustes necesarios en configuración Django, navegación Flutter y el acceso.

| Control | Estado comprobado | Verificación pendiente |
|---|---|---|
| Estructura Flutter, Django, docs, plataformas Android/iOS | Incluida en ZIP | Compilación por plataforma |
| Logotipo original | Copiado a recursos locales en Flutter y web | Revisión visual en dispositivo |
| Lámpara, cuerda y llamada al sonido original | Código de interacción incorporado | Audio remoto audible y prueba de gestos real |
| Login JWT Django | Ruta ya existente; Flutter usa API | Crear cuenta de prueba, comprobar login/expiración |
| Aviso obligatorio | Estado y casilla incorporados | Prueba Flutter en dispositivo |
| Calendario mensual/semanal/diario | Implementación Flutter y HTML | Ejecutar en Flutter; datos reales pendientes |
| Módulos con alcance acotado | Navegación solo PIUTTEC 2.0 | Revisar con requisitos de memoria |
| RF-12 solicitudes con Django API | Archivos integrados, migración y pruebas escritas | Migrar y ejecutar tests |
| Autenticación única para RF-12 | Se pasa token del login a la vista de solicitudes | Probar token real, logout y autorización |
| RNF-04 PostgreSQL | Configurable | Instancia/migraciones/pruebas en PostgreSQL |
| RNF-12 Despliegue | No realizado | URL HTTPS y comprobación externa |

**Importante:** las interfaces con datos de ejemplo no son servicios institucionales. El instalador de paquetes anterior no es necesario: este ZIP ya contiene los cambios. No se ha hecho `git push`.


#### Actualización: pase de lista Django

El pase local de Flutter se conserva sin cambios funcionales. Con JWT, el pase ahora utiliza `asistencias` (nueva migración `0001_initial`) y el resumen de RF-01 calcula la asistencia desde registros personales existentes. El gestor de archivos sigue sin API. Este cambio **sí requiere `manage.py migrate`** y pruebas del nuevo módulo; consulta [Asistencias y dashboard Django](CHANGELOG.md#asistencias-django). Las pruebas nuevas no se han ejecutado en este entorno.

---

<a id="qa-historico"></a>
## Auditoria y QA historicos

_Documento original: [Auditoria y QA historicos](CHANGELOG.md#qa-historico). Conservado en el historial Git._

### Estado comprobado — PIUTTEC 2.0 (cierre académico)

Fecha de elaboración: noviembre de 2026.

#### Verificaciones que SÍ se ejecutaron en este entorno

- Comparación binaria con el ZIP anterior: **196 archivos heredados presentes**, 177 idénticos, 19 modificados, 56 nuevos (antes de añadir este informe).
- Compilación sintáctica de **90 archivos Python** mediante `compile(..., 'exec')`: sin errores de sintaxis.
- Lectura sintáctica de **5 archivos YAML**: sin errores de lectura.
- XML plist de iOS: formato válido y propiedad `CFBundleName` encontrada.
- Verificación estática de importaciones relativas `frontend/lib/**/*.dart`: todos los destinos importados existen.
- Existencia de rutas nuevas de recursos, documentos, progreso, justificantes, logo, privacidad y script de PowerShell: confirmada.

#### Verificaciones NO ejecutadas / pendientes

- **Django `manage.py check`, migraciones reales y tests:** Django no está instalado en este entorno y no se pudieron descargar las dependencias por conectividad.
- **Flutter `pub get`, analyze, test, build web/APK:** no está instalado el SDK Flutter aquí.
- **PostgreSQL:** la configuración Compose se ha escrito pero no se ha levantado ni probado.
- **HTTPS y servidor público:** no se ha desplegado.
- **GitHub:** no se ha realizado `git push`.
- **Accesibilidad, roles institucionales, carga, auditoría de seguridad y operación real:** requieren pruebas de aceptación.

No confundir **código integrado** con **funcionalidad certificada**. Este paquete es una base consolidada y documentada para la entrega y validación académica, no una implementación institucional aprobada.

#### Ejecutar comprobación completa en Windows

```powershell
cd "C:\Software Proyectos\PIUTTEC2_Prueba\PIUTTEC2.0"
powershell -ExecutionPolicy Bypass -File .\VERIFICAR_PIUTTEC.ps1
```

Las evidencias se guardan en `evidencias_pruebas/`. Revisa los logs y corrige cualquier prueba roja antes de etiquetar una versión estable.

#### Archivos existentes modificados

- `.gitignore`
- `README.md`
- `backend/config/settings.py`
- `backend/config/urls.py`
- `backend/dashboard/resumen.py`
- `backend/dashboard/tests.py`
- `backend/solicitudes/admin.py`
- `backend/solicitudes/models.py`
- `backend/solicitudes/serializers.py`
- `backend/solicitudes/views.py`
- `frontend/ios/Runner/Info.plist`
- `frontend/lib/app.dart`
- `frontend/lib/features/auth/data/auth_session.dart`
- `frontend/lib/features/dashboard/ui/dashboard_view.dart`
- `frontend/lib/features/refuerzo/ui/refuerzo_quiz_view.dart`
- `frontend/lib/features/shell/ui/app_shell.dart`
- `frontend/lib/features/solicitudes/data/solicitudes_repository.dart`
- `frontend/lib/features/solicitudes/ui/solicitudes_view.dart`
- `frontend/pubspec.yaml`

#### Archivos añadidos (antes de este informe)

- `.env.production.example`
- `.github/workflows/ci-integral.yml`
- `CIERRE_ACADEMICO_RF_RNF.md`
- `GUIA_EJECUCION_FINAL.md`
- `VERIFICAR_PIUTTEC.ps1`
- `backend/.dockerignore`
- `backend/Dockerfile`
- `backend/accounts/auth_views.py`
- `backend/accounts/tests.py`
- `backend/accounts/views.py`
- `backend/archivos/__init__.py`
- `backend/archivos/admin.py`
- `backend/archivos/migrations/0001_initial.py`
- `backend/archivos/migrations/__init__.py`
- `backend/archivos/models.py`
- `backend/archivos/serializers.py`
- `backend/archivos/tests.py`
- `backend/archivos/urls.py`
- `backend/archivos/views.py`
- `backend/config/health.py`
- `backend/recursos/__init__.py`
- `backend/recursos/admin.py`
- `backend/recursos/management/__init__.py`
- `backend/recursos/management/commands/__init__.py`
- `backend/recursos/management/commands/sembrar_recursos_demo.py`
- `backend/recursos/migrations/0001_initial.py`
- `backend/recursos/migrations/__init__.py`
- `backend/recursos/models.py`
- `backend/recursos/serializers.py`
- `backend/recursos/tests.py`
- `backend/recursos/urls.py`
- `backend/recursos/views.py`
- `backend/refuerzo/__init__.py`
- `backend/refuerzo/admin.py`
- `backend/refuerzo/migrations/0001_initial.py`
- `backend/refuerzo/migrations/__init__.py`
- `backend/refuerzo/models.py`
- `backend/refuerzo/serializers.py`
- `backend/refuerzo/tests.py`
- `backend/refuerzo/urls.py`
- `backend/refuerzo/views.py`
- `backend/requirements-prod.txt`
- `backend/solicitudes/migrations/0002_solicitud_materia.py`
- `backend/solicitudes/migrations/0003_estado_devuelta.py`
- `backend/solicitudes/test_flujos_finales.py`
- `compose.yaml`
- `frontend/lib/features/archivos/data/archivos_repository.dart`
- `frontend/lib/features/archivos/ui/archivos_view.dart`
- `frontend/lib/features/docentes/ui/docentes_view.dart`
- `frontend/lib/features/recursos/data/recursos_repository.dart`
- `frontend/lib/features/recursos/ui/recursos_view.dart`
- `frontend/lib/features/refuerzo/data/refuerzo_repository.dart`
- `frontend/test/archivos_repository_test.dart`
- `frontend/test/docentes_view_test.dart`
- `frontend/test/recursos_repository_test.dart`
- `frontend/test/refuerzo_repository_test.dart`

---
