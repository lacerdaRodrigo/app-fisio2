import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modelos/agendamento.dart';
import '../modelos/paciente.dart';
import '../componentes/design_system.dart';
import '../provedores/provedores_dados.dart';
import '../utilitarios/utilitarios_data.dart';
import '../utilitarios/acoes_agendamento.dart';
import 'tela_cadastro_paciente.dart';
import 'tela_historico_geral_evolucoes.dart';
import 'tela_pacientes.dart';
import 'tela_nova_sessao.dart';
import 'tela_sessoes.dart';
import 'tela_configuracoes.dart';

class TelaDashboard extends ConsumerStatefulWidget {
  final String nomeUsuario;
  const TelaDashboard({super.key, required this.nomeUsuario});

  @override
  ConsumerState<TelaDashboard> createState() => _TelaDashboardState();
}

class _TelaDashboardState extends ConsumerState<TelaDashboard> {
  int _indiceSelecionado = 0;
  FiltroPacientes _filtroPacientes = FiltroPacientes.ativos;
  final ScrollController _dashboardScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;

      final carregamento = ref.read(provedorCarregamentoDados);
      if (carregamento.carregouComSucesso ||
          carregamento.status == StatusCarregamentoDados.carregando) {
        return;
      }

      carregarDadosReais(ref);
    });
  }

  @override
  void dispose() {
    _dashboardScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pacientes = ref.watch(provedorListaPacientes);
    final carregamento = ref.watch(provedorCarregamentoDados);

    final telas = [
      if (carregamento.carregouComSucesso)
        _construirConteudoDashboard(context)
      else if (carregamento.possuiErro)
        _construirDashboardErro(context, carregamento.mensagemErro)
      else
        _construirDashboardCarregando(context),
      const TelaSessoes(),
      TelaPacientes(
        key: ValueKey(_filtroPacientes),
        filtroInicial: _filtroPacientes,
      ),
      const TelaConfiguracoes(),
    ];

    return Scaffold(
      body: telas[_indiceSelecionado.clamp(0, telas.length - 1)],
      floatingActionButton: _construirFab(context, pacientes, carregamento),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSelecionado,
        onDestinationSelected: (index) =>
            setState(() => _indiceSelecionado = index),
        indicatorColor: FisioCores.primary.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: 'Sessões',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_alt_rounded),
            label: 'Pacientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Config',
          ),
        ],
      ),
    );
  }

  Widget? _construirFab(
    BuildContext context,
    List<Paciente> pacientes,
    EstadoCarregamentoDados carregamento,
  ) {
    if (_indiceSelecionado == 3) return null;

    if (!carregamento.carregouComSucesso) return null;

    final bool ehAbaPacientes = _indiceSelecionado == 2;

    if (!ehAbaPacientes && pacientes.isEmpty) return null;

    return FloatingActionButton.extended(
      heroTag: 'fab_principal',
      onPressed: ehAbaPacientes
          ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaCadastroPaciente()),
              )
          : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaNovaSessao()),
              ),
      icon: Icon(
        ehAbaPacientes ? Icons.person_add_alt_1_rounded : Icons.add_rounded,
      ),
      label: Text(ehAbaPacientes ? 'Novo Paciente' : 'Nova Sessão'),
      backgroundColor: FisioCores.primary,
      foregroundColor: Colors.white,
      elevation: 2,
    );
  }

  Widget _construirConteudoDashboard(BuildContext context) {
    final saudacao = UtilitariosData.obterSaudacao();
    final dataFormatada = UtilitariosData.formatarDataBr(DateTime.now());
    final theme = Theme.of(context);
    final pacientes = ref.watch(provedorListaPacientes);
    final agendamentos = ref.watch(provedorListaAgendamentos);
    final evolucoes = ref.watch(provedorListaEvolucoes);
    final hoje = DateTime.now();
    final agendamentosHoje =
        agendamentos.where((agendamento) => agendamento.ehDeHoje(hoje)).toList()
          ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
    final agendamentosHojePendentes = agendamentosHoje
        .where((agendamento) => agendamento.estaAgendado)
        .toList();
    final pendenciasAnteriores =
        agendamentos
            .where((agendamento) => agendamento.pendenteDeDiaAnterior(hoje))
            .toList()
          ..sort((a, b) => b.data.compareTo(a.data));

    return CustomScrollView(
      controller: _dashboardScrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.fromLTRB(
              FisioEspacamentos.xl,
              FisioEspacamentos.xxxl,
              FisioEspacamentos.xl,
              FisioEspacamentos.xxl,
            ),
            decoration: BoxDecoration(
              color: FisioCores.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(FisioRaios.lg),
                bottomRight: Radius.circular(FisioRaios.lg),
              ),
              boxShadow: FisioSombras.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$saudacao,',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: FisioEspacamentos.xs),
                Text(
                  widget.nomeUsuario,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: FisioEspacamentos.md),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dataFormatada,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            FisioEspacamentos.lg,
            FisioEspacamentos.lg,
            FisioEspacamentos.lg,
            0,
          ),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final largura = constraints.crossAxisExtent;
              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: largura > FisioPontoQuebra.tablet ? 4 : 2,
                  mainAxisExtent: 156,
                  crossAxisSpacing: FisioEspacamentos.md,
                  mainAxisSpacing: FisioEspacamentos.md,
                ),
                delegate: SliverChildListDelegate([
                  _construirCard(
                    'Pacientes\nCadastrados',
                    '${pacientes.length}',
                    Icons.people_alt_rounded,
                    FisioCores.primary,
                    onTap: () => _abrirPacientes(FiltroPacientes.todos),
                  ),
                  _construirCard(
                    'Pacientes\nAtivos',
                    '${pacientes.where((p) => p.estaAtivo).length}',
                    Icons.person_pin_circle_rounded,
                    FisioCores.indigo,
                    onTap: () => _abrirPacientes(FiltroPacientes.ativos),
                  ),
                  _construirCard(
                    'Agenda\ndo Dia',
                    '${agendamentosHojePendentes.length}',
                    Icons.schedule_rounded,
                    FisioCores.warning,
                    onTap: _rolarParaAgenda,
                  ),
                  _construirCard(
                    'Total de\nEvoluções',
                    '${evolucoes.length}',
                    Icons.trending_up_rounded,
                    FisioCores.pink,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TelaHistoricoGeralEvolucoes(),
                      ),
                    ),
                  ),
                ]),
              );
            },
          ),
        ),

        if (pendenciasAnteriores.isNotEmpty) ...[
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              FisioEspacamentos.xl,
              FisioEspacamentos.xl,
              FisioEspacamentos.xl,
              FisioEspacamentos.sm,
            ),
            sliver: SliverToBoxAdapter(
              child: _construirTituloSecaoComBadge(
                context,
                titulo: 'Pendências',
                badge: '${pendenciasAnteriores.length} sem desfecho',
                cor: FisioCores.warning,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: FisioEspacamentos.base),
            sliver: SliverList.builder(
              itemCount: pendenciasAnteriores.length,
              itemBuilder: (context, index) => _construirCardAgenda(
                context,
                pendenciasAnteriores[index],
                pendenteAnterior: true,
              ),
            ),
          ),
        ],

        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            FisioEspacamentos.xl,
            FisioEspacamentos.xl,
            FisioEspacamentos.xl,
            FisioEspacamentos.sm,
          ),
          sliver: SliverToBoxAdapter(
            child: _construirTituloSecaoComBadge(
              context,
              titulo: 'Agenda de Hoje',
              badge: dataFormatada,
              cor: FisioCores.primary,
            ),
          ),
        ),

        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: FisioEspacamentos.base),
          sliver: agendamentosHojePendentes.isEmpty
              ? SliverToBoxAdapter(child: _construirAgendaVazia())
              : SliverList.builder(
                  itemCount: agendamentosHojePendentes.length,
                  itemBuilder: (context, index) => _construirCardAgenda(
                    context,
                    agendamentosHojePendentes[index],
                  ),
                ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 132)),
      ],
    );
  }

  void _abrirPacientes(FiltroPacientes filtro) {
    setState(() {
      _filtroPacientes = filtro;
      _indiceSelecionado = 2;
    });
  }

  void _rolarParaAgenda() {
    if (!_dashboardScrollController.hasClients) return;

    _dashboardScrollController.animateTo(
      520,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _construirCard(
    String titulo,
    String valor,
    IconData icone,
    Color cor, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(FisioRaios.base),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(FisioEspacamentos.lg),
          decoration: FisioDecoracoes.card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FisioIconBox(icon: icone, color: cor, size: 48, iconSize: 22),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      valor,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: FisioCores.textPrimary,
                      ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: cor.withValues(alpha: 0.65),
                      size: 20,
                    ),
                ],
              ),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 11,
                  color: FisioCores.textSecondary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirAgendaVazia() {
    return Container(
      padding: EdgeInsets.all(FisioEspacamentos.xxl),
      decoration: FisioDecoracoes.card(),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: FisioEspacamentos.md),
          const Text(
            'Tudo limpo!',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: FisioCores.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: FisioEspacamentos.xs),
          Text(
            'Nenhum atendimento agendado para hoje.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _construirTituloSecaoComBadge(
    BuildContext context, {
    required String titulo,
    required String badge,
    required Color cor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: FisioCores.textPrimary,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: FisioEspacamentos.md,
            vertical: FisioEspacamentos.xs,
          ),
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(FisioRaios.lg),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirCardAgenda(
    BuildContext context,
    Agendamento agendamento, {
    bool pendenteAnterior = false,
  }) {
    final pacientes = ref.watch(provedorListaPacientes);
    final indicePaciente = pacientes.indexWhere(
      (item) => item.idPaciente == agendamento.idPaciente,
    );
    final paciente = indicePaciente == -1 ? null : pacientes[indicePaciente];
    final iniciais = paciente != null
        ? fisioIniciais(paciente.nome)
        : '??';
    final cor = paciente != null
        ? fisioAvatarColor(paciente.nome)
        : FisioCores.primary;
    final agora = DateTime.now();
    final atrasado = agendamento.estaAtrasado(agora);
    final statusCor = pendenteAnterior || atrasado
        ? FisioCores.warning
        : FisioCores.primary;
    final statusTexto = pendenteAnterior
        ? 'Pendente'
        : atrasado
        ? 'Atrasado'
        : 'Agendado';

    return Container(
      margin: EdgeInsets.only(bottom: FisioEspacamentos.md),
      padding: EdgeInsets.all(FisioEspacamentos.base),
      decoration: FisioDecoracoes.card(),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(FisioRaios.base),
              border: Border.all(color: cor.withValues(alpha: 0.16)),
            ),
            child: Center(
              child: Text(
                iniciais,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: cor,
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
                  paciente?.nome ?? 'Paciente não encontrado',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: FisioCores.textPrimary,
                  ),
                ),
                const SizedBox(height: FisioEspacamentos.xs),
                Wrap(
                  spacing: FisioEspacamentos.sm,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _MetaAgenda(
                      icon: Icons.schedule_rounded,
                      label:
                          '${agendamento.horaInicio} - ${agendamento.horaFim}',
                    ),
                    if (pendenteAnterior)
                      _MetaAgenda(
                        icon: Icons.calendar_month_rounded,
                        label: UtilitariosData.formatarDataBr(agendamento.data),
                      ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: FisioEspacamentos.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusCor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(FisioRaios.pill),
                      ),
                      child: Text(
                        statusTexto,
                        style: TextStyle(
                          color: statusCor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<AcaoAgendamento>(
            tooltip: 'Ações da sessão',
            icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade500),
            onSelected: (acao) =>
                executarAcaoAgendamento(context, ref, acao, agendamento, paciente),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: AcaoAgendamento.registrarEvolucao,
                child: Text('Registrar evolução'),
              ),
              PopupMenuItem(
                value: AcaoAgendamento.faltouComAviso,
                child: Text('Faltou com aviso'),
              ),
              PopupMenuItem(
                value: AcaoAgendamento.faltouSemAviso,
                child: Text('Faltou sem aviso'),
              ),
              PopupMenuItem(
                value: AcaoAgendamento.canceladoPaciente,
                child: Text('Cancelar pelo paciente'),
              ),
              PopupMenuItem(
                value: AcaoAgendamento.canceladoProfissional,
                child: Text('Cancelar pelo profissional'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirDashboardCarregando(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: FisioEspacamentos.xl),
            Text(
              'Carregando dados...',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirDashboardErro(BuildContext context, String? mensagemErro) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(FisioEspacamentos.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 56,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: FisioEspacamentos.base),
              Text(
                'Não foi possível carregar os dados.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: FisioEspacamentos.sm),
              Text(
                mensagemErro ??
                    'Verifique sua conexão e as permissões da planilha.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: FisioEspacamentos.xl),
              FilledButton.icon(
                onPressed: () => carregarDadosReais(ref),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaAgenda extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaAgenda({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: FisioCores.textMuted),
        const SizedBox(width: FisioEspacamentos.xs),
        Text(
          label,
          style: const TextStyle(color: FisioCores.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}
