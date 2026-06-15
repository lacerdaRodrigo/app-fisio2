import 'package:flutter_test/flutter_test.dart';
import 'package:fisio_home_care/servicos/versao_esquema.dart';

void main() {
  group('VersaoEsquema', () {
    test('VERSAO_ATUAL é definida', () {
      expect(VersaoEsquema.VERSAO_ATUAL, greaterThan(0));
      expect(VersaoEsquema.VERSAO_ATUAL, equals(1));
    });

    test('HISTORICO contém entrada para versão atual', () {
      expect(
        VersaoEsquema.HISTORICO.containsKey(VersaoEsquema.VERSAO_ATUAL),
        isTrue,
      );
    });

    test('HISTORICO[1] possui descrição', () {
      final descricao = VersaoEsquema.HISTORICO[1];
      expect(descricao, isNotNull);
      expect(descricao, isNotEmpty);
    });
  });

  group('VersaoEsquema.obterIndicesColunas', () {
    test('retorna mapa para versão atual', () {
      final indices = VersaoEsquema.obterIndicesColunas(1);
      expect(indices, isNotEmpty);
      expect(indices, isA<Map<String, int>>());
    });

    test('contém colunas essenciais para Pacientes', () {
      final indices = VersaoEsquema.obterIndicesColunas(1);
      expect(indices.containsKey('idPaciente'), isTrue);
      expect(indices.containsKey('nome'), isTrue);
      expect(indices.containsKey('telefone'), isTrue);
      expect(indices.containsKey('cpf'), isTrue);
      expect(indices.containsKey('endereco'), isTrue);
    });

    test('índices começam em 0', () {
      final indices = VersaoEsquema.obterIndicesColunas(1);
      expect(indices['idPaciente'], equals(0));
    });

    test('índices são sequenciais', () {
      final indices = VersaoEsquema.obterIndicesColunas(1);
      final valores = indices.values.toList();
      valores.sort();

      for (int i = 0; i < valores.length; i++) {
        expect(valores[i], equals(i));
      }
    });

    test('lança exceção para versão não suportada', () {
      expect(
        () => VersaoEsquema.obterIndicesColunas(999),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('VersaoEsquema.validar', () {
    test('retorna null para versão compatível', () {
      final resultado = VersaoEsquema.validar(VersaoEsquema.VERSAO_ATUAL);
      expect(resultado, isNull);
    });

    test('retorna mensagem para versão maior', () {
      final resultado = VersaoEsquema.validar(VersaoEsquema.VERSAO_ATUAL + 1);
      expect(resultado, isNotNull);
      expect(resultado, contains('Atualize o app'));
    });

    test('retorna mensagem para versão menor', () {
      final resultado = VersaoEsquema.validar(VersaoEsquema.VERSAO_ATUAL - 1);
      expect(resultado, isNotNull);
      expect(resultado, contains('migrar'));
    });

    test('mensagem contém número da versão', () {
      final resultado = VersaoEsquema.validar(2);
      expect(resultado, contains('2'));
    });
  });

  group('VersaoEsquema.ehSuportada', () {
    test('retorna true para versão atual', () {
      expect(
        VersaoEsquema.ehSuportada(VersaoEsquema.VERSAO_ATUAL),
        isTrue,
      );
    });

    test('retorna true para versão menor', () {
      expect(
        VersaoEsquema.ehSuportada(VersaoEsquema.VERSAO_ATUAL - 1),
        isTrue,
      );
    });

    test('retorna false para versão maior', () {
      expect(
        VersaoEsquema.ehSuportada(VersaoEsquema.VERSAO_ATUAL + 1),
        isFalse,
      );
    });
  });

  group('VersaoEsquema.obterDescricao', () {
    test('retorna descrição para versão conhecida', () {
      final descricao = VersaoEsquema.obterDescricao(1);
      expect(descricao, isNotEmpty);
      expect(descricao, isNotNull);
    });

    test('retorna mensagem para versão desconhecida', () {
      final descricao = VersaoEsquema.obterDescricao(999);
      expect(descricao, contains('desconhecida'));
    });
  });

  group('VersaoEsquema.obterProximaVersao', () {
    test('retorna versão incrementada', () {
      expect(VersaoEsquema.obterProximaVersao(1), equals(2));
      expect(VersaoEsquema.obterProximaVersao(5), equals(6));
    });
  });

  group('Fluxo de versionamento', () {
    test('versão 1 é suportada e compatível', () {
      expect(VersaoEsquema.ehSuportada(1), isTrue);
      expect(VersaoEsquema.validar(1), isNull);
    });

    test('índices estão definidos para versão 1', () {
      final indices = VersaoEsquema.obterIndicesColunas(1);
      expect(indices.isNotEmpty, isTrue);
    });

    test('próxima versão após 1 é 2', () {
      expect(VersaoEsquema.obterProximaVersao(1), equals(2));
    });

    test('histórico documenta versão 1', () {
      expect(VersaoEsquema.HISTORICO.containsKey(1), isTrue);
    });
  });
}
