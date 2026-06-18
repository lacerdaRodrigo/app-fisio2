import 'package:flutter/material.dart';

import 'design_system.dart';

const String _appVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: '0.0.0',
);

/// Versão do app no formato `vX.Y.Z`, vinda do `--dart-define=APP_VERSION`.
String get appVersao => 'v${_appVersion.split('+').first}';

/// Sobrepõe a versão do app, fixa no canto inferior direito de qualquer tela.
///
/// Usado no `builder` do [MaterialApp] para aparecer em TODAS as telas/rotas
/// sem precisar adicionar manualmente em cada uma. Não intercepta toques
/// (`IgnorePointer`) e respeita a área segura do dispositivo (`SafeArea`).
class VersaoOverlay extends StatelessWidget {
  const VersaoOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(right: 10, bottom: 4),
                child: Text(
                  appVersao,
                  style: const TextStyle(
                    fontSize: 10,
                    color: FisioCores.textMuted,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
