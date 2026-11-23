# PIUTTEC 2.0 — Acceso, registro y CRUD de cuentas

## Alcance implementado (código; requiere pruebas de ejecución)

Se integró la cuenta de usuario Django preexistente (`accounts.User`) con la interfaz Flutter y JWT. No se modificaron el modelo de usuario ni los datos existentes, por lo que **no es necesaria una migración de `accounts`**. Sí hay que ejecutar `migrate` porque la biblioteca SimpleJWT crea las tablas de su **lista de tokens revocados**.

### Recorrido en Flutter

1. En `http://localhost:5173` jala la cuerda de la lámpara verde.
2. Pulsa **Crear cuenta**. Ingresa usuario, correo, nombre/apellidos, contraseña y confirmación. Consulta y acepta el aviso de privacidad (la versión original se reutiliza).
3. Pulsa **Registrarme**. Flutter envía la solicitud a Django, que valida contraseña y unicidad, crea la cuenta en SQLite/PostgreSQL y devuelve el perfil público. Flutter inicia sesión con la cuenta recién creada; antes del calendario aparece el aviso de privacidad, igual que antes.
4. También puedes usar **Iniciar sesión** con una cuenta existente; el login no utiliza credenciales simuladas.
5. Ve a **Sistema → Mi perfil** (o al nombre en el menú lateral) para **consultar y editar nombre de usuario, nombre, apellidos y correo**, **cambiar contraseña** y **eliminar cuenta**.
6. Con una cuenta de administrador o `createsuperuser`, ve a **Sistema → Gestión de usuarios** para **crear, listar, editar rol/estado y eliminar cuentas**. Solo la API concede permisos; el menú oculto no basta para proteger datos.
7. Pulsa **Cerrar sesión**: la app borra la sesión de memoria inmediatamente y solicita a Django revocar el refresh token.

`Vista previa` permanece sin autenticación y **no puede registrar usuarios en la API**.

### Endpoints Django

| Método | Endpoint | Permiso | Uso |
|---|---|---|---|
| POST | `/api/auth/register/` | Público, límite 6/h por IP | Crear cuenta con rol `student`; aceptación del aviso |
| POST | `/api/auth/login/` | Público, límite 8/min | Obtener JWT access/refresh |
| POST | `/api/auth/refresh/` | Público, límite 30/min | Renovar y rotar refresh JWT |
| POST | `/api/auth/logout/` | JWT | Revocar refresh JWT |
| GET | `/api/auth/me/` | JWT | Consultar perfil |
| PATCH | `/api/auth/me/` | JWT | Modificar perfil sin modificar privilegios |
| DELETE | `/api/auth/me/` | JWT | Eliminar o anonimizar cuenta |
| POST | `/api/auth/change-password/` | JWT | Cambiar contraseña con contraseña actual |
| GET, POST | `/api/auth/users/` | Administrador | Listar y crear cuentas |
| GET, PATCH, DELETE | `/api/auth/users/{id}/` | Administrador | Leer, editar, desactivar, eliminar otras cuentas |

Campos de registro POST JSON:

```json
{
  "username": "alumno_prueba",
  "email": "alumno@example.test",
  "first_name": "Alma",
  "last_name": "Prueba",
  "password": "ClaveDePrueba2026!",
  "password_confirm": "ClaveDePrueba2026!",
  "accepted_privacy": true
}
```

**Importante:** ni el frontend ni la respuesta API exponen el hash de contraseña. Django `create_user` genera el hash conforme al algoritmo configurado; no se almacena texto plano en las tablas de usuarios. El registro público ignora `role`, `is_staff`, `is_superuser` suministrados maliciosamente.

### Borrado y auditoría

Si el usuario **no tiene solicitudes protegidas**, Django borra su cuenta, con cascada de los registros relacionados. Si existen solicitudes con la referencia protegida `on_delete=PROTECT`, Django conserva esas solicitudes por integridad de auditoría y **anonimiza y desactiva** al usuario (quita usuario/correo/nombre, contraseña y privilegios), eliminando los demás datos personales de práctica disponibles en módulos conectados. Los textos de solicitudes de auditoría todavía pueden contener información proporcionada por el usuario: antes de un uso real se requiere política institucional de conservación y supresión de datos.

### Medidas de seguridad y limitaciones

- Registros públicos solo como estudiante; rol docente/administrador únicamente mediante una operación privilegiada.
- Contraseñas con validadores de Django, sin hashes enviados al cliente.
- JWT de acceso 15 min y refresh 24 h, con rotación, blacklist y revocación por cambio de contraseña.
- El refresh JWT se mantiene **solo en memoria de Flutter**. Cerrar o recargar la aplicación obliga a iniciar sesión nuevamente; no se guarda en `localStorage` ni `shared_preferences`.
- Un access token previamente emitido **puede seguir activo hasta su vencimiento tras cerrar sesión**; el refresh queda revocado. Para uso público con requisitos estrictos, se recomienda cookies HttpOnly y revocación centralizada adicional.
- Falta **verificación de correo**, restablecimiento de contraseña por email, registro institucional real y evaluación legal del consentimiento. No debe presentarse como un sistema listo para producción ni usar información real de estudiantes sin autorización.
- El botón del interruptor sigue usando el MP3 original remoto y requiere conexión a ese recurso para sonar.

## Actualización sobre una carpeta existente (Windows 11)

1. Detén ambos servidores; haz copia de seguridad de `backend/db.sqlite3`, `backend/.env` y `backend/private_uploads/`.
2. Extrae el ZIP completo sobre tu proyecto. **No borres** la base de datos, `.env`, `.venv` ni los archivos subidos.
3. Terminal Django:

```powershell
cd "C:\Software Proyectos\PIUTTEC2_Prueba\PIUTTEC2.0\backend"
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe manage.py migrate
.\.venv\Scripts\python.exe manage.py check
.\.venv\Scripts\python.exe manage.py test accounts -v 2
.\.venv\Scripts\python.exe manage.py runserver
```

4. Segunda terminal Flutter:

```powershell
cd "C:\Software Proyectos\PIUTTEC2_Prueba\PIUTTEC2.0\frontend"
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port 5173
```

En Android Emulator se requiere `--dart-define=API_BASE_URL=http://10.0.2.2:8000/api/` y exponer Django en una interfaz de red adecuada para el emulador. En dispositivos físicos configura la dirección accesible de la API y revisa HTTPS.

## Matriz de pruebas sugerida

- [ ] Registro aceptado con datos válidos y aviso marcado.
- [ ] Rechazo de contraseña insegura, confirmación incorrecta, correo duplicado y aviso sin aceptar.
- [ ] Registro público no puede elegir administrador.
- [ ] Login correcto e incorrecto; refresh JWT.
- [ ] El perfil no expone el hash.
- [ ] Actualizar datos personales sin elevar rol o permisos.
- [ ] Cambiar contraseña valida la anterior, invalida tokens anteriores y requiere nuevo login.
- [ ] Logout invalida refresh token.
- [ ] DELETE propia cuenta sin solicitudes elimina usuario; con solicitudes lo anonimiza y desactiva.
- [ ] Estudiante no puede consultar ni editar otras cuentas.
- [ ] Administrador puede crear/listar/editar/desactivar/eliminar cuentas.
- [ ] Flujo completo lámpara → registro → privacidad → calendario → Mi perfil, sin regresión del pase de lista ni RF-01 a RF-13.

**Verificación en el entorno de generación:** sintaxis Python, estructura del código y empaquetado ZIP. Los test Django/Flutter solo pueden certificarse tras ejecutarse donde están sus dependencias y el SDK. La integración no se ha subido a GitHub.
