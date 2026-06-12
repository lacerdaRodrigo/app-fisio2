import 'package:flutter/services.dart';

/// Traduz erros do Google Sign-In para mensagens úteis na UI.
String mensagemErroLoginGoogle(Object erro) {
  if (erro is StateError && erro.message == 'Login Google cancelado.') {
    return 'Login cancelado.';
  }

  final texto = erro is PlatformException
      ? '${erro.code} ${erro.message} ${erro.details}'
      : erro.toString();

  if (texto.contains('12500')) {
    return 'Login Google não configurado no Android. '
        'Ative o provedor Google em Firebase → Authentication, '
        'confirme o SHA-1 no Firebase e crie o cliente OAuth Android '
        'no Google Cloud Console (projeto app-fisio-care-2).';
  }

  if (RegExp(r'\b10\b|: 10|ApiException: 10').hasMatch(texto)) {
    return 'SHA-1 ou pacote Android não conferem com o Firebase. '
        'Verifique com.rodrigo.fisio_care e baixe um novo google-services.json.';
  }

  if (texto.contains('access_denied') || texto.contains('12501')) {
    return 'Permissão negada. Adicione seu e-mail como usuário de teste '
        'na Tela de consentimento OAuth (Google Cloud Console).';
  }

  return 'Falha ao autenticar. Verifique sua conexão e tente novamente.';
}
