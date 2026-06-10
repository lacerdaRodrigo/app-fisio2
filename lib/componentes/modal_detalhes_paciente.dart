import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Consumer(
        builder: (context, ref, _) {
          final theme = Theme.of(context);
          final idade = paciente.calcularIdade();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              paciente.nome,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 24),
                  _LinhaInfo(
                    icone: Icons.phone_outlined,
                    titulo: 'Telefone',
                    valor: paciente.telefone,
                  ),
                  const SizedBox(height: 12),
                  _LinhaInfo(
                    icone: Icons.location_on_outlined,
                    titulo: 'Endereço',
                    valor: paciente.endereco,
                    acao: IconButton.filledTonal(
                      onPressed: () =>
                          _mostrarOpcoesRota(context, paciente.endereco),
                      icon: const Icon(Icons.route_rounded),
                      tooltip: 'Como chegar',
                    ),
                  ),
                  if ((paciente.queixaPrincipal ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _LinhaInfo(
                      icone: Icons.medical_information_outlined,
                      titulo: 'Queixa principal',
                      valor: paciente.queixaPrincipal!,
                    ),
                  ],
                  if ((paciente.histDoencaAtual ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _LinhaInfo(
                      icone: Icons.history_rounded,
                      titulo: 'Histórico da Doença Atual',
                      valor: paciente.histDoencaAtual!,
                    ),
                  ],
                  if ((paciente.genero ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _LinhaInfo(
                      icone: Icons.transgender,
                      titulo: 'Gênero',
                      valor: paciente.genero!,
                    ),
                  ],
                  if ((paciente.dor ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _LinhaInfo(
                      icone: Icons.favorite_outline_rounded,
                      titulo: 'Escala de Dor',
                      valor: '${paciente.dor}/10',
                    ),
                  ],
                  if ((paciente.comorbidades ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _LinhaInfo(
                      icone: Icons.medical_services_outlined,
                      titulo: 'Comorbidades',
                      valor: paciente.comorbidades!,
                    ),
                  ],
                  if ((paciente.medicamentos ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _LinhaInfo(
                      icone: Icons.medication_outlined,
                      titulo: 'Medicamentos em Uso',
                      valor: paciente.medicamentos!,
                    ),
                  ],
                  if ((paciente.alergias ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _LinhaInfo(
                      icone: Icons.warning_amber_rounded,
                      titulo: 'Alergias',
                      valor: paciente.alergias!,
                    ),
                  ],
                  if ((paciente.cirurgias ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _LinhaInfo(
                      icone: Icons.healing_outlined,
                      titulo: 'Cirurgias/Traumas',
                      valor: paciente.cirurgias!,
                    ),
                  ],
                  if ((paciente.habitosVida ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _LinhaInfo(
                      icone: Icons.directions_run_rounded,
                      titulo: 'Hábitos de Vida / Atividade Física',
                      valor: paciente.habitosVida!,
                    ),
                  ],
                  const SizedBox(height: 24),
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
                          builder: (_) =>
                              TelaHistoricoEvolucoes(paciente: paciente),
                        ),
                      );
                    },
                  ),
                  _BotaoAcao(
                    icone: Icons.archive_outlined,
                    texto: 'Arquivar Paciente',
                    cor: Colors.orange.shade700,
                    onTap: () =>
                        _arquivarPaciente(context, sheetContext, ref, paciente),
                  ),
                ],
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
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: const Text('Abrir no Google Maps'),
                onTap: () => _abrirRota(
                  context,
                  'https://www.google.com/maps/search/?api=1&query=$endereco',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.navigation_outlined),
                title: const Text('Abrir no Waze'),
                onTap: () =>
                    _abrirRota(context, 'https://waze.com/ul?q=$endereco'),
              ),
            ],
          ),
        ),
      );
    },
  );
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: theme.colorScheme.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(valor, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        ?acao,
      ],
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icone, color: corFinal),
      title: Text(
        texto,
        style: TextStyle(color: corFinal, fontWeight: FontWeight.w600),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: corFinal),
      onTap: onTap,
    );
  }
}
