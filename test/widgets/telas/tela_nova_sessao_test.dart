import 'package:fisio_home_care/modelos/agendamento.dart';
import 'package:fisio_home_care/modelos/paciente.dart';
import 'package:fisio_home_care/provedores/provedores_dados.dart';
import 'package:fisio_home_care/servicos/servico_repositorio_dados.dart';
import 'package:fisio_home_care/telas/tela_nova_sessao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fakes e notifiers de teste.
// ---------------------------------------------------------------------------

class FakeRepositorioDadosGoogle extends Fake
    implements RepositorioDadosGoogle {
  @override
  Future<void> salvarAgendamento(Agendamento agendamento) async {}
}

class RepositorioQueFalha extends Fake implements RepositorioDadosGoogle {
  @override
  Future<void> salvarAgendamento(Agendamento agendamento) async {
    throw Exception('falha simulada ao salvar');
  }
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

Paciente _paciente({
  String id = 'P001',
  String nome = 'João Teste',
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

ProviderContainer _criarContainer({
  List<Paciente> pacientes = const [],
  List<Agendamento> agendamentos = const [],
  RepositorioDadosGoogle? repositorio,
}) {
  return ProviderContainer(
    overrides: [
      provedorListaPacientes.overrideWith(() => PacientesComDados(pacientes)),
      provedorListaAgendamentos.overrideWith(
        () => AgendamentosComDados(agendamentos),
      ),
      if (repositorio != null)
        provedorRepositorioDados.overrideWith((ref) => repositorio),
    ],
  );
}

/// Monta a tela numa superfície grande e em formato de 24h (evita scroll e
/// AM/PM no seletor de horário). Restaura o tamanho ao final.
Future<void> _montar(WidgetTester tester, ProviderContainer container) async {
  addTearDown(container.dispose);
  await tester.binding.setSurfaceSize(const Size(1000, 1800));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR')],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
        home: const TelaNovaSessao(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selecionarPaciente(WidgetTester tester, String nome) async {
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(nome).last);
  await tester.pumpAndSettle();
}

Future<void> _selecionarDataHoje(WidgetTester tester) async {
  await tester.tap(find.text('Selecionar data'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> _selecionarHorario(
  WidgetTester tester,
  String hora,
  String minuto,
) async {
  await tester.tap(find.text('Selecionar horário'));
  await tester.pumpAndSettle();
  // Alterna para o modo de digitação do seletor de horário.
  await tester.tap(find.byIcon(Icons.keyboard_outlined));
  await tester.pumpAndSettle();
  // Campos de hora/minuto ficam dentro do diálogo — escopar para não pegar
  // os campos Valor/Observações da tela por trás.
  final campos = find.descendant(
    of: find.byType(Dialog),
    matching: find.byType(TextField),
  );
  await tester.enterText(campos.at(0), hora);
  await tester.enterText(campos.at(1), minuto);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelaNovaSessao — renderização', () {
    testWidgets('exibe título, campos e valor padrão preenchido', (
      tester,
    ) async {
      await _montar(tester, _criarContainer(pacientes: [_paciente()]));

      expect(find.text('Nova Sessão'), findsOneWidget);
      expect(find.text('Agende um atendimento domiciliar'), findsOneWidget);
      expect(find.text('Selecionar data'), findsOneWidget);
      expect(find.text('Selecionar horário'), findsOneWidget);
      expect(find.text('Agendar Sessão'), findsOneWidget);

      // O valor é pré-preenchido com o padrão (150,00).
      final valor = tester.widget<TextField>(
        find.widgetWithText(TextField, '150,00').first,
      );
      expect(valor.controller?.text, '150,00');
    });

    testWidgets('sem pacientes ativos exibe aviso', (tester) async {
      await _montar(
        tester,
        _criarContainer(
          pacientes: [_paciente(situacao: 'Arquivado')],
        ),
      );

      expect(
        find.text('Cadastre um paciente ativo antes de criar uma sessão.'),
        findsOneWidget,
      );
    });
  });

  group('TelaNovaSessao — validação', () {
    testWidgets('agendar sem selecionar paciente mostra erro de validação', (
      tester,
    ) async {
      await _montar(tester, _criarContainer(pacientes: [_paciente()]));

      await tester.tap(find.text('Agendar Sessão'));
      await tester.pumpAndSettle();

      expect(find.text('Selecione um paciente.'), findsOneWidget);
    });

    testWidgets('paciente selecionado sem data/hora não agenda', (
      tester,
    ) async {
      await _montar(
        tester,
        _criarContainer(
          pacientes: [_paciente()],
          repositorio: FakeRepositorioDadosGoogle(),
        ),
      );

      await _selecionarPaciente(tester, 'João Teste');

      await tester.tap(find.text('Agendar Sessão'));
      await tester.pumpAndSettle();

      // Não avança: sem snackbar de sucesso, ainda na tela.
      expect(find.text('Sessão agendada com sucesso!'), findsNothing);
      expect(find.text('Agendar Sessão'), findsOneWidget);
    });
  });

  group('TelaNovaSessao — seletores e agendamento', () {
    testWidgets('selecionar data preenche o campo de data', (tester) async {
      await _montar(tester, _criarContainer(pacientes: [_paciente()]));

      expect(find.text('Selecionar data'), findsOneWidget);
      await _selecionarDataHoje(tester);

      // O placeholder some quando uma data é escolhida.
      expect(find.text('Selecionar data'), findsNothing);
    });

    testWidgets('data/horário retroativo exibe mensagem de erro', (
      tester,
    ) async {
      await _montar(
        tester,
        _criarContainer(
          pacientes: [_paciente()],
          repositorio: FakeRepositorioDadosGoogle(),
        ),
      );

      await _selecionarPaciente(tester, 'João Teste');
      await _selecionarDataHoje(tester);
      await _selecionarHorario(tester, '00', '00'); // meia-noite → passado

      await tester.tap(find.text('Agendar Sessão'));
      await tester.pumpAndSettle();

      expect(
        find.text('Selecione uma data e horário futuros.'),
        findsOneWidget,
      );
    });

    testWidgets('agendamento válido salva e volta para a tela anterior', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = _criarContainer(
        pacientes: [_paciente()],
        repositorio: FakeRepositorioDadosGoogle(),
      );
      addTearDown(container.dispose);

      // Hospeda a tela numa rota empilhada para o pop ter destino.
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('pt', 'BR')],
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            ),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaNovaSessao()),
                  ),
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await _selecionarPaciente(tester, 'João Teste');
      await _selecionarDataHoje(tester);
      await _selecionarHorario(tester, '23', '59'); // futuro no mesmo dia

      await tester.tap(find.text('Agendar Sessão'));
      await tester.pumpAndSettle();

      // Voltou para a tela anterior e o agendamento foi salvo.
      expect(find.text('Nova Sessão'), findsNothing);
      expect(find.text('abrir'), findsOneWidget);

      final agendamentos = container.read(provedorListaAgendamentos);
      expect(agendamentos, hasLength(1));
      expect(agendamentos.first.idPaciente, 'P001');
      expect(agendamentos.first.horaInicio, '23:59');
    });

    testWidgets('falha ao salvar exibe snackbar de erro', (tester) async {
      await _montar(
        tester,
        _criarContainer(
          pacientes: [_paciente()],
          repositorio: RepositorioQueFalha(),
        ),
      );

      await _selecionarPaciente(tester, 'João Teste');
      await _selecionarDataHoje(tester);
      await _selecionarHorario(tester, '23', '59');

      await tester.tap(find.text('Agendar Sessão'));
      await tester.pumpAndSettle();

      expect(
        find.text('Ocorreu um erro inesperado. Tente novamente.'),
        findsOneWidget,
      );
    });
  });

  group('TelaNovaSessao — navegação', () {
    testWidgets('botão fechar aciona o retorno', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = _criarContainer(pacientes: [_paciente()]);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('pt', 'BR')],
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaNovaSessao()),
                  ),
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Nova Sessão'), findsOneWidget);

      await tester.tap(find.byKey(const Key('btn_fechar')));
      await tester.pumpAndSettle();

      // Voltou para a tela anterior.
      expect(find.text('Nova Sessão'), findsNothing);
      expect(find.text('abrir'), findsOneWidget);
    });
  });
}
