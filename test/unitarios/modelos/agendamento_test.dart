import 'package:flutter_test/flutter_test.dart';
import 'package:fisio_home_care/modelos/agendamento.dart';

void main() {
  group('Agendamento', () {
    late Agendamento agendamento;

    setUp(() {
      agendamento = Agendamento(
        idAgendamento: 'A001',
        idPaciente: 'P001',
        data: DateTime(2026, 6, 5),
        horaInicio: '14:00',
        horaFim: '15:00',
        valorSessao: 150.00,
        observacoes: 'Levar TENS',
        situacao: 'Agendado',
      );
    });

    test('estaAgendado deve retornar verdadeiro para situacao Agendado', () {
      expect(agendamento.estaAgendado, isTrue);
      expect(agendamento.foiRealizado, isFalse);
      expect(agendamento.foiCancelado, isFalse);
    });

    test(
      'copiarCom para Realizado deve atualizar a situacao mantendo dados',
      () {
        final realizado = agendamento.copiarCom(situacao: 'Realizado');
        expect(realizado.foiRealizado, isTrue);
        expect(realizado.estaAgendado, isFalse);
        expect(realizado.idPaciente, equals('P001'));
        expect(realizado.valorSessao, equals(150.00));
      },
    );

    test('paraMapaPlanilha deve conter todas as chaves da aba Agenda', () {
      final mapa = agendamento.paraMapaPlanilha();
      expect(mapa['ID_Agendamento'], equals('A001'));
      expect(mapa['Data'], equals('05/06/2026'));
      expect(mapa['Hora_Inicio'], equals('14:00'));
      expect(mapa['Valor_Sessao'], equals('150.00'));
      expect(mapa['Situacao'], equals('Agendado'));
    });

    test('ehDeHoje deve considerar apenas dia, mes e ano', () {
      expect(agendamento.ehDeHoje(DateTime(2026, 6, 5, 23, 59)), isTrue);
      expect(agendamento.ehDeHoje(DateTime(2026, 6, 6)), isFalse);
    });

    test('estaAtrasado deve considerar horario previsto sem desfecho', () {
      expect(agendamento.estaAtrasado(DateTime(2026, 6, 5, 14, 1)), isTrue);
      expect(agendamento.estaAtrasado(DateTime(2026, 6, 5, 13, 59)), isFalse);

      final realizado = agendamento.copiarCom(
        situacao: Agendamento.situacaoRealizado,
      );
      expect(realizado.estaAtrasado(DateTime(2026, 6, 5, 14, 1)), isFalse);
    });

    test('pendenteDeDiaAnterior deve ativar quando vira o dia', () {
      expect(
        agendamento.pendenteDeDiaAnterior(DateTime(2026, 6, 6, 8)),
        isTrue,
      );
      expect(
        agendamento.pendenteDeDiaAnterior(DateTime(2026, 6, 5, 23)),
        isFalse,
      );
    });

    test('cancelamentos e faltas devem ser desfechos', () {
      final canceladoPaciente = agendamento.copiarCom(
        situacao: Agendamento.situacaoCanceladoPaciente,
      );
      final faltouSemAviso = agendamento.copiarCom(
        situacao: Agendamento.situacaoFaltouSemAviso,
      );

      expect(canceladoPaciente.foiCancelado, isTrue);
      expect(canceladoPaciente.possuiDesfecho, isTrue);
      expect(faltouSemAviso.foiFalta, isTrue);
      expect(faltouSemAviso.possuiDesfecho, isTrue);
    });
  });
}
