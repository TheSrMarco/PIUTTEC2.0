# RF-04: Rendimiento académico individual y comparativo grupal

**Base:** PIUTTEC 2.0 completo con RF-02 y RF-03. Este paquete añade código y pruebas, no representa un push a GitHub ni una aprobación de ejecución.

## Funcionalidades implementadas en código

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

## Qué se entiende por "promedio grupal"

Se agrupan por **nombre de materia y código de grupo** (ignorando diferencias de mayúsculas y espacios) los valores registrados en el sistema por estudiantes de prueba. Cada cuenta aporta una media, de modo que duplicar una materia en un solo usuario no infla el número de participantes. Los registros no tienen verificación institucional de matrícula/grupo: por eso esta comparación es **orientativa, no oficial**. La media incluye la calificación propia.

**No hay calificaciones oficiales de la universidad ni comparación grupal en la vista previa.** Para mostrar la comparación autenticada se requieren cinco usuarios estudiantes reales/de prueba en la misma materia y grupo, con calificaciones registradas en `/api/materias/`. Si no se alcanza el umbral, la interfaz presenta un estado claro sin inventar cifras.

## Pruebas en Windows

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

### Comprobación funcional

1. Entra a Flutter con un usuario Django y abre **Academia → Materias y calificaciones**.
2. Añade dos materias y sus calificaciones, por ejemplo 8 y 10. Ve a **Comparativo académico** y comprueba promedio personal 9.00.
3. Edita una calificación, vuelve al comparativo y pulsa **Actualizar rendimiento** para validar el recálculo.
4. Para la comparación por grupo, registra la **misma materia** y el **mismo código de grupo** en al menos cinco cuentas con rol estudiante. Con menos de cinco el promedio permanece oculto.
5. Accede con otra cuenta y verifica que no pueda leer las materias personales de la primera en `/api/materias/` o `/api/rendimiento/`.
6. En **Vista previa**, registra materias, revisa el promedio personal y verifica que el grupal aparezca como no disponible.

## Pendientes técnicos / RNF

- [ ] Ejecutar realmente las 11 pruebas Django y las 4 Flutter nuevas.
- [ ] Probar `flutter analyze`, `flutter test` y `flutter build web` sin incidencias.
- [ ] Validar el endpoint con credenciales y probar la muestra de cinco cuentas.
- [ ] Conectar **grupos oficiales y calificaciones verificadas** (actualmente son capturas voluntarias de prueba).
- [ ] Validar rendimiento con muchos estudiantes (la consulta de agrupación es apropiada para piloto; requiere optimización antes de producción).
- [ ] Migrar de SQLite a PostgreSQL y comprobar una instancia real.
- [ ] Despliegue con HTTPS y pruebas de seguridad/autorización completas.

## Conservación del trabajo previo

No se sustituyen: el logo, login con lámpara, sonido original, aviso de privacidad, pase de lista, calendario, CRUD de agenda, CRUD de materias y horarios, RF-12 solicitudes, refuerzo, backend Django ni configuración PostgreSQL. La única navegación modificada es la entrada del comparativo, más la conservación explícita del directorio docente bajo una entrada separada.
