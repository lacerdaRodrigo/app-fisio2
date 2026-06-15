/// Utilitários para validação de dados de entrada
/// Todos os métodos retornam bool: true = válido, false = inválido
class Validadores {
  /// Valida um CPF. Remove formatação e verifica dígitos verificadores.
  /// Aceita: 123.456.789-09 ou 12345678909
  static bool validarCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');

    // CPF deve ter 11 dígitos
    if (cpf.length != 11) return false;

    // Números repetidos são inválidos
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;

    // Validar primeiro dígito verificador
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int resto = soma % 11;
    int digito1 = resto < 2 ? 0 : 11 - resto;

    if (int.parse(cpf[9]) != digito1) return false;

    // Validar segundo dígito verificador
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    resto = soma % 11;
    int digito2 = resto < 2 ? 0 : 11 - resto;

    return int.parse(cpf[10]) == digito2;
  }

  /// Valida telefone brasileiro.
  /// Aceita: (11) 9999-9999, (11) 99999-9999, 119999-9999, etc
  static bool validarTelefone(String telefone) {
    final apenas = telefone.replaceAll(RegExp(r'\D'), '');

    // Telefone deve ter 10 ou 11 dígitos
    if (apenas.length < 10 || apenas.length > 11) return false;

    // Não pode começar com zero
    if (apenas.startsWith('0')) return false;

    // DDD (primeiros 2 dígitos) deve ser de 11 a 99
    final ddd = int.parse(apenas.substring(0, 2));
    if (ddd < 11 || ddd > 99) return false;

    return true;
  }

  /// Valida data de nascimento.
  /// Não pode ser futura e deve resultar em uma pessoa viva.
  static bool validarDataNascimento(DateTime data) {
    final hoje = DateTime.now();

    // Data não pode ser no futuro
    if (data.isAfter(hoje)) return false;

    // Pessoa deve ter pelo menos 0 anos (pode ser 0 na criação)
    int idade = hoje.year - data.year;
    if (hoje.month < data.month ||
        (hoje.month == data.month && hoje.day < data.day)) {
      idade--;
    }

    return idade >= 0;
  }

  /// Valida endereço.
  /// Deve ter pelo menos 5 caracteres e não pode estar vazio.
  static bool validarEndereco(String endereco) {
    final trimado = endereco.trim();
    return trimado.isNotEmpty && trimado.length >= 5;
  }

  /// Valida nome completo.
  /// Deve ter pelo menos 2 nomes (primeiro e último).
  /// Cada nome deve ter pelo menos 2 caracteres.
  static bool validarNome(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+'));

    // Mínimo 2 partes (primeiro e último nome)
    if (partes.length < 2) return false;

    // Cada parte deve ter pelo menos 2 caracteres
    return partes.every((parte) => parte.length >= 2);
  }

  /// Retorna uma mensagem de erro específica para validação de CPF.
  static String? mensagemErroCPF(String cpf) {
    if (cpf.isEmpty) return 'CPF é obrigatório';
    if (cpf.replaceAll(RegExp(r'\D'), '').length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    if (!validarCPF(cpf)) return 'CPF é inválido';
    return null;
  }

  /// Retorna uma mensagem de erro específica para validação de telefone.
  static String? mensagemErroTelefone(String telefone) {
    if (telefone.isEmpty) return 'Telefone é obrigatório';
    if (!validarTelefone(telefone)) return 'Telefone é inválido';
    return null;
  }

  /// Retorna uma mensagem de erro específica para validação de data.
  static String? mensagemErroDataNascimento(DateTime? data) {
    if (data == null) return 'Data de nascimento é obrigatória';
    if (!validarDataNascimento(data)) {
      return 'Data de nascimento é inválida';
    }
    return null;
  }

  /// Retorna uma mensagem de erro específica para validação de endereço.
  static String? mensagemErroEndereco(String endereco) {
    if (endereco.isEmpty) return 'Endereço é obrigatório';
    if (!validarEndereco(endereco)) {
      return 'Endereço deve ter pelo menos 5 caracteres';
    }
    return null;
  }

  /// Retorna uma mensagem de erro específica para validação de nome.
  static String? mensagemErroNome(String nome) {
    if (nome.isEmpty) return 'Nome é obrigatório';
    if (!validarNome(nome)) {
      return 'Nome deve conter primeiro e último nome, com pelo menos 2 caracteres cada';
    }
    return null;
  }
}
