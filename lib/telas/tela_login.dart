import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provedores/provedor_autenticacao.dart';
import '../provedores/provedores_dados.dart';
import '../utilitarios/botao_google_web.dart';
import 'tela_dashboard.dart';

class TelaLogin extends ConsumerWidget {
  const TelaLogin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoAuth = ref.watch(provedorAutenticacao);
    final theme = Theme.of(context);

    // Reagir a mudanças no estado para navegação ou exibir mensagens de erro
    ref.listen(provedorAutenticacao, (anterior, proximo) {
      if ((anterior?.estaAutenticado ?? false) || !proximo.estaAutenticado) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) {
          return;
        }

        if (proximo.sessao != null) {
          try {
            await carregarDadosReais(ref);
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Falha ao carregar dados reais: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        if (!context.mounted) {
          return;
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => TelaDashboard(
              nomeUsuario:
                  proximo.sessao?.nomeUsuario ??
                  proximo.contaConectada?.nomeUsuario ??
                  'Profissional',
            ),
          ),
        );
      });
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C3E50), // Dark Blue
              Color(0xFF00796B), // Teal
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo ou Ícone Premium
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Título
                  Text(
                    'Fisio Home Care',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gestão Soberana de Prontuários',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Card Central
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // LGPD Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: estadoAuth.termosAceitos,
                                activeColor: theme.colorScheme.primary,
                                onChanged: (value) {
                                  ref
                                      .read(provedorAutenticacao.notifier)
                                      .aceitarTermos(value ?? false);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _mostrarTermos(context);
                                },
                                child: Text.rich(
                                  TextSpan(
                                    text:
                                        'Declaro que li e estou de acordo com os ',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.black87,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            'Termos de Uso e Política de Privacidade (LGPD).',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Mensagem de Erro
                        if (estadoAuth.mensagemErro != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    estadoAuth.mensagemErro!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Botão Entrar com Google
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: kIsWeb
                              ? _construirAcaoWeb(context, ref, estadoAuth)
                              : ElevatedButton(
                                  onPressed: estadoAuth.estaCarregando
                                      ? null
                                      : () => ref
                                            .read(provedorAutenticacao.notifier)
                                            .entrarComGoogle(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        Colors.grey.shade300,
                                    elevation: estadoAuth.estaCarregando
                                        ? 0
                                        : 4,
                                  ),
                                  child: estadoAuth.estaCarregando
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 12,
                                              backgroundColor: Colors.white,
                                              child: Text(
                                                'G',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Entrar com Google',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirAcaoWeb(
    BuildContext context,
    WidgetRef ref,
    EstadoAutenticacao estadoAuth,
  ) {
    if (estadoAuth.estaCarregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!estadoAuth.termosAceitos) {
      return ElevatedButton(
        onPressed: null,
        child: const Text('Aceite os termos para entrar'),
      );
    }

    if (estadoAuth.precisaAutorizarDados) {
      return ElevatedButton.icon(
        onPressed: () =>
            ref.read(provedorAutenticacao.notifier).autorizarDadosGoogle(),
        icon: const Icon(Icons.table_chart_outlined),
        label: Text(
          estadoAuth.contaConectada == null
              ? 'Autorizar Drive e Sheets'
              : 'Autorizar dados de ${estadoAuth.contaConectada!.email}',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      );
    }

    return Center(child: construirBotaoGoogleWeb());
  }

  void _mostrarTermos(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Termos de Uso e Privacidade'),
        content: const SingleChildScrollView(
          child: Text(
            'Ao marcar o aceite e entrar com Google, o profissional declara ter lido, compreendido '
            'e aceitado os termos de uso e a política de privacidade. O aplicativo acessará os dados '
            'autorizados apenas para gestão de agenda, pacientes, evoluções clínicas e auditoria, '
            'respeitando confidencialidade, rastreabilidade e princípios da LGPD.',
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
