import 'package:flutter/material.dart';
import 'privacy_notice_view.dart';

/// Presenta información de privacidad del prototipo antes de entrar.
/// La confirmación de lectura habilita el calendario; no es consentimiento legal general.
class PrivacyGateView extends StatefulWidget {
  const PrivacyGateView({super.key, required this.onAccepted, required this.onBack});
  final VoidCallback onAccepted;
  final VoidCallback onBack;

  @override
  State<PrivacyGateView> createState() => _PrivacyGateViewState();
}

class _PrivacyGateViewState extends State<PrivacyGateView> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820, maxHeight: 760),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 22, 24, 12),
                child: Row(children: [
                  Icon(Icons.privacy_tip_outlined),
                  SizedBox(width: 12),
                  Expanded(child: Text('Privacidad del prototipo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                ]),
              ),
              const Divider(height: 1),
              // Texto actualizado específico del prototipo, sin atribución institucional.
              const Flexible(child: PrivacyNoticeView()),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  CheckboxListTile(
                    key: const Key('privacy-accept-checkbox'),
                    value: _accepted,
                    onChanged: (value) => setState(() => _accepted = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('He leído la información de privacidad y comprendo que utilizo un prototipo académico.'),
                  ),
                  Row(children: [
                    TextButton(onPressed: widget.onBack, child: const Text('Volver')),
                    const Spacer(),
                    FilledButton(
                      key: const Key('privacy-continue'),
                      onPressed: _accepted ? widget.onAccepted : null,
                      child: const Text('Continuar'),
                    ),
                  ]),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
