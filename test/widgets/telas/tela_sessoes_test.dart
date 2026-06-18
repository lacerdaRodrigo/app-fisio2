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

Paciente _pacienteCom(String id, String nome) => Paciente(
  idPaciente: id,
  nome: nome,
  telefone: '11999999999',
  dataNascimento: DateTime(1990, 1, 1),
  cpf: '12345678901',
  endereco: 'Rua A',
  situacao: 'Ativo',
);

Agendamento _agendamentoPara(
  String id,
  String idPaciente,
  String situacao,
  DateTime data, {
  String horaInicio = '08:00',
}) {
  return Agendamento(
    idAgendamento: id,
    idPaciente: idPaciente,
    data: data,
    horaInicio: horaInicio,
    horaFim: '09:00',
    valorSessao: 150,
    situacao: situacao,
  );
}

Widget _criarApp(List<Agendamento> agendamentos) {
  return _criarAppCom([_paciente()], agendamentos);
}

Widget _criarAppCom(
  List<Paciente> pacientes,
  List<Agendamento> agendamentos,
) {
  return ProviderScope(
    overrides: [
      provedorListaPacientes.overrideWith(
        () => PacientesNotifierComDados(pacientes),
      ),
      provedorListaAgendamentos.overrideWith(
        () => AgendamentosNotifierComDados(agendamentos),
      ),
    ],
    child: const MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('pt', 'BR')],
      home: TelaSessoes(),
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

  group('TelaSessoes — busca e estado vazio', () {
    testWidgets('botão limpar apaga o termo de busca', (tester) async {
      await tester.pumpWidget(
        _criarApp([
          _agendamento('A001', Agendamento.situacaoAgendado, DateTime.now()),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'João');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.clear_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.clear_rounded), findsNothing);
      expect(find.text('João'), findsNothing);
    });

    testWidgets('estado vazio mostra rótulo de cada filtro', (tester) async {
      await tester.pumpWidget(_criarApp(const []));
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma sessão todas encontrada.'), findsOneWidget);

      for (final entrada in const {
        'Hoje': 'hoje',
        'Futuras': 'futuras',
        'Pendentes': 'pendentes',
        'Canceladas': 'canceladas',
        'Faltas': 'faltas',
        'Realizadas': 'realizadas',
      }.entries) {
        await tester.ensureVisible(find.text(entrada.key));
        await tester.tap(find.text(entrada.key));
        await tester.pumpAndSettle();
        expect(
          find.text('Nenhuma sessão ${entrada.value} encontrada.'),
          findsOneWidget,
        );
      }
    });
  });

  group('TelaSessoes — filtros por período e status', () {
    Future<void> montar(WidgetTester tester) async {
      final hoje = DateTime.now();
      final ontem = hoje.subtract(const Duration(days: 1));
      final amanha = hoje.add(const Duration(days: 1));

      await tester.pumpWidget(
        _criarAppCom(
          [
            _pacienteCom('P001', 'João Hoje'),
            _pacienteCom('P002', 'Maria Futura'),
            _pacienteCom('P003', 'Pedro Pendente'),
            _pacienteCom('P004', 'Ana Realizada'),
          ],
          [
            _agendamentoPara(
              'A001',
              'P001',
              Agendamento.situacaoAgendado,
              hoje,
              horaInicio: '23:59',
            ),
            _agendamentoPara(
              'A002',
              'P002',
              Agendamento.situacaoAgendado,
              amanha,
            ),
            _agendamentoPara(
              'A003',
              'P003',
              Agendamento.situacaoAgendado,
              ontem,
            ),
            _agendamentoPara(
              'A004',
              'P004',
              Agendamento.situacaoRealizado,
              hoje,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('filtro Futuras mostra apenas sessões futuras', (tester) async {
      await montar(tester);

      await tester.tap(find.text('Futuras'));
      await tester.pumpAndSettle();

      expect(find.text('Maria Futura'), findsOneWidget);
      expect(find.text('Pedro Pendente'), findsNothing);
    });

    testWidgets('filtro Pendentes mostra sessões atrasadas/anteriores', (
      tester,
    ) async {
      await montar(tester);

      await tester.tap(find.text('Pendentes'));
      await tester.pumpAndSettle();

      expect(find.text('Pedro Pendente'), findsOneWidget);
      expect(find.text('Maria Futura'), findsNothing);
    });

    testWidgets('filtro Realizadas mostra apenas sessões realizadas', (
      tester,
    ) async {
      await montar(tester);

      await tester.ensureVisible(find.text('Realizadas'));
      await tester.tap(find.text('Realizadas'));
      await tester.pumpAndSettle();

      expect(find.text('Ana Realizada'), findsOneWidget);
      expect(find.text('Maria Futura'), findsNothing);
    });

    testWidgets('filtro Hoje mostra sessões do dia', (tester) async {
      await montar(tester);

      await tester.tap(find.text('Hoje'));
      await tester.pumpAndSettle();

      expect(find.text('João Hoje'), findsOneWidget);
      expect(find.text('Maria Futura'), findsNothing);
    });
  });

  group('TelaSessoes — ações da sessão', () {
    testWidgets('menu de ações na lista abre diálogo de confirmação', (
      tester,
    ) async {
      await tester.pumpWidget(
        _criarApp([
          _agendamento('A001', Agendamento.situacaoAgendado, DateTime.now()),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Registrar evolução'), findsOneWidget);

      await tester.tap(find.text('Faltou sem aviso'));
      await tester.pumpAndSettle();

      expect(find.text('Atualizar sessão?'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
    });

    testWidgets(
      'visão por paciente ordena vários pacientes e aciona ação',
      (tester) async {
        await tester.pumpWidget(
          _criarAppCom(
            [
              _pacienteCom('P002', 'Bruno'),
              _pacienteCom('P001', 'Alice'),
            ],
            [
              _agendamentoPara(
                'A001',
                'P001',
                Agendamento.situacaoRealizado,
                DateTime.now(),
              ),
              _agendamentoPara(
                'A002',
                'P002',
                Agendamento.situacaoRealizado,
                DateTime.now(),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Por paciente'));
        await tester.pumpAndSettle();

        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Bruno'), findsOneWidget);

        // Expandir o grupo da Alice e acionar o menu de ações.
        await tester.tap(find.text('Alice'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Faltou com aviso'));
        await tester.pumpAndSettle();

        expect(find.text('Atualizar sessão?'), findsOneWidget);
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
      },
    );
  });
}
