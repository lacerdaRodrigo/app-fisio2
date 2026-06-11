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

  group('atualizarEvolucaoReal - lógica de substituição', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      final agora = DateTime.now();
      container.read(provedorListaEvolucoes.notifier).definir([
        Evolucao(
          idEvolucao: 'E001',
          idPaciente: 'P001',
          idAgendamento: 'A001',
          dataAtendimento: agora,
          evolucaoTexto: 'Versão original',
          horarioInicioReal: agora,
          horarioFimReal: agora.add(const Duration(hours: 1)),
        ),
        Evolucao(
          idEvolucao: 'E002',
          idPaciente: 'P002',
          idAgendamento: 'A002',
          dataAtendimento: agora,
          evolucaoTexto: 'Outra evolução',
          horarioInicioReal: agora,
          horarioFimReal: agora.add(const Duration(hours: 1)),
        ),
      ]);
    });

    tearDown(() {
      container.dispose();
    });

    test('deve substituir a evolução existente na lista', () {
      final agora = DateTime.now();
      final evolucaoAtualizada = Evolucao(
        idEvolucao: 'E001',
        idPaciente: 'P001',
        idAgendamento: 'A001',
        dataAtendimento: agora,
        evolucaoTexto: 'Versão atualizada',
        horarioInicioReal: agora,
        horarioFimReal: agora.add(const Duration(hours: 1)),
      );

      final listaAtual = container.read(provedorListaEvolucoes);
      container.read(provedorListaEvolucoes.notifier).definir([
        for (final e in listaAtual)
          if (e.idEvolucao == evolucaoAtualizada.idEvolucao)
            evolucaoAtualizada
          else
            e,
      ]);

      final lista = container.read(provedorListaEvolucoes);
      expect(lista.length, 2);
      expect(lista.firstWhere((e) => e.idEvolucao == 'E001').evolucaoTexto,
          'Versão atualizada');
      expect(lista.firstWhere((e) => e.idEvolucao == 'E002').evolucaoTexto,
          'Outra evolução');
    });
  });

  group('restaurarPacienteReal - lógica de alteração de situacao', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container.read(provedorListaPacientes.notifier).definir([
        Paciente(
          idPaciente: 'P001',
          nome: 'João Arquivado',
          telefone: '11999999999',
          dataNascimento: DateTime(1990, 1, 1),
          cpf: '12345678901',
          endereco: 'Rua A',
          situacao: 'Arquivado',
        ),
        Paciente(
          idPaciente: 'P002',
          nome: 'Maria Ativo',
          telefone: '11999999998',
          dataNascimento: DateTime(1992, 5, 10),
          cpf: '98765432101',
          endereco: 'Rua B',
          situacao: 'Ativo',
        ),
      ]);
    });

    tearDown(() {
      container.dispose();
    });

    test('deve alterar situacao de Arquivado para Ativo', () {
      final idPaciente = 'P001';
      final pacientesAtual = container.read(provedorListaPacientes);
      container.read(provedorListaPacientes.notifier).definir([
        for (final paciente in pacientesAtual)
          if (paciente.idPaciente == idPaciente)
            paciente.copiarCom(situacao: 'Ativo')
          else
            paciente,
      ]);

      final lista = container.read(provedorListaPacientes);
      expect(lista.length, 2);

      final restaurado = lista.firstWhere((p) => p.idPaciente == 'P001');
      expect(restaurado.estaAtivo, isTrue);
      expect(restaurado.situacao, 'Ativo');

      final outro = lista.firstWhere((p) => p.idPaciente == 'P002');
      expect(outro.estaAtivo, isTrue);
    });
  });
}
