# Aplicación PIUTTEC 2.0

Base Flutter para web, Android e iOS. El panel consume datos de demostración desde Django y el menú reproduce las secciones del prototipo HTML. También incluye sesión con JWT, pase de lista diario, aviso de privacidad y refuerzo académico.

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
- features/auth contiene la sesión y el inicio de sesión.
- features/attendance contiene el pase de lista conectado a las materias y las inscripciones de Django.

## Comprobación

~~~powershell
flutter analyze
flutter test
flutter build web
~~~
