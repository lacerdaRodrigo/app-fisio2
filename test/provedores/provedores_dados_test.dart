import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fisio_home_care/modelos/paciente.dart';
import 'package:fisio_home_care/modelos/agendamento.dart';
import 'package:fisio_home_care/modelos/evolucao.dart';
import 'package:fisio_home_care/provedores/provedores_dados.dart';

void main() {
  group('limparDados', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('deve limpar a lista de pacientes', () {
      container.read(provedorListaPacientes.notifier).definir([
        Paciente(
          idPaciente: 'P001',
          nome: 'João',
          telefone: '11999999999',
          dataNascimento: DateTime(1990, 1, 1),
          cpf: '12345678901',
          endereco: 'Rua A',
        ),
      ]);
      expect(container.read(provedorListaPacientes), isNotEmpty);

      container.read(provedorListaPacientes.notifier).definir([]);

      expect(container.read(provedorListaPacientes), isEmpty);
    });

    test('deve limpar a lista de agendamentos', () {
      container.read(provedorListaAgendamentos.notifier).definir([
        Agendamento(
          idAgendamento: 'A001',
          idPaciente: 'P001',
          data: DateTime.now(),
          horaInicio: '08:00',
          horaFim: '09:00',
          valorSessao: 150.0,
        ),
      ]);
      expect(container.read(provedorListaAgendamentos), isNotEmpty);

      container.read(provedorListaAgendamentos.notifier).definir([]);

      expect(container.read(provedorListaAgendamentos), isEmpty);
    });

    test('deve limpar a lista de evoluções', () {
      final agora = DateTime.now();
      container.read(provedorListaEvolucoes.notifier).definir([
        Evolucao(
          idEvolucao: 'E001',
          idPaciente: 'P001',
          idAgendamento: 'A001',
          dataAtendimento: agora,
          evolucaoTexto: 'Paciente evoluiu bem.',
          horarioInicioReal: agora,
          horarioFimReal: agora.add(const Duration(hours: 1)),
        ),
      ]);
      expect(container.read(provedorListaEvolucoes), isNotEmpty);

      container.read(provedorListaEvolucoes.notifier).definir([]);

      expect(container.read(provedorListaEvolucoes), isEmpty);
    });

    test('deve limpar o termo de busca', () {
      container.read(provedorBusca.notifier).definir('João');
      expect(container.read(provedorBusca), isNotEmpty);

      container.read(provedorBusca.notifier).definir('');

      expect(container.read(provedorBusca), isEmpty);
    });

    test('deve resetar o valor padrão da sessão para 150,00', () {
      container.read(provedorValorSessaoPadrao.notifier).definir('200,00');
      expect(container.read(provedorValorSessaoPadrao), '200,00');

      container.read(provedorValorSessaoPadrao.notifier).definir('150,00');

      expect(container.read(provedorValorSessaoPadrao), '150,00');
    });

    test('deve limpar logs de auditoria', () {
      container.read(provedorLogsAuditoria.notifier).adicionar('Log de teste');
      expect(container.read(provedorLogsAuditoria), isNotEmpty);

      container.read(provedorLogsAuditoria.notifier).definir([]);

      expect(container.read(provedorLogsAuditoria), isEmpty);
    });

    test('deve resetar planilhaId para null', () {
      container.read(provedorPlanilhaId.notifier).definir('abc123');
      expect(container.read(provedorPlanilhaId), isNotNull);

      container.read(provedorPlanilhaId.notifier).definir(null);

      expect(container.read(provedorPlanilhaId), isNull);
    });
  });
}
