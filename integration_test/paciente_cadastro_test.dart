import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'helpers.dart';

void main() {
  patrolTest(
    'CT-PC01: fluxo feliz — cadastra paciente com todos os campos válidos',
    ($) async {
      // Faz login primeiro
      final estaLogado = await TestHelpers.fazerLogin($);
      expect(estaLogado, true, reason: 'Deve estar logado');

      await TestHelpers.esperarDashboard($);

      // Navega para Pacientes
      await $.tap(find.text('Pacientes'));
      await $.pumpAndSettle();

      // Verifica que está na tela de Pacientes
      expect(find.text('Pacientes'), findsWidgets);

      // Clica em novo paciente (FAB ou botão)
      await $.tap(find.byIcon(Icons.add).first);
      await $.pumpAndSettle();

      // Aguarda tela de cadastro
      expect(find.text('Cadastrar Paciente'), findsWidgets);

      // Preenche nome
      await $.tap(find.byType(TextFormField).at(0));
      await $.enterText('João Silva');
      await $.pumpAndSettle();

      // Preenche CPF
      await $.tap(find.byType(TextFormField).at(1));
      await $.enterText('12345678901');
      await $.pumpAndSettle();

      // Preenche telefone
      await $.tap(find.byType(TextFormField).at(2));
      await $.enterText('11999999999');
      await $.pumpAndSettle();

      // Preenche data de nascimento
      await $.tap(find.byType(TextFormField).at(3));
      await $.enterText('01/01/1980');
      await $.pumpAndSettle();

      // Preenche endereço
      await $.tap(find.byType(TextFormField).at(4));
      await $.enterText('Rua Test, 123');
      await $.pumpAndSettle();

      // Clica botão Salvar Paciente
      await $.tap(find.text('Salvar Paciente'));
      await $.pumpAndSettle(Duration(seconds: 2));

      // Retorna à lista de pacientes
      expect(find.text('Pacientes'), findsWidgets);
      // Novo paciente deve aparecer na lista
      expect(find.text('João Silva'), findsWidgets);
    },
  );

  patrolTest(
    'CT-PC02: valida campos obrigatórios — mostra erro ao deixar vazio',
    ($) async {
      final estaLogado = await TestHelpers.fazerLogin($);
      expect(estaLogado, true);

      await TestHelpers.esperarDashboard($);

      // Navega para Pacientes
      await $.tap(find.text('Pacientes'));
      await $.pumpAndSettle();

      // Abre novo paciente
      await $.tap(find.byIcon(Icons.add).first);
      await $.pumpAndSettle();

      expect(find.text('Cadastrar Paciente'), findsWidgets);

      // Tenta salvar sem preencher nada
      await $.tap(find.text('Salvar Paciente'));
      await $.pumpAndSettle();

      // Deve exibir AlertDialog com campos obrigatórios
      expect(
        find.text('Campos obrigatórios'),
        findsWidgets,
        reason: 'Dialog deve indicar campos vazios',
      );

      // Fecha dialog (clica OK)
      await $.tap(find.text('OK'));
      await $.pumpAndSettle();

      // Continua na tela de cadastro
      expect(find.text('Cadastrar Paciente'), findsWidgets);
    },
  );

  patrolTest(
    'CT-PC03: valida CPF inválido',
    ($) async {
      final estaLogado = await TestHelpers.fazerLogin($);
      expect(estaLogado, true);

      await TestHelpers.esperarDashboard($);

      await $.tap(find.text('Pacientes'));
      await $.pumpAndSettle();

      await $.tap(find.byIcon(Icons.add).first);
      await $.pumpAndSettle();

      // Preenche nome válido
      await $.tap(find.byType(TextFormField).at(0));
      await $.enterText('João Silva');

      // Preenche CPF inválido (11 zeros)
      await $.tap(find.byType(TextFormField).at(1));
      await $.enterText('00000000000');
      await $.pumpAndSettle();

      // Preenche outros campos
      await $.tap(find.byType(TextFormField).at(2));
      await $.enterText('11999999999');

      await $.tap(find.byType(TextFormField).at(3));
      await $.enterText('01/01/1980');

      await $.tap(find.byType(TextFormField).at(4));
      await $.enterText('Rua Test, 123');
      await $.pumpAndSettle();

      // Tenta salvar
      await $.tap(find.text('Salvar Paciente'));
      await $.pumpAndSettle();

      // Deve exibir erro de CPF inválido
      expect(
        find.text('CPF inválido'),
        findsWidgets,
        reason: 'CPF 00000000000 é inválido',
      );
    },
  );

  patrolTest(
    'CT-PC04: navega e visualiza lista de pacientes',
    ($) async {
      final estaLogado = await TestHelpers.fazerLogin($);
      expect(estaLogado, true);

      await TestHelpers.esperarDashboard($);

      // Clica em Pacientes
      await $.tap(find.text('Pacientes'));
      await $.pumpAndSettle();

      // Verifica que lista está visível
      expect(find.text('Pacientes'), findsWidgets);

      // Deve ter filtros "Todos" e "Ativos"
      expect(find.text('Todos'), findsWidgets);
      expect(find.text('Ativos'), findsWidgets);

      // Se houver pacientes, devem aparecer listados
      // (este teste assume que pode haver pacientes já cadastrados)
    },
  );
}
