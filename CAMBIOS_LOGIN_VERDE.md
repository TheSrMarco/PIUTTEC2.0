# PIUTTEC 2.0 — Acceso con identidad verde

Esta versión parte del paquete completo `PIUTTEC2.0_COMPLETO_CORREGIDO_PRUEBAS_23NOV2026.zip`.

## Cambio visual
- Lámpara encendida: iluminación verde suave y pantalla de fondo con matiz esmeralda.
- Botón principal `Iniciar sesión`: verde PIUTTEC con texto blanco.
- Botón `Vista previa`: contorno verde y texto verde claro.
- Entradas: bordes en verde discreto, indicadores verdes y foco de color verde.
- La pantalla continúa siendo oscura, sin subtítulos de marca adicionales.

## Sin modificaciones funcionales
- Se conserva la interacción de jalar y soltar la cuerda.
- El sonido original `https://assets.codepen.io/605876/click.mp3` sigue referenciado.
- La sesión JWT, el aviso de privacidad, el pase de lista, el calendario, RF-12 y el backend no fueron modificados.
- El logo sigue siendo el recurso local `frontend/assets/branding/piuttec-ii-logo.png`.

## Archivos alterados
1. `frontend/lib/features/auth/ui/lamp_login_view.dart`
2. `VISTA_PREVIA.html`

## Pruebas pendientes de confirmación local
```powershell
cd frontend
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port 5173
```

Este entorno no dispone del SDK Flutter para ejecutar una compilación o los tests Flutter.
