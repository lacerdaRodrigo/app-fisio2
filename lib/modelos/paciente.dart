import '../utilitarios/validadores.dart';

/// Modelo de dados representando um paciente cadastrado.
/// Espelha a aba `Pacientes` da planilha `__saas_fisio_db__`.
class Paciente {
  final String idPaciente;
  final String nome;
  final String telefone;
  final DateTime dataNascimento;
  final String cpf;
  final String endereco;
  final String? queixaPrincipal;
  final String? histDoencaAtual;
  final String? histPregresso;
  final String? ocupacao;
  final String? genero;
  final String? dor;
  final String? comorbidades;
  final String? medicamentos;
  final String? alergias;
  final String? cirurgias;
  final String? habitosVida;
  final String situacao; // 'Ativo' ou 'Arquivado'
  final DateTime dataCadastro;

  Paciente({
    required this.idPaciente,
    required this.nome,
    required this.telefone,
    required this.dataNascimento,
    required this.cpf,
    required this.endereco,
    this.queixaPrincipal,
    this.histDoencaAtual,
    this.histPregresso,
    this.ocupacao,
    this.genero,
    this.dor,
    this.comorbidades,
    this.medicamentos,
    this.alergias,
    this.cirurgias,
    this.habitosVida,
    this.situacao = 'Ativo',
    DateTime? dataCadastro,
  }) : dataCadastro = dataCadastro ?? DateTime.now();

  /// Calcula a idade do paciente com base na data atual.
  int calcularIdade({DateTime? dataReferencia}) {
    final hoje = dataReferencia ?? DateTime.now();
    int idade = hoje.year - dataNascimento.year;
    if (hoje.month < dataNascimento.month ||
        (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) {
      idade--;
    }
    return idade;
  }

  bool get estaAtivo => situacao == 'Ativo';

/// Converte para mapa de valores para envio à planilha.
  Map<String, dynamic> paraMapaPlanilha() {
    return {
      'ID_Paciente': idPaciente,
      'Nome': nome,
      'Telefone': telefone,
      'Data_Nascimento':
          '${dataNascimento.day.toString().padLeft(2, '0')}/${dataNascimento.month.toString().padLeft(2, '0')}/${dataNascimento.year}',
      'CPF': cpf,
      'Endereco': endereco,
      'Queixa_Principal': queixaPrincipal ?? '',
      'Hist_Doenca_Atual': histDoencaAtual ?? '',
      'Hist_Pregresso': histPregresso ?? '',
      'Ocupacao': ocupacao ?? '',
      'Situacao': situacao,
      'Data_Cadastro': dataCadastro.toIso8601String(),
      'Genero': genero ?? '',
      'Dor': dor ?? '',
      'Comorbidades': comorbidades ?? '',
      'Medicamentos': medicamentos ?? '',
      'Alergias': alergias ?? '',
      'Cirurgias': cirurgias ?? '',
      'Habitos_Vida': habitosVida ?? '',
    };
  }

  factory Paciente.deLinhaPlanilha(List<String> linha) {
    // Validar dados básicos antes de processar
    if (linha.isEmpty) {
      throw FormatException('Linha de paciente vazia');
    }

    // Helper para obter valor seguro
    String obterValor(int idx, {String padrao = ''}) {
      if (idx >= linha.length) return padrao;
      final valor = linha[idx].trim();
      return valor.isEmpty ? padrao : valor;
    }

    // Helper para obter valor nullable
    String? obterValorOuNull(int idx) {
      if (idx >= linha.length) return null;
      final valor = linha[idx].trim();
      return valor.isEmpty ? null : valor;
    }

    // Validar nome
    final nome = obterValor(1);
    if (!Validadores.validarNome(nome)) {
      throw FormatException('Nome inválido: "$nome"');
    }

    // Validar telefone
    final telefone = obterValor(2);
    if (!Validadores.validarTelefone(telefone)) {
      throw FormatException('Telefone inválido: "$telefone"');
    }

    // Validar CPF
    final cpf = obterValor(4);
    if (!Validadores.validarCPF(cpf)) {
      throw FormatException('CPF inválido: "$cpf"');
    }

    // Validar endereço
    final endereco = obterValor(5);
    if (!Validadores.validarEndereco(endereco)) {
      throw FormatException('Endereço inválido: "$endereco"');
    }

    // Processar data de nascimento
    DateTime? dataNasc;
    if (linha.length > 3) {
      final partesData = linha[3].split('/');
      if (partesData.length == 3) {
        dataNasc = DateTime.tryParse(
          '${partesData[2]}-${partesData[1].padLeft(2, '0')}-${partesData[0].padLeft(2, '0')}',
        );
      }
    }
    dataNasc ??= DateTime.now();

    // Validar data de nascimento
    if (!Validadores.validarDataNascimento(dataNasc)) {
      throw FormatException(
        'Data de nascimento inválida: ${linha.length > 3 ? linha[3] : ""}',
      );
    }

    return Paciente(
      idPaciente: obterValor(0),
      nome: nome,
      telefone: telefone,
      dataNascimento: dataNasc,
      cpf: cpf,
      endereco: endereco,
      queixaPrincipal: obterValorOuNull(6),
      histDoencaAtual: obterValorOuNull(7),
      histPregresso: obterValorOuNull(8),
      ocupacao: obterValorOuNull(9),
      situacao: obterValor(10, padrao: 'Ativo'),
      dataCadastro: linha.length > 11
          ? DateTime.tryParse(linha[11]) ?? DateTime.now()
          : DateTime.now(),
      genero: obterValorOuNull(12),
      dor: obterValorOuNull(13),
      comorbidades: obterValorOuNull(14),
      medicamentos: obterValorOuNull(15),
      alergias: obterValorOuNull(16),
      cirurgias: obterValorOuNull(17),
      habitosVida: obterValorOuNull(18),
    );
  }

  Paciente copiarCom({
    String? nome,
    String? telefone,
    DateTime? dataNascimento,
    String? cpf,
    String? endereco,
    String? queixaPrincipal,
    String? histDoencaAtual,
    String? histPregresso,
    String? ocupacao,
    String? genero,
    String? dor,
    String? comorbidades,
    String? medicamentos,
    String? alergias,
    String? cirurgias,
    String? habitosVida,
    String? situacao,
  }) {
    return Paciente(
      idPaciente: idPaciente,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      cpf: cpf ?? this.cpf,
      endereco: endereco ?? this.endereco,
      queixaPrincipal: queixaPrincipal ?? this.queixaPrincipal,
      histDoencaAtual: histDoencaAtual ?? this.histDoencaAtual,
      histPregresso: histPregresso ?? this.histPregresso,
      ocupacao: ocupacao ?? this.ocupacao,
      genero: genero ?? this.genero,
      dor: dor ?? this.dor,
      comorbidades: comorbidades ?? this.comorbidades,
      medicamentos: medicamentos ?? this.medicamentos,
      alergias: alergias ?? this.alergias,
      cirurgias: cirurgias ?? this.cirurgias,
      habitosVida: habitosVida ?? this.habitosVida,
      situacao: situacao ?? this.situacao,
    );
  }
}
