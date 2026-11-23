# PIUTTEC 2.0 — corrección de compilación Flutter (23 de noviembre de 2026)

## Base de la actualización

`PIUTTEC2.0_COMPLETO_MI_NEURONA_RESTAURADA_23NOV2026.zip`, con Mi Neurona UTTEC, Django, Flutter, login, registro y CRUD. Esta entrega no cambia el backend ni las migraciones y no borra ningún archivo original.

## Fallos corregidos del registro de PowerShell

1. Se sustituyeron por `Row(mainAxisSize: MainAxisSize.min)` los seis usos inválidos de `Wrap(mainAxisSize: ...)` en Academia (2), Agenda, Archivos, Solicitudes y Administración de usuarios.
2. En Agenda se protege el campo opcional `TimeOfDay?` con `time?.format(context) ?? 'Sin hora'` y se simplificó la lectura del horario guardado.
3. Los dobles signos de no-nulo en el constructor de hora fueron eliminados.
4. Se eliminó un `import` sin utilizar en el dashboard y se agregaron llaves a las condiciones indicadas por el analizador.
5. En pruebas HTTP, las respuestas simuladas con caracteres como «Biología» y «Primera práctica» declaran `charset=utf-8`. Se mantiene la decodificación estricta de UTF-8 en los repositorios, adecuada para el JSON de Django. También se ajustaron las simulaciones en las pruebas de autenticación, agenda y dashboard.

## Validación disponible

- La integridad del archivo ZIP se verifica tras generarlo.
- Se verificó que los archivos originales no modificados sean byte por byte idénticos a la versión base.
- **No se ejecutaron `flutter analyze`, `flutter test` ni `flutter run` aquí**: el SDK Flutter no está instalado en este entorno. Las correcciones son específicas de los errores que enviaste, pero puede haber errores adicionales tras compilar.

## Instalación segura del parche en Windows

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
