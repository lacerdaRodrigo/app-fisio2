/// Utilitários de validação e formatação de CPF.
class ValidadorCpf {
  /// Verifica se o CPF é estruturalmente válido (algoritmo dos dígitos verificadores).
  static bool validar(String cpf) {
    // Remove caracteres não numéricos
    final apenas = cpf.replaceAll(RegExp(r'[^\d]'), '');

    if (apenas.length != 11) return false;

    // Rejeita CPFs com todos os dígitos iguais (ex: 111.111.111-11)
    if (RegExp(r'^(\d)\1{10}$').hasMatch(apenas)) return false;

    // Calcula o primeiro dígito verificador
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(apenas[i]) * (10 - i);
    }
    int resto = soma % 11;
    int digito1 = resto < 2 ? 0 : 11 - resto;

    if (int.parse(apenas[9]) != digito1) return false;

    // Calcula o segundo dígito verificador
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(apenas[i]) * (11 - i);
    }
    resto = soma % 11;
    int digito2 = resto < 2 ? 0 : 11 - resto;

    return int.parse(apenas[10]) == digito2;
  }

  /// Aplica a máscara de formatação (XXX.XXX.XXX-XX) em uma string numérica.
  static String formatar(String cpf) {
    final apenas = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (apenas.length != 11) return cpf;

    return '${apenas.substring(0, 3)}.${apenas.substring(3, 6)}.${apenas.substring(6, 9)}-${apenas.substring(9)}';
  }

  /// Remove a máscara de formatação, retornando apenas os dígitos.
  static String removerMascara(String cpf) {
    return cpf.replaceAll(RegExp(r'[^\d]'), '');
  }
}
