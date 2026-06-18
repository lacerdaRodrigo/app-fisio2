import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fisio_home_care/modelos/paciente.dart';
import 'package:fisio_home_care/provedores/provedores_dados.dart';
import 'package:fisio_home_care/telas/tela_pacientes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class PacientesNotifierComDados extends ListaPacientesNotifier {
  final List<Paciente> _dados;

  PacientesNotifierComDados(this._dados);

  @override
  List<Paciente> build() => _dados;
}

Paciente _pacienteAtivo(String id, String nome) => Paciente(
      idPaciente: id,
      nome: nome,
      telefone: '11999999999',
      dataNascimento: DateTime(1990, 1, 1),
      cpf: '$id$id${id}1'.padRight(11, '0').substring(0, 11),
      endereco: 'Rua A',
      situacao: 'Ativo',
    );

Paciente _pacienteArquivado(String id, String nome) => Paciente(
      idPaciente: id,
      nome: nome,
      telefone: '11999999999',
      dataNascimento: DateTime(1990, 1, 1),
      cpf: '$id$id${id}2'.padRight(11, '0').substring(0, 11),
      endereco: 'Rua B',
      situacao: 'Arquivado',
    );

Widget _criarApp(
  List<Paciente> pacientes, {
  FiltroPacientes filtro = FiltroPacientes.ativos,
}) {
  return ProviderScope(
    overrides: [
      provedorListaPacientes.overrideWith(
        () => PacientesNotifierComDados(pacientes),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: TelaPacientes(filtroInicial: filtro),
      supportedLocales: const [Locale('en', 'US')],
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelaPacientes - Filtro de Arquivados', () {
    testWidgets('deve exibir apenas pacientes ativos por padrão', (
      tester,
    ) async {
      await tester.pumpWidget(_criarApp([
        _pacienteAtivo('P001', 'João Ativo'),
        _pacienteArquivado('P002', 'Maria Arquivada'),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('João Ativo'), findsOneWidget);
      expect(find.text('Maria Arquivada'), findsNothing);
    });

    testWidgets('deve exibir apenas arquivados ao ativar toggle', (tester) async {
      await tester.pumpWidget(_criarApp([
        _pacienteAtivo('P001', 'João Ativo'),
        _pacienteArquivado('P002', 'Maria Arquivada'),
      ]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Arquivados'));
      await tester.pumpAndSettle();

      expect(find.text('João Ativo'), findsNothing);
      expect(find.text('Maria Arquivada'), findsOneWidget);
    });

    testWidgets('deve ocultar arquivados ao desativar toggle', (tester) async {
      await tester.pumpWidget(_criarApp([
        _pacienteAtivo('P001', 'João Ativo'),
        _pacienteArquivado('P002', 'Maria Arquivada'),
      ]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Arquivados'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Arquivados'));
      await tester.pumpAndSettle();

      expect(find.text('João Ativo'), findsOneWidget);
      expect(find.text('Maria Arquivada'), findsNothing);
    });
  });

  group('TelaPacientes - Badge e Contagem', () {
    testWidgets('deve exibir badge "Arquivado" no card de paciente arquivado', (
      tester,
    ) async {
      await tester.pumpWidget(_criarApp([
        _pacienteAtivo('P001', 'João Ativo'),
        _pacienteArquivado('P002', 'Maria Arquivada'),
      ]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Arquivados'));
      await tester.pumpAndSettle();

      expect(find.text('Arquivado'), findsOneWidget);
    });

    testWidgets('deve exibir contagem correta de pacientes ativos', (
      tester,
    ) async {
      await tester.pumpWidget(_criarApp([
        _pacienteAtivo('P001', 'João Ativo'),
        _pacienteAtivo('P002', 'Pedro Ativo'),
        _pacienteArquivado('P003', 'Maria Arquivada'),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('2 ativos'), findsOneWidget);
    });

    testWidgets('filtro "Todos" exibe contagem total', (tester) async {
      await tester.pumpWidget(
        _criarApp([
          _pacienteAtivo('P001', 'João Ativo'),
          _pacienteArquivado('P002', 'Maria Arquivada'),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();

      expect(find.text('2 total'), findsOneWidget);
      expect(find.text('João Ativo'), findsOneWidget);
      expect(find.text('Maria Arquivada'), findsOneWidget);
    });
  });

  group('TelaPacientes - Busca', () {
    testWidgets('busca filtra por nome', (tester) async {
      await tester.pumpWidget(
        _criarApp([
          _pacienteAtivo('P001', 'João Ativo'),
          _pacienteAtivo('P002', 'Pedro Ativo'),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'João');
      await tester.pumpAndSettle();

      expect(find.text('João Ativo'), findsOneWidget);
      expect(find.text('Pedro Ativo'), findsNothing);
    });

    testWidgets('busca por CPF filtra a lista', (tester) async {
      final joao = Paciente(
        idPaciente: 'P001',
        nome: 'João Ativo',
        telefone: '11999999999',
        dataNascimento: DateTime(1990, 1, 1),
        cpf: '52998224725',
        endereco: 'Rua A',
        situacao: 'Ativo',
      );
      await tester.pumpWidget(
        _criarApp([joao, _pacienteAtivo('P002', 'Pedro Ativo')]),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5299822');
      await tester.pumpAndSettle();

      expect(find.text('João Ativo'), findsOneWidget);
      expect(find.text('Pedro Ativo'), findsNothing);
    });

    testWidgets('botão limpar restaura a lista completa', (tester) async {
      await tester.pumpWidget(
        _criarApp([
          _pacienteAtivo('P001', 'João Ativo'),
          _pacienteAtivo('P002', 'Pedro Ativo'),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'João');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.clear), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.clear), findsNothing);
      expect(find.text('João Ativo'), findsOneWidget);
      expect(find.text('Pedro Ativo'), findsOneWidget);
    });

    testWidgets('lista vazia exibe estado vazio', (tester) async {
      await tester.pumpWidget(_criarApp(const []));
      await tester.pumpAndSettle();

      expect(find.text('Nenhum paciente encontrado.'), findsOneWidget);
      expect(find.byIcon(Icons.person_search_rounded), findsOneWidget);
    });
  });

  group('TelaPacientes - Interação', () {
    testWidgets('tocar no card abre o modal de detalhes', (tester) async {
      await tester.pumpWidget(
        _criarApp([_pacienteAtivo('P001', 'João Ativo')]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('João Ativo'));
      await tester.pumpAndSettle();

      // Seções exclusivas do modal de detalhes.
      expect(find.text('Telefone'), findsOneWidget);
      expect(find.text('Endereço'), findsOneWidget);
    });

    testWidgets('mudar filtroInicial atualiza o filtro (didUpdateWidget)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _criarApp(
          [
            _pacienteAtivo('P001', 'João Ativo'),
            _pacienteArquivado('P002', 'Maria Arquivada'),
          ],
          filtro: FiltroPacientes.ativos,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('João Ativo'), findsOneWidget);
      expect(find.text('Maria Arquivada'), findsNothing);

      // Reconstrói a mesma TelaPacientes com outro filtroInicial.
      await tester.pumpWidget(
        _criarApp(
          [
            _pacienteAtivo('P001', 'João Ativo'),
            _pacienteArquivado('P002', 'Maria Arquivada'),
          ],
          filtro: FiltroPacientes.arquivados,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Maria Arquivada'), findsOneWidget);
      expect(find.text('João Ativo'), findsNothing);
    });
  });
}
