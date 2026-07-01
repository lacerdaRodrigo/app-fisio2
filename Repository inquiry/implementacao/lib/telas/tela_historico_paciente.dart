import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../componentes/design_system_fisio.dart';

/// Modelo leve de um marco de evolução na timeline.
class MarcoEvolucao {
  final String titulo;
  final String data;
  final String texto;
  final int dor;
  const MarcoEvolucao(this.titulo, this.data, this.texto, this.dor);
}

/// Tela Histórico do Paciente — perfil, evolução da dor e timeline.
class TelaHistoricoPaciente extends ConsumerWidget {
  final String nome;
  final String subtitulo;
  final int totalSessoes;
  final int dorInicial;
  final int dorAtual;
  final int adesaoPct;
  final List<int> serieDor; // para o mini-gráfico
  final List<MarcoEvolucao> marcos;

  const TelaHistoricoPaciente({
    super.key,
    required this.nome,
    required this.subtitulo,
    required this.totalSessoes,
    required this.dorInicial,
    required this.dorAtual,
    required this.adesaoPct,
    required this.serieDor,
    required this.marcos,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: FisioCores.surface,
      child: FisioResponsiveCenter(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FisioGradientHeader(
              padding: const EdgeInsets.fromLTRB(18, 50, 18, 24),
              titulo: 'Histórico',
              leading: FisioHeaderIconButton(Icons.chevron_left_rounded,
                  onTap: () => Navigator.of(context).maybePop()),
              bottom: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28)),
                        ),
                        child: Text(fisioIniciais(nome),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nome,
                                style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3)),
                            Text(subtitulo,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.78))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _miniStat('$totalSessoes', 'sessões'),
                      const SizedBox(width: 8),
                      _miniStat('$dorInicial→$dorAtual', 'dor'),
                      const SizedBox(width: 8),
                      _miniStat('$adesaoPct%', 'adesão'),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: FisioCard(
                radius: 18,
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Evolução da dor',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: FisioCores.textPrimary)),
                        Text(
                            dorAtual < dorInicial
                                ? '↓ melhora consistente'
                                : 'estável',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: FisioCores.success)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 56,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: serieDor.map((d) {
                          final c = FisioPainSlider.cor(d);
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2.5),
                              height: 16 + d * 4.0,
                              decoration: BoxDecoration(
                                color: c.withValues(alpha: d <= 3 ? 0.9 : 0.55),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(5),
                                    bottom: Radius.circular(2)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FisioSectionLabel('Linha do tempo'),
                  const SizedBox(height: 14),
                  ..._timeline(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String valor, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(valor,
                style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1)),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.74))),
          ],
        ),
      ),
    );
  }

  List<Widget> _timeline() {
    return [
      for (var i = 0; i < marcos.length; i++)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: FisioPainSlider.cor(marcos[i].dor), width: 3),
                    ),
                  ),
                  if (i < marcos.length - 1)
                    Expanded(
                      child: Container(
                          width: 2, color: const Color(0xFFDCE3EB)),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: FisioCard(
                    radius: 16,
                    padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(marcos[i].titulo,
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: FisioCores.textPrimary)),
                            Text(marcos[i].data,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: FisioCores.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(marcos[i].texto,
                            style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                color: FisioCores.textSecondary)),
                        const SizedBox(height: 9),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: FisioPainSlider.cor(marcos[i].dor)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('Dor ${marcos[i].dor}/10',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: FisioPainSlider.cor(marcos[i].dor))),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    ];
  }
}
