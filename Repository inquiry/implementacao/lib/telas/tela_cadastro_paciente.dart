import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../componentes/design_system_fisio.dart';

/// Tela Cadastro de Paciente — fluxo em 3 passos (a tela abaixo mostra o passo
/// 2, Anamnese). Serve também para Editar Paciente.
class TelaCadastroPaciente extends ConsumerStatefulWidget {
  const TelaCadastroPaciente({super.key});

  @override
  ConsumerState<TelaCadastroPaciente> createState() =>
      _TelaCadastroPacienteState();
}

class _TelaCadastroPacienteState extends ConsumerState<TelaCadastroPaciente> {
  final _nome = TextEditingController();
  final _nascimento = TextEditingController();
  final _telefone = TextEditingController();
  final _queixa = TextEditingController();
  int _dor = 7;
  final int _passo = 2; // demonstra a etapa de anamnese

  @override
  void dispose() {
    _nome.dispose();
    _nascimento.dispose();
    _telefone.dispose();
    _queixa.dispose();
    super.dispose();
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
              titulo: 'Novo paciente',
              subtitulo: 'Passo $_passo de 3 · Anamnese',
              leading: FisioHeaderIconButton(Icons.chevron_left_rounded,
                  onTap: () => Navigator.of(context).maybePop()),
              bottom: Row(
                children: List.generate(3, (i) {
                  final feito = i < _passo;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: feito ? 0.85 : 0.3),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
                children: [
                  const FisioSectionLabel('Dados pessoais'),
                  const SizedBox(height: 10),
                  _campo(_nome, 'Nome completo'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _campo(_nascimento, 'Nascimento')),
                      const SizedBox(width: 10),
                      Expanded(child: _campo(_telefone, 'Telefone')),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const FisioSectionLabel('Queixa principal'),
                  const SizedBox(height: 10),
                  _campo(_queixa, 'Descreva a queixa do paciente…',
                      linhas: 3),
                  const SizedBox(height: 18),
                  const FisioSectionLabel('Escala de dor inicial'),
                  const SizedBox(height: 4),
                  FisioPainSlider(
                    valor: _dor,
                    onChanged: (v) => setState(() => _dor = v),
                  ),
                  const SizedBox(height: 22),
                  FisioPrimaryButton('Continuar',
                      onTap: () => Navigator.of(context).maybePop()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(TextEditingController c, String label, {int linhas = 1}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 12),
      decoration: BoxDecoration(
        color: FisioCores.card,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFEBF0F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: FisioCores.textMuted)),
          TextField(
            controller: c,
            minLines: linhas,
            maxLines: linhas,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: FisioCores.textPrimary,
                height: 1.4),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 2),
            ),
          ),
        ],
      ),
    );
  }
}
