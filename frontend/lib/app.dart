import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/data/session_controller.dart';
import 'features/auth/ui/login_view.dart';
import 'features/auth/ui/registration_preview.dart';
import 'features/shell/ui/app_shell.dart';

class PiuttecApp extends StatelessWidget {
  const PiuttecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIUTTEC 2.0',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: const Locale('es', 'MX'),
      supportedLocales: const [Locale('es', 'MX')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const _EntryGate(),
    );
  }
}

class _EntryGate extends StatefulWidget {
  const _EntryGate();
  @override
  State<_EntryGate> createState() => _EntryGateState();
}

class _EntryGateState extends State<_EntryGate> {
  final _session = SessionController();
  bool _entered = false;
  bool _showLogin = false;
  bool _authenticatedEntry = false;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  void _openLogin() {
    setState(() {
      _entered = false;
      _showLogin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _session,
      builder: (context, _) {
        if (_entered && (!_authenticatedEntry || _session.user != null)) {
          return AppShell(
            key: ValueKey(_session.user?.id),
            session: _session,
            onLogin: _openLogin,
            onLogout: () {
              _session.logout();
              setState(() {
                _entered = false;
                _authenticatedEntry = false;
                _showLogin = true;
              });
            },
          );
        }
        if (_showLogin || _authenticatedEntry) {
          return LoginView(
            session: _session,
            onLoggedIn: () => setState(() {
              _entered = true;
              _authenticatedEntry = true;
              _showLogin = false;
            }),
            onBack: () => setState(() {
              _authenticatedEntry = false;
              _showLogin = false;
            }),
          );
        }
        return RegistrationPreview(
          onLogin: _openLogin,
          onContinue: () => setState(() {
            _entered = true;
            _authenticatedEntry = false;
          }),
        );
      },
    );
  }
}
