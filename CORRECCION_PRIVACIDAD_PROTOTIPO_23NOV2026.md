# Corrección de privacidad — PIUTTEC 2.0 (23/11/2026)

## Qué se corrigió

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

## Archivos modificados

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

## Advertencias pendientes (NO resueltas por editar el texto)

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
