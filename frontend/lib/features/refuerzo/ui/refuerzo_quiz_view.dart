import 'package:flutter/material.dart';

const _questions =
    <({String prompt, List<String> options, int answer, String explanation})>[
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

class RefuerzoQuizView extends StatefulWidget {
  const RefuerzoQuizView({super.key});

  @override
  State<RefuerzoQuizView> createState() => _RefuerzoQuizViewState();
}

class _RefuerzoQuizViewState extends State<RefuerzoQuizView> {
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finished = _index == _questions.length;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Fundamentos de redes digitales',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (finished) ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  'Resultado: $_score de ${_questions.length} aciertos',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => setState(() {
                  _index = 0;
                  _score = 0;
                }),
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
    final question = _questions[_index];
    final correct = _selected == question.answer;

    return [
      Semantics(
        liveRegion: true,
        child: Text('Pregunta ${_index + 1} de ${_questions.length}'),
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
          onPressed: () => setState(() {
            _index++;
            _selected = null;
            _answered = false;
          }),
          child: Text(
            _index + 1 == _questions.length
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
