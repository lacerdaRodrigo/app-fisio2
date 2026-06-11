import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'design_system.dart';
import '../modelos/paciente.dart';
import '../provedores/provedores_dados.dart';
import '../telas/tela_historico_evolucoes.dart';
import '../telas/tela_registro_evolucao.dart';

void mostrarModalDetalhesPaciente(BuildContext context, Paciente paciente) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Consumer(
        builder: (context, ref, _) {
          final theme = Theme.of(context);
          final idade = paciente.calcularIdade();

          final alturaMaxima = MediaQuery.of(context).size.height * 0.6;

          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: alturaMaxima),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.96),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(34),
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                        boxShadow: FisioSombras.card,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          // Header fixo
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: FisioCores.primary.withValues(
                                  alpha: 0.12,
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: FisioCores.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      paciente.nome,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: FisioCores.textPrimary,
                                          ),
                                    ),
                                    Text(
                                      '$idade anos  •  ${paciente.cpf}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Corpo rolável
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _LinhaInfo(
                                    icone: Icons.phone_outlined,
                                    titulo: 'Telefone',
                                    valor: paciente.telefone,
                                  ),
                                  _LinhaInfo(
                                    icone: Icons.location_on_outlined,
                                    titulo: 'Endereço',
                                    valor: paciente.endereco,
                                    acao: IconButton.filledTonal(
                                      onPressed: () => _mostrarOpcoesRota(
                                        context,
                                        paciente.endereco,
                                      ),
                                      icon: const Icon(Icons.route_rounded),
                                      tooltip: 'Como chegar',
                                    ),
                                  ),
                                  if ((paciente.queixaPrincipal ?? '')
                                      .isNotEmpty)
                                    _LinhaInfo(
                                      icone: Icons.medical_information_outlined,
                                      titulo: 'Queixa principal',
                                      valor: paciente.queixaPrincipal!,
                                    ),
                                  if ((paciente.histDoencaAtual ?? '')
                                      .isNotEmpty)
                                    _LinhaInfo(
                                      icone: Icons.history_rounded,
                                      titulo: 'Histórico da Doença Atual',
                                      valor: paciente.histDoencaAtual!,
                                    ),
                                  if ((paciente.genero ?? '').isNotEmpty)
                                    _LinhaInfo(
                                      icone: Icons.transgender,
                                      titulo: 'Gênero',
                                      valor: paciente.genero!,
                                    ),
                                  if ((paciente.dor ?? '').isNotEmpty)
                                    _LinhaInfo(
                                      icone: Icons.favorite_outline_rounded,
                                      titulo: 'Escala de Dor',
                                      valor: '${paciente.dor}/10',
                                    ),
                                  if ((paciente.comorbidades ?? '').isNotEmpty)
                                    _LinhaInfo(
                                      icone: Icons.medical_services_outlined,
                                      titulo: 'Comorbidades',
                                      valor: paciente.comorbidades!,
                                    ),
                                  if ((paciente.medicamentos ?? '').isNotEmpty)
                                    _LinhaInfo(
                                      icone: Icons.medication_outlined,
                                      titulo: 'Medicamentos em Uso',
                                      valor: paciente.medicamentos!,
                                    ),
                                  if ((paciente.alergias ?? '').isNotEmpty)
                                    _LinhaInfo(
                                      icone: Icons.warning_amber_rounded,
                                      titulo: 'Alergias',
                                      valor: paciente.alergias!,
                                    ),
                                  if ((paciente.cirurgias ?? '').isNotEmpty)
                                    _LinhaInfo(
                                      icone: Icons.healing_outlined,
                                      titulo: 'Cirurgias/Traumas',
                                      valor: paciente.cirurgias!,
                                    ),
                                  if ((paciente.habitosVida ?? '').isNotEmpty)
                                    _LinhaInfo(
                                      icone: Icons.directions_run_rounded,
                                      titulo:
                                          'Hábitos de Vida / Atividade Física',
                                      valor: paciente.habitosVida!,
                                    ),
                                  if (paciente.estaAtivo) ...[
                                    const SizedBox(height: 8),
                                    _UltimaCondicao(paciente: paciente),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Footer fixo
                          _BotaoAcao(
                            icone: Icons.edit_note_rounded,
                            texto: 'Nova Evolução',
                            onTap: () {
                              Navigator.pop(sheetContext);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TelaRegistroEvolucao(paciente: paciente),
                                ),
                              );
                            },
                          ),
                          _BotaoAcao(
                            icone: Icons.history_edu_rounded,
                            texto: 'Ver Histórico',
                            onTap: () {
                              Navigator.pop(sheetContext);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TelaHistoricoEvolucoes(
                                    paciente: paciente,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (paciente.estaAtivo)
                            _BotaoAcao(
                              icone: Icons.archive_outlined,
                              texto: 'Arquivar Paciente',
                              cor: Colors.orange.shade700,
                              onTap: () => _arquivarPaciente(
                                context,
                                sheetContext,
                                ref,
                                paciente,
                              ),
                            )
                          else
                            _BotaoAcao(
                              icone: Icons.unarchive_outlined,
                              texto: 'Restaurar Paciente',
                              cor: Colors.green.shade700,
                              onTap: () => _restaurarPaciente(
                                context,
                                sheetContext,
                                ref,
                                paciente,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _mostrarOpcoesRota(BuildContext context, String endereco) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) {
      return SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: FisioSombras.card,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text(
                'Como chegar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: FisioCores.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                endereco,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: FisioCores.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              _OpcaoRota(
                icone: Icons.map_outlined,
                titulo: 'Abrir no Google Maps',
                subtitulo: 'Usar o Maps para navegar até o endereço.',
                onTap: () => _abrirRota(
                  context,
                  'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(endereco)}',
                ),
              ),
              const SizedBox(height: 10),
              _OpcaoRota(
                icone: Icons.navigation_outlined,
                titulo: 'Abrir no Waze',
                subtitulo: 'Usar o Waze com a rota do atendimento.',
                onTap: () => _abrirRota(
                  context,
                  'https://waze.com/ul?q=${Uri.encodeComponent(endereco)}',
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _OpcaoRota extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _OpcaoRota({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FisioCores.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: FisioDecoracoes.tinted(FisioCores.primary, radius: 15),
          child: Icon(icone, color: FisioCores.primary),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            color: FisioCores.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(subtitulo),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: FisioCores.primary,
        ),
        onTap: onTap,
      ),
    );
  }
}

Future<void> _abrirRota(BuildContext context, String url) async {
  Navigator.pop(context);
  final uri = Uri.parse(url);
  final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!context.mounted || abriu) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Não foi possível abrir o aplicativo de rotas.'),
    ),
  );
}

Future<void> _arquivarPaciente(
  BuildContext context,
  BuildContext sheetContext,
  WidgetRef ref,
  Paciente paciente,
) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Arquivar paciente?'),
      content: Text('${paciente.nome} deixará de aparecer na lista principal.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Arquivar'),
        ),
      ],
    ),
  );

  if (confirmou != true || !context.mounted) return;

  try {
    await arquivarPacienteReal(ref, paciente.idPaciente);
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Falha ao arquivar paciente: $e'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (!context.mounted) return;
  Navigator.pop(sheetContext);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Paciente arquivado.'),
      backgroundColor: Colors.orange,
    ),
  );
}

Future<void> _restaurarPaciente(
  BuildContext context,
  BuildContext sheetContext,
  WidgetRef ref,
  Paciente paciente,
) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Restaurar paciente?'),
      content: Text('${paciente.nome} voltará a aparecer na lista principal.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Restaurar'),
        ),
      ],
    ),
  );

  if (confirmou != true || !context.mounted) return;

  try {
    await restaurarPacienteReal(ref, paciente.idPaciente);
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Falha ao restaurar paciente: $e'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (!context.mounted) return;
  Navigator.pop(sheetContext);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Paciente restaurado.'),
      backgroundColor: Colors.green,
    ),
  );
}

class _LinhaInfo extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;
  final Widget? acao;

  const _LinhaInfo({
    required this.icone,
    required this.titulo,
    required this.valor,
    this.acao,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: FisioDecoracoes.tinted(
              theme.colorScheme.primary,
              radius: 14,
            ),
            child: Icon(icone, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: FisioCores.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
          ?acao,
        ],
      ),
    );
  }
}

class _UltimaCondicao extends ConsumerWidget {
  final Paciente paciente;

  const _UltimaCondicao({required this.paciente});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evolucoes = ref.watch(provedorListaEvolucoes);
    final ultima =
        evolucoes.where((e) => e.idPaciente == paciente.idPaciente).toList()
          ..sort((a, b) => b.dataAtendimento.compareTo(a.dataAtendimento));

    if (ultima.isEmpty) return const SizedBox.shrink();

    final evol = ultima.first;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: FisioDecoracoes.tinted(FisioCores.success, radius: 14),
            child: const Icon(
              Icons.trending_up_rounded,
              color: FisioCores.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Última evolução',
                  style: const TextStyle(
                    fontSize: 12,
                    color: FisioCores.textSecondary,
                  ),
                ),
                Text(
                  'Condição: ${evol.condicaoPaciente}  •  Dor: ${evol.dorSessao}/10',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BotaoAcao extends StatelessWidget {
  final IconData icone;
  final String texto;
  final VoidCallback onTap;
  final Color? cor;

  const _BotaoAcao({
    required this.icone,
    required this.texto,
    required this.onTap,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final corFinal = cor ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: corFinal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          leading: Icon(icone, color: corFinal),
          title: Text(
            texto,
            style: TextStyle(color: corFinal, fontWeight: FontWeight.w700),
          ),
          trailing: Icon(Icons.chevron_right_rounded, color: corFinal),
          onTap: onTap,
        ),
      ),
    );
  }
}
