# PIUTTEC 2.0 — corrección de análisis y pruebas de Flutter

Base: PIUTTEC2.0_COMPLETO_CORREGIDO_23NOV2026.zip.

Estas correcciones respetan la interfaz visual, el pase de lista, el aviso de privacidad y la navegación existentes. No se modifican Django, el esquema de solicitudes, las credenciales ni el sonido de la lámpara.

Archivos corregidos:
- test/privacy_gate_view_test.dart: los botones actuales se llaman «Continuar» y «Volver», por lo que las pruebas utilizan el botón identificado por Key y el TextButton correcto.
- test/lamp_login_view_test.dart: «Iniciar sesión» aparece como título y como botón; se localiza específicamente FilledButton.
- lib/features/attendance/ui/attendance_view.dart: bloque entre llaves en un if.
- lib/features/demo/ui/demo_modules.dart: elimina _badge sin usar y pone entre llaves las ramas de if/else.
- lib/features/solicitudes/data/solicitudes_repository.dart: initializing formal del token.
- lib/features/solicitudes/ui/solicitudes_view.dart: usa initialValue en DropdownButtonFormField.

## Aplicar el ZIP de corrección en PowerShell

En la carpeta raíz de tu proyecto (que contiene frontend y backend):

```powershell
cd "C:\Software Proyectos\PIUTTEC2_Prueba\PIUTTEC2.0"
Expand-Archive -LiteralPath "$env:USERPROFILE\Downloads\PIUTTEC2.0_CORRECCION_PRUEBAS_ANALISIS.zip" -DestinationPath . -Force
cd frontend
flutter analyze
flutter test
```

Si usas el ZIP completo en vez del parche, descomprime en una carpeta nueva para no reemplazar .venv, .env ni db.sqlite3 de tu instalación actual.

## Alcance de la verificación
Se comprobó que los reemplazos son únicos y que solo cambian los archivos descritos. No hay SDK Flutter/Dart en este contenedor; por tanto, `flutter analyze` y `flutter test` requieren validación en tu computadora.
