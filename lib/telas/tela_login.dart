import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../provedores/provedor_autenticacao.dart';
import 'tela_dashboard.dart';

final _urlTermos = Uri.parse('https://app-fisio-care-2.web.app/termos.html');
final _urlPrivacidade = Uri.parse(
  'https://app-fisio-care-2.web.app/privacidade.html',
);

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
          // Navega imediatamente para o dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => TelaDashboard(
                nomeUsuario: proximo.sessao?.nomeUsuario ?? 'Profissional',
              ),
            ),
          );
        }
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
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Declaro que li e estou de acordo com os ',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  _LinkLegal(
                                    texto: 'Termos de Uso',
                                    url: _urlTermos,
                                  ),
                                  Text(
                                    ' e a ',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  _LinkLegal(
                                    texto: 'Política de Privacidade (LGPD)',
                                    url: _urlPrivacidade,
                                  ),
                                  Text(
                                    '.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
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
    final theme = Theme.of(context);

    if (estadoAuth.estaCarregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!estadoAuth.termosAceitos) {
      return ElevatedButton(
        onPressed: null,
        child: const Text('Aceite os termos para entrar'),
      );
    }

    return ElevatedButton(
      onPressed: () =>
          ref.read(provedorAutenticacao.notifier).entrarComGoogle(),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.white,
            child: Text('G', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 12),
          Text(
            'Entrar com Google',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _LinkLegal extends StatelessWidget {
  final String texto;
  final Uri url;

  const _LinkLegal({required this.texto, required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _abrirUrlLegal(context, url),
      child: Text(
        texto,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Future<void> _abrirUrlLegal(BuildContext context, Uri url) async {
    final abriu = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (abriu || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Não foi possível abrir o documento.')),
    );
  }
}
