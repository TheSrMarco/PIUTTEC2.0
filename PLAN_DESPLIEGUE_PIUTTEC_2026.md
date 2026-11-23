# PIUTTEC 2.0 — Opciones de despliegue (23 de noviembre de 2026)

> Documento de planificación, NO configuración de despliegue ni aval institucional.
> Prototipo académico; no utilizar datos personales reales hasta completar seguridad,
> aviso de privacidad con responsable identificado, pruebas y autorización pertinente.

## Arquitectura recomendada para una demostración accesible por Internet

```text
Navegador Chrome/Android
     |
     v
Flutter Web -> Cloudflare Pages (HTML/CSS/JS compilados de `flutter build web`)
     |
     | HTTPS /api/
     v
Django REST Framework + Gunicorn -> Railway (servicio API)
     |                           \
     | conexión TLS PostgreSQL     \ descarga/subida privada
     v                              v
Neon PostgreSQL (datos relacionales)  almacenamiento persistente (R2 / S3,
                                      o volumen persistente configurado)
```

**La base de datos propuesta es PostgreSQL administrado.** No recomendamos SQLite
como base de datos de la instalación pública con varios usuarios. Neon Free es
apropiado para pruebas con datos ficticios dentro de sus límites; no constituye
por sí mismo una estrategia de continuidad, respaldos ni cumplimiento legal.

### Alternativa de menor complejidad operativa

- Railway: Django y PostgreSQL en el mismo proyecto y opcional volumen de archivos;
  una sola consola, cobro según consumo y plan.
- Flutter Web: Cloudflare Pages o hosting estático equivalente.
- Django: Gunicorn, variables de entorno y HTTPS mediante proxy; sin runserver.
- Base de datos: PostgreSQL; jamás crear tablas manualmente, usar `manage.py migrate`.

### Qué no debes hacer

- No poner el host `127.0.0.1:8000` dentro de una compilación pública Flutter.
- No confiar en el filesystem efímero para justificantes o documentos.
- No subir `.env`, `db.sqlite3`, secretos, documentos ni usuarios de prueba a GitHub.
- No desactivar CORS, controles de rol, HTTPS o `DJANGO_DEBUG=0` para facilitar el despliegue.
- No utilizar correo y datos reales de alumnos hasta identificar al responsable efectivo.
- No utilizar Render Postgres Free como almacén persistente de largo plazo:
  su modalidad gratuita expira tras 30 días, según documentación del proveedor.

## Preparación técnica que ya admite este código

`frontend/lib` usa `API_BASE_URL` mediante `String.fromEnvironment`.
Para la compilación web final, indicar la URL absoluta HTTPS de la API:

```powershell
cd frontend
flutter build web --release --dart-define=API_BASE_URL=https://api.ejemplo.com/api/
```

El resultado está en `frontend/build/web`. Esa carpeta de salida se publica
como sitio estático. La URL del ejemplo es ficticia: reemplazarla por la real.

En el backend, configurar secretos en el proveedor de hosting, nunca en el repositorio:

```
DJANGO_DEBUG=0
DJANGO_SECRET_KEY=<clave generada en el proveedor>
DJANGO_ALLOWED_HOSTS=api.ejemplo.com
CORS_ALLOWED_ORIGINS=https://app.ejemplo.com
DB_ENGINE=postgres
PGDATABASE=<dbname>
PGUSER=<usuario>
PGPASSWORD=<clave>
PGHOST=<host del proveedor>
PGPORT=5432
PGSSLMODE=require
```

`PGSSLMODE=require` se pasa a `psycopg` desde la configuración de Django. Requiere
comprobar que el servicio de base de datos emite una conexión TLS válida.
Asegurar, además, la correcta configuración de proxy HTTPS, static files,
ALLOWED_HOSTS y TLS antes de habilitar tráfico público.

## Migración desde SQLite

1. Hacer copia verificable de `backend/db.sqlite3` y de `private_uploads/`.
2. Probar el proyecto con una base PostgreSQL **vacía** y ejecutar `migrate`.
3. Si hay datos que conservar: usar un procedimiento de migración supervisado
   (`dumpdata`/`loaddata` evaluando tokens, ContentTypes, usuarios y claves foráneas).
4. Validar conteos, roles, autenticación y relaciones en ambos motores.
5. Crear copia de respaldo, comprobar recuperación y registrar resultados.

No elimines SQLite hasta verificar que los registros y archivos se recuperan
correctamente. Documentar una rutina de respaldos externos a la instancia.

## Pendientes de seguridad y privacidad para uso público

- Identificar responsable y contacto del prototipo; acordar plazos de conservación.
- Revisar validez del aviso legal según tratamiento real y jurisdicción.
- Configurar almacenamiento privado duradero para archivos (Cloudflare R2/S3 o volumen).
- Revisar el middleware para HTTPS/proxy, CSRF/Admin, cabeceras y cookies.
- Sustituir secretos locales por variables de entorno seguras.
- Configurar backups automatizados y ensayar restauración.
- Considerar controles contra abuso en registro e inicio de sesión; revisión de permisos.
- Ejecutar `manage.py test`, `flutter test`, `flutter analyze` y prueba extremo a extremo.
- Definir entorno de staging, dominio y despliegues automáticos tras revisión.

## Referencias de proveedores, revisadas el 23/11/2026

- Cloudflare Pages: https://developers.cloudflare.com/pages/
- Railway y tarifas: https://railway.com/pricing
- Railway PostgreSQL: https://docs.railway.com/databases/postgresql
- Neon Free Postgres (1 GB por proyecto anunciado en octubre de 2026):
  https://neon.com/blog/neon-free-plan-1-gb-per-project
- Render Free: https://render.com/docs/free

Los precios, políticas de uso gratuito, regiones y cuotas pueden variar;
revisar siempre la página del proveedor antes de contratar.
