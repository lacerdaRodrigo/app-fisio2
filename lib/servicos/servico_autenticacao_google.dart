import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';

import 'cliente_google_autenticado.dart';

const googleOAuthClientIdWeb = String.fromEnvironment(
  'GOOGLE_OAUTH_CLIENT_ID_WEB',
  defaultValue:
      '820919952399-r2268ts3r6jvaoshn5361rtb7f8mrrqi.apps.googleusercontent.com',
);

const escoposGoogleFisio = <String>[
  'email',
  'https://www.googleapis.com/auth/drive.file',
  'https://www.googleapis.com/auth/spreadsheets',
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
  Future<void> inicializar();
  Future<SessaoGoogle> entrar();
  Future<SessaoGoogle> autorizarDados();
  Future<void> sair();
}

class ServicoAutenticacaoGoogleReal implements ServicoAutenticacaoGoogle {
  final _contasController = StreamController<ContaGoogleConectada>.broadcast();
  GoogleSignInAccount? _contaAtual;
  bool _inicializado = false;

  @override
  Stream<ContaGoogleConectada> get contasConectadas => _contasController.stream;

  @override
  Future<void> inicializar() async {
    if (_inicializado) return;

    await GoogleSignIn.instance.initialize(clientId: googleOAuthClientIdWeb);
    GoogleSignIn.instance.authenticationEvents.listen((event) async {
      if (event case GoogleSignInAuthenticationEventSignIn(:final user)) {
        _contaAtual = user;
        _contasController.add(
          ContaGoogleConectada(
            nomeUsuario: user.displayName ?? user.email,
            email: user.email,
          ),
        );
      }
    });
    _inicializado = true;
  }

  @override
  Future<SessaoGoogle> entrar() async {
    await inicializar();

    final conta = await GoogleSignIn.instance.authenticate(
      scopeHint: escoposGoogleFisio,
    );
    _contaAtual = conta;
    return _sessaoDeConta(conta);
  }

  @override
  Future<SessaoGoogle> autorizarDados() async {
    await inicializar();
    final conta = _contaAtual;
    if (conta == null) {
      throw StateError('Faça login com Google antes de autorizar os dados.');
    }
    return _sessaoDeConta(conta);
  }

  Future<SessaoGoogle> _sessaoDeConta(GoogleSignInAccount conta) async {
    await conta.authorizationClient.authorizeScopes(escoposGoogleFisio);
    Future<Map<String, String>> obterHeaders() async {
      final headers = await conta.authorizationClient.authorizationHeaders(
        escoposGoogleFisio,
      );
      if (headers == null) {
        throw StateError('Não foi possível obter autorização do Google.');
      }
      return headers;
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
    await GoogleSignIn.instance.signOut();
  }
}
