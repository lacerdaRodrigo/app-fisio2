import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos/agendamento.dart';
import '../modelos/evolucao.dart';
import '../modelos/paciente.dart';
import '../servicos/servico_repositorio_dados.dart';
import 'provedor_autenticacao.dart';

enum StatusCarregamentoDados { inicial, carregando, carregado, erro }

class EstadoCarregamentoDados {
  final StatusCarregamentoDados status;
  final String? mensagemErro;

  const EstadoCarregamentoDados({
    this.status = StatusCarregamentoDados.inicial,
    this.mensagemErro,
  });

  bool get estaCarregando =>
      status == StatusCarregamentoDados.inicial ||
      status == StatusCarregamentoDados.carregando;

  bool get carregouComSucesso => status == StatusCarregamentoDados.carregado;

  bool get possuiErro => status == StatusCarregamentoDados.erro;
}

class CarregamentoDadosNotifier extends Notifier<EstadoCarregamentoDados> {
  @override
  EstadoCarregamentoDados build() => const EstadoCarregamentoDados();

  void carregando() {
    state = const EstadoCarregamentoDados(
      status: StatusCarregamentoDados.carregando,
    );
  }

  void sucesso() {
    state = const EstadoCarregamentoDados(
      status: StatusCarregamentoDados.carregado,
    );
  }

  void erro(Object erro) {
    state = EstadoCarregamentoDados(
      status: StatusCarregamentoDados.erro,
      mensagemErro: 'Não foi possível carregar os dados da planilha. $erro',
    );
  }

  void resetar() {
    state = const EstadoCarregamentoDados();
  }
}

class ListaPacientesNotifier extends Notifier<List<Paciente>> {
  @override
  List<Paciente> build() => [];

  void definir(List<Paciente> pacientes) => state = pacientes;
}

class BuscaNotifier extends Notifier<String> {
  @override
  String build() => '';

  void definir(String termo) => state = termo;
}

class ListaAgendamentosNotifier extends Notifier<List<Agendamento>> {
  @override
  List<Agendamento> build() => [];

  void definir(List<Agendamento> agendamentos) => state = agendamentos;
}

class ListaEvolucoesNotifier extends Notifier<List<Evolucao>> {
  @override
  List<Evolucao> build() => [];

  void definir(List<Evolucao> evolucoes) => state = evolucoes;
}

class ValorSessaoPadraoNotifier extends Notifier<String> {
  @override
  String build() => '150,00';

  void definir(String valor) => state = valor;
}

class LogsAuditoriaNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void definir(List<String> logs) => state = logs;

  void adicionar(String log) => state = [log, ...state];
}

class PlanilhaIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void definir(String? id) => state = id;
}

final provedorRepositorioDados = Provider<RepositorioDadosGoogle?>((ref) {
  final sessao = ref.watch(provedorAutenticacao).sessao;
  if (sessao == null) {
    return null;
  }
  return RepositorioDadosGoogle(sessao.criarCliente());
});

final provedorCarregamentoDados =
    NotifierProvider<CarregamentoDadosNotifier, EstadoCarregamentoDados>(
      CarregamentoDadosNotifier.new,
    );
final provedorListaPacientes =
    NotifierProvider<ListaPacientesNotifier, List<Paciente>>(
      ListaPacientesNotifier.new,
    );
final provedorBusca = NotifierProvider<BuscaNotifier, String>(
  BuscaNotifier.new,
);
final provedorListaAgendamentos =
    NotifierProvider<ListaAgendamentosNotifier, List<Agendamento>>(
      ListaAgendamentosNotifier.new,
    );
final provedorListaEvolucoes =
    NotifierProvider<ListaEvolucoesNotifier, List<Evolucao>>(
      ListaEvolucoesNotifier.new,
    );
final provedorValorSessaoPadrao =
    NotifierProvider<ValorSessaoPadraoNotifier, String>(
      ValorSessaoPadraoNotifier.new,
    );
final provedorLogsAuditoria =
    NotifierProvider<LogsAuditoriaNotifier, List<String>>(
      LogsAuditoriaNotifier.new,
    );
final provedorPlanilhaId = NotifierProvider<PlanilhaIdNotifier, String?>(
  PlanilhaIdNotifier.new,
);

void limparDados(WidgetRef ref) {
  ref.read(provedorCarregamentoDados.notifier).resetar();
  ref.read(provedorListaPacientes.notifier).definir([]);
  ref.read(provedorBusca.notifier).definir('');
  ref.read(provedorListaAgendamentos.notifier).definir([]);
  ref.read(provedorListaEvolucoes.notifier).definir([]);
  ref.read(provedorValorSessaoPadrao.notifier).definir('150,00');
  ref.read(provedorLogsAuditoria.notifier).definir([]);
  ref.read(provedorPlanilhaId.notifier).definir(null);
}

Future<void> carregarDadosReais(WidgetRef ref) async {
  final carregamento = ref.read(provedorCarregamentoDados.notifier);
  carregamento.carregando();

  try {
    final dados = await _repositorio(ref).carregarTudo();
    ref.read(provedorListaPacientes.notifier).definir(dados.pacientes);
    ref.read(provedorListaAgendamentos.notifier).definir(dados.agendamentos);
    ref.read(provedorListaEvolucoes.notifier).definir(dados.evolucoes);
    ref
        .read(provedorValorSessaoPadrao.notifier)
        .definir(dados.valorSessaoPadrao);
    ref.read(provedorLogsAuditoria.notifier).definir(dados.logsAuditoria);
    ref.read(provedorPlanilhaId.notifier).definir(dados.planilhaId);
    carregamento.sucesso();
  } catch (erro) {
    carregamento.erro(erro);
  }
}

Future<void> salvarPacienteReal(WidgetRef ref, Paciente paciente) async {
  await _repositorio(ref).salvarPaciente(paciente);
  final pacientes = ref.read(provedorListaPacientes);
  ref.read(provedorListaPacientes.notifier).definir([...pacientes, paciente]);
  registrarLog(
    ref,
    'CADASTRO_PACIENTE',
    'Paciente ${paciente.idPaciente} cadastrado.',
  );
}

Future<void> salvarAgendamentoReal(
  WidgetRef ref,
  Agendamento agendamento,
) async {
  await _repositorio(ref).salvarAgendamento(agendamento);
  final agendamentos = ref.read(provedorListaAgendamentos);
  ref.read(provedorListaAgendamentos.notifier).definir([
    ...agendamentos,
    agendamento,
  ]);
  registrarLog(
    ref,
    'AGENDAMENTO_SESSAO',
    'Sessão ${agendamento.idAgendamento} agendada.',
  );
}

Future<void> salvarEvolucaoReal(WidgetRef ref, Evolucao evolucao) async {
  await _repositorio(ref).salvarEvolucao(evolucao);
  final evolucoes = ref.read(provedorListaEvolucoes);
  ref.read(provedorListaEvolucoes.notifier).definir([...evolucoes, evolucao]);
  registrarLog(
    ref,
    'REGISTRO_EVOLUCAO',
    'Evolução ${evolucao.idEvolucao} criada.',
  );
}

Future<void> atualizarEvolucaoReal(WidgetRef ref, Evolucao evolucao) async {
  await _repositorio(ref).atualizarEvolucao(evolucao);
  final evolucoes = ref.read(provedorListaEvolucoes);
  ref.read(provedorListaEvolucoes.notifier).definir([
    for (final e in evolucoes)
      if (e.idEvolucao == evolucao.idEvolucao) evolucao else e,
  ]);
  registrarLog(
    ref,
    'EDITAR_EVOLUCAO',
    'Evolução ${evolucao.idEvolucao} atualizada.',
  );
}

Future<void> marcarAgendamentoRealizadoReal(
  WidgetRef ref,
  String idAgendamento,
) async {
  await atualizarSituacaoAgendamentoReal(
    ref,
    idAgendamento,
    Agendamento.situacaoRealizado,
  );
}

Future<void> atualizarSituacaoAgendamentoReal(
  WidgetRef ref,
  String idAgendamento,
  String situacao,
) async {
  await _repositorio(ref).atualizarSituacaoAgendamento(idAgendamento, situacao);
  final agendamentos = ref.read(provedorListaAgendamentos);
  ref.read(provedorListaAgendamentos.notifier).definir([
    for (final agendamento in agendamentos)
      if (agendamento.idAgendamento == idAgendamento)
        agendamento.copiarCom(situacao: situacao)
      else
        agendamento,
  ]);
  registrarLog(
    ref,
    'ATUALIZAR_AGENDAMENTO',
    'Sessão $idAgendamento atualizada para $situacao.',
  );
}

Future<void> arquivarPacienteReal(WidgetRef ref, String idPaciente) async {
  await _repositorio(ref).arquivarPaciente(idPaciente);
  final pacientes = ref.read(provedorListaPacientes);
  ref.read(provedorListaPacientes.notifier).definir([
    for (final paciente in pacientes)
      if (paciente.idPaciente == idPaciente)
        paciente.copiarCom(situacao: 'Arquivado')
      else
        paciente,
  ]);
  registrarLog(ref, 'ARQUIVAMENTO_PACIENTE', 'Paciente $idPaciente arquivado.');
}

Future<void> restaurarPacienteReal(WidgetRef ref, String idPaciente) async {
  await _repositorio(ref).restaurarPaciente(idPaciente);
  final pacientes = ref.read(provedorListaPacientes);
  ref.read(provedorListaPacientes.notifier).definir([
    for (final paciente in pacientes)
      if (paciente.idPaciente == idPaciente)
        paciente.copiarCom(situacao: 'Ativo')
      else
        paciente,
  ]);
  registrarLog(ref, 'RESTAURACAO_PACIENTE', 'Paciente $idPaciente restaurado.');
}

Future<void> salvarValorSessaoPadraoReal(WidgetRef ref, String valor) async {
  await _repositorio(ref).salvarValorSessaoPadrao(valor);
  ref.read(provedorValorSessaoPadrao.notifier).definir(valor);
  registrarLog(
    ref,
    'CONFIGURACAO',
    'Valor padrão da sessão atualizado para R\$ $valor.',
  );
}

void registrarLog(WidgetRef ref, String operacao, String detalhes) {
  final agora = DateTime.now();
  final data =
      '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year} '
      '${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}';

  ref
      .read(provedorLogsAuditoria.notifier)
      .adicionar('$data - $operacao - $detalhes');
}

RepositorioDadosGoogle _repositorio(WidgetRef ref) {
  final repositorio = ref.read(provedorRepositorioDados);
  if (repositorio == null) {
    throw StateError('Autorize Drive e Sheets antes de acessar os dados.');
  }
  return repositorio;
}
