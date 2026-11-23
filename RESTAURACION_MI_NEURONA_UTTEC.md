# Restauración de Mi Neurona UTTEC — 23 de noviembre de 2026

## Qué ocurrió

La integración inicial partió de `main` (`f8cb1b4f619e46636be59a0742ee758aa56ea5fa`), y no incorporó la rama `feature/neurona-uttec-demo` (`f92514657478e922bca74d016ee0ce1290515c79`). Por eso se omitió el cuaderno de aprendizaje de esa rama. La afirmación anterior de que «la neurona» era un sistema predictivo de demanda de equipos fue incorrecta: la función original es **Mi Neurona UTTEC**, un mapa de aprendizajes conectados, no un modelo TensorFlow entrenado.

## Recuperación realizada

- Se restauró `frontend/lib/features/learning/ui/learning_graph_view.dart`, siguiendo el contenido de la rama original (12 temas, cuatro asignaturas, explicaciones, ejemplos, conexiones, apuntes y autoevaluación).
- Se añadió la entrada **Aprendizaje → Mi Neurona UTTEC** al menú Flutter existente, sin quitar **Refuerzo académico**.
- Se recuperó la navegación por la ruta `/neurona` de la rama original.
- Se adaptó exclusivamente la ruta del logo al recurso local vigente (`assets/branding/piuttec-ii-logo.png`).
- Se incorporaron tres pruebas Flutter de la pantalla, la persistencia temporal al navegar y la ruta original.
- Los apuntes y marcadores **solo persisten mientras permanece abierta la pantalla**. Esto reproduce el alcance original; no se ha creado una sincronización ficticia con Django o PostgreSQL.

## Fuentes de recuperación

- Repositorio original: `https://github.com/TheSrMarco/PIUTTEC2.0`
- Rama: `https://github.com/TheSrMarco/PIUTTEC2.0/tree/feature/neurona-uttec-demo`
- Código original de Neurona: SHA del blob `3981dd8e81962435472015511b03ec0c05c4a485`
- Prueba original: SHA del blob `977a1f07d5519fcf036752201dc1f36f4349682c`

## Pruebas pendientes en Windows

```powershell
cd "C:\Software Proyectos\PIUTTEC2_Prueba\PIUTTEC2.0\frontend"
flutter pub get
flutter analyze
flutter test test/learning_graph_test.dart
flutter test
flutter run -d chrome --web-port 5173
```

No hay Flutter SDK en el entorno donde se preparó el ZIP. Por ello las pruebas están escritas, pero **no certificadas como aprobadas**. No se realizó `git push` a GitHub.
