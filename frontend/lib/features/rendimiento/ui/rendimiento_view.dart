import 'package:flutter/material.dart';

import '../data/rendimiento_repository.dart';

/// RF-04: análisis de las calificaciones del usuario.
/// Una comparación solo aparece cuando el backend acredita una muestra mínima.
class RendimientoView extends StatefulWidget {
  const RendimientoView({super.key, this.accessToken});

  final String? accessToken;

  @override
  State<RendimientoView> createState() => _RendimientoViewState();
}

class _RendimientoViewState extends State<RendimientoView> {
  late final RendimientoRepository _repository;
  ReporteRendimiento? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = RendimientoRepository(accessToken: widget.accessToken);
    _cargar();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repository.cargar();
      if (mounted) setState(() => _data = result);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _numero(double? value) => value == null ? '—' : value.toStringAsFixed(2);

  Widget _barra({required double valor, required Color color}) =>
      LinearProgressIndicator(
        value: (valor / 10).clamp(0.0, 1.0).toDouble(),
        minHeight: 9,
        borderRadius: BorderRadius.circular(8),
        color: color,
        backgroundColor: color.withValues(alpha: 0.12),
      );

  Widget _fila(MateriaRendimiento materia, ColorScheme colors) {
    final grupal = materia.promedioGrupal;
    return Card(
      key: ValueKey('rendimiento-${materia.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(child: Text(materia.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w700))),
              if (materia.grupo.trim().isNotEmpty)
                Text('Grupo ${materia.grupo}',
                    style: TextStyle(color: colors.onSurfaceVariant)),
            ]),
            const SizedBox(height: 14),
            Text('Mi calificación: ${_numero(materia.calificacion)} / 10'),
            const SizedBox(height: 6),
            if (materia.calificacion != null)
              _barra(valor: materia.calificacion!, color: colors.primary)
            else
              const Text('Aún no hay calificación registrada.'),
            const SizedBox(height: 12),
            if (grupal != null) ...[
              Text('Promedio del grupo: ${_numero(grupal)} / 10 '
                  '(${materia.participantes} participantes)'),
              const SizedBox(height: 6),
              _barra(valor: grupal, color: colors.tertiary),
              const SizedBox(height: 8),
              Text('Diferencia: ${materia.diferencia! > 0 ? '+' : ''}'
                  '${_numero(materia.diferencia)} puntos'),
            ] else
              Text(
                materia.estadoGrupal == 'sin_calificacion'
                    ? 'Registra tu calificación en Materias para comparar.'
                    : materia.estadoGrupal == 'sin_grupo'
                        ? 'Asigna un grupo a la materia para habilitar la comparación.'
                        : materia.estadoGrupal == 'sin_datos_grupales_demo'
                            ? 'Vista previa: no hay datos de otros estudiantes.'
                            : 'Comparación grupal no disponible: muestra insuficiente.',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final data = _data;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Mi rendimiento',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    )),
            IconButton(
              tooltip: 'Actualizar rendimiento',
              onPressed: _loading ? null : _cargar,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loading) const LinearProgressIndicator(),
        if (_error != null) ...[
          Card(child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(children: [
              Text(_error!),
              TextButton(onPressed: _cargar, child: const Text('Reintentar')),
            ]),
          )),
        ],
        if (!_loading && _error == null && data != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Wrap(spacing: 28, runSpacing: 12, children: [
                _metrica('Promedio personal', _numero(data.promedioPersonal), colors),
                _metrica('Materias evaluadas', '${data.evaluadas}', colors),
                _metrica('Sin calificación', '${data.sinCalificar}', colors),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Text(data.aviso, style: TextStyle(color: colors.onSurfaceVariant)),
          const SizedBox(height: 16),
          if (data.materias.isEmpty)
            const Card(child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Aún no registras materias. Agrégalas en Academia.'),
            ))
          else ...[
            Text('Comparación por materia',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final materia in data.materias) _fila(materia, colors),
          ],
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'El promedio grupal se muestra únicamente con '
              '${data.minimoGrupal} o más participantes distintos. '
              'La calificación personal se obtiene de Materias y calificaciones.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }

  Widget _metrica(String label, String value, ColorScheme colors) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: colors.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 23,
        )),
      ]);
}
