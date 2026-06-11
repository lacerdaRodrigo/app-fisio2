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

Widget _criarApp(List<Paciente> pacientes) {
  return ProviderScope(
    overrides: [
      provedorListaPacientes.overrideWith(
        () => PacientesNotifierComDados(pacientes),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: const TelaPacientes(),
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
  });
}
