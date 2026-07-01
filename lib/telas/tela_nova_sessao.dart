import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../componentes/design_system.dart';
import '../modelos/agendamento.dart';
import '../modelos/paciente.dart';
import '../provedores/provedores_dados.dart';
import '../utilitarios/gerador_id.dart';
import '../utilitarios/utilitarios_data.dart';

class TelaNovaSessao extends ConsumerStatefulWidget {
  const TelaNovaSessao({super.key});

  @override
  ConsumerState<TelaNovaSessao> createState() => _TelaNovaSessaoState();
}

class _TelaNovaSessaoState extends ConsumerState<TelaNovaSessao> {
  Paciente? _paciente;
  DateTime _data = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _hora = const TimeOfDay(hour: 9, minute: 0);
  final _valorController = TextEditingController();
  final _obsController = TextEditingController();
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _valorController.text = ref.read(provedorValorSessaoPadrao);
  }

  @override
  void dispose() {
    _valorController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  String _formatarHora(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _escolherData() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );
    if (d != null) setState(() => _data = d);
  }

  Future<void> _escolherHora() async {
    final t = await showTimePicker(context: context, initialTime: _hora);
    if (t != null) setState(() => _hora = t);
  }

  void _selecionarPaciente() {
    final pacientes = ref
        .read(provedorListaPacientes)
        .where((p) => p.estaAtivo)
        .toList();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: FisioCores.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Selecionar paciente',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ),
          ...pacientes.map((p) => ListTile(
                leading: FisioAvatar(p.nome, size: 40, radius: 12),
                title: Text(p.nome,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  setState(() => _paciente = p);
                  Navigator.pop(context);
                },
              )),
          if (pacientes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nenhum paciente ativo. Cadastre um paciente antes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: FisioCores.textMuted),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _agendarSessao() async {
    if (_paciente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um paciente.')),
      );
      return;
    }

    final dataHora = DateTime(
      _data.year,
      _data.month,
      _data.day,
      _hora.hour,
      _hora.minute,
    );

    if (UtilitariosData.ehDataRetroativa(dataHora)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecione uma data e horário futuros.')),
      );
      return;
    }

    setState(() => _salvando = true);

    final agendamentos = ref.read(provedorListaAgendamentos);
    final valor =
        double.tryParse(_valorController.text
                .replaceAll('.', '')
                .replaceAll(',', '.')) ??
            0;
    final horaFim = dataHora.add(const Duration(hours: 1));
    final novoAgendamento = Agendamento(
      idAgendamento: GeradorId.proximo(
        'A',
        agendamentos.map((a) => a.idAgendamento),
      ),
      idPaciente: _paciente!.idPaciente,
      data: DateTime(_data.year, _data.month, _data.day),
      horaInicio: _formatarHora(_hora),
      horaFim:
          '${horaFim.hour.toString().padLeft(2, '0')}:${horaFim.minute.toString().padLeft(2, '0')}',
      valorSessao: valor,
      observacoes: _obsController.text.trim(),
    );

    try {
      await salvarAgendamentoReal(ref, novoAgendamento);
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sessão agendada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocorreu um erro inesperado. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
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
                    key: const Key('btn_fechar'),
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
                              child: const Icon(
                                  Icons.person_add_alt_1_rounded,
                                  color: FisioCores.textMuted,
                                  size: 20),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    _paciente?.nome ??
                                        'Selecionar paciente',
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
                          child: _campoMini(
                              'Data',
                              UtilitariosData.formatarDataBr(_data),
                              _escolherData),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 10,
                          child: _campoMini(
                              'Início', _formatarHora(_hora), _escolherHora),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const FisioSectionLabel('Valor da sessão (R\$)'),
                    const SizedBox(height: 9),
                    FisioCard(
                      radius: 16,
                      padding:
                          const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_money_rounded,
                              color: FisioCores.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _valorController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: FisioCores.textPrimary),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: '150,00',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const FisioSectionLabel('Observações'),
                    const SizedBox(height: 9),
                    FisioCard(
                      radius: 16,
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: TextField(
                        controller: _obsController,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(
                            fontSize: 13.5, color: FisioCores.textPrimary),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Levar eletroestimulador, etc…',
                          hintStyle:
                              TextStyle(color: FisioCores.textMuted),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    FisioPrimaryButton(
                      _salvando ? 'Agendando…' : 'Agendar sessão',
                      onTap: _salvando ? null : _agendarSessao,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
}
