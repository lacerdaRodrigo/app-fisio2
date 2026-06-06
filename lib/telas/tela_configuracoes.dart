import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../provedores/provedores_dados.dart';

class TelaConfiguracoes extends ConsumerStatefulWidget {
  const TelaConfiguracoes({super.key});

  @override
  ConsumerState<TelaConfiguracoes> createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends ConsumerState<TelaConfiguracoes> {
  final _valorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _valorController.text = ref.read(provedorValorSessaoPadrao);
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logs = ref.watch(provedorLogsAuditoria);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Configurações',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _CartaoSecao(
              titulo: 'Valor padrão da sessão',
              icone: Icons.attach_money_rounded,
              child: Column(
                children: [
                  TextField(
                    controller: _valorController,
                    decoration: const InputDecoration(
                      labelText: 'Valor em R\$',
                      hintText: '150,00',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _salvarValorPadrao,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Salvar valor padrão'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _CartaoSecao(
              titulo: 'Dados e privacidade',
              icone: Icons.privacy_tip_outlined,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.table_chart_outlined),
                    title: const Text('Visualizar Planilha de Dados'),
                    subtitle: const Text('Abre o Google Sheets no navegador.'),
                    onTap: () => _abrirPlanilha(context),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.article_outlined),
                    title: const Text('Visualizar Termos de Uso'),
                    subtitle: const Text(
                      'Releia a declaração LGPD aceita no login.',
                    ),
                    onTap: () => _mostrarTermos(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _CartaoSecao(
              titulo: 'Logs de auditoria',
              icone: Icons.fact_check_outlined,
              child: logs.isEmpty
                  ? Text(
                      'Nenhuma ação crítica registrada nesta sessão.',
                      style: TextStyle(color: Colors.grey.shade600),
                    )
                  : Column(
                      children: [
                        for (final log in logs.take(10))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            leading: Icon(
                              Icons.circle,
                              size: 8,
                              color: theme.colorScheme.primary,
                            ),
                            title: Text(log, style: theme.textTheme.bodySmall),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvarValorPadrao() async {
    final valor = _valorController.text.trim();
    if (valor.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe um valor padrão.')));
      return;
    }

    try {
      await salvarValorSessaoPadraoReal(ref, valor);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valor padrão salvo.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao salvar configuração: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _abrirPlanilha(BuildContext context) async {
    final planilhaId = ref.read(provedorPlanilhaId);
    final abriu = await launchUrl(
      Uri.parse(
        planilhaId == null
            ? 'https://docs.google.com/spreadsheets/'
            : 'https://docs.google.com/spreadsheets/d/$planilhaId/edit',
      ),
      mode: LaunchMode.externalApplication,
    );
    if (!context.mounted || abriu) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Não foi possível abrir o Google Sheets.')),
    );
  }

  void _mostrarTermos(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Termos de Uso e Privacidade'),
        content: const SingleChildScrollView(
          child: Text(
            'Ao utilizar o Fisio Home Care, o profissional declara ciência de que os dados clínicos '
            'são usados exclusivamente para gestão de atendimentos, prontuários e agenda domiciliar. '
            'O acesso à conta Google deve ser usado apenas para ler e gravar dados operacionais na '
            'planilha autorizada pelo usuário, mantendo confidencialidade e rastreabilidade conforme a LGPD.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class _CartaoSecao extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final Widget child;

  const _CartaoSecao({
    required this.titulo,
    required this.icone,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
