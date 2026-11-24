# Aplicación PIUTTEC 2.0

Aplicación Flutter para web, Android e iOS. El acceso incluye lámpara con cuerda y JWT, aviso de privacidad obligatorio y calendario. La navegación agrupa únicamente módulos del reporte PIUTTEC 2.0. Varias secciones muestran datos de ejemplo; solicitudes RF-12 utiliza la API Django.

## Ejecutar en Windows

Inicia primero el servidor como indica el README de la raíz. Desde esta carpeta ejecuta:

~~~powershell
flutter pub get
flutter run -d chrome --web-port 5173
~~~

Para un emulador de Android:

~~~powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/
~~~

Las carpetas web, android e ios son las plataformas generadas por Flutter. La compilación de iOS requiere macOS y Xcode.

## Organización

- core/network contiene el cliente HTTP y su dirección configurable.
- core/theme contiene la apariencia compartida.
- features/shell/ui contiene la navegación adaptable.
- features/dashboard separa datos, modelo y presentación. El ViewModel usa ChangeNotifier de Flutter.

## Comprobación

~~~powershell
flutter analyze
flutter build web
~~~

## Nuevo flujo de acceso

Jala la cuerda para abrir el formulario. La lámpara intenta reproducir el audio original de la fuente remota CodePen. Tras un acceso Django válido o elegir la vista previa, aparece un aviso de privacidad que debe aceptarse antes de abrir el calendario.

El logotipo completo se carga desde `assets/branding/piuttec-ii-logo.png` sin conexión a GitHub. La pantalla de solicitudes recibe el token JWT del login principal, sin solicitar credenciales dos veces. Los módulos demostrativos siguen sin persistencia en servidor.

Ver el README de la raíz para levantar el backend y ejecutar las pruebas.
