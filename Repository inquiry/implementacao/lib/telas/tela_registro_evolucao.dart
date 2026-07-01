import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../componentes/design_system_fisio.dart';

/// Tela Registro de Evolução.
/// O botão de microfone alterna o estado "ouvindo" — conecte ao seu serviço
/// de speech-to-text em [_alternarDitado].
class TelaRegistroEvolucao extends ConsumerStatefulWidget {
  final String nomePaciente;
  final int numeroSessao;
  final DateTime data;
  final String contexto;

  const TelaRegistroEvolucao({
    super.key,
    required this.nomePaciente,
    required this.numeroSessao,
    required this.data,
    this.contexto = 'Atendimento domiciliar',
  });

  @override
  ConsumerState<TelaRegistroEvolucao> createState() =>
      _TelaRegistroEvolucaoState();
}

class _TelaRegistroEvolucaoState extends ConsumerState<TelaRegistroEvolucao> {
  final _controller = TextEditingController();
  bool _ouvindo = false;
  int _dor = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _alternarDitado() {
    setState(() => _ouvindo = !_ouvindo);
    // TODO: iniciar/parar reconhecimento de voz e anexar ao _controller.
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FisioCores.surface,
      child: FisioResponsiveCenter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FisioGradientHeader(
              padding: const EdgeInsets.fromLTRB(18, 50, 18, 22),
              titulo: 'Evolução',
              subtitulo:
                  'Sessão ${widget.numeroSessao} · ${_dataCurta(widget.data)}',
              leading: FisioHeaderIconButton(Icons.chevron_left_rounded,
                  onTap: () => Navigator.of(context).maybePop()),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                children: [
                  FisioCard(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    radius: 16,
                    child: Row(
                      children: [
                        FisioAvatar(widget.nomePaciente, size: 40, radius: 13),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.nomePaciente,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: FisioCores.textPrimary)),
                              Text(widget.contexto,
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: FisioCores.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const FisioSectionLabel('Relato da sessão'),
                      GestureDetector(
                        onTap: _alternarDitado,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _ouvindo
                                ? FisioCores.primary
                                : FisioCores.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_ouvindo ? Icons.stop_rounded : Icons.mic_rounded,
                                  size: 15,
                                  color: _ouvindo ? Colors.white : FisioCores.primary),
                              const SizedBox(width: 6),
                              Text(_ouvindo ? 'Parar' : 'Ditar',
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: _ouvindo
                                          ? Colors.white
                                          : FisioCores.primary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Container(
                    decoration: BoxDecoration(
                      color: FisioCores.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _ouvindo
                              ? FisioCores.primary
                              : const Color(0xFFEBF0F3)),
                      boxShadow: _ouvindo
                          ? [
                              BoxShadow(
                                  color: FisioCores.primary.withValues(alpha: 0.12),
                                  blurRadius: 0,
                                  spreadRadius: 3)
                            ]
                          : null,
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _controller,
                          maxLines: 5,
                          minLines: 5,
                          style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF475569)),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText:
                                'Descreva a evolução, condutas e resposta do paciente…',
                            hintStyle: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: FisioCores.textMuted),
                          ),
                        ),
                        if (_ouvindo)
                          Row(
                            children: const [
                              _Onda(14),
                              _Onda(22),
                              _Onda(10),
                              _Onda(18),
                              _Onda(8),
                              SizedBox(width: 6),
                              Text('Ouvindo…',
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: FisioCores.primary)),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const FisioSectionLabel('Dor ao final'),
                  const SizedBox(height: 4),
                  FisioPainSlider(
                    valor: _dor,
                    legendaEsq: '0',
                    legendaDir: '10',
                    onChanged: (v) => setState(() => _dor = v),
                  ),
                  const SizedBox(height: 22),
                  FisioPrimaryButton('Salvar evolução',
                      onTap: () => Navigator.of(context).maybePop()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dataCurta(DateTime d) {
    const meses = ['jan','fev','mar','abr','mai','jun','jul','ago','set','out','nov','dez'];
    return '${d.day} ${meses[d.month - 1]} ${d.year}';
  }
}

class _Onda extends StatelessWidget {
  final double altura;
  const _Onda(this.altura);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: altura,
      margin: const EdgeInsets.only(right: 4, top: 12),
      decoration: BoxDecoration(
        color: FisioCores.primary,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
