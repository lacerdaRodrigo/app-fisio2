import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modelos/agendamento.dart';
import '../provedores/provedor_autenticacao.dart';
import '../provedores/provedores_dados.dart';
import '../utilitarios/utilitarios_data.dart';
import 'tela_pacientes.dart';
import 'tela_nova_sessao.dart';
import 'tela_configuracoes.dart';
import 'tela_registro_evolucao.dart';

class TelaDashboard extends ConsumerStatefulWidget {
  final String nomeUsuario;
  const TelaDashboard({super.key, required this.nomeUsuario});

  @override
  ConsumerState<TelaDashboard> createState() => _TelaDashboardState();
}

class _TelaDashboardState extends ConsumerState<TelaDashboard> {
  int _indiceSelecionado = 0;

  @override
  Widget build(BuildContext context) {
    final telas = [
      _construirConteudoDashboard(context),
      const TelaPacientes(),
      const TelaConfiguracoes(),
    ];

    return Scaffold(
      body: telas[_indiceSelecionado],
      bottomNavigationBar: _construirBarraNavegacao(),
      floatingActionButton: _indiceSelecionado == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaNovaSessao()),
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Nova Sessão'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _construirBarraNavegacao() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _indiceSelecionado,
        onDestinationSelected: (i) => setState(() => _indiceSelecionado = i),
        indicatorColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Pacientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }

  Widget _construirConteudoDashboard(BuildContext context) {
    final saudacao = UtilitariosData.obterSaudacao();
    final dataFormatada = UtilitariosData.formatarDataBr(DateTime.now());
    final theme = Theme.of(context);
    final pacientes = ref.watch(provedorListaPacientes);
    final agendamentos = ref.watch(provedorListaAgendamentos);
    final evolucoes = ref.watch(provedorListaEvolucoes);
    final estadoAuth = ref.watch(provedorAutenticacao);
    final hoje = DateTime.now();
    final agendamentosHoje =
        agendamentos
            .where(
              (agendamento) =>
                  _mesmoDia(agendamento.data, hoje) && agendamento.estaAgendado,
            )
            .toList()
          ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Cabeçalho
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$saudacao,',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.nomeUsuario,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          widget.nomeUsuario.isNotEmpty
                              ? widget.nomeUsuario[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dataFormatada,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (estadoAuth.precisaAutorizarDados)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: _construirAvisoAutorizacaoDados(context),
              ),
            ),

          // Cards de Resumo
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 142,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildListDelegate([
                _construirCard(
                  'Pacientes\nCadastrados',
                  '${pacientes.length}',
                  Icons.people_alt_rounded,
                  const Color(0xFF00796B),
                ),
                _construirCard(
                  'Pacientes\nAtivos',
                  '${pacientes.where((p) => p.estaAtivo).length}',
                  Icons.person_pin_circle_rounded,
                  const Color(0xFF00BFA5),
                ),
                _construirCard(
                  'Agenda\ndo Dia',
                  '${agendamentosHoje.length}',
                  Icons.calendar_today_rounded,
                  const Color(0xFFFF8F00),
                ),
                _construirCard(
                  'Total de\nEvoluções',
                  '${evolucoes.length}',
                  Icons.trending_up_rounded,
                  const Color(0xFF5C6BC0),
                ),
              ]),
            ),
          ),

          // Título da Seção Agenda
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Agenda de Hoje',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: agendamentosHoje.isEmpty
                ? SliverToBoxAdapter(child: _construirAgendaVazia())
                : SliverList.builder(
                    itemCount: agendamentosHoje.length,
                    itemBuilder: (context, index) =>
                        _construirCardAgenda(context, agendamentosHoje[index]),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _construirCard(
    String titulo,
    String valor,
    IconData icone,
    Color cor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cor.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, color: cor, size: 22),
          ),
          const Spacer(),
          Text(
            valor,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _construirAvisoAutorizacaoDados(BuildContext context) {
    final estadoAuth = ref.watch(provedorAutenticacao);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFECB3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_open_rounded, color: Colors.orange.shade800),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Autorize seus dados para carregar a planilha',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'O login Google já foi concluído. Falta permitir Drive/Sheets para ler e gravar pacientes, agenda e evoluções.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: estadoAuth.estaCarregando
                  ? null
                  : () => _autorizarDados(context),
              icon: estadoAuth.estaCarregando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.table_chart_outlined),
              label: Text(
                estadoAuth.estaCarregando
                    ? 'Autorizando...'
                    : 'Autorizar Drive e Sheets',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _autorizarDados(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(provedorAutenticacao.notifier).autorizarDadosGoogle();
      await carregarDadosReais(ref);
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Dados carregados com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Falha ao autorizar/carregar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _construirAgendaVazia() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum atendimento agendado para hoje.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _construirCardAgenda(BuildContext context, Agendamento agendamento) {
    final pacientes = ref.watch(provedorListaPacientes);
    final indicePaciente = pacientes.indexWhere(
      (item) => item.idPaciente == agendamento.idPaciente,
    );
    final paciente = indicePaciente == -1 ? null : pacientes[indicePaciente];
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.home_repair_service_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paciente?.nome ?? 'Paciente não encontrado',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${agendamento.horaInicio} - ${agendamento.horaFim}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: paciente == null
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TelaRegistroEvolucao(
                        paciente: paciente,
                        agendamento: agendamento,
                      ),
                    ),
                  ),
            icon: const Icon(Icons.edit_note_rounded),
            tooltip: 'Registrar evolução',
          ),
        ],
      ),
    );
  }

  bool _mesmoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
