import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../componentes/design_system_fisio.dart';
import '../modelos/paciente.dart';
import '../provedores/provedores_dados.dart';
import '../utilitarios/utilitarios_data.dart';

/// Tela Nova Sessão (também serve para Editar — passe [agendamentoExistente]).
class TelaNovaSessao extends ConsumerStatefulWidget {
  final Paciente? pacientePre;
  const TelaNovaSessao({super.key, this.pacientePre});

  @override
  ConsumerState<TelaNovaSessao> createState() => _TelaNovaSessaoState();
}

class _TelaNovaSessaoState extends ConsumerState<TelaNovaSessao> {
  Paciente? _paciente;
  DateTime _data = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _hora = const TimeOfDay(hour: 9, minute: 0);
  bool _recorrente = true;

  @override
  void initState() {
    super.initState();
    _paciente = widget.pacientePre;
  }

  @override
  Widget build(BuildContext context) {
    final valor = _paciente?.valorSessao ?? 0;

    return ColoredBox(
      color: FisioCores.surface,
      child: FisioResponsiveCenter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FisioGradientHeader(
              padding: const EdgeInsets.fromLTRB(18, 50, 18, 22),
              titulo: 'Nova sessão',
              subtitulo: 'Agendar atendimento',
              leading: FisioHeaderIconButton(Icons.chevron_left_rounded,
                  onTap: () => Navigator.of(context).maybePop()),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
                children: [
                  const FisioSectionLabel('Paciente'),
                  const SizedBox(height: 9),
                  FisioCard(
                    padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                    radius: 16,
                    onTap: _selecionarPaciente,
                    child: Row(
                      children: [
                        if (_paciente != null)
                          FisioAvatar(_paciente!.nome, size: 42, radius: 13)
                        else
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(13)),
                            child: const Icon(Icons.person_add_alt_1_rounded,
                                color: FisioCores.textMuted, size: 20),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_paciente?.nome ?? 'Selecionar paciente',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: FisioCores.textPrimary)),
                              const Text('Toque para escolher',
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: FisioCores.textMuted)),
                            ],
                          ),
                        ),
                        const Icon(Icons.expand_more_rounded,
                            color: Color(0xFFCBD5E1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const FisioSectionLabel('Data e horário'),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        flex: 13,
                        child: _campoMini('Data',
                            UtilitariosData.formatarDataBr(_data), _escolherData),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 10,
                        child: _campoMini('Início', _hora.format(context),
                            _escolherHora),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const FisioSectionLabel('Valor da sessão'),
                  const SizedBox(height: 9),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4F8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          style: BorderStyle.solid),
                    ),
                    child: Row(
                      children: [
                        Text(
                            'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF475569),
                                fontFeatures: [FontFeature.tabularFigures()])),
                        const Spacer(),
                        const Icon(Icons.lock_outline_rounded,
                            size: 15, color: FisioCores.textMuted),
                        const SizedBox(width: 6),
                        const Text('do cadastro',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: FisioCores.textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  FisioCard(
                    padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                    radius: 14,
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Repetir semanalmente',
                                  style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: FisioCores.textPrimary)),
                              Text('Cria as próximas 4 sessões',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: FisioCores.textMuted)),
                            ],
                          ),
                        ),
                        Switch(
                          value: _recorrente,
                          activeColor: Colors.white,
                          activeTrackColor: FisioCores.primary,
                          onChanged: (v) => setState(() => _recorrente = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  FisioPrimaryButton('Agendar sessão', onTap: _salvar),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoMini(String label, String valor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: FisioCard(
        radius: 14,
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: FisioCores.textMuted)),
            const SizedBox(height: 2),
            Text(valor,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: FisioCores.textPrimary)),
          ],
        ),
      ),
    );
  }

  Future<void> _escolherData() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _data = d);
  }

  Future<void> _escolherHora() async {
    final t = await showTimePicker(context: context, initialTime: _hora);
    if (t != null) setState(() => _hora = t);
  }

  void _selecionarPaciente() {
    final pacientes = ref.read(provedorListaPacientes);
    showModalBottomSheet(
      context: context,
      backgroundColor: FisioCores.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: pacientes
            .map((p) => ListTile(
                  leading: FisioAvatar(p.nome, size: 40, radius: 12),
                  title: Text(p.nome,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () {
                    setState(() => _paciente = p);
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  void _salvar() {
    // TODO: integrar com o provider de criação de agendamento.
    Navigator.of(context).maybePop();
  }
}
