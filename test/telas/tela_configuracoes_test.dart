import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fisio_home_care/telas/tela_configuracoes.dart';
import 'package:fisio_home_care/provedores/provedor_autenticacao.dart';
import '../helpers/fakes.dart';

Widget criarAppTeste() {
  return ProviderScope(
    overrides: [
      provedorServicoAutenticacaoGoogle.overrideWithValue(
        ServicoAutenticacaoGoogleFake(),
      ),
    ],
    child: const MaterialApp(home: TelaConfiguracoes()),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelaConfiguracoes', () {
    testWidgets('deve exibir o cartão Conta com o botão Sair', (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 2000));
      await tester.pumpWidget(criarAppTeste());
      await tester.pumpAndSettle();

      expect(find.text('Conta'), findsOneWidget);
      expect(find.text('Sair da conta'), findsOneWidget);
      expect(
        find.text('Desconecta o Google e volta ao login.'),
        findsOneWidget,
      );
    });

    testWidgets('botão Sair da conta abre diálogo de confirmação', (
      tester,
    ) async {
      await tester.pumpWidget(criarAppTeste());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sair da conta'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tem certeza?'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Sair'), findsOneWidget);
    });

    testWidgets('cancelar o diálogo mantém na tela de configurações', (
      tester,
    ) async {
      await tester.pumpWidget(criarAppTeste());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sair da conta'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(TelaConfiguracoes), findsOneWidget);
    });

    testWidgets('deve exibir o título Configurações', (tester) async {
      await tester.pumpWidget(criarAppTeste());
      await tester.pumpAndSettle();

      expect(find.text('Configurações'), findsOneWidget);
    });
  });
}
