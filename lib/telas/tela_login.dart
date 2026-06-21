import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../componentes/design_system.dart';
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

      WidgetsBinding.instance.addPostFrameCallback((_) {
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
        decoration: const BoxDecoration(gradient: FisioGradientes.hero),
        child: Stack(
          children: [
            const Positioned(
              top: -90,
              left: -80,
              child: _OrbeDecorativo(color: FisioCores.primaryLight),
            ),
            const Positioned(
              bottom: -90,
              right: -70,
              child: _OrbeDecorativo(color: Colors.white),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: FisioResponsiveCenter(
                    maxWidth: 420,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo glassmorphism
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.16),
                                    blurRadius: 28,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.medical_services_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Título
                        Text.rich(
                          TextSpan(
                            text: 'Fisio',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: 'Care',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: const Color(0xFF5EEAD4),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gestão inteligente para sua rotina domiciliar.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Card Central Glassmorphism
                        FisioGlass(
                          borderRadius: BorderRadius.circular(28),
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
                                      activeColor: Colors.white,
                                      checkColor: const Color(0xFF0F172A),
                                      side: const BorderSide(
                                        color: Colors.white54,
                                      ),
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
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          'Declaro que li e estou de acordo com os ',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                              ),
                                        ),
                                        _LinkLegal(
                                          texto: 'Termos de Uso',
                                          url: _urlTermos,
                                        ),
                                        Text(
                                          ' e a ',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                              ),
                                        ),
                                        _LinkLegal(
                                          texto:
                                              'Política de Privacidade (LGPD)',
                                          url: _urlPrivacidade,
                                        ),
                                        Text(
                                          '.',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
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
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
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
                                    ? _construirAcaoWeb(
                                        context,
                                        ref,
                                        estadoAuth,
                                      )
                                    : ElevatedButton(
                                        onPressed: (estadoAuth.estaCarregando ||
                                                !estadoAuth.termosAceitos)
                                            ? null
                                            : () => ref
                                                  .read(
                                                    provedorAutenticacao
                                                        .notifier,
                                                  )
                                                  .entrarComGoogle(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor:
                                              FisioCores.primaryDark,
                                          disabledBackgroundColor: Colors.white
                                              .withValues(alpha: 0.5),
                                          elevation: estadoAuth.estaCarregando
                                              ? 0
                                              : 8,
                                          shadowColor: Colors.black.withValues(
                                            alpha: 0.18,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                        ),
                                        child: estadoAuth.estaCarregando
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 3,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(FisioCores.primaryDark),
                                                ),
                                              )
                                            : const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor:
                                                        FisioCores.primaryDark,
                                                    child: Text(
                                                      'G',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Entrar com Google',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
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
          ],
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
      return const ElevatedButton(
        onPressed: null,
        child: Text('Aceite os termos para entrar'),
      );
    }

    return ElevatedButton(
      onPressed: () =>
          ref.read(provedorAutenticacao.notifier).entrarComGoogle(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: FisioCores.primaryDark,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: FisioCores.primaryDark,
            child: Text(
              'G',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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

class _OrbeDecorativo extends StatelessWidget {
  final Color color;

  const _OrbeDecorativo({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 80,
            spreadRadius: 30,
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
          color: const Color(0xFF5EEAD4),
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
