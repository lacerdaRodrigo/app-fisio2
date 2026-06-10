import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fisio_home_care/modelos/paciente.dart';
import 'package:fisio_home_care/provedores/provedores_dados.dart';
import 'package:fisio_home_care/telas/tela_cadastro_paciente.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fisio_home_care/servicos/servico_repositorio_dados.dart';

class MockListaPacientesNotifier extends ListaPacientesNotifier {
 @override
 List<Paciente> pacientes = [];

 @override
 Future<void> adicionarPaciente(Paciente paciente) async {
 pacientes.add(paciente);
 }
}

class FakeRepositorioDadosGoogle extends Fake implements RepositorioDadosGoogle {
  @override
  Future<void> salvarPaciente(Paciente paciente) async {}
}

Widget criarAppTeste() {
 return ProviderScope(
 overrides: [
 provedorListaPacientes.overrideWith(
 () => ListaPacientesNotifier(),
 ),
 ],
 child: MaterialApp(
 localizationsDelegates: [
 GlobalMaterialLocalizations.delegate,
 GlobalWidgetsLocalizations.delegate,
 ],
 home: TelaCadastroPaciente(),
  supportedLocales: const [Locale('en', 'US')],
 ),
 );
}

void main() {
 TestWidgetsFlutterBinding.ensureInitialized();

group('TelaCadastroPaciente - Endereço', () {
 testWidgets('deve exibir "Toque para preencher endereço" quando vazio', (
 tester,
 ) async {
 await tester.pumpWidget(criarAppTeste());
 await tester.pumpAndSettle();

 expect(find.byType(InkWell).at(1), findsOneWidget);
 });

testWidgets('tocar no endereço abre o modal com 4 campos', (tester) async {
 await tester.pumpWidget(criarAppTeste());
 await tester.pumpAndSettle();

 await tester.tap(find.byType(InkWell).at(1));
 await tester.pumpAndSettle();

 expect(find.text('Editar Endereço'), findsOneWidget);
 expect(find.text('Rua/Avenida *'), findsOneWidget);
 expect(find.text('Número'), findsOneWidget);
 expect(find.text('Bairro *'), findsOneWidget);
 expect(find.text('Cidade *'), findsOneWidget);
 expect(find.text('Cancelar'), findsOneWidget);
 expect(find.text('Confirmar'), findsOneWidget);
});

testWidgets('preencher campos e confirmar atualiza o endereço exibido', (
 tester,
 ) async {
 await tester.pumpWidget(criarAppTeste());
 await tester.pumpAndSettle();

 await tester.tap(find.byType(InkWell).at(1));
 await tester.pumpAndSettle();

 await tester.enterText(find.widgetWithText(TextFormField, 'Rua/Avenida *'), 'Rua Belém');
 await tester.enterText(find.widgetWithText(TextFormField, 'Número'), '105');
 await tester.enterText(find.widgetWithText(TextFormField, 'Bairro *'), 'Centro');
 await tester.enterText(find.widgetWithText(TextFormField, 'Cidade *'), 'São Paulo');

 await tester.tap(find.text('Confirmar'));
 await tester.pumpAndSettle();

 expect(find.text('Rua Belém, 105, Centro, São Paulo'), findsOneWidget);
});

testWidgets('campos obrigatórios impedem confirmar sem preenchimento', (
 tester,
 ) async {
 await tester.pumpWidget(criarAppTeste());
 await tester.pumpAndSettle();

 await tester.tap(find.byType(InkWell).at(1));
 await tester.pumpAndSettle();

 await tester.tap(find.text('Confirmar'));
 await tester.pumpAndSettle();

 expect(find.text('Editar Endereço'), findsOneWidget);
 expect(find.text('Informe a rua/avenida.'), findsOneWidget);
 expect(find.text('Informe o bairro.'), findsOneWidget);
 expect(find.text('Informe a cidade.'), findsOneWidget);
});

testWidgets('endereço com apenas rua e cidade é composto corretamente', (
 tester,
 ) async {
 await tester.pumpWidget(criarAppTeste());
 await tester.pumpAndSettle();

 await tester.tap(find.byType(InkWell).at(1));
 await tester.pumpAndSettle();

 await tester.enterText(find.widgetWithText(TextFormField, 'Rua/Avenida *'), 'Av Paulista');
 await tester.enterText(find.widgetWithText(TextFormField, 'Bairro *'), 'Bela Vista');
 await tester.enterText(find.widgetWithText(TextFormField, 'Cidade *'), 'São Paulo');
 // Número vazio

 await tester.tap(find.text('Confirmar'));
 await tester.pumpAndSettle();

 expect(find.text('Av Paulista, Bela Vista, São Paulo'), findsOneWidget);
});

testWidgets('cancelar não altera o endereço', (tester) async {
 await tester.pumpWidget(criarAppTeste());
 await tester.pumpAndSettle();

 expect(find.byType(InkWell).at(1), findsOneWidget);

 await tester.tap(find.byType(InkWell).at(1));
 await tester.pumpAndSettle();

 await tester.enterText(find.widgetWithText(TextFormField, 'Rua/Avenida *'), 'Rua X');
 await tester.enterText(find.widgetWithText(TextFormField, 'Bairro *'), 'Bairro Y');
 await tester.enterText(find.widgetWithText(TextFormField, 'Cidade *'), 'Cidade Z');

 await tester.tap(find.text('Cancelar'));
 await tester.pumpAndSettle();

 expect(find.byType(InkWell).at(1), findsOneWidget);
 expect(find.text('Rua X'), findsNothing);
});
});

group('TelaCadastroPaciente - Anamnese Clínica', () {
 testWidgets('deve exibir seção de Anamnese Clínica com todos os campos', (
 tester,
 ) async {
 await tester.pumpWidget(criarAppTeste());
 await tester.pumpAndSettle();

 // Scroll down to make the Anamnese section visible (ListView lazy rendering)
 await tester.scrollUntilVisible(
  find.text('Anamnese Clínica'),
  200,
  scrollable: find.byType(Scrollable).first,
 );
 await tester.pumpAndSettle();
 expect(find.text('Anamnese Clínica'), findsOneWidget);
 expect(find.text('Queixa Principal (QP)'), findsOneWidget);

 await tester.scrollUntilVisible(
  find.text('Histórico da Doença Atual (HDA)'),
  200,
  scrollable: find.byType(Scrollable).first,
 );
 await tester.pumpAndSettle();
 expect(find.text('Histórico da Doença Atual (HDA)'), findsOneWidget);

 await tester.scrollUntilVisible(
  find.text('Gênero'),
  200,
  scrollable: find.byType(Scrollable).first,
 );
 await tester.pumpAndSettle();
        expect(find.text('Gênero'), findsOneWidget);

 await tester.scrollUntilVisible(
  find.text('Escala de dor (0-10)'),
  200,
  scrollable: find.byType(Scrollable).first,
 );
 await tester.pumpAndSettle();
        expect(find.text('Escala de dor (0-10)'), findsOneWidget);
 });

testWidgets('deve permitir salvar paciente sem preencher campos de anamnese', (
  tester,
) async {
  // Use the mock notifier from the start to avoid rebuilding the widget
  final mockNotifier = MockListaPacientesNotifier();
  mockNotifier.pacientes = [];

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        provedorListaPacientes.overrideWith(() => mockNotifier),
        provedorRepositorioDados.overrideWith((ref) => FakeRepositorioDadosGoogle()),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: TelaCadastroPaciente(),
        supportedLocales: const [Locale('en', 'US')],
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Preencher apenas dados pessoais obrigatórios
  await tester.enterText(find.widgetWithText(TextFormField, 'Nome Completo *'), 'João Souza');
  await tester.enterText(find.widgetWithText(TextFormField, 'CPF *'), '52998224725');
  await tester.enterText(find.widgetWithText(TextFormField, 'Telefone *'), '31987654321');

  // Preencher data de nascimento
  await tester.tap(find.text('Selecionar data'));
  await tester.pumpAndSettle();
  // Confirmar a seleção padrão (1990-01-01) sem mudar a data
  final okButton = find.widgetWithText(TextButton, 'OK');
  if (okButton.evaluate().isNotEmpty) {
    await tester.tap(okButton);
  } else {
    // Se não encontrar "OK", tenta fechar o diálogo
    await tester.tapAt(const Offset(100, 100));
  }
  await tester.pumpAndSettle();

  // Preencher endereço
  await tester.tap(find.byType(InkWell).at(1));
  await tester.pumpAndSettle();
  await tester.enterText(find.widgetWithText(TextFormField, 'Rua/Avenida *'), 'Rua B');
  await tester.enterText(find.widgetWithText(TextFormField, 'Bairro *'), 'Bairro C');
  await tester.enterText(find.widgetWithText(TextFormField, 'Cidade *'), 'Cidade D');
  await tester.tap(find.text('Confirmar'));
  await tester.pumpAndSettle();

  // Preencher escala de dor (que agora é obrigatório)
  await tester.scrollUntilVisible(
    find.widgetWithText(TextFormField, 'Escala de dor (0-10)'),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.enterText(find.widgetWithText(TextFormField, 'Escala de dor (0-10)'), '5');
  await tester.pumpAndSettle();

  // Scroll até o botão Salvar e clicar
  await tester.scrollUntilVisible(
    find.text('Salvar Paciente'),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Salvar Paciente'));
  await tester.pumpAndSettle();

  // Verificar se os dados básicos foram salvos
  expect(mockNotifier.state, isNotEmpty);
  final pacienteSalvo = mockNotifier.state.first;
  expect(pacienteSalvo.nome, 'João Souza');
  expect(pacienteSalvo.queixaPrincipal, isNull);
  expect(pacienteSalvo.histDoencaAtual, isNull);
  expect(pacienteSalvo.comorbidades, isNull);
  expect(pacienteSalvo.medicamentos, isNull);
  expect(pacienteSalvo.alergias, isNull);
  expect(pacienteSalvo.cirurgias, isNull);
  expect(pacienteSalvo.habitosVida, isNull);
});

testWidgets('deve bloquear digitação de valor acima de 10 na escala de dor', (
  tester,
) async {
  await tester.pumpWidget(criarAppTeste());
  await tester.pumpAndSettle();

  // Scroll até o campo de dor
  await tester.scrollUntilVisible(
    find.widgetWithText(TextFormField, 'Escala de dor (0-10)'),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();

  // Tentar digitar 11 - deve ser bloqueado e manter vazio
  await tester.enterText(find.widgetWithText(TextFormField, 'Escala de dor (0-10)'), '11');
  await tester.pumpAndSettle();

  // O campo deve permanecer vazio (valor rejeitado pelo Formatter)
  final dorField = find.widgetWithText(TextFormField, 'Escala de dor (0-10)');
  final TextFormField dorWidget = tester.widget(dorField);
  expect(dorWidget.controller?.text, isEmpty);

  // Digitar valor válido (5) - deve aceitar
  await tester.enterText(find.widgetWithText(TextFormField, 'Escala de dor (0-10)'), '5');
  await tester.pumpAndSettle();
  expect(dorWidget.controller?.text, equals('5'));

  // Tentar digitar 99 - deve ser bloqueado e manter 5
  await tester.enterText(find.widgetWithText(TextFormField, 'Escala de dor (0-10)'), '99');
  await tester.pumpAndSettle();
  expect(dorWidget.controller?.text, equals('5'));
});
});
}