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
  });
}
