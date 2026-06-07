import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fisio_home_care/provedores/provedor_autenticacao.dart';
import 'package:fisio_home_care/servicos/servico_autenticacao_google.dart';

class ServicoAutenticacaoGoogleFake implements ServicoAutenticacaoGoogle {
  @override
  Stream<ContaGoogleConectada> get contasConectadas => const Stream.empty();

  @override
  Stream<SessaoGoogle> get sessoesConectadas => const Stream.empty();

  @override
  Future<void> inicializar() async {}

  @override
  Future<SessaoGoogle?> tentarRestaurarSessao() async => null;

  @override
  Future<SessaoGoogle> entrar() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return _sessao();
  }

  SessaoGoogle _sessao() {
    return SessaoGoogle(
      nomeUsuario: 'Dr. Teste',
      email: 'teste@example.com',
      obterHeaders: () async => {'Authorization': 'Bearer fake-token'},
    );
  }

  @override
  Future<void> sair() async {}
}

void main() {
  group('AutenticacaoNotificador', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          provedorServicoAutenticacaoGoogle.overrideWithValue(
            ServicoAutenticacaoGoogleFake(),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'O estado inicial deve ter termos não aceitos e não estar autenticado',
      () {
        final estado = container.read(provedorAutenticacao);
        expect(estado.termosAceitos, isFalse);
        expect(estado.estaAutenticado, isFalse);
        expect(estado.estaCarregando, isFalse);
        expect(estado.mensagemErro, isNull);
      },
    );

    test('aceitarTermos deve atualizar o estado para verdadeiro', () {
      container.read(provedorAutenticacao.notifier).aceitarTermos(true);
      final estado = container.read(provedorAutenticacao);
      expect(estado.termosAceitos, isTrue);
    });

    test('entrarComGoogle sem aceitar os termos deve gerar um erro', () async {
      await container.read(provedorAutenticacao.notifier).entrarComGoogle();

      final estado = container.read(provedorAutenticacao);
      expect(estado.estaCarregando, isFalse);
      expect(estado.estaAutenticado, isFalse);
      expect(
        estado.mensagemErro,
        'Você precisa aceitar os Termos de Uso e LGPD.',
      );
    });

    test(
      'entrarComGoogle com os termos aceitos deve mudar para estado de carregamento',
      () async {
        final notifier = container.read(provedorAutenticacao.notifier);
        notifier.aceitarTermos(true);

        final future = notifier.entrarComGoogle();

        var estado = container.read(provedorAutenticacao);
        expect(estado.estaCarregando, isTrue);
        expect(estado.mensagemErro, isNull);

        await future;

        estado = container.read(provedorAutenticacao);
        expect(estado.estaCarregando, isFalse);
        expect(estado.estaAutenticado, isTrue);
        expect(estado.sessao?.email, 'teste@example.com');
      },
    );

    test('sair deve resetar o estado para o inicial', () async {
      final notifier = container.read(provedorAutenticacao.notifier);
      notifier.aceitarTermos(true);
      await notifier.sair();

      final estado = container.read(provedorAutenticacao);
      expect(estado.termosAceitos, isFalse);
      expect(estado.estaAutenticado, isFalse);
    });
  });
}
