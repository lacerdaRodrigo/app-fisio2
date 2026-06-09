import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../servicos/preferencias.dart';
import '../servicos/servico_autenticacao_google.dart';

final provedorServicoAutenticacaoGoogle = Provider<ServicoAutenticacaoGoogle>(
  (ref) => ServicoAutenticacaoGoogleReal(),
);

class EstadoAutenticacao {
  final bool estaAutenticado;
  final bool estaCarregando;
  final bool termosAceitos;
  final String? mensagemErro;
  final SessaoGoogle? sessao;
  final ContaGoogleConectada? contaConectada;

  EstadoAutenticacao({
    this.estaAutenticado = false,
    this.estaCarregando = false,
    this.termosAceitos = false,
    this.mensagemErro,
    this.sessao,
    this.contaConectada,
  });

  EstadoAutenticacao copiarCom({
    bool? estaAutenticado,
    bool? estaCarregando,
    bool? termosAceitos,
    String? mensagemErro,
    SessaoGoogle? sessao,
    ContaGoogleConectada? contaConectada,
  }) {
    return EstadoAutenticacao(
      estaAutenticado: estaAutenticado ?? this.estaAutenticado,
      estaCarregando: estaCarregando ?? this.estaCarregando,
      termosAceitos: termosAceitos ?? this.termosAceitos,
      mensagemErro: mensagemErro,
      sessao: sessao ?? this.sessao,
      contaConectada: contaConectada ?? this.contaConectada,
    );
  }
}

// Notificador de Estado
class AutenticacaoNotificador extends Notifier<EstadoAutenticacao> {
  @override
  EstadoAutenticacao build() {
    final servico = ref.read(provedorServicoAutenticacaoGoogle);
    final assinaturaContas = servico.contasConectadas.listen((conta) {
      state = state.copiarCom(
        estaCarregando: false,
        mensagemErro: null,
        contaConectada: conta,
      );
    });
    ref.onDispose(assinaturaContas.cancel);

    final assinaturaSessoes = servico.sessoesConectadas.listen(
      _autenticarComSessao,
      onError: (Object _) {
        state = state.copiarCom(
          estaCarregando: false,
          mensagemErro:
              'Falha ao autenticar. Verifique sua conexão e tente novamente.',
        );
      },
    );
    ref.onDispose(assinaturaSessoes.cancel);

    unawaited(
      servico.inicializar().catchError((Object _) {
        state = state.copiarCom(
          mensagemErro: 'Falha ao inicializar o login Google.',
        );
      }),
    );

    return EstadoAutenticacao();
  }

  void _autenticarComSessao(SessaoGoogle sessao) {
    state = state.copiarCom(
      estaAutenticado: true,
      estaCarregando: false,
      mensagemErro: null,
      sessao: sessao,
    );
  }

  void aceitarTermos(bool aceitou) {
    state = state.copiarCom(termosAceitos: aceitou, mensagemErro: null);
  }

  Future<void> entrarComGoogle() async {
    if (!state.termosAceitos) {
      state = state.copiarCom(
        mensagemErro: 'Você precisa aceitar os Termos de Uso e LGPD.',
      );
      return;
    }

    state = state.copiarCom(estaCarregando: true, mensagemErro: null);

    try {
      final sessao = await ref.read(provedorServicoAutenticacaoGoogle).entrar();
      state = state.copiarCom(
        estaAutenticado: true,
        estaCarregando: false,
        sessao: sessao,
      );
    } catch (e) {
      print('ERRO_LOGIN_GOOGLE: $e');
      state = state.copiarCom(
        estaCarregando: false,
        mensagemErro:
            'Falha ao autenticar. Verifique sua conexão e tente novamente.',
      );
    }
  }

  Future<void> sair() async {
    await ref.read(provedorServicoAutenticacaoGoogle).sair();
    await Preferencias.limparPlanilhaId();
    state = EstadoAutenticacao();
  }
}

// Provedor
final provedorAutenticacao =
    NotifierProvider<AutenticacaoNotificador, EstadoAutenticacao>(
      AutenticacaoNotificador.new,
    );
