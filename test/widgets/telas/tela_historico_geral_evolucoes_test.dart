import 'package:fisio_home_care/modelos/evolucao.dart';
import 'package:fisio_home_care/modelos/paciente.dart';
import 'package:fisio_home_care/provedores/provedores_dados.dart';
import 'package:fisio_home_care/telas/tela_historico_geral_evolucoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class PacientesNotifierComDados extends ListaPacientesNotifier {
  final List<Paciente> _dados;

  PacientesNotifierComDados(this._dados);

  @override
  List<Paciente> build() => _dados;
}

class EvolucoesNotifierComDados extends ListaEvolucoesNotifier {
  final List<Evolucao> _dados;

  EvolucoesNotifierComDados(this._dados);

  @override
  List<Evolucao> build() => _dados;
}

Paciente _paciente() => Paciente(
  idPaciente: 'P001',
  nome: 'Maria Evolução',
  telefone: '11999999999',
  dataNascimento: DateTime(1990, 1, 1),
  cpf: '12345678901',
  endereco: 'Rua A',
  situacao: 'Ativo',
);

Evolucao _evolucao(String id, String texto, String condicao) {
  return Evolucao(
    idEvolucao: id,
    idPaciente: 'P001',
    idAgendamento: 'A$id',
    dataAtendimento: DateTime(2026, 6, 10),
    evolucaoTexto: texto,
    horarioInicioReal: DateTime(2026, 6, 10, 8),
    horarioFimReal: DateTime(2026, 6, 10, 9),
    condicaoPaciente: condicao,
    dorSessao: 4,
  );
}

Widget _criarApp(List<Evolucao> evolucoes) {
  return ProviderScope(
    overrides: [
      provedorListaPacientes.overrideWith(
        () => PacientesNotifierComDados([_paciente()]),
      ),
      provedorListaEvolucoes.overrideWith(
        () => EvolucoesNotifierComDados(evolucoes),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      home: const TelaHistoricoGeralEvolucoes(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelaHistoricoGeralEvolucoes', () {
    testWidgets('deve buscar evolução por texto clínico', (tester) async {
      await tester.pumpWidget(
        _criarApp([
          _evolucao('001', 'Treino de marcha com apoio', 'Melhora'),
          _evolucao('002', 'Alongamento global', 'Estável'),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'marcha');
      await tester.pumpAndSettle();

      expect(find.text('Treino de marcha com apoio'), findsOneWidget);
      expect(find.text('Alongamento global'), findsNothing);
    });

    testWidgets('deve agrupar evoluções por paciente', (tester) async {
      await tester.pumpWidget(
        _criarApp([
          _evolucao('001', 'Treino de marcha com apoio', 'Melhora'),
          _evolucao('002', 'Alongamento global', 'Estável'),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Por paciente'));
      await tester.pumpAndSettle();

      expect(find.text('Maria Evolução'), findsOneWidget);
      expect(find.textContaining('2 evoluções'), findsOneWidget);
    });
  });
}
