import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fisio_home_care/telas/tela_login.dart';
import 'package:fisio_home_care/provedores/provedor_autenticacao.dart';
import 'package:fisio_home_care/servicos/servico_autenticacao_google.dart';
import '../../unitarios/auxiliares/fakes.dart';

/// Fake cujo [entrar] só completa quando o teste mandar, permitindo
/// inspecionar o estado de carregamento sem disparar a navegação real.
class ServicoAutenticacaoGoogleControlavel
    implements ServicoAutenticacaoGoogle {
  final _entrar = Completer<SessaoGoogle>();
  bool entrarFoiChamado = false;

  @override
  Stream<ContaGoogleConectada> get contasConectadas => const Stream.empty();

  @override
  Stream<SessaoGoogle> get sessoesConectadas => const Stream.empty();

  @override
  Future<void> inicializar() async {}

  @override
  Future<SessaoGoogle?> tentarRestaurarSessao() async => null;

  @override
  Future<SessaoGoogle> entrar() {
    entrarFoiChamado = true;
    return _entrar.future;
  }

  @override
  Future<void> sair() async {}
}

Widget criarAppTeste(ServicoAutenticacaoGoogle servico) {
  return ProviderScope(
    overrides: [
      provedorServicoAutenticacaoGoogle.overrideWithValue(servico),
    ],
    child: const MaterialApp(home: TelaLogin()),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TelaLogin', () {
    testWidgets('deve exibir título, subtítulo e botão Entrar com Google', (
      tester,
    ) async {
      await tester.pumpWidget(criarAppTeste(ServicoAutenticacaoGoogleFake()));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Fisio', findRichText: true),
        findsWidgets,
      );
      expect(
        find.textContaining('Care', findRichText: true),
        findsWidgets,
      );
      expect(
        find.text('Gestão inteligente para sua rotina domiciliar.'),
        findsOneWidget,
      );
      expect(find.text('Entrar com Google'), findsOneWidget);
      expect(find.byIcon(Icons.medical_services_rounded), findsOneWidget);
    });

    testWidgets('deve exibir checkbox de termos e os links legais', (
      tester,
    ) async {
      await tester.pumpWidget(criarAppTeste(ServicoAutenticacaoGoogleFake()));
      await tester.pumpAndSettle();

      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('Termos de Uso'), findsOneWidget);
      expect(find.text('Política de Privacidade (LGPD)'), findsOneWidget);
    });

    testWidgets('checkbox começa desmarcado e sem mensagem de erro', (
      tester,
    ) async {
      await tester.pumpWidget(criarAppTeste(ServicoAutenticacaoGoogleFake()));
      await tester.pumpAndSettle();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('tocar no checkbox marca os termos como aceitos', (
      tester,
    ) async {
      await tester.pumpWidget(criarAppTeste(ServicoAutenticacaoGoogleFake()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets(
      'entrar sem aceitar os termos exibe mensagem de erro e não chama o serviço',
      (tester) async {
        final servico = ServicoAutenticacaoGoogleControlavel();
        await tester.pumpWidget(criarAppTeste(servico));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        expect(
          find.text('Você precisa aceitar os Termos de Uso e LGPD.'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(servico.entrarFoiChamado, isFalse);
      },
    );

    testWidgets(
      'aceitar termos e entrar chama o serviço e exibe indicador de carregamento',
      (tester) async {
        final servico = ServicoAutenticacaoGoogleControlavel();
        await tester.pumpWidget(criarAppTeste(servico));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(servico.entrarFoiChamado, isTrue);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );
  });
}
