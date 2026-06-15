import '../utilitarios/utilitarios_data.dart';
import '../utilitarios/validadores.dart';

/// Modelo de dados representando um paciente cadastrado.
/// Espelha a aba `Pacientes` da planilha `__saas_fisio_db__`.
class Paciente {
  /// Mapa de nomes de coluna para índices (0-based).
  /// Atualizar aqui quando a estrutura da planilha mudar.
  static const indicesColunas = {
    'idPaciente': 0,
    'nome': 1,
    'telefone': 2,
    'dataNascimento': 3,
    'cpf': 4,
    'endereco': 5,
    'queixaPrincipal': 6,
    'histDoencaAtual': 7,
    'histPregresso': 8,
    'ocupacao': 9,
    'situacao': 10,
    'dataCadastro': 11,
    'genero': 12,
    'dor': 13,
    'comorbidades': 14,
    'medicamentos': 15,
    'alergias': 16,
    'cirurgias': 17,
    'habitosVida': 18,
  };
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
  int calcularIdade({DateTime? dataReferencia}) =>
      UtilitariosData.calcularIdade(dataNascimento, dataReferencia: dataReferencia);

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

    String obterValor(String nomeColuna, {String padrao = ''}) {
      final idx = indicesColunas[nomeColuna] ?? -1;
      if (idx == -1) throw FormatException('Coluna desconhecida: $nomeColuna');
      if (idx >= linha.length) return padrao;
      final valor = linha[idx].trim();
      return valor.isEmpty ? padrao : valor;
    }

    String? obterValorOuNull(String nomeColuna) {
      final idx = indicesColunas[nomeColuna] ?? -1;
      if (idx == -1 || idx >= linha.length) return null;
      final valor = linha[idx].trim();
      return valor.isEmpty ? null : valor;
    }

    /// Helper para obter data pelo nome da coluna
    DateTime obterData(String nomeColuna, {DateTime? padrao}) {
      final valor = obterValor(nomeColuna);
      if (valor.isEmpty) return padrao ?? DateTime.now();

      // Tentar parser formato DD/MM/YYYY
      final partes = valor.split('/');
      if (partes.length == 3) {
        try {
          return DateTime.parse(
            '${partes[2]}-${partes[1].padLeft(2, '0')}-${partes[0].padLeft(2, '0')}',
          );
        } catch (_) {
          // Ignorar erro e tentar ISO format
        }
      }

      // Tentar parser ISO format
      return DateTime.tryParse(valor) ?? (padrao ?? DateTime.now());
    }

    // Obter dados básicos
    final idPaciente = obterValor('idPaciente');
    final nome = obterValor('nome');
    final telefone = obterValor('telefone');
    final cpf = obterValor('cpf');
    final endereco = obterValor('endereco');

    // Validar nome
    if (!Validadores.validarNome(nome)) {
      throw FormatException('Nome inválido: "$nome"');
    }

    // Validar telefone
    if (!Validadores.validarTelefone(telefone)) {
      throw FormatException('Telefone inválido: "$telefone"');
    }

    // Validar CPF
    if (!Validadores.validarCPF(cpf)) {
      throw FormatException('CPF inválido: "$cpf"');
    }

    // Validar endereço
    if (!Validadores.validarEndereco(endereco)) {
      throw FormatException('Endereço inválido: "$endereco"');
    }

    // Processar data de nascimento
    final dataNasc = obterData('dataNascimento');

    // Validar data de nascimento
    if (!Validadores.validarDataNascimento(dataNasc)) {
      throw FormatException(
        'Data de nascimento inválida: ${obterValor('dataNascimento')}',
      );
    }

    // Processar data de cadastro
    final dataCadastro = obterData('dataCadastro', padrao: DateTime.now());

    return Paciente(
      idPaciente: idPaciente,
      nome: nome,
      telefone: telefone,
      dataNascimento: dataNasc,
      cpf: cpf,
      endereco: endereco,
      queixaPrincipal: obterValorOuNull('queixaPrincipal'),
      histDoencaAtual: obterValorOuNull('histDoencaAtual'),
      histPregresso: obterValorOuNull('histPregresso'),
      ocupacao: obterValorOuNull('ocupacao'),
      situacao: obterValor('situacao', padrao: 'Ativo'),
      dataCadastro: dataCadastro,
      genero: obterValorOuNull('genero'),
      dor: obterValorOuNull('dor'),
      comorbidades: obterValorOuNull('comorbidades'),
      medicamentos: obterValorOuNull('medicamentos'),
      alergias: obterValorOuNull('alergias'),
      cirurgias: obterValorOuNull('cirurgias'),
      habitosVida: obterValorOuNull('habitosVida'),
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
      dataCadastro: dataCadastro, // preserva data original
    );
  }
}
