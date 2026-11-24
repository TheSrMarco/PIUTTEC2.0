# Tema institucional verde de PIUTTEC II — 23/11/2026

## Base y alcance

Esta entrega es el **proyecto completo**, no una captura ni un parche.
Se construyó sobre `PIUTTEC2.0_COMPLETO_CORREGIDO_COMPILACION_FLUTTER_23NOV2026.zip`.

La identidad verde se aplica desde las fuentes del proyecto a:

- Tema Material 3 de Flutter (modo claro y oscuro): botones, indicadores, entradas, diálogos, controles y elementos que heredan el tema.
- Pantallas de acceso, registro y perfil: botones verdes de marca con contraste adecuado.
- Pantalla **Mi Neurona UTTEC**: sustitución de violeta por acentos verdes/menta; sus cuatro áreas conservan tonos diferenciados.
- Calendario: reemplazo del evento violeta de demostración por verde.
- Portal HTML original: escala completa `brand-*` de Tailwind, degradados y estados interactivos.
- Hoja de estilos del portal original (`Style.css`): acentos de enfoque y resplandores.
- Gráficas y códigos de materias del prototipo (`Script_Main.js`): escala coherente con el verde institucional.

Los verdes de marca principales son `#087C49` (botones con texto blanco),
`#0FA958` (acento), `#8BE4B3` (acento sobre fondos oscuros) y
`#064A33` (verde profundo). Se preservan colores con significado específico:
rojo para error/falta, ámbar para retardo/advertencia y azules en categorías
con función de distinción. El login verde existente no pierde su lámpara.

## Componentes preservados

- Backend Django completo, modelos, migraciones, permisos y API JWT.
- Pantallas Flutter existentes, sus repositorios y pruebas.
- Mapa de Mi Neurona UTTEC, doce temas, notas y conexiones.
- Recursos binarios originales, logotipos, sonidos y WebGL.
- HTML y JS originales del prototipo, sin reemplazar su lógica de negocio.

## Validación necesaria

Los cambios son de identidad visual; no se afirma que las pruebas integrales
Django/Flutter ya estén aprobadas. En el registro de pruebas más reciente del
usuario se detectaron fallos previos de `TextEditingController` en
`academia_view_test.dart` y de liberación de `SemanticsHandle` en
`learning_graph_test.dart`, **ajenos al cambio de colores**. Deben resolverse
por separado antes de considerar aprobada la suite.

Ejecutar dentro de `frontend/`:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port 5173
```

No es necesario cambiar `.env`, la base SQLite ni volver a migrar Django
por esta actualización de apariencia.
