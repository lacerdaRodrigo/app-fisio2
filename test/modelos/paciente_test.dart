import 'package:flutter_test/flutter_test.dart';
import 'package:fisio_home_care/modelos/paciente.dart';

void main() {
  group('Paciente', () {
    late Paciente paciente;

    setUp(() {
      paciente = Paciente(
        idPaciente: 'P001',
        nome: 'Carlos Eduardo',
        telefone: '(11) 99999-9999',
        dataNascimento: DateTime(1986, 6, 4),
        cpf: '529.982.247-25',
        endereco: 'Rua das Flores, 123, São Paulo - SP',
        queixaPrincipal: 'Dor lombar crônica',
        situacao: 'Ativo',
      );
    });

    test(
      'calcularIdade deve retornar 40 anos para nascido em 04/06/1986 na data 04/06/2026',
      () {
        expect(
          paciente.calcularIdade(dataReferencia: DateTime(2026, 6, 4)),
          equals(40),
        );
      },
    );

    test(
      'calcularIdade deve retornar 39 se o aniversário ainda não chegou',
      () {
        expect(
          paciente.calcularIdade(dataReferencia: DateTime(2026, 5, 1)),
          equals(39),
        );
      },
    );

    test('estaAtivo deve retornar verdadeiro quando situacao é Ativo', () {
      expect(paciente.estaAtivo, isTrue);
    });

    test('estaAtivo deve retornar falso quando situacao é Arquivado', () {
      final arquivado = paciente.copiarCom(situacao: 'Arquivado');
      expect(arquivado.estaAtivo, isFalse);
    });

    test(
      'copiarCom deve criar novo paciente com situacao alterada sem modificar o original',
      () {
        final arquivado = paciente.copiarCom(situacao: 'Arquivado');
        expect(arquivado.situacao, equals('Arquivado'));
        expect(paciente.situacao, equals('Ativo')); // Original inalterado
        expect(arquivado.nome, equals('Carlos Eduardo')); // Dados mantidos
      },
    );

    test('paraMapaPlanilha deve conter todas as chaves esperadas', () {
      final mapa = paciente.paraMapaPlanilha();
      expect(mapa.containsKey('ID_Paciente'), isTrue);
      expect(mapa.containsKey('Nome'), isTrue);
      expect(mapa.containsKey('CPF'), isTrue);
      expect(mapa.containsKey('Situacao'), isTrue);
      expect(mapa['Nome'], equals('Carlos Eduardo'));
      expect(mapa['Data_Nascimento'], equals('04/06/1986'));
    });

    test(
      'deLinhaPlanilha deve criar Paciente corretamente a partir de uma linha',
      () {
        final linha = [
          'P002',
          'Ana Paula',
          '(21) 98888-8888',
          '15/03/1996',
          '222.222.222-22',
          'Rua B, 456',
          'Dor no ombro',
          'HDA aqui',
          'Sem alergias',
          'Professora',
          'Ativo',
          '2026-06-04T10:00:00.000',
        ];
        final novoPaciente = Paciente.deLinhaPlanilha(linha);
        expect(novoPaciente.nome, equals('Ana Paula'));
        expect(novoPaciente.dataNascimento, equals(DateTime(1996, 3, 15)));
        expect(novoPaciente.situacao, equals('Ativo'));
      },
    );
  });
}
