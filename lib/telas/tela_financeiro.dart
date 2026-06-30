import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../componentes/design_system.dart';
import '../modelos/agendamento.dart';
import '../provedores/provedores_dados.dart';
import '../utilitarios/utilitarios_data.dart';

enum VisualizacaoFinanceiro { lista, porPaciente }

class TelaFinanceiro extends ConsumerStatefulWidget {
  const TelaFinanceiro({super.key});

  @override
  ConsumerState<TelaFinanceiro> createState() => _TelaFinanceiroState();
}

class _TelaFinanceiroState extends ConsumerState<TelaFinanceiro> {
  late DateTime _mesSelecionado;
  VisualizacaoFinanceiro _visualizacao = VisualizacaoFinanceiro.lista;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _mesSelecionado = DateTime(agora.year, agora.month);
  }

  @override
  Widget build(BuildContext context) {
    final agendamentos = ref.watch(provedorListaAgendamentos);
    final pacientes = ref.watch(provedorListaPacientes);

    final mesesDisponiveis = _extrairMeses(agendamentos);
    if (mesesDisponiveis.isEmpty) {
      final agora = DateTime.now();
      mesesDisponiveis.add(DateTime(agora.year, agora.month));
    }
    if (!mesesDisponiveis.any((m) => UtilitariosData.mesmoMesAno(m, _mesSelecionado))) {
      mesesDisponiveis.add(_mesSelecionado);
      mesesDisponiveis.sort((a, b) => b.compareTo(a));
    }

    final sessoesDoMes = agendamentos.where(
      (a) => UtilitariosData.mesmoMesAno(a.data, _mesSelecionado) &&
          (a.foiRealizado || a.estaAgendado),
    ).toList()
      ..sort((a, b) => b.data.compareTo(a.data));

    final faturado = agendamentos
        .where((a) => a.foiRealizado && UtilitariosData.mesmoMesAno(a.data, _mesSelecionado))
        .fold(0.0, (soma, a) => soma + a.valorSessao);

    final previsto = agendamentos
        .where((a) => a.estaAgendado && UtilitariosData.mesmoMesAno(a.data, _mesSelecionado))
        .fold(0.0, (soma, a) => soma + a.valorSessao);

    final realizadas = agendamentos
        .where((a) => a.foiRealizado && UtilitariosData.mesmoMesAno(a.data, _mesSelecionado))
        .length;

    final mapaPacientes = {
      for (final p in pacientes) p.idPaciente: p.nome,
    };

    return SafeArea(
      child: FisioResponsiveCenter(
        maxWidth: 620,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: FisioDecoracoes.tinted(FisioCores.primary),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: FisioCores.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Financeiro',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: FisioCores.textPrimary,
                            ),
                          ),
                        ),
                        FisioBadge(
                          label: UtilitariosData.formatarMesAno(_mesSelecionado),
                          color: FisioCores.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Cards de resumo
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _construirCardResumo(
                        'Faturado',
                        _formatarValor(faturado),
                        Icons.check_circle_rounded,
                        FisioCores.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _construirCardResumo(
                        'Previsto',
                        _formatarValor(previsto),
                        Icons.schedule_rounded,
                        FisioCores.info,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _construirCardResumo(
                        'Realizadas',
                        '$realizadas',
                        Icons.event_available_rounded,
                        FisioCores.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Chips de mês + seletor de visualização
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final mes in mesesDisponiveis)
                            _chipMes(mes),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _seletorVisualizacao(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Lista de sessões
            if (sessoesDoMes.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EstadoVazio(),
              )
            else if (_visualizacao == VisualizacaoFinanceiro.lista)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final sessao = sessoesDoMes[index];
                      final nome = mapaPacientes[sessao.idPaciente] ?? 'Paciente não encontrado';
                      return _construirCardSessao(sessao, nome);
                    },
                    childCount: sessoesDoMes.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final grupos = _agruparPorPaciente(sessoesDoMes);
                      final idsPacientes = grupos.keys.toList()
                        ..sort((a, b) {
                          final nomeA = mapaPacientes[a] ?? a;
                          final nomeB = mapaPacientes[b] ?? b;
                          return nomeA.compareTo(nomeB);
                        });
                      final idPaciente = idsPacientes[index];
                      final sessoesPaciente = grupos[idPaciente]!;
                      final nome = mapaPacientes[idPaciente] ?? 'Paciente não encontrado';
                      final totalPaciente = sessoesPaciente.fold(
                        0.0,
                        (soma, a) => soma + a.valorSessao,
                      );

                      return _GrupoPacienteFinanceiro(
                        nome: nome,
                        sessoes: sessoesPaciente,
                        totalPaciente: totalPaciente,
                        itemBuilder: (sessao) => _construirCardSessao(sessao, nome),
                      );
                    },
                    childCount: _agruparPorPaciente(sessoesDoMes).length,
                  ),
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
            child: _botaoVisualizacao('Lista', VisualizacaoFinanceiro.lista),
          ),
          Expanded(
            child: _botaoVisualizacao('Por paciente', VisualizacaoFinanceiro.porPaciente),
          ),
        ],
      ),
    );
  }

  Widget _botaoVisualizacao(String label, VisualizacaoFinanceiro visualizacao) {
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

  Map<String, List<Agendamento>> _agruparPorPaciente(List<Agendamento> sessoes) {
    final grupos = <String, List<Agendamento>>{};
    for (final sessao in sessoes) {
      grupos.putIfAbsent(sessao.idPaciente, () => []).add(sessao);
    }
    return grupos;
  }

  List<DateTime> _extrairMeses(List<Agendamento> agendamentos) {
    final meses = <String, DateTime>{};
    for (final a in agendamentos) {
      final chave = '${a.data.year}-${a.data.month}';
      meses.putIfAbsent(chave, () => DateTime(a.data.year, a.data.month));
    }
    final lista = meses.values.toList()..sort((a, b) => b.compareTo(a));
    return lista;
  }

  Widget _chipMes(DateTime mes) {
    final selecionado = UtilitariosData.mesmoMesAno(mes, _mesSelecionado);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _mesSelecionado = mes),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selecionado ? FisioCores.primary : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selecionado ? FisioCores.primary : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            UtilitariosData.formatarMesAno(mes),
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

  Widget _construirCardResumo(
    String titulo,
    String valor,
    IconData icone,
    Color cor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: FisioDecoracoes.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: FisioDecoracoes.tinted(cor, radius: 12),
            child: Icon(icone, color: cor, size: 18),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: FisioCores.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 11,
              color: FisioCores.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCardSessao(Agendamento sessao, String nomePaciente) {
    final cor = sessao.foiRealizado ? FisioCores.success : FisioCores.info;
    final status = sessao.foiRealizado ? 'Realizado' : 'Agendado';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: FisioDecoracoes.card(),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: fisioAvatarColor(nomePaciente).withValues(alpha: 0.15),
              child: Text(
                fisioIniciais(nomePaciente),
                style: TextStyle(
                  color: fisioAvatarColor(nomePaciente),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomePaciente,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: FisioCores.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${UtilitariosData.formatarDataBr(sessao.data)} • ${sessao.horaInicio}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: FisioCores.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatarValor(sessao.valorSessao),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cor,
                  ),
                ),
                const SizedBox(height: 4),
                FisioBadge(label: status, color: cor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

class _GrupoPacienteFinanceiro extends StatelessWidget {
  final String nome;
  final List<Agendamento> sessoes;
  final double totalPaciente;
  final Widget Function(Agendamento sessao) itemBuilder;

  const _GrupoPacienteFinanceiro({
    required this.nome,
    required this.sessoes,
    required this.totalPaciente,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final cor = fisioAvatarColor(nome);
    final realizadas = sessoes.where((s) => s.foiRealizado).length;
    final agendadas = sessoes.where((s) => s.estaAgendado).length;

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
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  fisioIniciais(nome),
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
              '$realizadas realizadas • $agendadas agendadas • R\$ ${totalPaciente.toStringAsFixed(2).replaceAll('.', ',')}',
              style: const TextStyle(color: FisioCores.textSecondary, fontSize: 12),
            ),
            children: [for (final sessao in sessoes) itemBuilder(sessao)],
          ),
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 72,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma sessão neste mês.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: FisioCores.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
