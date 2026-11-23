import 'package:flutter/material.dart';
import '../data/refuerzo_repository.dart';

typedef _Pregunta = ({String prompt, List<String> options, int answer, String explanation});

const List<_Pregunta> _questions = [
      (
        prompt:
            '¿Qué protocolo de transporte establece una conexión mediante el '
            'Three-Way Handshake y entrega los datos en orden?',
        options: ['UDP', 'TCP', 'ICMP'],
        answer: 1,
        explanation:
            'TCP establece la conexión con SYN, SYN-ACK y ACK. '
            'Los números de secuencia permiten entregar los datos en orden.',
      ),
      (
        prompt: '¿Cuál es el propósito principal de una VLAN en un switch administrable?',
        options: [
          'Aumentar el voltaje del enlace',
          'Segmentar dominios de broadcast lógicamente',
          'Sustituir el direccionamiento IP',
        ],
        answer: 1,
        explanation:
            'Cada VLAN separa el tráfico de difusión en su propio dominio, '
            'aunque los equipos compartan el mismo switch físico.',
      ),
      (
        prompt: '¿Qué puerto utiliza por defecto HTTPS?',
        options: ['80', '22', '443'],
        answer: 2,
        explanation:
            'HTTPS usa el puerto 443 por defecto y protege HTTP mediante TLS.',
      ),
    ];


const List<_Pregunta> _questionsProgramacion = [
  (prompt: '¿Qué estructura repite instrucciones mientras una condición es verdadera?',
   options: ['if', 'while', 'return'], answer: 1,
   explanation: 'while ejecuta iteraciones mientras se cumple su condición.'),
  (prompt: '¿Qué estructura FIFO procesa primero el elemento que entró primero?',
   options: ['Pila', 'Cola', 'Árbol'], answer: 1,
   explanation: 'Una cola mantiene el orden FIFO: primero en entrar, primero en salir.'),
  (prompt: '¿Qué palabra se usa para herencia de clases en Java?',
   options: ['extends', 'implements', 'final'], answer: 0,
   explanation: 'extends expresa herencia entre clases en Java.'),
];

const List<_Pregunta> _questionsSql = [
  (prompt: '¿Qué sentencia SQL consulta registros de una tabla?',
   options: ['SELECT', 'UPDATE', 'DROP'], answer: 0,
   explanation: 'SELECT recupera filas sin modificar la tabla.'),
  (prompt: '¿Cuál cláusula filtra grupos después de aplicar GROUP BY?',
   options: ['WHERE', 'HAVING', 'ORDER BY'], answer: 1,
   explanation: 'HAVING filtra agregaciones por grupo; WHERE filtra filas antes de agrupar.'),
  (prompt: '¿Qué mecanismo identifica una fila de forma única?',
   options: ['Clave foránea', 'Clave primaria', 'Índice no único'], answer: 1,
   explanation: 'PRIMARY KEY identifica de forma única una fila y no admite NULL.'),
];

class RefuerzoQuizView extends StatefulWidget {
  const RefuerzoQuizView({super.key, this.accessToken});
  final String? accessToken;

  @override
  State<RefuerzoQuizView> createState() => _RefuerzoQuizViewState();
}

class _RefuerzoQuizViewState extends State<RefuerzoQuizView> {
  String _tema = 'Fundamentos de redes digitales';
  String _carrera = 'Desarrollo y Gestión de Software';
  int _cuatrimestre = 9;
  int _parcial = 3;
  List<_Pregunta> get _banco => switch (_tema) {
    'Programación y algoritmos' => _questionsProgramacion,
    'Bases de datos y SQL' => _questionsSql,
    _ => _questions,
  };

  void _reiniciarQuiz() => setState(() {
    _index = 0;
    _score = 0;
    _selected = null;
    _answered = false;
  });

  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  late final RefuerzoRepository _repo;
  ResumenRefuerzo? _resumen;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _repo = RefuerzoRepository(accessToken: widget.accessToken);
    _cargarResumen();
  }

  Future<void> _cargarResumen() async {
    try {
      final result = await _repo.resumen();
      if (mounted) setState(() { _resumen = result; _error = null; });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _guardarResultado() async {
    if (_saving) return;
    setState(() { _saving = true; _error = null; });
    try {
      await _repo.registrar(tema: _tema, carrera: _carrera,
        cuatrimestre: _cuatrimestre, parcial: _parcial,
        aciertos: _score, total: _banco.length);
      await _cargarResumen();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _repo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finished = _index == _banco.length;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Refuerzo académico', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _tema,
              decoration: const InputDecoration(labelText: 'Tema'),
              items: const [
                DropdownMenuItem(value: 'Fundamentos de redes digitales', child: Text('Fundamentos de redes digitales')),
                DropdownMenuItem(value: 'Programación y algoritmos', child: Text('Programación y algoritmos')),
                DropdownMenuItem(value: 'Bases de datos y SQL', child: Text('Bases de datos y SQL')),
              ],
              onChanged: _saving ? null : (value) {
                if (value == null) return;
                _reiniciarQuiz();
                setState(() => _tema = value);
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _carrera,
              decoration: const InputDecoration(labelText: 'Carrera'),
              items: const [DropdownMenuItem(value: 'Desarrollo y Gestión de Software',
                child: Text('Desarrollo y Gestión de Software'))],
              onChanged: (value) { if (value != null) setState(() => _carrera = value); },
            ),
            Row(children: [
              Expanded(child: DropdownButtonFormField<int>(
                initialValue: _cuatrimestre,
                decoration: const InputDecoration(labelText: 'Cuatrimestre'),
                items: [for (var i = 1; i <= 11; i++) DropdownMenuItem(value: i, child: Text('$i'))],
                onChanged: (value) { if (value != null) setState(() => _cuatrimestre = value); },
              )),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<int>(
                initialValue: _parcial,
                decoration: const InputDecoration(labelText: 'Parcial'),
                items: [for (var i = 1; i <= 3; i++) DropdownMenuItem(value: i, child: Text('$i'))],
                onChanged: (value) { if (value != null) setState(() => _parcial = value); },
              )),
            ]),
            const SizedBox(height: 4),
            const Text('Banco de preguntas de práctica; no sustituye una evaluación oficial.'),
            const SizedBox(height: 8),
            Text(widget.accessToken == null
              ? 'Vista previa: el progreso se guarda en este navegador.'
              : 'Los intentos se guardan en tu cuenta de Django.'),
            if (_resumen != null) Card(child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Intentos: ${_resumen!.intentos} · Mejor resultado: '
                  '${_resumen!.mejor?.toStringAsFixed(1) ?? 'N/D'} %'),
                if (_resumen!.logros.isNotEmpty)
                  Text('Logros: ${_resumen!.logros.join(', ')}'),
              ]),
            )),
            if (_saving) const LinearProgressIndicator(),
            if (_error != null) Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 16),
            if (finished) ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  'Resultado: $_score de ${_banco.length} aciertos',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _reiniciarQuiz,
                child: const Text('Volver a intentar'),
              ),
            ] else
              ..._buildQuestion(theme),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildQuestion(ThemeData theme) {
    final question = _banco[_index];
    final correct = _selected == question.answer;

    return [
      Semantics(
        liveRegion: true,
        child: Text('Pregunta ${_index + 1} de ${_banco.length}'),
      ),
      const SizedBox(height: 8),
      Text(question.prompt, style: theme.textTheme.titleMedium),
      const SizedBox(height: 8),
      RadioGroup<int>(
        groupValue: _selected,
        onChanged: (value) => setState(() => _selected = value),
        child: Column(
          children: [
            for (final (index, option) in question.options.indexed)
              RadioListTile<int>(
                value: index,
                enabled: !_answered,
                contentPadding: EdgeInsets.zero,
                title: Text(option),
              ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      if (_answered) ...[
        Semantics(
          liveRegion: true,
          child: Text(
            correct
                ? 'Correcto. ${question.explanation}'
                : 'La respuesta correcta es ${question.options[question.answer]}. '
                      '${question.explanation}',
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {
            final terminado = _index + 1 == _banco.length;
            setState(() {
              _index++;
              _selected = null;
              _answered = false;
            });
            if (terminado) _guardarResultado();
          },
          child: Text(
            _index + 1 == _banco.length
                ? 'Ver resultado'
                : 'Siguiente pregunta',
          ),
        ),
      ] else
        FilledButton(
          onPressed: _selected == null
              ? null
              : () => setState(() {
                  if (correct) _score++;
                  _answered = true;
                }),
          child: const Text('Comprobar respuesta'),
        ),
    ];
  }
}
