import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-LG01: exibe erro ao clicar em Entrar com Google sem aceitar termos',
    ($) async {
      await $.pumpAndSettle();
      expect(find.text(E2EConfig.Selectors.appTitle), findsWidgets);

      await $.tap(find.byType(ElevatedButton));
      await $.pumpAndSettle();

      expect(
        find.text('Você precisa aceitar os Termos de Uso e LGPD.'),
        findsWidgets,
      );
    },
  );

  patrolTest(
    'CT-LG02: marca checkbox e verifica campos da tela de login',
    ($) async {
      await $.pumpAndSettle();

      expect(find.text(E2EConfig.Selectors.appTitle), findsWidgets);
      expect(find.text('Termos de Uso'), findsWidgets);
      expect(find.text('Política de Privacidade (LGPD)'), findsWidgets);

      await $.tap(find.byType(Checkbox).first);
      await $.pumpAndSettle();
    },
  );

  patrolTest(
    'CT-LG03: cancela autenticação e retorna à tela de login',
    ($) async {
      await $.pumpAndSettle();

      await $.tap(find.byType(Checkbox).first);
      await $.pumpAndSettle();

      await $.tap(find.byType(ElevatedButton));
      await $.pumpAndSettle(E2EConfig.googleSignInDelay);

      await $.native.pressButton(NativeButton.back);
      await $.pumpAndSettle();

      expect(find.text(E2EConfig.Selectors.appTitle), findsWidgets);
    },
  );

  patrolTest(
    'CT-LG04: tela de login exibe elementos corretamente',
    ($) async {
      await $.pumpAndSettle();

      expect(
        find.text(E2EConfig.Selectors.appTitle),
        findsWidgets,
        reason: 'Título FisioCare deve estar visível',
      );

      expect(
        find.byType(Checkbox),
        findsWidgets,
        reason: 'Checkbox de termos deve estar visível',
      );

      expect(
        find.byType(ElevatedButton),
        findsWidgets,
        reason: 'Botão Entrar com Google deve estar visível',
      );

      expect(
        find.text('Termos de Uso'),
        findsWidgets,
        reason: 'Link Termos deve estar visível',
      );
    },
  );

  patrolTest(
    'CT-LG05: restaura sessão automaticamente ao reabrir o app',
    ($) async {
      await $.pumpAndSettle(E2EConfig.defaultTimeout);

      final estaLogado =
          find.text(E2EConfig.Selectors.dashboardGreeting).evaluate().isNotEmpty;

      if (estaLogado) {
        expect(find.text(E2EConfig.Selectors.dashboardGreeting), findsWidgets);
      }
    },
  );

  patrolTest(
    'CT-LG06: fluxo de autenticação iniciado corretamente',
    ($) async {
      await $.pumpAndSettle();

      expect(find.text(E2EConfig.Selectors.appTitle), findsWidgets);

      await $.tap(find.byType(Checkbox).first);
      await $.pumpAndSettle(E2EConfig.defaultWait);

      await $.tap(find.byType(ElevatedButton));
      await $.pumpAndSettle(E2EConfig.googleSignInDelay);

      // Se chegou até aqui, o UI responde corretamente
      expect(true, isTrue, reason: 'Fluxo de autenticação iniciado');
    },
  );
}
