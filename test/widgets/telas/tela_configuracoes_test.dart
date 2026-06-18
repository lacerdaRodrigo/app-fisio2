import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fisio_home_care/telas/tela_configuracoes.dart';
import 'package:fisio_home_care/telas/tela_login.dart';
import 'package:fisio_home_care/provedores/provedor_autenticacao.dart';
import 'package:fisio_home_care/provedores/provedores_dados.dart';
import 'package:fisio_home_care/servicos/servico_repositorio_dados.dart';
import '../../unitarios/auxiliares/fakes.dart';

class FakeRepoConfig extends Fake implements RepositorioDadosGoogle {
  @override
  Future<void> salvarValorSessaoPadrao(String valor) async {}
}

class RepoConfigQueFalha extends Fake implements RepositorioDadosGoogle {
  @override
  Future<void> salvarValorSessaoPadrao(String valor) async {
    throw Exception('falha');
  }
}

class LogsComDados extends LogsAuditoriaNotifier {
  final List<String> _dados;
  LogsComDados(this._dados);
  @override
  List<String> build() => _dados;
}

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

Widget _app({
  RepositorioDadosGoogle? repositorio,
  List<String> logs = const [],
  String? planilhaId,
}) {
  return ProviderScope(
    overrides: [
      provedorServicoAutenticacaoGoogle.overrideWithValue(
        ServicoAutenticacaoGoogleFake(),
      ),
      if (repositorio != null)
        provedorRepositorioDados.overrideWith((ref) => repositorio),
      provedorLogsAuditoria.overrideWith(() => LogsComDados(logs)),
      if (planilhaId != null)
        provedorPlanilhaId.overrideWith(() => _PlanilhaIdFixo(planilhaId)),
    ],
    child: const MaterialApp(home: TelaConfiguracoes()),
  );
}

class _PlanilhaIdFixo extends PlanilhaIdNotifier {
  final String _id;
  _PlanilhaIdFixo(this._id);
  @override
  String? build() => _id;
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

  group('TelaConfiguracoes - Cobertura adicional', () {
    testWidgets('salvar valor vazio mostra aviso', (tester) async {
      await tester.pumpWidget(_app(repositorio: FakeRepoConfig()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Valor em R\$'),
        '',
      );
      await tester.tap(find.text('Salvar valor padrão'));
      await tester.pumpAndSettle();

      expect(find.text('Informe um valor padrão.'), findsOneWidget);
    });

    testWidgets('salvar valor com sucesso mostra confirmação', (tester) async {
      await tester.pumpWidget(_app(repositorio: FakeRepoConfig()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Valor em R\$'),
        '200,00',
      );
      await tester.tap(find.text('Salvar valor padrão'));
      await tester.pumpAndSettle();

      expect(find.text('Valor padrão salvo.'), findsOneWidget);
    });

    testWidgets('salvar valor com erro mostra snackbar de erro', (
      tester,
    ) async {
      await tester.pumpWidget(_app(repositorio: RepoConfigQueFalha()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Valor em R\$'),
        '200,00',
      );
      await tester.tap(find.text('Salvar valor padrão'));
      await tester.pumpAndSettle();

      expect(
        find.text('Ocorreu um erro inesperado. Tente novamente.'),
        findsOneWidget,
      );
    });

    testWidgets('logs de auditoria são exibidos quando existem', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(logs: ['10/06 - LOGIN - entrou', '10/06 - CADASTRO - paciente']),
      );
      await tester.pumpAndSettle();

      expect(find.text('10/06 - LOGIN - entrou'), findsOneWidget);
      expect(
        find.text('Nenhuma ação crítica registrada nesta sessão.'),
        findsNothing,
      );
    });

    testWidgets('visualizar termos abre e fecha o diálogo', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Visualizar Termos de Uso'));
      await tester.pumpAndSettle();

      expect(find.text('Termos de Uso e Privacidade'), findsOneWidget);
      await tester.tap(find.text('Fechar'));
      await tester.pumpAndSettle();

      expect(find.text('Termos de Uso e Privacidade'), findsNothing);
    });

    testWidgets('abrir planilha falha exibe snackbar', (tester) async {
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/url_launcher'),
            (call) async => false,
          );
      addTearDown(() {
        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/url_launcher'),
              null,
            );
      });

      await tester.pumpWidget(_app(planilhaId: 'ABC123'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Visualizar Planilha de Dados'));
      await tester.pumpAndSettle();

      expect(
        find.text('Não foi possível abrir o Google Sheets.'),
        findsOneWidget,
      );
    });

    testWidgets('confirmar logout navega para o login', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sair da conta'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      expect(find.byType(TelaLogin), findsOneWidget);
    });
  });
}
