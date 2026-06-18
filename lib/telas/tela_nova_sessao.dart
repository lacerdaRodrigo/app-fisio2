import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../componentes/design_system.dart';
import '../modelos/agendamento.dart';
import '../provedores/provedores_dados.dart';
import '../utilitarios/gerador_id.dart';
import '../utilitarios/utilitarios_data.dart';

class TelaNovaSessao extends ConsumerStatefulWidget {
  const TelaNovaSessao({super.key});

  @override
  ConsumerState<TelaNovaSessao> createState() => _TelaNovaSessaoState();
}

class _TelaNovaSessaoState extends ConsumerState<TelaNovaSessao> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _observacoesController = TextEditingController();
  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;
  String? _pacienteSelecionado;
  String? _mensagemErroData;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _valorController.text = ref.read(provedorValorSessaoPadrao);
  }

  @override
  void dispose() {
    _valorController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pacientesAtivos = ref
        .watch(provedorListaPacientes)
        .where((paciente) => paciente.estaAtivo)
        .toList();

    return Scaffold(
      body: Column(
        children: [
          FisioPageHeader(
            title: 'Nova Sessão',
            subtitle: 'Agende um atendimento domiciliar',
            onBack: () => Navigator.pop(context),
            closeIcon: true,
          ),
          Expanded(
            child: Form(
              key: _chaveFormulario,
              child: FisioResponsiveCenter(
                maxWidth: 560,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
                  children: [
                    // Seleção de Paciente
                    DropdownButtonFormField<String>(
                      initialValue: _pacienteSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Paciente *',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      items: [
                        for (final paciente in pacientesAtivos)
                          DropdownMenuItem(
                            value: paciente.idPaciente,
                            child: Text(paciente.nome),
                          ),
                      ],
                      onChanged: (v) =>
                          setState(() => _pacienteSelecionado = v),
                      validator: (v) =>
                          v == null ? 'Selecione um paciente.' : null,
                    ),
                    if (pacientesAtivos.isEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Cadastre um paciente ativo antes de criar uma sessão.',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Data
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _selecionarData,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Data do Atendimento *',
                          prefixIcon: const Icon(Icons.calendar_today_rounded),
                          errorText: _mensagemErroData,
                        ),
                        child: Text(
                          _dataSelecionada != null
                              ? UtilitariosData.formatarDataBr(
                                  _dataSelecionada!,
                                )
                              : 'Selecionar data',
                          style: TextStyle(
                            color: _dataSelecionada != null
                                ? Colors.black87
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hora
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _selecionarHora,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Horário de Início *',
                          prefixIcon: Icon(Icons.access_time_rounded),
                        ),
                        child: Text(
                          _horaSelecionada != null
                              ? '${_horaSelecionada!.hour.toString().padLeft(2, '0')}:${_horaSelecionada!.minute.toString().padLeft(2, '0')}'
                              : 'Selecionar horário',
                          style: TextStyle(
                            color: _horaSelecionada != null
                                ? Colors.black87
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Valor
                    TextFormField(
                      controller: _valorController,
                      decoration: const InputDecoration(
                        labelText: 'Valor da Sessão (R\$)',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                        hintText: '150,00',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Observações
                    TextFormField(
                      controller: _observacoesController,
                      decoration: const InputDecoration(
                        labelText: 'Observações',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                        hintText: 'Levar eletroestimulador, etc...',
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 32),

                    // Botão Agendar
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _salvando ? null : _agendarSessao,
                        icon: _salvando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.event_available_rounded),
                        label: Text(
                          _salvando ? 'Agendando...' : 'Agendar Sessão',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );
    if (data != null) {
      setState(() {
        _dataSelecionada = data;
        _mensagemErroData = null;
      });
    }
  }

  Future<void> _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() => _horaSelecionada = hora);
    }
  }

  Future<void> _agendarSessao() async {
    if (!_chaveFormulario.currentState!.validate()) return;
    if (_dataSelecionada == null || _horaSelecionada == null) return;

    // Validação de horário retroativo
    final dataHoraSelecionada = DateTime(
      _dataSelecionada!.year,
      _dataSelecionada!.month,
      _dataSelecionada!.day,
      _horaSelecionada!.hour,
      _horaSelecionada!.minute,
    );

    if (UtilitariosData.ehDataRetroativa(dataHoraSelecionada)) {
      setState(
        () => _mensagemErroData = 'Selecione uma data e horário futuros.',
      );
      return;
    }

    setState(() => _salvando = true);

    final agendamentos = ref.read(provedorListaAgendamentos);
    final valor =
        double.tryParse(
          _valorController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;
    final horaFim = dataHoraSelecionada.add(const Duration(hours: 1));
    final novoAgendamento = Agendamento(
      idAgendamento: GeradorId.proximo(
        'A',
        agendamentos.map((a) => a.idAgendamento),
      ),
      idPaciente: _pacienteSelecionado!,
      data: DateTime(
        dataHoraSelecionada.year,
        dataHoraSelecionada.month,
        dataHoraSelecionada.day,
      ),
      horaInicio:
          '${_horaSelecionada!.hour.toString().padLeft(2, '0')}:${_horaSelecionada!.minute.toString().padLeft(2, '0')}',
      horaFim:
          '${horaFim.hour.toString().padLeft(2, '0')}:${horaFim.minute.toString().padLeft(2, '0')}',
      valorSessao: valor,
      observacoes: _observacoesController.text.trim(),
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
}
