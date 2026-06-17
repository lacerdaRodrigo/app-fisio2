import 'package:fisio_home_care/modelos/agendamento.dart';
import 'package:fisio_home_care/modelos/paciente.dart';
import 'package:fisio_home_care/provedores/provedores_dados.dart';
import 'package:fisio_home_care/telas/tela_sessoes.dart';
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

class AgendamentosNotifierComDados extends ListaAgendamentosNotifier {
  final List<Agendamento> _dados;

  AgendamentosNotifierComDados(this._dados);

  @override
  List<Agendamento> build() => _dados;
}

Paciente _paciente() => Paciente(
  idPaciente: 'P001',
  nome: 'João Sessões',
  telefone: '11999999999',
  dataNascimento: DateTime(1990, 1, 1),
  cpf: '12345678901',
  endereco: 'Rua A',
  situacao: 'Ativo',
);

Agendamento _agendamento(String id, String situacao, DateTime data) {
  return Agendamento(
    idAgendamento: id,
    idPaciente: 'P001',
    data: data,
    horaInicio: '08:00',
    horaFim: '09:00',
    valorSessao: 150,
    situacao: situacao,
  );
}

Widget _criarApp(List<Agendamento> agendamentos) {
  return ProviderScope(
    overrides: [
      provedorListaPacientes.overrideWith(
        () => PacientesNotifierComDados([_paciente()]),
      ),
      provedorListaAgendamentos.overrideWith(
        () => AgendamentosNotifierComDados(agendamentos),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      home: const TelaSessoes(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelaSessoes', () {
    testWidgets('deve listar sessões canceladas pelo filtro Canceladas', (
      tester,
    ) async {
      await tester.pumpWidget(
        _criarApp([
          _agendamento(
            'A001',
            Agendamento.situacaoCanceladoProfissional,
            DateTime.now(),
          ),
          _agendamento(
            'A002',
            Agendamento.situacaoFaltouSemAviso,
            DateTime.now(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Canceladas'));
      await tester.pumpAndSettle();

      expect(find.text('Cancelado pelo profissional'), findsOneWidget);
      expect(find.text('Faltou sem aviso'), findsNothing);
    });

    testWidgets('deve listar faltas pelo filtro Faltas', (tester) async {
      await tester.pumpWidget(
        _criarApp([
          _agendamento(
            'A001',
            Agendamento.situacaoFaltouComAviso,
            DateTime.now(),
          ),
          _agendamento(
            'A002',
            Agendamento.situacaoCanceladoPaciente,
            DateTime.now(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Faltas'));
      await tester.pumpAndSettle();

      expect(find.text('Faltou com aviso'), findsOneWidget);
      expect(find.text('Cancelado pelo paciente'), findsNothing);
    });

    testWidgets('deve buscar sessões por nome do paciente', (tester) async {
      await tester.pumpWidget(
        _criarApp([
          _agendamento(
            'A001',
            Agendamento.situacaoCanceladoProfissional,
            DateTime.now(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'João Sessões');
      await tester.pumpAndSettle();

      expect(find.text('Cancelado pelo profissional'), findsOneWidget);
    });

    testWidgets('deve agrupar sessões por paciente', (tester) async {
      await tester.pumpWidget(
        _criarApp([
          _agendamento('A001', Agendamento.situacaoAgendado, DateTime.now()),
          _agendamento('A002', Agendamento.situacaoRealizado, DateTime.now()),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Por paciente'));
      await tester.pumpAndSettle();

      expect(find.text('João Sessões'), findsOneWidget);
      expect(find.textContaining('2 sessões'), findsOneWidget);
    });
  });
}
