import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../data/auth_session.dart';
import 'registration_view.dart';

/// Adaptación nativa Flutter de la lámpara SVG del HTML aportado.
/// La cuerda se puede tocar, arrastrar o activar con el botón de accesibilidad.
class LampLoginView extends StatefulWidget {
  const LampLoginView({super.key, required this.onAuthenticated, required this.onDemo});
  final ValueChanged<AuthSession> onAuthenticated;
  final VoidCallback onDemo;

  @override
  State<LampLoginView> createState() => _LampLoginViewState();
}

class _LampLoginViewState extends State<LampLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final AudioPlayer _switchAudio = AudioPlayer();
  bool _lampOn = false;
  bool _obscure = true;
  bool _loading = false;
  double _pull = 0;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    unawaited(_switchAudio.dispose());
    super.dispose();
  }

  // La cuerda es la interacción primaria. Reutilizamos el mismo MP3 remoto
  // citado por el HTML original del usuario; requiere acceso a Internet.
  static const String _originalClickSoundUrl = 'https://assets.codepen.io/605876/click.mp3';
  void _toggleLamp() {
    setState(() { _lampOn = !_lampOn; _pull = 0; });
    unawaited(_playSwitchSound());
  }

  Future<void> _playSwitchSound() async {
    try {
      await _switchAudio.stop();
      await _switchAudio.play(UrlSource(_originalClickSoundUrl));
    } catch (_) {
      // Si el navegador bloquea el audio, el acceso sigue disponible.
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate() || _loading) return;
    setState(() { _loading = true; _error = null; });
    try {
      final session = await AuthApi().signIn(_username.text, _password.text);
      _password.clear();
      if (mounted) widget.onAuthenticated(session);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error is FormatException
              ? error.message.toString()
              : 'No fue posible conectar con Django. Comprueba que la API local esté iniciada.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openRegistration() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => RegistrationView(onRegistered: widget.onAuthenticated),
    ));
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF087C49);
    return Scaffold(
      backgroundColor: const Color(0xFF111A29),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 550),
              opacity: _lampOn ? 1 : 0,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.23, -0.15),
                    radius: 0.95,
                    colors: [Color(0x660DA66B), Color(0x24236650), Color(0x00111A29)],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 760;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.asset(
                                  'assets/branding/piuttec-ii-logo.png',
                                  height: 54, width: 190, fit: BoxFit.contain,
                                  semanticLabel: 'PIUTTEC II',
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Flex(
                            direction: wide ? Axis.horizontal : Axis.vertical,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: wide ? 390 : 320,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 300,
                                      height: 370,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: CustomPaint(
                                              painter: _LampPainter(on: _lampOn, pull: _pull),
                                            ),
                                          ),
                                          // Zona táctil INVISIBLE ubicada sobre la cuerda,
                                          // no es un botón visual que sustituya el jalón.
                                          Positioned(
                                            left: 155,
                                            top: 135,
                                            width: 80,
                                            height: 190,
                                            child: Semantics(
                                              label: _lampOn ? 'Apagar lámpara' : 'Jalar cuerda para encender la lámpara',
                                              hint: 'Arrastra hacia abajo y suelta; también puedes activar con teclado.',
                                              button: true,
                                              child: GestureDetector(
                                                key: const Key('lamp-pull-switch'),
                                                behavior: HitTestBehavior.opaque,
                                                onTap: _toggleLamp,
                                                onVerticalDragUpdate: (details) {
                                                  setState(() => _pull = (_pull + details.delta.dy).clamp(0.0, 60.0).toDouble());
                                                },
                                                onVerticalDragEnd: (_) {
                                                  if (_pull >= 30) {
                                                    _toggleLamp();
                                                  } else {
                                                    setState(() => _pull = 0);
                                                  }
                                                },
                                                child: const SizedBox.expand(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text('Jala la cuerda y suéltala para encender o apagar.', style: TextStyle(color: Color(0xFFAFC1D5))),
                                  ],
                                ),
                              ),
                              if (wide) const SizedBox(width: 45) else const SizedBox(height: 34),
                              if (wide)
                                Flexible(child: _loginPanel(green))
                              else
                                _loginPanel(green),
                            ],
                          ),
            
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginPanel(Color green) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 470),
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _lampOn ? 1 : 0,
      child: _buildForm(green),
    ),
  );

  Widget _buildForm(Color green) {
    return Container(
      padding: const EdgeInsets.all(27),
      decoration: BoxDecoration(
        color: const Color(0xE51B2A3C),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFF356654)),
        boxShadow: const [BoxShadow(color: Color(0x35000000), blurRadius: 30, offset: Offset(0, 12))],
      ),
      child: ExcludeFocus(
        excluding: !_lampOn,
        child: IgnorePointer(
          ignoring: !_lampOn,
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Iniciar sesión', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 26),
              TextFormField(
                controller: _username,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.white),
                decoration: _field('Usuario', Icons.person_outline),
                validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el usuario' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                style: const TextStyle(color: Colors.white),
                onFieldSubmitted: (_) => _signIn(),
                decoration: _field('Contraseña', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Ingresa una contraseña' : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(_error!, style: const TextStyle(color: Color(0xFFFFB6A5))),
              ],
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _loading ? null : _signIn,
                icon: _loading
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.login),
                label: const Text('Iniciar sesión'),
                style: FilledButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                key: const Key('auth-open-registration'),
                onPressed: _loading ? null : _openRegistration,
                icon: const Icon(Icons.person_add_alt_outlined),
                label: const Text('Crear cuenta'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF91E9B8)),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: widget.onDemo,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Vista previa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF91E9B8),
                  side: const BorderSide(color: Color(0xFF38AC7C), width: 1.25),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  InputDecoration _field(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xFFCCD8E4)),
    prefixIcon: Icon(icon, color: const Color(0xFF75DCAD)),
    filled: true,
    fillColor: const Color(0xFF203749),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF496C67)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF21C584), width: 2),
    ),
  );
}

class _LampPainter extends CustomPainter {
  const _LampPainter({required this.on, required this.pull});
  final bool on;
  final double pull;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 200;
    final sy = size.height / 300;
    canvas.save();
    canvas.scale(sx, sy);
    if (on) {
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(100, 125), width: 210, height: 210),
        Paint()..shader = const RadialGradient(
          colors: [Color(0x8A4AE6A0), Color(0x004AE6A0)],
        ).createShader(const Rect.fromLTWH(-5, 20, 210, 210)),
      );
    }
    final base = Paint()..color = const Color(0xFFCCC7BF);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(92, 100, 16, 160), const Radius.circular(8)), base);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(60, 250, 80, 12), const Radius.circular(6)), base);
    canvas.drawLine(
      const Offset(130, 110),
      Offset(130, 180 + pull),
      Paint()..color = const Color(0xFFD0B08E)..strokeWidth = 2,
    );
    canvas.drawCircle(Offset(130, 190 + pull), 6, Paint()..color = on ? const Color(0xFF42C98E) : const Color(0xFFC7B5A2));
    final shade = Path()
      ..moveTo(30, 110)
      ..cubicTo(30, 50, 170, 50, 170, 110)
      ..cubicTo(170, 125, 30, 125, 30, 110)
      ..close();
    canvas.drawPath(shade, Paint()..color = on ? const Color(0xFFF1FFF6) : const Color(0xFFF0E8DD));
    if (on) {
      canvas.drawPath(shade, Paint()
        ..color = const Color(0x993DEC9A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LampPainter oldDelegate) => on != oldDelegate.on || pull != oldDelegate.pull;
}
