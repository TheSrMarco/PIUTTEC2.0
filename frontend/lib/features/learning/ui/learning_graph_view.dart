// Mi Neurona UTTEC: restaurado desde la rama feature/neurona-uttec-demo.
// Contenidos y relaciones del prototipo académico original (2026-11-16).
// Adaptación: logo local vigente, navegación desde AppShell y repintado del mapa.
import 'dart:math' as math;
import 'package:flutter/material.dart';

const _accent = Color(0xFF70E5A7);
const _surface = Color(0xFF202023);
const _subjects = ['Redes digitales', 'Programación', 'Matemáticas', 'Inteligencia artificial'];
const _colors = [Color(0xFF69D4C4), Color(0xFFA8DF78), Color(0xFFE6C986), _accent];

class _Topic {
  const _Topic(this.title, this.subject, this.summary, this.points, this.example, this.related);
  final String title;
  final int subject;
  final String summary;
  final List<String> points;
  final String example;
  final List<int> related;
}

// Mismos doce temas, explicaciones, ejemplos y enlaces de la rama original.
const _topics = <_Topic>[
  _Topic('Dirección IP', 0,
    'Una dirección IP identifica una interfaz dentro de una red y permite dirigir paquetes hacia su destino.',
    [
      'IPv4 utiliza 32 bits y suele escribirse como cuatro números separados por puntos.',
      'Una dirección privada se usa dentro de una red local. El acceso a internet suele pasar por un router.',
      'La dirección y el prefijo de red se interpretan juntos para saber qué destinos son locales.',
    ],
    '192.168.1.10/24: el prefijo /24 indica cuántos bits corresponden a la red.', [1, 2]),
  _Topic('DNS', 0,
    'El sistema de nombres de dominio relaciona nombres legibles con registros, como las direcciones IP de un servicio.',
    [
      'El navegador consulta un resolvedor cuando necesita localizar un dominio.',
      'Los registros A contienen direcciones IPv4 y los AAAA, direcciones IPv6.',
      'Las respuestas pueden guardarse en caché durante el tiempo indicado por su TTL.',
    ],
    'Al visitar un sitio, DNS ayuda a resolver su nombre antes de iniciar la conexión con el servidor.', [0, 5]),
  _Topic('Subredes', 0,
    'Dividir una red en subredes permite organizar el direccionamiento y separar segmentos de comunicación.',
    [
      'Un prefijo más largo reserva más bits para identificar la red.',
      'En una subred IPv4 convencional, las direcciones de red y broadcast no se asignan a equipos.',
      'Los equipos recurren a una puerta de enlace para comunicarse con otras redes.',
    ],
    'Una red /24 se puede dividir en dos subredes /25. Cada una contiene 128 direcciones totales.', [0, 6]),
  _Topic('Variables', 1,
    'Una variable permite dar nombre a un valor que un programa necesita consultar o modificar.',
    [
      'Los tipos describen qué valores y operaciones admite un dato.',
      'Usa nombres que expliquen la intención: promedio, intentos o nombreAlumno.',
      'El alcance determina en qué parte del programa puede utilizarse una variable.',
    ],
    'double promedio = 9.2;\nfinal nombreAlumno = "Ana";', [4, 5, 6]),
  _Topic('Condicionales', 1,
    'Una condición permite elegir qué instrucciones ejecutar según un resultado verdadero o falso.',
    [
      'if ejecuta un bloque cuando una condición es verdadera.',
      'else ofrece un camino alternativo.',
      'Los operadores de comparación y los operadores lógicos permiten construir decisiones.',
    ],
    'if (promedio >= 8) {\n  print("Meta alcanzada");\n} else {\n  print("Continuar practicando");\n}', [3, 5, 10]),
  _Topic('Funciones en código', 1,
    'Una función agrupa instrucciones para realizar una tarea y puede recibir parámetros y devolver un resultado.',
    [
      'Permite reutilizar una operación sin copiar sus instrucciones.',
      'Los parámetros representan los datos de entrada.',
      'Una responsabilidad clara hace que una función sea más fácil de comprender y comprobar.',
    ],
    'double cuadrado(double x) {\n  return x * x;\n}', [3, 4, 6, 1]),
  _Topic('Funciones matemáticas', 2,
    'Una función asigna a cada elemento de su dominio exactamente un valor de salida.',
    [
      'El dominio contiene los valores de entrada admitidos.',
      'El rango reúne los valores que la función puede producir.',
      'Una fórmula, una tabla y una gráfica son formas de representar una función.',
    ],
    'f(x) = x²\nf(3) = 9\nLa misma regla puede escribirse como una función en un programa.', [5, 7, 8, 11]),
  _Topic('Derivadas', 2,
    'La derivada describe cómo cambia una función respecto a su variable en un punto.',
    [
      'Geométricamente representa la pendiente de la recta tangente.',
      'Una derivada positiva indica crecimiento local y una negativa, decrecimiento local.',
      'En el entrenamiento de redes neuronales se usan derivadas para ajustar parámetros.',
    ],
    'Si f(x) = x², entonces f′(x) = 2x.\nEn x = 3, la pendiente es 6.', [6, 9, 11]),
  _Topic('Vectores', 2,
    'Un vector puede representar una lista ordenada de componentes, como varias características de un dato.',
    [
      'Dos vectores de igual dimensión pueden sumarse componente a componente.',
      'El producto punto multiplica componentes correspondientes y suma los resultados.',
      'En aprendizaje automático, una entrada puede representarse mediante un vector numérico.',
    ],
    'x = (2, 3), w = (4, 1)\nw · x = 4 × 2 + 1 × 3 = 11', [6, 9, 10]),
  _Topic('Redes neuronales', 3,
    'Una red neuronal artificial combina unidades de cálculo conectadas para transformar entradas en salidas.',
    [
      'Las conexiones tienen pesos que se ajustan durante el entrenamiento.',
      'Las capas intermedias permiten construir representaciones de los datos.',
      'El entrenamiento compara las predicciones con los resultados esperados para reducir el error.',
    ],
    'Entrada: una imagen convertida en valores numéricos.\nProceso: varias capas de cálculo.\nSalida: la predicción de una categoría.', [10, 11, 7, 8]),
  _Topic('Perceptrón', 3,
    'El perceptrón es un modelo de clasificación que combina entradas con pesos y aplica una regla de decisión.',
    [
      'Calcula una suma ponderada de las entradas y añade un sesgo.',
      'Su frontera de decisión es lineal.',
      'Un perceptrón simple no puede resolver por sí solo todos los problemas de clasificación, como XOR.',
    ],
    'z = w · x + b\nLa clase se decide comparando z con un umbral.', [8, 9, 11, 4]),
  _Topic('Función de activación', 3,
    'Una función de activación transforma el valor calculado por una unidad de una red neuronal.',
    [
      'ReLU devuelve cero para entradas negativas y conserva las positivas.',
      'Sigmoide produce valores entre cero y uno.',
      'Las activaciones no lineales permiten modelar relaciones más complejas que una sola transformación lineal.',
    ],
    'ReLU(x) = max(0, x)\nReLU(-2) = 0\nReLU(3) = 3', [6, 7, 9, 10]),
];

class LearningGraphView extends StatefulWidget {
  const LearningGraphView({super.key});
  @override
  State<LearningGraphView> createState() => _LearningGraphViewState();
}

class _LearningGraphViewState extends State<LearningGraphView> {
  final _notes = List.generate(_topics.length, (_) => TextEditingController());
  final _studied = <int>{};
  final _scroll = ScrollController();
  int _selected = 9;
  bool _showGraph = false;

  @override
  void dispose() {
    for (final controller in _notes) { controller.dispose(); }
    _scroll.dispose();
    super.dispose();
  }

  void _open(int index) {
    setState(() { _selected = index; _showGraph = false; });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Widget _sidebar() => Material(
    color: const Color(0xFF27272B),
    child: ListView(padding: const EdgeInsets.all(16), children: [
      const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Text('MIS TEMAS', style: TextStyle(letterSpacing: 1.5, fontSize: 12, color: Colors.white60)),
      ),
      for (var subject = 0; subject < _subjects.length; subject++) ...[
        Padding(padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          child: Text(_subjects[subject], style: TextStyle(color: _colors[subject], fontWeight: FontWeight.w600))),
        for (var index = 0; index < _topics.length; index++)
          if (_topics[index].subject == subject)
            ListTile(
              key: ValueKey('topic-$index'), dense: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              selected: index == _selected && !_showGraph,
              selectedTileColor: Colors.white10, selectedColor: Colors.white,
              leading: Icon(_studied.contains(index) ? Icons.check_circle_outline : Icons.description_outlined,
                size: 18, color: _studied.contains(index) ? Colors.greenAccent : Colors.white38),
              title: Text(_topics[index].title), onTap: () => _open(index),
            ),
      ],
    ]),
  );

  Widget _reader() {
    final topic = _topics[_selected];
    return ListView(
      key: const ValueKey('topic-reader'), controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      children: [ Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${_subjects[topic.subject]} / Tema', style: TextStyle(color: _colors[topic.subject], fontSize: 14)),
          const SizedBox(height: 14),
          Text(topic.title, key: const ValueKey('topic-heading'),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2)),
          const SizedBox(height: 20),
          Text(topic.summary, style: const TextStyle(fontSize: 18, height: 1.7, color: Color(0xFFDDDDDF))),
          const SizedBox(height: 28),
          const Text('Ideas clave', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          for (final point in topic.points)
            Padding(padding: const EdgeInsets.only(bottom: 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('•  ', style: TextStyle(fontSize: 18, color: _accent)),
                Expanded(child: Text(point, style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFFCCCCD0)))),
              ])),
          const SizedBox(height: 16),
          const Text('Ejemplo', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(width: double.infinity, padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFF2A2A30), borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10)),
            child: SelectableText(topic.example, style: const TextStyle(fontSize: 16, height: 1.6))),
          const SizedBox(height: 28),
          const Text('Temas conectados', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final related in topic.related)
              ActionChip(key: ValueKey('related-$related'), avatar: const Icon(Icons.link, size: 16),
                label: Text(_topics[related].title), onPressed: () => _open(related)),
          ]),
          const SizedBox(height: 28),
          const Text('Mis apuntes', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Escribe con tus palabras lo que entendiste, una duda o un ejemplo.',
            style: TextStyle(color: Colors.white60, height: 1.5)),
          const SizedBox(height: 12),
          TextField(key: ValueKey('notes-$_selected'), controller: _notes[_selected],
            minLines: 4, maxLines: null,
            style: const TextStyle(fontSize: 16, height: 1.6),
            decoration: const InputDecoration(labelText: 'Apuntes personales', alignLabelWithHint: true,
              hintText: 'Hoy aprendí que…', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(contentPadding: EdgeInsets.zero,
            title: const Text('Creo que lo domino'),
            subtitle: const Text('Autoevaluación personal; no es una acreditación.'),
            value: _studied.contains(_selected),
            onChanged: (value) => setState(() {
              if (value) { _studied.add(_selected); } else { _studied.remove(_selected); }
            })),
          const SizedBox(height: 20),
          const Text('Prueba de navegación: los apuntes y la autoevaluación se conservan mientras esta pantalla siga abierta. Se reinician al recargar o salir.',
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.6)),
          const SizedBox(height: 20),
        ]))), ],
    );
  }

  Widget _graph() => Column(children: [
    const Padding(padding: EdgeInsets.all(20),
      child: Text('Cada punto es un tema. Tócalo para abrir sus apuntes. Amplía el mapa para explorar.',
        style: TextStyle(color: Colors.white70))),
    Expanded(child: InteractiveViewer(minScale: 1, maxScale: 4, trackpadScrollCausesScale: true,
      child: SizedBox.expand(child: FittedBox(child: SizedBox(width: 960, height: 620,
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _KnowledgePainter(_selected, Set.of(_studied)))),
          for (var subject = 0; subject < 4; subject++)
            Positioned(left: _cluster(subject).dx - 140, top: _cluster(subject).dy - 100, width: 280,
              child: Text(_subjects[subject], textAlign: TextAlign.center,
                style: TextStyle(color: _colors[subject], fontSize: 17, fontWeight: FontWeight.w600))),
          for (var index = 0; index < _topics.length; index++)
            Positioned(left: _position(index).dx - 85, top: _position(index).dy - 12,
              width: 170, height: 76,
              child: Semantics(button: true, label: 'Abrir ${_topics[index].title}',
                child: InkWell(onTap: () => _open(index), borderRadius: BorderRadius.circular(14),
                  child: ExcludeSemantics(child: Column(children: [
                    Container(width: index == _selected ? 22 : 16,
                      height: index == _selected ? 22 : 16,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        color: _studied.contains(index) ? Colors.greenAccent : _colors[_topics[index].subject],
                        boxShadow: [BoxShadow(color: _colors[_topics[index].subject].withValues(alpha: 0.25), blurRadius: 16)])),
                    const SizedBox(height: 8),
                    Text(_topics[index].title, textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.white70)),
                  ]))))),
        ]))),))),
    Padding(padding: const EdgeInsets.all(16),
      child: Text('${_topics.length} temas · ${_subjects.length} materias · ${_studied.length} marcados como dominados',
        style: const TextStyle(color: Colors.white60))),
  ]);

  @override
  Widget build(BuildContext context) => Theme(
    data: ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: _accent, brightness: Brightness.dark),
      scaffoldBackgroundColor: _surface),
    child: Material(color: _surface, child: LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 850;
        return Column(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(color: Color(0xFF27272B),
              border: Border(bottom: BorderSide(color: Colors.white12))),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                child: Image.asset('assets/branding/piuttec-ii-logo.png',
                  width: wide ? 124 : 88, height: 36, fit: BoxFit.contain,
                  semanticLabel: 'Logo PIUTTEC II')),
              const SizedBox(width: 16),
              if (wide)
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Mi Neurona UTTEC', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                  Text('Tu cuaderno de aprendizajes conectados',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
                ]))
              else const Spacer(),
              IconButton.filledTonal(tooltip: 'Ver tema', isSelected: !_showGraph,
                onPressed: () => setState(() => _showGraph = false),
                icon: const Icon(Icons.description_outlined)),
              const SizedBox(width: 8),
              IconButton.filledTonal(tooltip: 'Ver mapa', isSelected: _showGraph,
                onPressed: () => setState(() => _showGraph = true),
                icon: const Icon(Icons.hub_outlined)),
            ])),
          if (!wide)
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonFormField<int>(initialValue: _selected,
                key: ValueKey('selector-$_selected'), isExpanded: true,
                decoration: const InputDecoration(labelText: 'Explorar temas', border: OutlineInputBorder(), isDense: true),
                items: [for (var i = 0; i < _topics.length; i++)
                  DropdownMenuItem(value: i, child: Text(
                    '${_subjects[_topics[i].subject]} · ${_topics[i].title}',
                    overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)))],
                onChanged: (value) { if (value != null) _open(value); })),
          Expanded(child: Row(children: [
            if (wide) SizedBox(width: 280, child: _sidebar()),
            Expanded(child: _showGraph ? _graph() : _reader()),
          ])),
        ]);
      },
    )),
  );
}

Offset _cluster(int subject) => [
  const Offset(240, 150), const Offset(720, 150),
  const Offset(240, 440), const Offset(720, 440),
][subject];
Offset _position(int index) {
  final angle = (index % 3) * math.pi * 2 / 3 - math.pi / 2;
  return _cluster(_topics[index].subject) +
    Offset(math.cos(angle) * 145, math.sin(angle) * 65 + 25);
}

class _KnowledgePainter extends CustomPainter {
  const _KnowledgePainter(this.selected, this.studied);
  final int selected;
  final Set<int> studied;
  @override
  void paint(Canvas canvas, Size size) {
    final drawn = <String>{};
    for (var from = 0; from < _topics.length; from++) {
      for (final to in _topics[from].related) {
        final key = from < to ? '$from-$to' : '$to-$from';
        if (!drawn.add(key)) continue;
        final active = from == selected || to == selected;
        canvas.drawLine(_position(from), _position(to), Paint()
          ..color = active ? _accent.withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.12)
          ..strokeWidth = active ? 1.8 : 1);
      }
    }
  }
  @override
  bool shouldRepaint(_KnowledgePainter oldDelegate) =>
    oldDelegate.selected != selected ||
    oldDelegate.studied.length != studied.length ||
    !oldDelegate.studied.containsAll(studied);
}
