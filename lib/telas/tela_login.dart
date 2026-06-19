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

    ref.listen(provedorAutenticacao, (anterior, proximo) {
      if ((anterior?.estaAutenticado ?? false) || !proximo.estaAutenticado) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }

        if (proximo.sessao != null) {
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
        color: FisioCores.primary,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(FisioEspacamentos.xl),
              child: FisioResponsiveCenter(
                maxWidth: 420,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: FisioDecoracoes.tinted(
                          Colors.white,
                          radius: FisioRaios.xl,
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: FisioEspacamentos.xl),

                    Text.rich(
                      TextSpan(
                        text: 'Fisio',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(
                            text: 'Care',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: FisioCores.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: FisioEspacamentos.sm),
                    Text(
                      'Gestão inteligente para sua rotina domiciliar.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: FisioEspacamentos.xxxl),

                    FisioCard(
                      radius: FisioRaios.lg,
                      padding: const EdgeInsets.all(FisioEspacamentos.xl),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: estadoAuth.termosAceitos,
                                  activeColor: FisioCores.primary,
                                  checkColor: Colors.white,
                                  side: BorderSide(
                                    color: FisioCores.textMuted,
                                  ),
                                  onChanged: (value) {
                                    ref
                                        .read(provedorAutenticacao.notifier)
                                        .aceitarTermos(value ?? false);
                                  },
                                ),
                              ),
                              const SizedBox(width: FisioEspacamentos.md),
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment:
                                      WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'Declaro que li e estou de acordo com os ',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: FisioCores.textPrimary,
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
                                            color: FisioCores.textPrimary,
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
                                            color: FisioCores.textPrimary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          if (estadoAuth.mensagemErro != null) ...[
                            const SizedBox(height: FisioEspacamentos.base),
                            Container(
                              padding: const EdgeInsets.all(FisioEspacamentos.md),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(FisioRaios.md),
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
                                  const SizedBox(width: FisioEspacamentos.sm),
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

                          const SizedBox(height: FisioEspacamentos.xl),

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
                                    onPressed: estadoAuth.estaCarregando
                                        ? null
                                        : () => ref
                                              .read(
                                                provedorAutenticacao
                                                    .notifier,
                                              )
                                              .entrarComGoogle(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: FisioCores.primary,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: FisioCores
                                          .primary
                                          .withValues(alpha: 0.5),
                                      elevation: estadoAuth.estaCarregando
                                          ? 0
                                          : 1,
                                      shadowColor: FisioCores.primary
                                          .withValues(alpha: 0.18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          FisioRaios.base,
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
                                                  >(Colors.white),
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                radius: 12,
                                                backgroundColor:
                                                    Colors.white,
                                                child: Text(
                                                  'G',
                                                  style: TextStyle(
                                                    color: FisioCores.primary,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Entrar com Google',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.w600,
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
        backgroundColor: FisioCores.primary,
        foregroundColor: Colors.white,
        elevation: 1,
        shadowColor: FisioCores.primary.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FisioRaios.base),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.white,
            child: Text(
              'G',
              style: TextStyle(
                color: FisioCores.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Entrar com Google',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          color: FisioCores.secondary,
          fontWeight: FontWeight.w600,
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
