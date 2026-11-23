import 'dart:async';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_session.dart';
import 'features/auth/ui/lamp_login_view.dart';
import 'features/privacy/ui/privacy_gate_view.dart';
import 'features/shell/ui/app_shell.dart';
import 'features/learning/ui/learning_graph_view.dart';

class PiuttecApp extends StatefulWidget {
  const PiuttecApp({super.key});

  @override
  State<PiuttecApp> createState() => _PiuttecAppState();
}

class _PiuttecAppState extends State<PiuttecApp> {
  AuthSession? _session;
  AuthSession? _candidateSession;
  bool _enteredDemo = false;
  bool _pendingPrivacy = false;
  Timer? _refreshTimer;
  bool _refreshing = false;

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    if (_session == null) return;
    _refreshTimer = Timer.periodic(const Duration(minutes: 4), (_) async {
      if (_session == null || _refreshing) return;
      _refreshing = true;
      final previous = _session!;
      try {
        final updated = await AuthApi().refreshSession(previous);
        if (mounted && identical(_session, previous)) {
          setState(() => _session = updated);
        }
      } catch (_) {
        if (mounted && identical(_session, previous)) _resetAccess();
      } finally {
        _refreshing = false;
      }
    });
  }

  void _beginAccess(AuthSession? session) => setState(() {
    _candidateSession = session;
    _pendingPrivacy = true;
  });

  void _acceptNotice() {
    setState(() {
    _session = _candidateSession;
    _enteredDemo = _candidateSession == null;
    _candidateSession = null;
    _pendingPrivacy = false;
    });
    _scheduleRefresh();
  }

  void _resetAccess() {
    final current = _session ?? _candidateSession;
    if (current != null) {
      unawaited(AuthApi().signOut(current).catchError((Object _) {}));
    }
    _refreshTimer?.cancel();
    setState(() {
    _session = null;
    _candidateSession = null;
    _enteredDemo = false;
    _pendingPrivacy = false;
    });
  }

  void _updateProfile(UserProfile profile) {
    final current = _session;
    if (current == null || !mounted) return;
    setState(() => _session = current.copyWith(username: profile.username,
      role: profile.isStaff ? 'administrator' : profile.role));
  }

  @override
  Widget build(BuildContext context) {
    final entered = _session != null || _enteredDemo;
    return MaterialApp(
      title: 'PIUTTEC 2.0',
      debugShowCheckedModeBanner: false,
      routes: {'/neurona': (context) => const Scaffold(body: LearningGraphView())},
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: _pendingPrivacy
          ? Stack(children: [
              AbsorbPointer(
                absorbing: true,
                child: ExcludeFocus(
                  excluding: true,
                  child: AppShell(
                    demoMode: _candidateSession == null,
                    username: _candidateSession?.username,
                    onLogout: _resetAccess,
                    accessToken: _candidateSession?.accessToken,
                    isAdministrator: _candidateSession?.isAdministrator ?? false,
                    onProfileUpdated: _updateProfile,
                  ),
                ),
              ),
              const ModalBarrier(dismissible: false, color: Colors.black54),
              Center(child: PrivacyGateView(onAccepted: _acceptNotice, onBack: _resetAccess)),
            ])
          : entered
              ? AppShell(
                  onLogout: _resetAccess,
                  demoMode: _session == null,
                  accessToken: _session?.accessToken,
                  isAdministrator: _session?.isAdministrator ?? false,
                  username: _session?.username,
                  onProfileUpdated: _updateProfile,
                )
              : LampLoginView(
                  onAuthenticated: (session) => _beginAccess(session),
                  onDemo: () => _beginAccess(null),
                ),
    );
  }
}
