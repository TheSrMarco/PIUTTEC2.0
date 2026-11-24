import 'package:flutter/material.dart';
import '../data/auth_session.dart';
import '../../privacy/ui/privacy_notice_view.dart';

/// Registro auténtico en Django, exclusivamente con rol estudiante.
class RegistrationView extends StatefulWidget {
  const RegistrationView({super.key, required this.onRegistered, this.api});
  final ValueChanged<AuthSession> onRegistered;
  final AuthApi? api;

  @override
  State<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _acceptedPrivacy = false;
  bool _visiblePassword = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in [_username, _email, _first, _last, _password, _confirm]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (_busy || !_form.currentState!.validate()) return;
    if (!_acceptedPrivacy) {
      setState(() => _error = 'Debes confirmar que leíste la información de privacidad del prototipo.');
      return;
    }
    setState(() { _busy = true; _error = null; });
    try {
      final api = widget.api ?? AuthApi();
      await api.register(username: _username.text, email: _email.text,
        firstName: _first.text, lastName: _last.text, password: _password.text,
        passwordConfirm: _confirm.text, acceptedPrivacy: _acceptedPrivacy);
      final session = await api.signIn(_username.text, _password.text);
      _password.clear();
      _confirm.clear();
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onRegistered(session);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error is FormatException ? error.message.toString()
        : 'No fue posible conectar con Django. Verifica que el servidor esté encendido.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showNotice() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Privacidad del prototipo')),
      body: const PrivacyNoticeView(),
    )));
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder(),
  );

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF087C49);
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta'), backgroundColor: const Color(0xFF103B32),
        foregroundColor: Colors.white),
      body: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 610), child: Card(
          child: Padding(padding: const EdgeInsets.all(24), child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Icon(Icons.person_add_alt_1_outlined, color: green, size: 40),
              const SizedBox(height: 8),
              Text('Registro de estudiante', style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center),
              const SizedBox(height: 6),
              const Text('Crea tu cuenta de prueba para acceder a las funciones conectadas a Django.',
                textAlign: TextAlign.center),
              const SizedBox(height: 20),
              TextFormField(key: const Key('register-username'), controller: _username,
                decoration: _decoration('Nombre de usuario', Icons.person_outline),
                textInputAction: TextInputAction.next,
                validator: (v) => (v ?? '').trim().length < 3 ? 'Escribe al menos 3 caracteres.' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _first, textInputAction: TextInputAction.next,
                decoration: _decoration('Nombre', Icons.badge_outlined)),
              const SizedBox(height: 12),
              TextFormField(controller: _last, textInputAction: TextInputAction.next,
                decoration: _decoration('Apellidos', Icons.badge_outlined)),
              const SizedBox(height: 12),
              TextFormField(key: const Key('register-email'), controller: _email,
                keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next,
                decoration: _decoration('Correo electrónico', Icons.alternate_email),
                validator: (v) => (v ?? '').contains('@') ? null : 'Escribe un correo válido.'),
              const SizedBox(height: 12),
              TextFormField(key: const Key('register-password'), controller: _password,
                obscureText: !_visiblePassword,
                decoration: _decoration('Contraseña', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(tooltip: 'Mostrar u ocultar contraseña',
                    onPressed: () => setState(() => _visiblePassword = !_visiblePassword),
                    icon: Icon(_visiblePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined))),
                validator: (v) => (v ?? '').length < 8 ? 'Mínimo 8 caracteres.' : null),
              const SizedBox(height: 12),
              TextFormField(key: const Key('register-confirm'), controller: _confirm,
                obscureText: !_visiblePassword,
                decoration: _decoration('Confirmar contraseña', Icons.lock_reset_outlined),
                validator: (v) => v != _password.text ? 'Las contraseñas no coinciden.' : null),
              const SizedBox(height: 12),
              TextButton.icon(onPressed: _showNotice,
                icon: const Icon(Icons.privacy_tip_outlined), label: const Text('Leer información de privacidad')),
              CheckboxListTile(key: const Key('register-privacy'),
                contentPadding: EdgeInsets.zero,
                value: _acceptedPrivacy,
                onChanged: _busy ? null : (value) => setState(() => _acceptedPrivacy = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Leí la información de privacidad y entiendo que esta cuenta es de prueba.'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 14),
              FilledButton.icon(key: const Key('register-submit'),
                style: FilledButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50)),
                onPressed: _busy ? null : _register,
                icon: _busy ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.person_add_alt),
                label: const Text('Registrarme'),
              ),
              const SizedBox(height: 8),
              const Text('El registro público asigna únicamente el rol Estudiante.',
                style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
            ]),
          )),
        ))),
      ),
    );
  }
}
