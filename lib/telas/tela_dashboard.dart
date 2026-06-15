import 'dart:ui' as ui;
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
    ];

    return Scaffold(
      body: Stack(
        children: [
          telas[_indiceSelecionado.clamp(0, telas.length - 1)],
          _construirNavFlutuante(context, pacientes, carregamento),
          _construirFab(context, pacientes, carregamento),
        ],
      ),
    );
  }

  Widget _construirNavFlutuante(
    BuildContext context,
    List<Paciente> pacientes,
    EstadoCarregamentoDados carregamento,
  ) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: SizedBox(
        height: 86,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavItem(
                          icon: Icons.home_rounded,
                          label: 'Início',
                          isActive: _indiceSelecionado == 0,
                          onTap: () => setState(() => _indiceSelecionado = 0),
                        ),
                        _NavItem(
                          icon: Icons.event_note_rounded,
                          label: 'Sessões',
                          isActive: _indiceSelecionado == 1,
                          onTap: () => setState(() => _indiceSelecionado = 1),
                        ),
                        _NavItem(
                          icon: Icons.people_alt_rounded,
                          label: 'Pacientes',
                          isActive: _indiceSelecionado == 2,
                          onTap: () => setState(() => _indiceSelecionado = 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirFab(
    BuildContext context,
    List<Paciente> pacientes,
    EstadoCarregamentoDados carregamento,
  ) {
    if (_indiceSelecionado == 0) return const SizedBox.shrink();

    if (!carregamento.carregouComSucesso) return const SizedBox.shrink();

    final bool ehAbaPacientes = _indiceSelecionado == 2;

    if (!ehAbaPacientes && pacientes.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: Center(
        child: FloatingActionButton.extended(
          heroTag: 'fab_principal',
          onPressed: ehAbaPacientes
              ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaCadastroPaciente()))
              : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaNovaSessao())),
          icon: Icon(
            ehAbaPacientes
                ? Icons.person_add_alt_1_rounded
                : Icons.add_rounded,
          ),
          label: Text(ehAbaPacientes ? 'Novo Paciente' : 'Nova Sessão'),
          backgroundColor: FisioCores.primary,
          foregroundColor: Colors.white,
          elevation: 6,
        ),
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
        // Cabeçalho
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
            decoration: BoxDecoration(
              gradient: FisioGradientes.teal,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: FisioCores.primary.withValues(alpha: 0.18),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
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
                            color: Colors.white.withValues(alpha: 0.75),
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
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TelaConfiguracoes(),
                        ),
                      ),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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

        // Cards de Resumo
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final largura = constraints.crossAxisExtent;
              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: largura > 620 ? 4 : 2,
                  mainAxisExtent: 156,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
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

        // Título da Seção Agenda
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: FisioDecoracoes.card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cor.withValues(alpha: 0.14)),
                ),
                child: Icon(icone, color: cor, size: 22),
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      valor,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.all(32),
      decoration: FisioDecoracoes.card(),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'Tudo limpo!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: FisioCores.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
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
            fontWeight: FontWeight.w800,
            color: FisioCores.textPrimary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
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
        ? paciente.nome
              .split(' ')
              .map((n) => n.isNotEmpty ? n[0] : '')
              .take(2)
              .join()
              .toUpperCase()
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: FisioDecoracoes.card(),
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
                iniciais,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusCor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusTexto,
                        style: TextStyle(
                          color: statusCor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
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
            const SizedBox(height: 24),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 56,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Não foi possível carregar os dados.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mensagemErro ??
                    'Verifique sua conexão e as permissões da planilha.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cor = isActive ? FisioCores.primary : FisioCores.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: cor, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
          ],
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
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: FisioCores.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}
