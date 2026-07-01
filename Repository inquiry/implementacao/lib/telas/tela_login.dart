import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../componentes/design_system_fisio.dart';

/// Tela de Login — Google Sign-In + consentimento LGPD.
class TelaLogin extends ConsumerStatefulWidget {
  final Future<void> Function()? onGoogle;
  final VoidCallback? onAbrirPrivacidade;
  final VoidCallback? onAbrirTermos;

  const TelaLogin({
    super.key,
    this.onGoogle,
    this.onAbrirPrivacidade,
    this.onAbrirTermos,
  });

  @override
  ConsumerState<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends ConsumerState<TelaLogin> {
  bool _lgpd = false;
  bool _carregando = false;

  Future<void> _entrar() async {
    if (!_lgpd || _carregando) return;
    setState(() => _carregando = true);
    try {
      await widget.onGoogle?.call();
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: FisioGradients.header),
        child: Stack(
          children: [
            // brand
            Align(
              alignment: const Alignment(0, -0.45),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.favorite_rounded,
                        color: Colors.white, size: 38),
                  ),
                  const SizedBox(height: 22),
                  const Text('Fisio Home Care',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.6)),
                  const SizedBox(height: 6),
                  Text('Gestão de atendimentos\ndomiciliares de fisioterapia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.82))),
                ],
              ),
            ),
            // sheet
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: FisioCores.card,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _entrar,
                          child: Opacity(
                            opacity: _lgpd ? 1 : 0.55,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8)),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_carregando)
                                    const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: FisioCores.primary))
                                  else
                                    const _GoogleG(),
                                  const SizedBox(width: 11),
                                  const Text('Continuar com Google',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: FisioCores.textPrimary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _lgpd = !_lgpd),
                              child: Container(
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.only(top: 1),
                                decoration: BoxDecoration(
                                  color: _lgpd
                                      ? FisioCores.primary
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                      color: _lgpd
                                          ? FisioCores.primary
                                          : const Color(0xFFCBD5E1),
                                      width: 2),
                                ),
                                child: _lgpd
                                    ? const Icon(Icons.check_rounded,
                                        size: 14, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  style: const TextStyle(
                                      fontSize: 12,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                      color: FisioCores.textSecondary),
                                  children: [
                                    const TextSpan(text: 'Li e concordo com a '),
                                    TextSpan(
                                        text: 'Política de Privacidade',
                                        style: const TextStyle(
                                            color: FisioCores.primary,
                                            fontWeight: FontWeight.w700)),
                                    const TextSpan(text: ' e os '),
                                    TextSpan(
                                        text: 'Termos de Uso',
                                        style: const TextStyle(
                                            color: FisioCores.primary,
                                            fontWeight: FontWeight.w700)),
                                    const TextSpan(
                                        text:
                                            ', e autorizo o tratamento dos meus dados conforme a LGPD.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4F8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_outline_rounded,
                                  size: 15, color: FisioCores.textMuted),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                    'Seus dados ficam na sua própria planilha Google. Nada é armazenado em nossos servidores.',
                                    style: TextStyle(
                                        fontSize: 11,
                                        height: 1.4,
                                        fontWeight: FontWeight.w500,
                                        color: FisioCores.textMuted)),
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
}

class _GoogleG extends StatelessWidget {
  const _GoogleG();
  @override
  Widget build(BuildContext context) {
    // Substitua por Image.asset('assets/google.png') se preferir o logo oficial.
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text('G',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4285F4))),
    );
  }
}
