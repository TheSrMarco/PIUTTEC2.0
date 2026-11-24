import 'package:flutter/material.dart';
import '../../auth/data/auth_session.dart';

/// CRUD administrativo. La API valida permisos; ocultar esta vista no es seguridad.
class UsersAdminView extends StatefulWidget {
  const UsersAdminView({super.key, required this.accessToken});
  final String accessToken;

  @override
  State<UsersAdminView> createState() => _UsersAdminViewState();
}

class _UsersAdminViewState extends State<UsersAdminView> {
  List<UserProfile> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _refresh(); }

  Future<void> _refresh() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await AuthApi().listUsers(widget.accessToken);
      if (mounted) setState(() => _users = list);
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _message(Object error) => error is FormatException
      ? error.message.toString() : 'No se pudo conectar con Django.';

  void _notice(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createUser() async {
    final user = TextEditingController();
    final email = TextEditingController();
    final first = TextEditingController();
    final last = TextEditingController();
    final pass = TextEditingController();
    final form = GlobalKey<FormState>();
    var authorized = false;
    final details = await showDialog<List<String>>(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, update) => AlertDialog(
        title: const Text('Nuevo usuario de prueba'),
        content: SingleChildScrollView(child: SizedBox(width: 400, child: Form(key: form, child: Column(
          mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: user, decoration: const InputDecoration(labelText: 'Usuario'),
              validator: (v) => (v ?? '').trim().length < 3 ? 'Mínimo 3 caracteres' : null),
            TextFormField(controller: email, decoration: const InputDecoration(labelText: 'Correo'),
              validator: (v) => (v ?? '').contains('@') ? null : 'Correo inválido'),
            TextField(controller: first, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: last, decoration: const InputDecoration(labelText: 'Apellidos')),
            TextFormField(controller: pass, obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña temporal'),
              validator: (v) => (v ?? '').length < 8 ? 'Mínimo 8 caracteres' : null),
            CheckboxListTile(contentPadding: EdgeInsets.zero, value: authorized,
              onChanged: (v) => update(() => authorized = v ?? false),
              title: const Text('Cuento con autorización para registrar esta cuenta.'),
            ),
          ],
        )))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: authorized ? () {
            if (form.currentState!.validate()) {
              Navigator.pop(ctx, [user.text, email.text,
                first.text, last.text, pass.text]);
            }
          } : null, child: const Text('Crear')),
        ],
      ),
    ));
    // No usamos el estado de los TextField una vez cerrado el diálogo.
    if (details == null || !mounted) return;
    try {
      await AuthApi().createUser(widget.accessToken, username: details[0],
        email: details[1], firstName: details[2], lastName: details[3], password: details[4]);
      _notice('Usuario creado con rol estudiante.');
      await _refresh();
    } catch (error) { _notice(_message(error)); }
  }

  Future<void> _edit(UserProfile record) async {
    var role = record.role;
    var active = record.isActive;
    final username = TextEditingController(text: record.username);
    final email = TextEditingController(text: record.email);
    final form = GlobalKey<FormState>();
    final result = await showDialog<Map<String, dynamic>>(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, update) => AlertDialog(
        title: Text('Editar #${record.id}'),
        content: SizedBox(width: 380, child: Form(key: form, child: Column(
          mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: username,
              decoration: const InputDecoration(labelText: 'Usuario'),
              validator: (v) => (v ?? '').trim().length < 3 ? 'Mínimo 3 caracteres' : null),
            TextFormField(controller: email,
              decoration: const InputDecoration(labelText: 'Correo'),
              validator: (v) => (v ?? '').contains('@') ? null : 'Correo inválido'),
            DropdownButtonFormField<String>(initialValue: role,
              decoration: const InputDecoration(labelText: 'Rol'),
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Estudiante')),
                DropdownMenuItem(value: 'teacher', child: Text('Docente')),
                DropdownMenuItem(value: 'administrator', child: Text('Administrador')),
              ],
              onChanged: (v) { if (v != null) update(() => role = v); }),
            SwitchListTile(value: active, onChanged: (v) => update(() => active = v),
              title: const Text('Cuenta activa')),
          ],
        ))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: () {
            if (form.currentState!.validate()) {
              Navigator.pop(ctx, {
                'role': role, 'active': active,
                'username': username.text.trim(), 'email': email.text.trim(),
              });
            }
          }, child: const Text('Guardar')),
        ],
      ),
    ));
    if (result == null || !mounted) return;
    try {
      await AuthApi().updateUser(widget.accessToken, record,
        role: result['role'] as String, isActive: result['active'] as bool,
        username: result['username'] as String, email: result['email'] as String);
      _notice('Cuenta actualizada.');
      await _refresh();
    } catch (error) { _notice(_message(error)); }
  }

  Future<void> _delete(UserProfile user) async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Eliminar usuario'),
      content: Text('¿Eliminar a ${user.username}? La operación no se puede deshacer.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
      ],
    ));
    if (confirmed != true || !mounted) return;
    try {
      await AuthApi().deleteUser(widget.accessToken, user.id);
      _notice('Cuenta eliminada o anonimizada.');
      await _refresh();
    } catch (error) { _notice(_message(error)); }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(spacing: 12, runSpacing: 10, alignment: WrapAlignment.spaceBetween,
        children: [
          Text('Gestión de usuarios', style: Theme.of(context).textTheme.headlineSmall),
          Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(tooltip: 'Actualizar', onPressed: _refresh, icon: const Icon(Icons.refresh)),
            FilledButton.icon(onPressed: _createUser,
              icon: const Icon(Icons.person_add_outlined), label: const Text('Crear usuario')),
          ]),
        ]),
      const SizedBox(height: 16),
      if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      Expanded(child: _loading
        ? const Center(child: CircularProgressIndicator())
        : _users.isEmpty ? const Center(child: Text('No hay usuarios registrados.'))
        : ListView.separated(itemCount: _users.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = _users[index];
              return ListTile(
                title: Text(user.username),
                subtitle: Text('${user.email} · ${user.role} · ${user.isActive ? 'Activa' : 'Inactiva'}'),
                leading: Icon(user.isActive ? Icons.person_outline : Icons.person_off_outlined),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(tooltip: 'Editar', onPressed: () => _edit(user),
                    icon: const Icon(Icons.edit_outlined)),
                  IconButton(tooltip: 'Eliminar', onPressed: () => _delete(user),
                    icon: const Icon(Icons.delete_outline)),
                ]),
              );
            })),
    ]),
  );
}
