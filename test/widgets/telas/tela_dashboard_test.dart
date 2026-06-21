import 'package:fisio_home_care/modelos/agendamento.dart';
import 'package:fisio_home_care/modelos/paciente.dart';
import 'package:fisio_home_care/provedores/provedor_autenticacao.dart';
import 'package:fisio_home_care/provedores/provedores_dados.dart';
import 'package:fisio_home_care/telas/tela_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../unitarios/auxiliares/fakes.dart';

// ---------------------------------------------------------------------------
// Notifiers de teste — devolvem estado pré-carregado em build().
// ---------------------------------------------------------------------------

class CarregamentoComEstado extends CarregamentoDadosNotifier {
  final EstadoCarregamentoDados _inicial;

  CarregamentoComEstado(this._inicial);

  @override
  EstadoCarregamentoDados build() => _inicial;
}

class PacientesComDados extends ListaPacientesNotifier {
  final List<Paciente> _dados;

  PacientesComDados(this._dados);

  @override
  List<Paciente> build() => _dados;
}

class AgendamentosComDados extends ListaAgendamentosNotifier {
  final List<Agendamento> _dados;

  AgendamentosComDados(this._dados);

  @override
  List<Agendamento> build() => _dados;
}

// ---------------------------------------------------------------------------
// Construtores de dados de teste.
// ---------------------------------------------------------------------------

Paciente _paciente({
  String id = 'P001',
  String nome = 'João Dashboard',
  String situacao = 'Ativo',
}) {
  return Paciente(
    idPaciente: id,
    nome: nome,
    telefone: '11999999999',
    dataNascimento: DateTime(1990, 1, 1),
    cpf: '12345678901',
    endereco: 'Rua A',
    situacao: situacao,
  );
}

Agendamento _agendamento({
  required String id,
  String idPaciente = 'P001',
  required DateTime data,
  String horaInicio = '23:59',
  String situacao = Agendamento.situacaoAgendado,
}) {
  return Agendamento(
    idAgendamento: id,
    idPaciente: idPaciente,
    data: data,
    horaInicio: horaInicio,
    horaFim: '23:59',
    valorSessao: 150,
    situacao: situacao,
  );
}

const _carregado = EstadoCarregamentoDados(
  status: StatusCarregamentoDados.carregado,
);

Widget _criarApp({
  required EstadoCarregamentoDados carregamento,
  List<Paciente> pacientes = const [],
  List<Agendamento> agendamentos = const [],
  String nome = 'Dr. Teste',
}) {
  return ProviderScope(
    overrides: [
      provedorServicoAutenticacaoGoogle.overrideWithValue(
        ServicoAutenticacaoGoogleFake(),
      ),
      provedorCarregamentoDados.overrideWith(
        () => CarregamentoComEstado(carregamento),
      ),
      provedorListaPacientes.overrideWith(() => PacientesComDados(pacientes)),
      provedorListaAgendamentos.overrideWith(
        () => AgendamentosComDados(agendamentos),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      home: TelaDashboard(nomeUsuario: nome),
    ),
  );
}

/// Monta o app numa tela grande (evita overflow das seções fixas: nav e FAB)
/// e restaura o tamanho ao final do teste.
Future<void> _montar(WidgetTester tester, Widget app) async {
  await tester.binding.setSurfaceSize(const Size(1200, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(app);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelaDashboard — estados de carregamento', () {
    testWidgets('estado carregando exibe indicador de progresso', (
      tester,
    ) async {
      await _montar(
        tester,
        _criarApp(
          carregamento: const EstadoCarregamentoDados(
            status: StatusCarregamentoDados.carregando,
          ),
        ),
      );
      // Não usar pumpAndSettle: o CircularProgressIndicator anima sem parar.
      await tester.pump();

      expect(find.text('Carregando dados...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('estado erro exibe mensagem e botão tentar novamente', (
      tester,
    ) async {
      await _montar(
        tester,
        _criarApp(
          carregamento: const EstadoCarregamentoDados(
            status: StatusCarregamentoDados.erro,
            mensagemErro: 'Falha de rede teste',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      expect(find.text('Não foi possível carregar os dados.'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);

      // Tocar em "Tentar novamente" reexecuta o carregamento (repo nulo → erro).
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível carregar os dados.'), findsOneWidget);
    });
  });

  group('TelaDashboard — cabeçalho e cards', () {
    testWidgets('cabeçalho mostra nome e inicial do usuário', (tester) async {
      await _montar(
        tester,
        _criarApp(carregamento: _carregado, pacientes: [_paciente()]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dr. Teste'), findsOneWidget);
      expect(find.text('D'), findsOneWidget); // inicial no avatar
    });

    testWidgets('tocar no avatar abre as Configurações', (tester) async {
      await _montar(
        tester,
        _criarApp(carregamento: _carregado, pacientes: [_paciente()]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('D'));
      await tester.pumpAndSettle();

      expect(find.text('Configurações'), findsOneWidget);
    });

    testWidgets('cards de resumo exibem títulos e contagens', (tester) async {
      await _montar(
        tester,
        _criarApp(
          carregamento: _carregado,
          pacientes: [
            _paciente(id: 'P001', nome: 'João Ativo', situacao: 'Ativo'),
            _paciente(
              id: 'P002',
              nome: 'Maria Arquivada',
              situacao: 'Arquivado',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pacientes\nCadastrados'), findsOneWidget);
      expect(find.text('Pacientes\nAtivos'), findsOneWidget);
      expect(find.text('Agenda\ndo Dia'), findsOneWidget);
      expect(find.text('Total de\nEvoluções'), findsOneWidget);

      expect(find.text('2'), findsOneWidget); // cadastrados
      expect(find.text('1'), findsOneWidget); // ativos
    });

    testWidgets('agenda vazia exibe estado "Tudo limpo!"', (tester) async {
      await _montar(
        tester,
        _criarApp(carregamento: _carregado, pacientes: [_paciente()]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Agenda de Hoje'), findsOneWidget);
      expect(find.text('Tudo limpo!'), findsOneWidget);
      expect(
        find.text('Nenhum atendimento agendado para hoje.'),
        findsOneWidget,
      );
    });
  });

  group('TelaDashboard — interação com cards', () {
    testWidgets('card "Pacientes Cadastrados" abre a aba Pacientes', (
      tester,
    ) async {
      await _montar(
        tester,
        _criarApp(carregamento: _carregado, pacientes: [_paciente()]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pacientes\nCadastrados'));
      await tester.pumpAndSettle();

      // Na aba Pacientes aparece o FAB de novo paciente.
      expect(find.text('Novo Paciente'), findsOneWidget);
    });

    testWidgets('card "Pacientes Ativos" abre a aba Pacientes', (tester) async {
      await _montar(
        tester,
        _criarApp(carregamento: _carregado, pacientes: [_paciente()]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pacientes\nAtivos'));
      await tester.pumpAndSettle();

      expect(find.text('Novo Paciente'), findsOneWidget);
    });

    testWidgets('card "Total de Evoluções" navega para o histórico', (
      tester,
    ) async {
      await _montar(
        tester,
        _criarApp(carregamento: _carregado, pacientes: [_paciente()]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Total de\nEvoluções'));
      await tester.pumpAndSettle();

      // Tela de histórico de evoluções (título "Evoluções") com badge de registros.
      expect(find.text('Evoluções'), findsOneWidget);
      expect(find.textContaining('registros'), findsOneWidget);
    });

    testWidgets('card "Agenda do Dia" rola a lista sem erros', (tester) async {
      await _montar(
        tester,
        _criarApp(carregamento: _carregado, pacientes: [_paciente()]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Agenda\ndo Dia'));
      await tester.pumpAndSettle();

      expect(find.byType(TelaDashboard), findsOneWidget);
    });
  });

  group('TelaDashboard — navegação e FAB', () {
    testWidgets('barra inferior alterna abas e mostra os FABs corretos', (
      tester,
    ) async {
      await _montar(
        tester,
        _criarApp(carregamento: _carregado, pacientes: [_paciente()]),
      );
      await tester.pumpAndSettle();

      // Na aba Início (0) não há FAB.
      expect(find.text('Novo Paciente'), findsNothing);

      await tester.tap(find.text('Sessões'));
      await tester.pumpAndSettle();
      // Sessões não tem FAB flutuante — botão "Nova" fica no header da tela.
      expect(find.text('Novo Paciente'), findsNothing);

      await tester.tap(find.text('Pacientes'));
      await tester.pumpAndSettle();
      expect(find.text('Novo Paciente'), findsOneWidget);

      // Voltar para a aba Início esconde os FABs novamente.
      await tester.tap(find.text('Início'));
      await tester.pumpAndSettle();
      expect(find.text('Novo Paciente'), findsNothing);
      expect(find.text('Agenda de Hoje'), findsOneWidget);
    });

    testWidgets('FAB "Novo Paciente" abre o cadastro de paciente', (
      tester,
    ) async {
      await _montar(
        tester,
        _criarApp(carregamento: _carregado, pacientes: [_paciente()]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pacientes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Novo Paciente'));
      await tester.pumpAndSettle();

      expect(find.text('Novo Paciente'), findsWidgets);
      expect(find.byType(TextField), findsWidgets);
    });
  });

  group('TelaDashboard — agenda e pendências', () {
    testWidgets('lista sessões de hoje com status Agendado e Atrasado', (
      tester,
    ) async {
      final hoje = DateTime.now();
      await _montar(
        tester,
        _criarApp(
          carregamento: _carregado,
          pacientes: [_paciente()],
          agendamentos: [
            _agendamento(id: 'A001', data: hoje, horaInicio: '23:59'),
            _agendamento(id: 'A002', data: hoje, horaInicio: '00:00'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('João Dashboard'), findsNWidgets(2));
      expect(find.text('Agendado'), findsOneWidget);
      expect(find.text('Atrasado'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert_rounded), findsNWidgets(2));
    });

    testWidgets('pendências de dias anteriores aparecem com paciente ausente', (
      tester,
    ) async {
      final ontem = DateTime.now().subtract(const Duration(days: 1));
      await _montar(
        tester,
        _criarApp(
          carregamento: _carregado,
          pacientes: [_paciente()],
          agendamentos: [
            _agendamento(id: 'A009', idPaciente: 'P999', data: ontem),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pendências'), findsOneWidget);
      expect(find.text('1 sem desfecho'), findsOneWidget);
      expect(find.text('Pendente'), findsOneWidget);
      expect(find.text('Paciente não encontrado'), findsOneWidget);
    });

    testWidgets(
      'menu de ações da sessão abre opções e diálogo de confirmação',
      (tester) async {
        final hoje = DateTime.now();
        await _montar(
          tester,
          _criarApp(
            carregamento: _carregado,
            pacientes: [_paciente()],
            agendamentos: [_agendamento(id: 'A001', data: hoje)],
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.more_vert_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Registrar evolução'), findsOneWidget);
        expect(find.text('Faltou com aviso'), findsOneWidget);
        expect(find.text('Cancelar pelo profissional'), findsOneWidget);

        await tester.tap(find.text('Faltou sem aviso'));
        await tester.pumpAndSettle();

        expect(find.text('Atualizar sessão?'), findsOneWidget);
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
      },
    );
  });
}
