import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../servicos/servico_autenticacao_google.dart';

final provedorServicoAutenticacaoGoogle = Provider<ServicoAutenticacaoGoogle>(
  (ref) => ServicoAutenticacaoGoogleReal(),
);

// Estado da Autenticação
class EstadoAutenticacao {
  final bool estaAutenticado;
  final bool estaCarregando;
  final bool termosAceitos;
  final bool googleConectado;
  final bool precisaAutorizarDados;
  final String? mensagemErro;
  final SessaoGoogle? sessao;
  final ContaGoogleConectada? contaConectada;

  EstadoAutenticacao({
    this.estaAutenticado = false,
    this.estaCarregando = false,
    this.termosAceitos = false,
    this.googleConectado = false,
    this.precisaAutorizarDados = false,
    this.mensagemErro,
    this.sessao,
    this.contaConectada,
  });

  EstadoAutenticacao copiarCom({
    bool? estaAutenticado,
    bool? estaCarregando,
    bool? termosAceitos,
    bool? googleConectado,
    bool? precisaAutorizarDados,
    String? mensagemErro,
    SessaoGoogle? sessao,
    ContaGoogleConectada? contaConectada,
  }) {
    return EstadoAutenticacao(
      estaAutenticado: estaAutenticado ?? this.estaAutenticado,
      estaCarregando: estaCarregando ?? this.estaCarregando,
      termosAceitos: termosAceitos ?? this.termosAceitos,
      googleConectado: googleConectado ?? this.googleConectado,
      precisaAutorizarDados:
          precisaAutorizarDados ?? this.precisaAutorizarDados,
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
    unawaited(
      servico.inicializar().catchError((Object _) {
        state = state.copiarCom(
          mensagemErro: 'Falha ao inicializar o login Google.',
        );
      }),
    );

    final assinatura = servico.contasConectadas.listen((conta) async {
      if (!state.termosAceitos) {
        state = state.copiarCom(
          estaCarregando: false,
          mensagemErro: 'Você precisa aceitar os Termos de Uso e LGPD.',
        );
        await servico.sair();
        return;
      }

      state = state.copiarCom(
        estaAutenticado: false,
        estaCarregando: false,
        mensagemErro: null,
        googleConectado: true,
        precisaAutorizarDados: true,
        contaConectada: conta,
      );
    });
    ref.onDispose(assinatura.cancel);

    return EstadoAutenticacao();
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
        googleConectado: true,
        precisaAutorizarDados: false,
        sessao: sessao,
      );
    } catch (e) {
      state = state.copiarCom(
        estaCarregando: false,
        mensagemErro:
            'Falha ao autenticar. Verifique sua conexão e tente novamente.',
      );
    }
  }

  Future<void> autorizarDadosGoogle() async {
    if (!state.termosAceitos) {
      state = state.copiarCom(
        mensagemErro: 'Você precisa aceitar os Termos de Uso e LGPD.',
      );
      return;
    }

    state = state.copiarCom(estaCarregando: true, mensagemErro: null);

    try {
      final sessao = await ref
          .read(provedorServicoAutenticacaoGoogle)
          .autorizarDados();
      state = state.copiarCom(
        estaAutenticado: true,
        estaCarregando: false,
        googleConectado: true,
        precisaAutorizarDados: false,
        sessao: sessao,
      );
    } catch (e) {
      state = state.copiarCom(
        estaCarregando: false,
        mensagemErro:
            'Falha ao autorizar Drive/Sheets. Verifique permissões e tente novamente.',
      );
    }
  }

  Future<void> sair() async {
    await ref.read(provedorServicoAutenticacaoGoogle).sair();
    state = EstadoAutenticacao();
  }
}

// Provedor
final provedorAutenticacao =
    NotifierProvider<AutenticacaoNotificador, EstadoAutenticacao>(
      AutenticacaoNotificador.new,
    );
