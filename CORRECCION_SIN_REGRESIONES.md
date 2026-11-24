# Corrección conservadora de PIUTTEC 2.0 — 23/11/2026

Base: ZIP completo preparado anteriormente a partir del ZIP `PIUTTEC2.0-main.zip` proporcionado por el equipo.

## Hallazgos comparados contra el ZIP original

- `privacidad.js`, `frontend/lib/features/privacy/ui/privacy_notice_view.dart`, `Script_Main.js`, `portal_de_gesti_n_acad_mica_e_institucional.html`, el cuestionario de refuerzo y el dashboard original no han sido borrados ni alterados.
- El error estaba en `frontend/lib/features/shell/ui/app_shell.dart`: el dashboard original se desplazó a otra entrada y el pase de lista se sustituyó por una vista meramente informativa.
- En `frontend/lib/features/privacy/ui/privacy_gate_view.dart` existía un resumen del aviso y un botón que abría el texto original; en esta corrección el **aviso existente se muestra íntegro**, con la aceptación obligatoria inmediatamente después.

## Correcciones aplicadas

1. Menú «Panel académico» vuelve a mostrar el `DashboardView` original conectado a Django en el entorno de demostración.
2. Menú «Pase de lista y asistencias» abre una vista Flutter que incorpora P/R/J/F, cálculo de porcentaje, selección de fecha, historial, confirmación de marcado masivo y almacenamiento local con `shared_preferences`.
3. El texto del aviso de privacidad original NO se editó. Se reutiliza su `PrivacyNoticeView` completo dentro de la pantalla de aceptación; no se duplica la redacción.
4. Se conservan `Script_Main.js`, `privacidad.js` y el portal HTML original byte por byte. El pase de lista HTML y sus datos almacenados en `localStorage` permanecen funcionalmente separados del nuevo pase de lista Flutter.
5. No se modificó la API Django adicional ni RF-12 con respecto al ZIP consolidado anterior.

## Advertencias y verificación

- El módulo Flutter de pase de lista almacena datos **locales en el propio dispositivo/navegador** y **no sincroniza** con el localStorage del prototipo HTML ni con PostgreSQL. No simula un guardado institucional.
- Se añadió `shared_preferences: ^2.3.5` en `frontend/pubspec.yaml`. Ejecuta `flutter pub get` para actualizar el archivo lock de dependencias. **No se ha compilado Flutter en este entorno.**
- Para validar: `cd frontend`, `flutter pub get`, `flutter analyze`, `flutter test` y `flutter run -d chrome`. Ejecuta también Django si quieres el dashboard integrado.
- El efecto de lámpara y su URL de sonido original no se han modificado.
- No se hizo push a GitHub.
