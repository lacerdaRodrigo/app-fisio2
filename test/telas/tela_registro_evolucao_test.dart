import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fisio_home_care/modelos/paciente.dart';
import 'package:fisio_home_care/modelos/evolucao.dart';
import 'package:fisio_home_care/provedores/provedores_dados.dart';
import 'package:fisio_home_care/telas/tela_registro_evolucao.dart';
import 'package:fisio_home_care/telas/tela_historico_evolucoes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class EvolucoesNotifierComDados extends ListaEvolucoesNotifier {
  final List<Evolucao> _dados;

  EvolucoesNotifierComDados(this._dados);

  @override
  List<Evolucao> build() => _dados;
}

Paciente _paciente() => Paciente(
      idPaciente: 'P001',
      nome: 'João Silva',
      telefone: '11999999999',
      dataNascimento: DateTime(1990, 1, 1),
      cpf: '12345678901',
      endereco: 'Rua A',
    );

Evolucao _evolucao({required int diferencaHoras}) {
  return Evolucao(
    idEvolucao: 'E001',
    idPaciente: 'P001',
    idAgendamento: 'A001',
    dataAtendimento: DateTime.now(),
    evolucaoTexto: 'Paciente apresentou melhora significativa.',
    dataRegistro: DateTime.now().subtract(Duration(hours: diferencaHoras)),
    localAtendimento: 'Domicílio',
    statusPresenca: 'Presente',
    dorSessao: 3,
    horarioInicioReal: DateTime.now().subtract(const Duration(hours: 2)),
    horarioFimReal: DateTime.now().subtract(const Duration(hours: 1)),
    condicaoPaciente: 'Melhora',
    pressaoArterial: '120/80',
    frequenciaCardiaca: 72,
  );
}

Widget _criarAppRegistroEvolucao({
  Paciente? paciente,
  Evolucao? evolucaoExistente,
  List<Evolucao> evolucoes = const [],
}) {
  return ProviderScope(
    overrides: [
      provedorListaEvolucoes.overrideWith(
        () => EvolucoesNotifierComDados(evolucoes),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: TelaRegistroEvolucao(
        paciente: paciente ?? _paciente(),
        evolucaoExistente: evolucaoExistente,
      ),
      supportedLocales: const [Locale('en', 'US')],
    ),
  );
}

Widget _criarAppTimeline({
  required Paciente paciente,
  required List<Evolucao> evolucoes,
}) {
  return ProviderScope(
    overrides: [
      provedorListaEvolucoes.overrideWith(
        () => EvolucoesNotifierComDados(evolucoes),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: TelaHistoricoEvolucoes(paciente: paciente),
      supportedLocales: const [Locale('en', 'US')],
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelaRegistroEvolucao - Modo Novo', () {
    testWidgets('deve exibir título "Registrar Evolução"', (tester) async {
      await tester.pumpWidget(_criarAppRegistroEvolucao());
      await tester.pumpAndSettle();

      expect(find.text('Registrar Evolução'), findsOneWidget);
    });

    testWidgets('deve exibir botão "Salvar Evolução"', (tester) async {
      await tester.pumpWidget(_criarAppRegistroEvolucao());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Salvar Evolução'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Salvar Evolução'), findsOneWidget);
    });
  });

  group('TelaRegistroEvolucao - Modo Edição (<24h)', () {
    testWidgets('deve exibir título "Editar Evolução"', (tester) async {
      await tester.pumpWidget(_criarAppRegistroEvolucao(
        evolucaoExistente: _evolucao(diferencaHoras: 1),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Editar Evolução'), findsOneWidget);
    });

    testWidgets('deve exibir botão "Atualizar Evolução"', (tester) async {
      await tester.pumpWidget(_criarAppRegistroEvolucao(
        evolucaoExistente: _evolucao(diferencaHoras: 1),
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Atualizar Evolução'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Atualizar Evolução'), findsOneWidget);
    });

    testWidgets('deve pré-preencher campos a partir da evolução existente', (
      tester,
    ) async {
      final evol = _evolucao(diferencaHoras: 1);
      await tester.pumpWidget(_criarAppRegistroEvolucao(
        evolucaoExistente: evol,
      ));
      await tester.pumpAndSettle();

      // Scroll to find the evolução text field
      await tester.scrollUntilVisible(
        find.text('Evolução técnica *'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      final campoEvolucao = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Evolução técnica *'),
      );
      expect(campoEvolucao.controller?.text, equals(evol.evolucaoTexto));
    });

    testWidgets('não deve exibir banner de bloqueio', (tester) async {
      await tester.pumpWidget(_criarAppRegistroEvolucao(
        evolucaoExistente: _evolucao(diferencaHoras: 1),
      ));
      await tester.pumpAndSettle();

      expect(
        find.text('Evolução bloqueada — mais de 24h do registro'),
        findsNothing,
      );
    });
  });

  group('TelaRegistroEvolucao - Modo ReadOnly (>24h)', () {
    testWidgets('deve exibir banner de bloqueio', (tester) async {
      await tester.pumpWidget(_criarAppRegistroEvolucao(
        evolucaoExistente: _evolucao(diferencaHoras: 48),
      ));
      await tester.pumpAndSettle();

      expect(
        find.text('Evolução bloqueada — mais de 24h do registro'),
        findsOneWidget,
      );
    });

    testWidgets('não deve exibir botão salvar', (tester) async {
      await tester.pumpWidget(_criarAppRegistroEvolucao(
        evolucaoExistente: _evolucao(diferencaHoras: 48),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Atualizar Evolução'), findsNothing);
    });
  });

  group('TelaHistoricoEvolucoes - Botão Editar na Timeline', () {
    testWidgets('deve exibir botão editar quando evolução tem <24h', (
      tester,
    ) async {
      await tester.pumpWidget(_criarAppTimeline(
        paciente: _paciente(),
        evolucoes: [_evolucao(diferencaHoras: 1)],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Editar'), findsOneWidget);
    });

    testWidgets('não deve exibir botão editar quando evolução tem >24h', (
      tester,
    ) async {
      await tester.pumpWidget(_criarAppTimeline(
        paciente: _paciente(),
        evolucoes: [_evolucao(diferencaHoras: 48)],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Editar'), findsNothing);
    });
  });
}
