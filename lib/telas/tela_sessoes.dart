import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../componentes/design_system.dart';
import '../modelos/agendamento.dart';
import '../modelos/paciente.dart';
import '../provedores/provedores_dados.dart';
import '../utilitarios/utilitarios_data.dart';
import 'tela_registro_evolucao.dart';

enum FiltroSessoes {
  todas,
  hoje,
  futuras,
  pendentes,
  canceladas,
  faltas,
  realizadas,
}

enum VisualizacaoSessoes { lista, porPaciente }

class TelaSessoes extends ConsumerStatefulWidget {
  const TelaSessoes({super.key});

  @override
  ConsumerState<TelaSessoes> createState() => _TelaSessoesState();
}

class _TelaSessoesState extends ConsumerState<TelaSessoes> {
  FiltroSessoes _filtro = FiltroSessoes.todas;
  VisualizacaoSessoes _visualizacao = VisualizacaoSessoes.lista;
  final _buscaController = TextEditingController();
  String _termoBusca = '';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final agendamentos = [...ref.watch(provedorListaAgendamentos)]
      ..sort((a, b) => b.inicioPrevisto.compareTo(a.inicioPrevisto));
    final pacientes = {
      for (final paciente in ref.watch(provedorListaPacientes))
        paciente.idPaciente: paciente,
    };
    final sessoes = agendamentos
        .where(_aplicarFiltro)
        .where((agendamento) => _aplicarBusca(agendamento, pacientes))
        .toList();
    final grupos = _agruparPorPaciente(sessoes, pacientes);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.055),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Sessões',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: FisioCores.textPrimary,
                          ),
                        ),
                      ),
                      FisioBadge(
                        label: '${sessoes.length} registros',
                        color: FisioCores.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _buscaController,
                    onChanged: (valor) => setState(() => _termoBusca = valor),
                    decoration: InputDecoration(
                      hintText: 'Buscar paciente, data ou status...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _termoBusca.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _buscaController.clear();
                                setState(() => _termoBusca = '');
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _chipFiltro('Todas', FiltroSessoes.todas),
                        _chipFiltro('Hoje', FiltroSessoes.hoje),
                        _chipFiltro('Futuras', FiltroSessoes.futuras),
                        _chipFiltro('Pendentes', FiltroSessoes.pendentes),
                        _chipFiltro('Canceladas', FiltroSessoes.canceladas),
                        _chipFiltro('Faltas', FiltroSessoes.faltas),
                        _chipFiltro('Realizadas', FiltroSessoes.realizadas),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _seletorVisualizacao(),
                ],
              ),
            ),
            Expanded(
              child: sessoes.isEmpty
                  ? _EstadoVazio(filtro: _labelFiltro(_filtro))
                  : FisioResponsiveCenter(
                      maxWidth: 720,
                      child: _visualizacao == VisualizacaoSessoes.lista
                          ? _listaSessoes(sessoes, pacientes)
                          : _listaAgrupada(grupos, pacientes),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seletorVisualizacao() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _botaoVisualizacao('Lista', VisualizacaoSessoes.lista),
          ),
          Expanded(
            child: _botaoVisualizacao(
              'Por paciente',
              VisualizacaoSessoes.porPaciente,
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoVisualizacao(String label, VisualizacaoSessoes visualizacao) {
    final selecionado = _visualizacao == visualizacao;

    return GestureDetector(
      onTap: () => setState(() => _visualizacao = visualizacao),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selecionado ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: selecionado ? FisioSombras.card : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selecionado ? FisioCores.primary : FisioCores.textSecondary,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _listaSessoes(
    List<Agendamento> sessoes,
    Map<String, Paciente> pacientes,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 132),
      itemCount: sessoes.length,
      itemBuilder: (context, index) {
        final agendamento = sessoes[index];
        return _CardSessao(
          agendamento: agendamento,
          paciente: pacientes[agendamento.idPaciente],
          onAcao: (acao) => _executarAcao(
            context,
            acao,
            agendamento,
            pacientes[agendamento.idPaciente],
          ),
        );
      },
    );
  }

  Widget _listaAgrupada(
    Map<String, List<Agendamento>> grupos,
    Map<String, Paciente> pacientes,
  ) {
    final idsPacientes = grupos.keys.toList()
      ..sort((a, b) {
        final nomeA = pacientes[a]?.nome ?? a;
        final nomeB = pacientes[b]?.nome ?? b;
        return nomeA.compareTo(nomeB);
      });

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 132),
      itemCount: idsPacientes.length,
      itemBuilder: (context, index) {
        final idPaciente = idsPacientes[index];
        final sessoesPaciente = grupos[idPaciente]!;
        final paciente = pacientes[idPaciente];
        return _GrupoPacienteSessoes(
          paciente: paciente,
          sessoes: sessoesPaciente,
          itemBuilder: (agendamento) => _CardSessao(
            agendamento: agendamento,
            paciente: paciente,
            onAcao: (acao) =>
                _executarAcao(context, acao, agendamento, paciente),
          ),
        );
      },
    );
  }

  Widget _chipFiltro(String label, FiltroSessoes filtro) {
    final selecionado = _filtro == filtro;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filtro = filtro),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selecionado
                ? FisioCores.primaryDark
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selecionado
                  ? FisioCores.primaryDark
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: selecionado ? Colors.white : FisioCores.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  bool _aplicarFiltro(Agendamento agendamento) {
    final agora = DateTime.now();

    return switch (_filtro) {
      FiltroSessoes.todas => true,
      FiltroSessoes.hoje => agendamento.ehDeHoje(agora),
      FiltroSessoes.futuras =>
        agendamento.estaAgendado &&
            agendamento.inicioPrevisto.isAfter(agora) &&
            !agendamento.ehDeHoje(agora),
      FiltroSessoes.pendentes =>
        agendamento.estaAtrasado(agora) ||
            agendamento.pendenteDeDiaAnterior(agora),
      FiltroSessoes.canceladas => agendamento.foiCancelado,
      FiltroSessoes.faltas => agendamento.foiFalta,
      FiltroSessoes.realizadas => agendamento.foiRealizado,
    };
  }

  bool _aplicarBusca(Agendamento agendamento, Map<String, Paciente> pacientes) {
    final termo = _termoBusca.trim().toLowerCase();
    if (termo.isEmpty) return true;

    final paciente = pacientes[agendamento.idPaciente];
    final data = UtilitariosData.formatarDataBr(agendamento.data);
    final alvo = [
      paciente?.nome,
      paciente?.cpf,
      agendamento.situacao,
      data,
      agendamento.horaInicio,
      agendamento.horaFim,
    ].whereType<String>().join(' ').toLowerCase();

    return alvo.contains(termo);
  }

  Map<String, List<Agendamento>> _agruparPorPaciente(
    List<Agendamento> sessoes,
    Map<String, Paciente> pacientes,
  ) {
    final grupos = <String, List<Agendamento>>{};
    for (final sessao in sessoes) {
      grupos.putIfAbsent(sessao.idPaciente, () => []).add(sessao);
    }
    for (final lista in grupos.values) {
      lista.sort((a, b) => b.inicioPrevisto.compareTo(a.inicioPrevisto));
    }
    return grupos;
  }

  String _labelFiltro(FiltroSessoes filtro) {
    return switch (filtro) {
      FiltroSessoes.todas => 'todas',
      FiltroSessoes.hoje => 'hoje',
      FiltroSessoes.futuras => 'futuras',
      FiltroSessoes.pendentes => 'pendentes',
      FiltroSessoes.canceladas => 'canceladas',
      FiltroSessoes.faltas => 'faltas',
      FiltroSessoes.realizadas => 'realizadas',
    };
  }

  Future<void> _executarAcao(
    BuildContext context,
    _AcaoSessao acao,
    Agendamento agendamento,
    Paciente? paciente,
  ) async {
    if (acao == _AcaoSessao.registrarEvolucao) {
      if (paciente == null) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TelaRegistroEvolucao(
            paciente: paciente,
            agendamento: agendamento,
          ),
        ),
      );
      return;
    }

    final situacao = switch (acao) {
      _AcaoSessao.faltouComAviso => Agendamento.situacaoFaltouComAviso,
      _AcaoSessao.faltouSemAviso => Agendamento.situacaoFaltouSemAviso,
      _AcaoSessao.canceladoPaciente => Agendamento.situacaoCanceladoPaciente,
      _AcaoSessao.canceladoProfissional =>
        Agendamento.situacaoCanceladoProfissional,
      _AcaoSessao.registrarEvolucao => Agendamento.situacaoAgendado,
    };

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atualizar sessão?'),
        content: Text('Marcar esta sessão como "$situacao"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmou != true || !context.mounted) return;

    try {
      await atualizarSituacaoAgendamentoReal(
        ref,
        agendamento.idAgendamento,
        situacao,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sessão atualizada para $situacao.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao atualizar sessão: $e'),
          backgroundColor: FisioCores.danger,
        ),
      );
    }
  }
}

class _EstadoVazio extends StatelessWidget {
  final String filtro;

  const _EstadoVazio({required this.filtro});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 72,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma sessão $filtro encontrada.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: FisioCores.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardSessao extends StatelessWidget {
  final Agendamento agendamento;
  final Paciente? paciente;
  final ValueChanged<_AcaoSessao> onAcao;

  const _CardSessao({
    required this.agendamento,
    required this.paciente,
    required this.onAcao,
  });

  @override
  Widget build(BuildContext context) {
    final nome = paciente?.nome ?? 'Paciente não encontrado';
    final cor = paciente == null
        ? FisioCores.primary
        : fisioAvatarColor(paciente!.nome);
    final statusCor = _corSituacao(agendamento);

    return FisioCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cor.withValues(alpha: 0.16)),
            ),
            child: Center(
              child: Text(
                paciente == null ? '??' : fisioIniciais(paciente!.nome),
                style: TextStyle(
                  color: cor,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: FisioCores.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _MetaSessao(
                      icon: Icons.calendar_month_rounded,
                      label: UtilitariosData.formatarDataBr(agendamento.data),
                    ),
                    _MetaSessao(
                      icon: Icons.schedule_rounded,
                      label:
                          '${agendamento.horaInicio} - ${agendamento.horaFim}',
                    ),
                    FisioBadge(label: agendamento.situacao, color: statusCor),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<_AcaoSessao>(
            tooltip: 'Ações da sessão',
            icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade500),
            onSelected: onAcao,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _AcaoSessao.registrarEvolucao,
                child: Text('Registrar evolução'),
              ),
              PopupMenuItem(
                value: _AcaoSessao.faltouComAviso,
                child: Text('Faltou com aviso'),
              ),
              PopupMenuItem(
                value: _AcaoSessao.faltouSemAviso,
                child: Text('Faltou sem aviso'),
              ),
              PopupMenuItem(
                value: _AcaoSessao.canceladoPaciente,
                child: Text('Cancelar pelo paciente'),
              ),
              PopupMenuItem(
                value: _AcaoSessao.canceladoProfissional,
                child: Text('Cancelar pelo profissional'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _corSituacao(Agendamento agendamento) {
    if (agendamento.foiRealizado) return FisioCores.success;
    if (agendamento.foiCancelado) return FisioCores.danger;
    if (agendamento.foiFalta) return FisioCores.warning;
    if (agendamento.estaAtrasado(DateTime.now()) ||
        agendamento.pendenteDeDiaAnterior(DateTime.now())) {
      return FisioCores.warning;
    }
    return FisioCores.primary;
  }
}

class _GrupoPacienteSessoes extends StatelessWidget {
  final Paciente? paciente;
  final List<Agendamento> sessoes;
  final Widget Function(Agendamento agendamento) itemBuilder;

  const _GrupoPacienteSessoes({
    required this.paciente,
    required this.sessoes,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final nome = paciente?.nome ?? 'Paciente não encontrado';
    final cor = paciente == null
        ? FisioCores.primary
        : fisioAvatarColor(paciente!.nome);
    final ultima = sessoes.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: FisioCores.card,
        borderRadius: BorderRadius.circular(24),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cor.withValues(alpha: 0.16)),
              ),
              child: Center(
                child: Text(
                  paciente == null ? '??' : fisioIniciais(paciente!.nome),
                  style: TextStyle(
                    color: cor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: Text(
              nome,
              style: const TextStyle(
                color: FisioCores.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              '${sessoes.length} sessões • última: ${ultima.situacao}',
              style: const TextStyle(color: FisioCores.textSecondary),
            ),
            children: [for (final sessao in sessoes) itemBuilder(sessao)],
          ),
        ),
      ),
    );
  }
}

class _MetaSessao extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaSessao({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: FisioCores.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: FisioCores.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

enum _AcaoSessao {
  registrarEvolucao,
  faltouComAviso,
  faltouSemAviso,
  canceladoPaciente,
  canceladoProfissional,
}
