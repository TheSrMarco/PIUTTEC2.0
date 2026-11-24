# Cambios de acceso, registro y CRUD — versión integral

**Origen:** `PIUTTEC2.0_PROYECTO_INTEGRAL_CIERRE_ACADEMICO.zip` (253 archivos). Esta actualización no reemplaza los módulos académicos anteriores; agrega la administración de cuentas sobre la aplicación existente.

## Nuevas funciones

- Registro público real en Django (solo estudiante) y formulario Flutter bajo la lámpara verde.
- Control de campos duplicados, confirmación de contraseña, validadores Django y consentimiento del aviso.
- Perfil autenticado: consultar, editar, cambiar contraseña, eliminar/anonimizar.
- Administración de usuarios: lista, alta, cambio de roles/estado y baja; protegida por permisos de servidor.
- JWT con refresh rotativo, lista de revocación, logout y revocación de credenciales ante cambio de contraseña.
- Tests Django en `backend/accounts/tests.py`; tests Flutter de llamadas HTTP y pantalla de registro.

## Compatibilidad

No se editan las migraciones originales ni los modelos académicos. El modelo `accounts.User` permanece intacto. El aviso de privacidad original, el pase de lista, agenda, horarios, solicitudes, gestor de archivos, refuerzo, calendario y lámpara original no se reemplazan. Los archivos existentes editados corresponden solo a los enlaces de navegación/autenticación y a las pruebas preexistentes del login.

## Estado de QA

- Validado: compilación sintáctica Python (`compileall`), integridad del ZIP, conservación de los archivos originales y balance de delimitadores de Dart modificados.
- **Pendiente de ejecución en Windows:** `manage.py migrate`, `manage.py test accounts -v 2`, `flutter analyze`, `flutter test`, `flutter build web --release`, recorrido integral.
- No se realizó push ni despliegue en GitHub.

Más información: [GUIA_LOGIN_REGISTRO_CRUD.md](GUIA_LOGIN_REGISTRO_CRUD.md).
