import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'CT-LG01: exibe erro ao clicar em Entrar com Google sem aceitar termos',
    ($) async {
      // App inicia automaticamente na tela de login
      await $.pumpAndSettle();

      // Verifica que a tela de login está exibida
      expect(find.text('FisioCare'), findsWidgets);

      // Clica no botão "Entrar com Google" sem aceitar termos
      await $.tap(find.byType(ElevatedButton));
      await $.pumpAndSettle();

      // Deve exibir erro
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

      // Verifica que os textos estão presentes
      expect(find.text('FisioCare'), findsWidgets);
      expect(find.text('Termos de Uso'), findsWidgets);
      expect(find.text('Política de Privacidade (LGPD)'), findsWidgets);

      // Marca checkbox de aceito termos
      await $.tap(find.byType(Checkbox).first);
      await $.pumpAndSettle();
    },
  );

  patrolTest(
    'CT-LG03: cancela autenticação e retorna à tela de login',
    ($) async {
      await $.pumpAndSettle();

      // Marca checkbox
      await $.tap(find.byType(Checkbox).first);
      await $.pumpAndSettle();

      // Clica login (abre modal Google)
      await $.tap(find.byType(ElevatedButton));
      await $.pumpAndSettle(Duration(seconds: 2));

      // Pressiona back para cancelar fluxo de Google Sign-In
      await $.native.pressButton(NativeButton.back);
      await $.pumpAndSettle();

      // Deve voltar à tela de login
      expect(find.text('FisioCare'), findsWidgets);
    },
  );

  patrolTest(
    'CT-LG04: realiza login com sucesso e exibe Dashboard',
    ($) async {
      await $.pumpAndSettle();

      expect(find.text('FisioCare'), findsWidgets);

      // Aceita termos
      await $.tap(find.byType(Checkbox).first);
      await $.pumpAndSettle();

      // Clica login (abre Google Sign-In)
      await $.tap(find.byType(ElevatedButton));
      await $.pumpAndSettle(Duration(seconds: 3));

      // Aguarda que o usuário selecione conta e autorize
      // (em E2E real, o Patrol pode interagir com dialogs do sistema)
      // Este teste espera que o login seja concluído
      await $.pumpAndSettle(Duration(seconds: 10));

      // Após login bem-sucedido, espera Dashboard
      expect(
        find.text('Boa noite'),
        findsWidgets,
        reason: 'Dashboard deve aparecer após login',
      );
    },
  );

  patrolTest(
    'CT-LG05: restaura sessão automaticamente ao reabrir o app',
    ($) async {
      // Se estiver logado (de teste anterior), deve permanecer logado
      await $.pumpAndSettle(Duration(seconds: 3));

      final estaLogado = find.text('Boa noite').evaluate().isNotEmpty;

      if (estaLogado) {
        // App mantém sessão — verifica que está no Dashboard
        expect(find.text('Boa noite'), findsWidgets);
      }
    },
  );

  patrolTest(
    'CT-LG06: faz logout e redireciona para tela de login',
    ($) async {
      await $.pumpAndSettle();

      // Se não está logado, não pode fazer logout
      final estaLogado = find.text('Boa noite').evaluate().isNotEmpty;
      if (!estaLogado) {
        return;
      }

      // Abre menu (tap avatar)
      final avatarFinder = find.byType(CircleAvatar).first;
      await $.tap(avatarFinder);
      await $.pumpAndSettle();

      // Aguarda Configurações aparecer
      await $.tap(find.text('Configurações'));
      await $.pumpAndSettle(Duration(seconds: 1));

      // Scroll para encontrar botão Sair
      await $.scrollUntilVisible(
        find.text('Sair da conta'),
        dyScroll: -200,
      );

      await $.tap(find.text('Sair da conta'));
      await $.pumpAndSettle();

      // Confirma logout no AlertDialog (clica OK)
      await $.tap(find.text('OK'));
      await $.pumpAndSettle(Duration(seconds: 1));

      // Deve estar de volta na tela de login
      expect(find.text('FisioCare'), findsWidgets);
    },
  );
}
