# Guía de ejecución — PIUTTEC 2.0 (Windows 11 / PowerShell)

## Preparación inicial (una sola vez)

1. Extraer el ZIP en una carpeta nueva. Si reemplazas una instalación existente, copiar antes `backend/.env`, `backend/db.sqlite3` y `backend/private_uploads/` a una carpeta de respaldo. **No borres esas tres rutas.**
2. Abrir PowerShell en la raíz del proyecto.
3. Backend:

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
.\.venv\Scripts\python.exe manage.py migrate
.\.venv\Scripts\python.exe manage.py sembrar_recursos_demo
.\.venv\Scripts\python.exe manage.py createsuperuser
.\.venv\Scripts\python.exe manage.py runserver
```

4. En otra terminal, frontend:

```powershell
cd frontend
flutter pub get
flutter run -d chrome --web-port 5173
```

- Flutter: http://localhost:5173
- Django admin: http://127.0.0.1:8000/admin/
- Salud API: http://127.0.0.1:8000/api/health/

La nueva instalación inicia con SQLite; `manage.py migrate` crea también las tablas **recursos, archivos, refuerzo** y actualiza **solicitudes**. La orden `sembrar_recursos_demo` añade cuatro recursos ficticios para practicar y se puede ejecutar más de una vez sin duplicarlos.

Desde el administrador crea un usuario estudiante y otro con `role=administrator` para revisar solicitudes. El superusuario también puede aprobar. Para acceder a `/admin/` la cuenta debe tener `is_staff` o ser superusuario; el rol `administrator` por sí solo no da acceso al admin de Django.

## Actualizar instalación existente sin perder registros

Detén los servidores. Guarda la base `db.sqlite3`, el archivo `.env` y `private_uploads/`. Copia encima **únicamente el código** del nuevo ZIP. Ejecuta las migraciones antes de iniciar Django. No sobreescribas la BD por una vacía ni confundas el nuevo ZIP con un parche.

## Ejecutar toda la batería y guardar evidencia

Desde la raíz:

```powershell
powershell -ExecutionPolicy Bypass -File .\VERIFICAR_PIUTTEC.ps1
```

Genera logs y `evidencias_pruebas/resumen.csv` y comprueba `manage.py check`, consistencia de migraciones, tests Django, `flutter pub get`, `flutter analyze`, `flutter test` y `flutter build web --release`. Si una prueba falla, no marcar el requisito como aprobado.

Para arrancar de nuevo desde la raíz:

```powershell
cd backend
.\.venv\Scripts\python.exe manage.py runserver
# abrir otra terminal
cd frontend
flutter run -d chrome --web-port 5173
```

## Recorrido funcional recomendado

1. Inicia sesión en Flutter usando una cuenta Django y acepta el aviso de privacidad.
2. Añade una materia y una asistencia `F` de ayer.
3. En Trámites y justificantes crea una solicitud `justificante` con esa materia y fecha.
4. Entra con una cuenta administradora y aprueba el justificante: la falta `F` debe pasar a `J`.
5. En `/admin/`, crea un recurso activo o usa los cuatro `(demo)` precargados. Solicítalo desde Recursos; comprueba que queda pendiente hasta aprobación.
6. Con la cuenta administradora aprueba la reserva. Envía otra reserva que coincida en horario; la segunda no debe poder aprobarse.
7. Aprueba un préstamo de equipo y utiliza Registrar devolución. El historial queda con estado `devuelta`.
8. En gestor de archivos sube un PDF pequeño y comprueba que otra cuenta no lo puede leer; descárgalo y elimina el registro.
9. Completa un quiz de Redes, Programación o SQL. Revisa los intentos/logros y el panel académico.
10. En Academia registra el nombre de un docente y comprueba que aparezca en Directorio docente.

## PostgreSQL (local con Docker, opcional)

El Compose incluido prepara PostgreSQL 17 y Django; no expone el backend a internet. **No lo interpretes como un despliegue en producción con HTTPS**.

```powershell
Copy-Item .env.production.example .env.production
# Edita .env.production y cambia TODAS las credenciales de ejemplo.
docker compose --env-file .env.production up --build -d postgres
# Al estar sana la base, levanta API:
docker compose --env-file .env.production up -d api
# Realiza migraciones con el contenedor:
docker compose --env-file .env.production exec api python manage.py migrate
```

Para una URL pública aún necesitas proxy TLS, cabeceras de proxy confiables, CORS con el dominio real, políticas de backups, pruebas de penetración, recursos persistentes, pruebas de carga y revisión legal del aviso de privacidad.

## Puntos de API

`/api/auth/login/`, `/api/auth/refresh/`, `/api/auth/me/`, `/api/health/`, `/api/dashboard/resumen/`, `/api/materias/`, `/api/horarios/`, `/api/agenda/`, `/api/asistencias/`, `/api/rendimiento/`, `/api/solicitudes/`, `/api/recursos/`, `/api/archivos/`, `/api/refuerzo/intentos/`, `/api/refuerzo/intentos/resumen/`.

Todos los endpoints de usuario —salvo login/refresh y health— requieren JWT, y en los recursos con propietario el queryset limita los resultados a esa cuenta.

## Registro y CRUD de usuarios (integración posterior)

Después de actualizar esta versión **ejecuta nuevamente `manage.py migrate`**, ahora también crea las tablas de SimpleJWT para revocación de tokens. El login y el registro están dentro del Flutter del puerto 5173, no en la raíz del servidor Django. Prueba `manage.py test accounts -v 2`. El registro público crea estudiantes; los roles administrativos se asignan solamente por cuentas con permisos. Consulta [GUIA_LOGIN_REGISTRO_CRUD.md](GUIA_LOGIN_REGISTRO_CRUD.md).
