import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

void main() {
  patrolTest(
    'SMOKE: App inicia e tela de login aparece',
    ($) async {
      // Aguarda o app renderizar
      await $.pumpAndSettle();

      // Verifica que a tela de login está visível
      expect(
        find.text(E2EConfig.Selectors.appTitle),
        findsWidgets,
        reason: 'Tela de login deve exibir título FisioCare',
      );

      // Verifica elementos básicos
      expect(
        find.byType(Checkbox),
        findsWidgets,
        reason: 'Checkbox de termos deve estar visível',
      );

      expect(
        find.byType(ElevatedButton),
        findsWidgets,
        reason: 'Botão de login deve estar visível',
      );

      print('✅ App iniciou corretamente');
    },
  );

  patrolTest(
    'SMOKE: Checkbox pode ser marcado',
    ($) async {
      await $.pumpAndSettle();

      // Encontra o checkbox
      final checkbox = find.byType(Checkbox).first;
      expect(checkbox, findsOneWidget);

      // Marca o checkbox
      await $.tap(checkbox);
      await $.pumpAndSettle();

      print('✅ Checkbox foi clicado corretamente');
    },
  );

  patrolTest(
    'SMOKE: Botão login pode ser tocado',
    ($) async {
      await $.pumpAndSettle();

      // Encontra o botão
      final button = find.byType(ElevatedButton).first;
      expect(button, findsOneWidget);

      // Clica no botão
      await $.tap(button);
      await $.pumpAndSettle();

      // Verifica que error message apareceu (pois checkbox não foi marcado)
      expect(
        find.text('Você precisa aceitar'),
        findsWidgets,
        reason: 'Deve exibir erro de termos não aceitos',
      );

      print('✅ Botão login foi clicado corretamente');
    },
  );
}
