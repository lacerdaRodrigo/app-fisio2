import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fisio_home_care/modelos/paciente.dart';
import 'package:fisio_home_care/provedores/provedores_dados.dart';
import 'package:fisio_home_care/telas/tela_cadastro_paciente.dart';

Widget criarAppTeste() {
  return ProviderScope(
    overrides: [
      provedorListaPacientes.overrideWith(
        () => ListaPacientesNotifier(),
      ),
    ],
    child: const MaterialApp(home: TelaCadastroPaciente()),
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

      expect(find.text('Toque para preencher endereço'), findsOneWidget);
    });

    testWidgets('tocar no endereço abre o modal com 4 campos', (tester) async {
      await tester.pumpWidget(criarAppTeste());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Toque para preencher endereço'));
      await tester.pumpAndSettle();

      expect(find.text('Editar Endereço'), findsOneWidget);
      expect(find.text('Rua *'), findsOneWidget);
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

      await tester.tap(find.text('Toque para preencher endereço'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Rua *'), 'Rua Belém');
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

      await tester.tap(find.text('Toque para preencher endereço'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(find.text('Editar Endereço'), findsOneWidget);
      expect(find.text('Informe a rua.'), findsOneWidget);
      expect(find.text('Informe o bairro.'), findsOneWidget);
      expect(find.text('Informe a cidade.'), findsOneWidget);
    });

    testWidgets('endereço com apenas rua e cidade é composto corretamente', (
      tester,
    ) async {
      await tester.pumpWidget(criarAppTeste());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Toque para preencher endereço'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Rua *'), 'Av Paulista');
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

      expect(find.text('Toque para preencher endereço'), findsOneWidget);

      await tester.tap(find.text('Toque para preencher endereço'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Rua *'), 'Rua X');
      await tester.enterText(find.widgetWithText(TextFormField, 'Bairro *'), 'Bairro Y');
      await tester.enterText(find.widgetWithText(TextFormField, 'Cidade *'), 'Cidade Z');

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Toque para preencher endereço'), findsOneWidget);
      expect(find.text('Rua X'), findsNothing);
    });
  });
}
