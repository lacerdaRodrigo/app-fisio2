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
    };
  }

  /// Cria um Paciente a partir de uma linha da planilha (lista de strings).
  factory Paciente.deLinhaPlanilha(List<String> linha) {
    final partesData = linha[3].split('/');
    return Paciente(
      idPaciente: linha[0],
      nome: linha[1],
      telefone: linha[2],
      dataNascimento: DateTime(
        int.parse(partesData[2]),
        int.parse(partesData[1]),
        int.parse(partesData[0]),
      ),
      cpf: linha[4],
      endereco: linha[5],
      queixaPrincipal: linha.length > 6 ? linha[6] : null,
      histDoencaAtual: linha.length > 7 ? linha[7] : null,
      histPregresso: linha.length > 8 ? linha[8] : null,
      ocupacao: linha.length > 9 ? linha[9] : null,
      situacao: linha.length > 10 ? linha[10] : 'Ativo',
      dataCadastro: linha.length > 11
          ? DateTime.tryParse(linha[11]) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Paciente copiarCom({String? situacao}) {
    return Paciente(
      idPaciente: idPaciente,
      nome: nome,
      telefone: telefone,
      dataNascimento: dataNascimento,
      cpf: cpf,
      endereco: endereco,
      queixaPrincipal: queixaPrincipal,
      histDoencaAtual: histDoencaAtual,
      histPregresso: histPregresso,
      ocupacao: ocupacao,
      situacao: situacao ?? this.situacao,
      dataCadastro: dataCadastro,
    );
  }
}
