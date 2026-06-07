import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';

import 'cliente_google_autenticado.dart';

const googleOAuthClientIdWeb = String.fromEnvironment(
  'GOOGLE_OAUTH_CLIENT_ID_WEB',
  defaultValue:
      '1034972209864-22ivlkbu9eu206fv6tvot90mup62stic.apps.googleusercontent.com',
);

const escoposGoogleFisio = <String>[
  'email',
  'https://www.googleapis.com/auth/drive.file',
];

class SessaoGoogle {
  final String nomeUsuario;
  final String email;
  final Future<Map<String, String>> Function() obterHeaders;

  const SessaoGoogle({
    required this.nomeUsuario,
    required this.email,
    required this.obterHeaders,
  });

  ClienteGoogleAutenticado criarCliente() {
    return ClienteGoogleAutenticado(obterHeaders);
  }
}

class ContaGoogleConectada {
  final String nomeUsuario;
  final String email;

  const ContaGoogleConectada({required this.nomeUsuario, required this.email});
}

abstract class ServicoAutenticacaoGoogle {
  Stream<ContaGoogleConectada> get contasConectadas;
  Stream<SessaoGoogle> get sessoesConectadas;
  Future<void> inicializar();
  Future<SessaoGoogle?> tentarRestaurarSessao();
  Future<SessaoGoogle> entrar();
  Future<void> sair();
}

class ServicoAutenticacaoGoogleReal implements ServicoAutenticacaoGoogle {
  final _contasController = StreamController<ContaGoogleConectada>.broadcast();
  final _sessoesController = StreamController<SessaoGoogle>.broadcast();
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: googleOAuthClientIdWeb,
    scopes: escoposGoogleFisio,
  );
  GoogleSignInAccount? _contaAtual;
  bool _inicializado = false;

  @override
  Stream<ContaGoogleConectada> get contasConectadas => _contasController.stream;

  @override
  Stream<SessaoGoogle> get sessoesConectadas => _sessoesController.stream;

  @override
  Future<void> inicializar() async {
    if (_inicializado) return;
    _inicializado = true;
  }

  @override
  Future<SessaoGoogle?> tentarRestaurarSessao() async {
    await inicializar();

    final conta = await _googleSignIn.signInSilently();
    if (conta == null) return null;

    _contaAtual = conta;
    return _criarSessao(conta);
  }

  @override
  Future<SessaoGoogle> entrar() async {
    await inicializar();

    final conta = await _googleSignIn.signIn();
    if (conta == null) {
      throw StateError('Login Google cancelado.');
    }

    _contaAtual = conta;
    final sessao = _criarSessao(conta);
    _sessoesController.add(sessao);
    _contasController.add(
      ContaGoogleConectada(
        nomeUsuario: conta.displayName ?? conta.email,
        email: conta.email,
      ),
    );
    return sessao;
  }

  SessaoGoogle _criarSessao(GoogleSignInAccount conta) {
    Future<Map<String, String>> obterHeaders() async {
      final auth = await conta.authentication;
      final token = auth.accessToken;
      if (token == null || token.isEmpty) {
        throw StateError('Não foi possível obter autorização do Google.');
      }
      return {'Authorization': 'Bearer $token'};
    }

    return SessaoGoogle(
      nomeUsuario: conta.displayName ?? conta.email,
      email: conta.email,
      obterHeaders: obterHeaders,
    );
  }

  @override
  Future<void> sair() async {
    if (!_inicializado) return;
    _contaAtual = null;
    await _googleSignIn.signOut();
  }
}
