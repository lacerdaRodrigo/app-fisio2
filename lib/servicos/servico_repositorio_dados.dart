import 'package:http/http.dart' as http;

import '../modelos/agendamento.dart';
import '../modelos/evolucao.dart';
import '../modelos/paciente.dart';
import '../utilitarios/utilitarios_data.dart';
import 'preferencias.dart';
import 'servico_google_drive.dart';
import 'servico_google_sheets.dart';

class DadosCarregados {
  final List<Paciente> pacientes;
  final List<Agendamento> agendamentos;
  final List<Evolucao> evolucoes;
  final String valorSessaoPadrao;
  final List<String> logsAuditoria;
  final String planilhaId;

  const DadosCarregados({
    required this.pacientes,
    required this.agendamentos,
    required this.evolucoes,
    required this.valorSessaoPadrao,
    required this.logsAuditoria,
    required this.planilhaId,
  });
}

class RepositorioDadosGoogle {
  final ServicoGoogleDrive _drive;
  final ServicoGoogleSheets _sheets;
  String? _planilhaId;

  RepositorioDadosGoogle(http.Client cliente)
    : _drive = ServicoGoogleDrive(cliente),
      _sheets = ServicoGoogleSheets(cliente);

  void limparCache() {
    _planilhaId = null;
    Preferencias.limparPlanilhaId();
  }

  Future<String> obterPlanilhaId() async {
    if (_planilhaId != null) return _planilhaId!;

    _planilhaId = await Preferencias.lerPlanilhaId();
    if (_planilhaId != null) {
      return _planilhaId!;
    }

    final existente = await _drive.buscarPlanilhaBanco();
    if (existente != null) {
      _planilhaId = existente;
      await _sheets.garantirEstrutura(existente);
      await Preferencias.salvarPlanilhaId(existente);
      return existente;
    }

    _planilhaId = await _sheets.criarPlanilhaBanco();
    await Preferencias.salvarPlanilhaId(_planilhaId!);
    return _planilhaId!;
  }

  Future<DadosCarregados> carregarTudo() async {
    final id = await obterPlanilhaId();

    // Carrega todas as abas em paralelo
    final results = await Future.wait([
      _sheets.lerAba(id, 'Pacientes'),
      _sheets.lerAba(id, 'Agenda'),
      _sheets.lerAba(id, 'Evolucoes'),
      _sheets.lerAba(id, 'Configuracoes'),
      _sheets.lerAba(id, 'Auditoria'),
    ]);

    final pacientes = results[0].map(_pacienteDeLinha).toList();
    final agendamentos = results[1].map(_agendamentoDeLinha).toList();
    final evolucoes = results[2].map(_evolucaoDeLinha).toList();
    final configuracoes = results[3];
    final logs = results[4].reversed.map((linha) {
      final dados = _preencher(linha, 4);
      return '${dados[1]} - ${dados[2]} - ${dados[3]}';
    }).toList();

    return DadosCarregados(
      pacientes: pacientes,
      agendamentos: agendamentos,
      evolucoes: evolucoes,
      valorSessaoPadrao: _valorConfiguracao(
        configuracoes,
        'valor_sessao_padrao',
        padrao: '150,00',
      ),
      logsAuditoria: logs,
      planilhaId: id,
    );
  }

  Future<void> salvarPaciente(Paciente paciente) async {
    final id = await obterPlanilhaId();
    await _sheets.inserirLinha(id, 'Pacientes', _valoresPaciente(paciente));
    await registrarAuditoria(
      'CADASTRO_PACIENTE',
      'Paciente ${paciente.idPaciente} cadastrado.',
    );
  }

  Future<void> salvarAgendamento(Agendamento agendamento) async {
    final id = await obterPlanilhaId();
    await _sheets.inserirLinha(id, 'Agenda', _valoresAgendamento(agendamento));
    await registrarAuditoria(
      'AGENDAMENTO_SESSAO',
      'Sessão ${agendamento.idAgendamento} agendada.',
    );
  }

  Future<void> salvarEvolucao(Evolucao evolucao) async {
    final id = await obterPlanilhaId();
    await _sheets.inserirLinha(id, 'Evolucoes', _valoresEvolucao(evolucao));
    await registrarAuditoria(
      'REGISTRO_EVOLUCAO',
      'Evolução ${evolucao.idEvolucao} criada.',
    );
  }

  Future<void> atualizarEvolucao(Evolucao evolucao) async {
    final id = await obterPlanilhaId();
    final linhas = await _sheets.lerAba(id, 'Evolucoes');
    final indice = linhas.indexWhere(
      (linha) => linha.isNotEmpty && linha.first == evolucao.idEvolucao,
    );
    if (indice == -1) return;

    await _sheets.atualizarLinha(
      id,
      'Evolucoes!A${indice + 2}:N${indice + 2}',
      _valoresEvolucao(evolucao),
    );
    await registrarAuditoria(
      'EDITAR_EVOLUCAO',
      'Evolução ${evolucao.idEvolucao} atualizada.',
    );
  }

  Future<void> arquivarPaciente(String idPaciente) async {
    final id = await obterPlanilhaId();
    final linhas = await _sheets.lerAba(id, 'Pacientes');
    final indice = linhas.indexWhere(
      (linha) => linha.isNotEmpty && linha.first == idPaciente,
    );
    if (indice == -1) return;

    final linha = _preencher(linhas[indice], 19);
    linha[10] = 'Arquivado';
    await _sheets.atualizarLinha(
      id,
      'Pacientes!A${indice + 2}:S${indice + 2}',
      linha,
    );
    await registrarAuditoria(
      'ARQUIVAMENTO_PACIENTE',
      'Paciente $idPaciente arquivado.',
    );
  }

  Future<void> restaurarPaciente(String idPaciente) async {
    final id = await obterPlanilhaId();
    final linhas = await _sheets.lerAba(id, 'Pacientes');
    final indice = linhas.indexWhere(
      (linha) => linha.isNotEmpty && linha.first == idPaciente,
    );
    if (indice == -1) return;

    final linha = _preencher(linhas[indice], 19);
    linha[10] = 'Ativo';
    await _sheets.atualizarLinha(
      id,
      'Pacientes!A${indice + 2}:S${indice + 2}',
      linha,
    );
    await registrarAuditoria(
      'RESTAURACAO_PACIENTE',
      'Paciente $idPaciente restaurado.',
    );
  }

  Future<void> marcarAgendamentoRealizado(String idAgendamento) async {
    await atualizarSituacaoAgendamento(
      idAgendamento,
      Agendamento.situacaoRealizado,
    );
  }

  Future<void> atualizarSituacaoAgendamento(
    String idAgendamento,
    String situacao,
  ) async {
    final id = await obterPlanilhaId();
    final linhas = await _sheets.lerAba(id, 'Agenda');
    final indice = linhas.indexWhere(
      (linha) => linha.isNotEmpty && linha.first == idAgendamento,
    );
    if (indice == -1) return;

    final linha = _preencher(linhas[indice], 9);
    linha[7] = situacao;
    await _sheets.atualizarLinha(
      id,
      'Agenda!A${indice + 2}:I${indice + 2}',
      linha,
    );
    await registrarAuditoria(
      'ATUALIZAR_AGENDAMENTO',
      'Sessão $idAgendamento atualizada para $situacao.',
    );
  }

  Future<void> salvarValorSessaoPadrao(String valor) async {
    final id = await obterPlanilhaId();
    final linhas = await _sheets.lerAba(id, 'Configuracoes');
    final indice = linhas.indexWhere(
      (linha) => linha.isNotEmpty && linha.first == 'valor_sessao_padrao',
    );

    if (indice == -1) {
      await _sheets.inserirLinha(id, 'Configuracoes', [
        'valor_sessao_padrao',
        valor,
      ]);
    } else {
      await _sheets.atualizarLinha(
        id,
        'Configuracoes!A${indice + 2}:B${indice + 2}',
        ['valor_sessao_padrao', valor],
      );
    }

    await registrarAuditoria(
      'CONFIGURACAO',
      'Valor padrão da sessão atualizado para R\$ $valor.',
    );
  }

  Future<void> registrarAuditoria(String operacao, String detalhes) async {
    final id = await obterPlanilhaId();
    final linhas = await _sheets.lerAba(id, 'Auditoria');
    final agora = DateTime.now();
    final data =
        '${UtilitariosData.formatarDataBr(agora)} ${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}';

    await _sheets.inserirLinha(id, 'Auditoria', [
      'L${(linhas.length + 1).toString().padLeft(3, '0')}',
      data,
      operacao,
      detalhes,
    ]);
  }

  String urlPlanilha(String planilhaId) {
    return 'https://docs.google.com/spreadsheets/d/$planilhaId/edit';
  }

  Paciente _pacienteDeLinha(List<String> linhaOriginal) {
    final linha = _preencher(linhaOriginal, 19);
    return Paciente(
      idPaciente: linha[0],
      nome: linha[1],
      telefone: linha[2],
      dataNascimento: _parseDataBr(linha[3]),
      cpf: linha[4],
      endereco: linha[5],
      queixaPrincipal: linha[6],
      histDoencaAtual: linha[7],
      histPregresso: linha[8],
      ocupacao: linha[9],
      situacao: linha[10].isEmpty ? 'Ativo' : linha[10],
      dataCadastro: DateTime.tryParse(linha[11]) ?? DateTime.now(),
      genero: linha[12].isEmpty ? null : linha[12],
      dor: linha[13].isEmpty ? null : linha[13],
      comorbidades: linha[14].isEmpty ? null : linha[14],
      medicamentos: linha[15].isEmpty ? null : linha[15],
      alergias: linha[16].isEmpty ? null : linha[16],
      cirurgias: linha[17].isEmpty ? null : linha[17],
      habitosVida: linha[18].isEmpty ? null : linha[18],
    );
  }

  Agendamento _agendamentoDeLinha(List<String> linhaOriginal) {
    final linha = _preencher(linhaOriginal, 9);
    return Agendamento(
      idAgendamento: linha[0],
      idPaciente: linha[1],
      data: _parseDataBr(linha[2]),
      horaInicio: linha[3],
      horaFim: linha[4],
      valorSessao: double.tryParse(linha[5].replaceAll(',', '.')) ?? 0,
      observacoes: linha[6],
      situacao: linha[7].isEmpty ? 'Agendado' : linha[7],
      dataCriacao: DateTime.tryParse(linha[8]) ?? DateTime.now(),
    );
  }

  Evolucao _evolucaoDeLinha(List<String> linhaOriginal) {
    return Evolucao.deLinhaPlanilha(linhaOriginal);
  }

  List<Object?> _valoresPaciente(Paciente paciente) {
    final mapa = paciente.paraMapaPlanilha();
    return ServicoGoogleSheets.cabecalhos['Pacientes']!
        .map((coluna) => mapa[coluna] ?? '')
        .toList();
  }

  List<Object?> _valoresAgendamento(Agendamento agendamento) {
    final mapa = agendamento.paraMapaPlanilha();
    return ServicoGoogleSheets.cabecalhos['Agenda']!
        .map((coluna) => mapa[coluna] ?? '')
        .toList();
  }

  List<Object?> _valoresEvolucao(Evolucao evolucao) {
    final mapa = evolucao.paraMapaPlanilha();
    return ServicoGoogleSheets.cabecalhos['Evolucoes']!
        .map((coluna) => mapa[coluna] ?? '')
        .toList();
  }

  String _valorConfiguracao(
    List<List<String>> linhas,
    String chave, {
    required String padrao,
  }) {
    final linha = linhas.firstWhere(
      (linha) => linha.isNotEmpty && linha.first == chave,
      orElse: () => const [],
    );
    return linha.length > 1 && linha[1].isNotEmpty ? linha[1] : padrao;
  }

  List<String> _preencher(List<String> linha, int tamanho) {
    return [...linha, for (var i = linha.length; i < tamanho; i++) ''];
  }

  DateTime _parseDataBr(String data) {
    final partes = data.split('/');
    if (partes.length != 3) return DateTime.now();
    return DateTime(
      int.tryParse(partes[2]) ?? DateTime.now().year,
      int.tryParse(partes[1]) ?? DateTime.now().month,
      int.tryParse(partes[0]) ?? DateTime.now().day,
    );
  }
}
