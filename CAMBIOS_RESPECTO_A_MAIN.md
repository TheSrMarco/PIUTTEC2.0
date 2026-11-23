# Inventario de cambios respecto al ZIP recibido

Base: `PIUTTEC2.0-main.zip`, con la estructura original de GitHub. Este paquete consolidado **no incluye la carpeta `.git`**, porque un ZIP descargado de GitHub no contiene el historial.

Se aplicaron los componentes UI y RF-12 **directamente a una copia** de la base original. No es necesario ejecutar instaladores anteriores.

## Archivos originales modificados

- `README.md`
- `backend/config/settings.py`
- `backend/config/urls.py`
- `frontend/README.md`
- `frontend/lib/app.dart`
- `frontend/lib/features/shell/ui/app_shell.dart`
- `frontend/pubspec.yaml`

## Archivos nuevos

- `.github/workflows/rf12-backend.yml`
- `ESTADO_Y_PRUEBAS.md`
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

## Archivos originales eliminados

(ninguno)

**Limitaciones:** no se ejecutó Flutter ni Django; sonido remoto original no distribuido localmente; la web `VISTA_PREVIA.html` es maqueta, no app Flutter; no se hizo push a GitHub.
