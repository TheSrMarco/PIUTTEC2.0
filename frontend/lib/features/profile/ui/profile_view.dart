import 'package:flutter/material.dart';
import '../../auth/data/auth_session.dart';

/// Lectura, actualización, cambio de contraseña y eliminación de cuenta.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.accessToken, required this.onUpdated,
    required this.onLoggedOut, this.api});
  final String accessToken;
  final ValueChanged<UserProfile> onUpdated;
  final VoidCallback onLoggedOut;
  final AuthApi? api;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  UserProfile? _profile;
  bool _loading = true;
  bool _saving = false;
  String? _message;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() {
    for (final controller in [_username, _first, _last, _email]) { controller.dispose(); }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final profile = await (widget.api ?? AuthApi()).getProfile(widget.accessToken);
      if (!mounted) return;
      setState(() {
        _profile = profile; _username.text = profile.username;
        _first.text = profile.firstName; _last.text = profile.lastName;
        _email.text = profile.email; _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _message = _errorText(e); });
    }
  }

  String _errorText(Object e) => e is FormatException ? e.message.toString()
      : 'No se pudo conectar con Django.';

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() { _saving = true; _message = null; });
    try {
      final profile = await (widget.api ?? AuthApi()).updateProfile(widget.accessToken,
        username: _username.text, email: _email.text,
        firstName: _first.text, lastName: _last.text);
      if (!mounted) return;
      setState(() { _profile = profile; _message = 'Perfil actualizado correctamente.'; });
      widget.onUpdated(profile);
    } catch (e) {
      if (mounted) setState(() => _message = _errorText(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    final key = GlobalKey<FormState>();
    final credentials = await showDialog<List<String>>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Cambiar contraseña'),
      content: Form(key: key, child: SizedBox(width: 360,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: current, obscureText: true,
            decoration: const InputDecoration(labelText: 'Contraseña actual'),
            validator: (v) => (v ?? '').isEmpty ? 'Obligatoria' : null),
          TextFormField(controller: next, obscureText: true,
            decoration: const InputDecoration(labelText: 'Nueva contraseña'),
            validator: (v) => (v ?? '').length < 8 ? 'Mínimo 8 caracteres' : null),
          TextFormField(controller: confirm, obscureText: true,
            decoration: const InputDecoration(labelText: 'Repetir nueva contraseña'),
            validator: (v) => v != next.text ? 'No coincide' : null),
        ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
        FilledButton(onPressed: () { if (key.currentState!.validate()) {
          Navigator.pop(dialogContext, [current.text, next.text, confirm.text]);
        } }, child: const Text('Cambiar')),
      ],
    ));
    if (credentials == null || !mounted) return;
    setState(() { _saving = true; _message = null; });
    try {
      await (widget.api ?? AuthApi()).changePassword(widget.accessToken,
        current: credentials[0], next: credentials[1], confirmation: credentials[2]);
      if (mounted) widget.onLoggedOut(); // Los tokens anteriores dejan de ser válidos.
    } catch (e) {
      if (mounted) setState(() => _message = _errorText(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('¿Eliminar tu cuenta?'),
      content: const Text('Perderás el acceso. Los trámites que deban conservarse por auditoría se anonimizarán; los demás datos de práctica se eliminarán.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Eliminar cuenta')),
      ],
    ));
    if (confirmed != true || !mounted) return;
    setState(() { _saving = true; _message = null; });
    try {
      await (widget.api ?? AuthApi()).deleteAccount(widget.accessToken);
      if (mounted) widget.onLoggedOut();
    } catch (e) {
      if (mounted) setState(() => _message = _errorText(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_profile == null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min,
        children: [Text(_message ?? 'No se pudo cargar el perfil.'),
          TextButton(onPressed: () { setState(() => _loading = true); _load(); },
            child: const Text('Reintentar'))]));
    }
    final profile = _profile!;
    return Center(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: Card(child: Padding(padding: const EdgeInsets.all(24), child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.account_circle_outlined, color: Color(0xFF087C49), size: 48),
          const SizedBox(height: 8),
          Text('Mi perfil', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Rol asignado: ${profile.role} · ID ${profile.id}', textAlign: TextAlign.center),
          const SizedBox(height: 22),
          TextFormField(key: const Key('profile-username'), controller: _username,
            decoration: const InputDecoration(labelText: 'Usuario', border: OutlineInputBorder()),
            validator: (v) => (v ?? '').trim().length < 3 ? 'Usuario demasiado corto' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _first,
            decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextFormField(controller: _last,
            decoration: const InputDecoration(labelText: 'Apellidos', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextFormField(key: const Key('profile-email'), controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Correo', border: OutlineInputBorder()),
            validator: (v) => (v ?? '').contains('@') ? null : 'Correo no válido'),
          if (_message != null) ...[
            const SizedBox(height: 12), Text(_message!, key: const Key('profile-message')),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(key: const Key('profile-save'),
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_outlined), label: const Text('Guardar cambios'),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF087C49),
              minimumSize: const Size.fromHeight(48))),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: _saving ? null : _changePassword,
            icon: const Icon(Icons.password), label: const Text('Cambiar contraseña')),
          const Divider(height: 38),
          TextButton.icon(onPressed: _saving ? null : _delete,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            icon: const Icon(Icons.delete_forever_outlined),
            label: const Text('Eliminar mi cuenta')),
        ]),
      ))),
    )));
  }
}
