/// Gerenciamento de versão do esquema das planilhas
/// Garante compatibilidade entre versões do app e estrutura da planilha
class VersaoEsquema {
  /// Versão atual suportada pelo app
  static const int VERSAO_ATUAL = 1;

  /// Descrição das mudanças por versão
  static const Map<int, String> HISTORICO = {
    1: 'Versão inicial com abas: Pacientes, Agenda, Evolucoes, Configuracoes, Auditoria',
  };

  /// Retorna os índices das colunas para uma versão específica
  /// Mapeia nome da coluna -> índice (0-based)
  static Map<String, int> obterIndicesColunas(int versao) {
    switch (versao) {
      case 1:
        return {
          // Aba: Pacientes
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
      default:
        throw UnsupportedError(
          'Versão de esquema $versao não é suportada por este app. '
          'Versão suportada: $VERSAO_ATUAL',
        );
    }
  }

  /// Valida se a versão é compatível
  /// Retorna null se compatível, ou mensagem de erro se não
  static String? validar(int versaoSheets) {
    if (versaoSheets > VERSAO_ATUAL) {
      return 'A planilha usa versão $versaoSheets, '
          'mas este app suporta apenas até versão $VERSAO_ATUAL. '
          'Atualize o app para a versão mais recente.';
    }

    if (versaoSheets < VERSAO_ATUAL) {
      return 'A planilha usa versão $versaoSheets, '
          'mas este app requer versão $VERSAO_ATUAL. '
          'Você precisa migrar a planilha. '
          'Consulte: https://fisio-home-care.local/migration-guide';
    }

    return null; // Compatível
  }

  /// Retorna a descrição da versão
  static String obterDescricao(int versao) {
    return HISTORICO[versao] ?? 'Versão desconhecida';
  }

  /// Retorna verdadeiro se a versão é suportada
  static bool ehSuportada(int versao) {
    return versao <= VERSAO_ATUAL;
  }

  /// Obtém a próxima versão esperada
  static int obterProximaVersao(int versaoAtual) => versaoAtual + 1;
}
