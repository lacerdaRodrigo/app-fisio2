import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../componentes/design_system.dart';
import '../modelos/agendamento.dart';
import '../provedores/provedores_dados.dart';
import '../utilitarios/utilitarios_data.dart';

class TelaEditarSessao extends ConsumerStatefulWidget {
  final Agendamento agendamento;
  final String nomePaciente;

  const TelaEditarSessao({
    super.key,
    required this.agendamento,
    required this.nomePaciente,
  });

  @override
  ConsumerState<TelaEditarSessao> createState() => _TelaEditarSessaoState();
}

class _TelaEditarSessaoState extends ConsumerState<TelaEditarSessao> {
  late final TextEditingController _valorController;
  late final TextEditingController _observacoesController;
  late DateTime _dataSelecionada;
  late TimeOfDay _horaInicio;
  late TimeOfDay _horaFim;
  String? _mensagemErroData;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final a = widget.agendamento;
    _valorController = TextEditingController(
      text: a.valorSessao.toStringAsFixed(2).replaceAll('.', ','),
    );
    _observacoesController = TextEditingController(text: a.observacoes ?? '');
    _dataSelecionada = a.data;
    _horaInicio = _parseTimeOfDay(a.horaInicio);
    _horaFim = _parseTimeOfDay(a.horaFim);
  }

  @override
  void dispose() {
    _valorController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTimeOfDay(String hora) {
    final partes = hora.split(':');
    return TimeOfDay(
      hour: int.tryParse(partes.first) ?? 0,
      minute: partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0,
    );
  }

  String _formatarHora(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FisioGradientHeader(
            padding: const EdgeInsets.fromLTRB(18, 50, 18, 22),
            titulo: 'Editar Sessão',
            subtitulo: widget.nomePaciente,
            leading: FisioHeaderIconButton(Icons.chevron_left_rounded,
                key: const Key('btn_fechar'),
                onTap: () => Navigator.pop(context)),
          ),
          Expanded(
            child: FisioResponsiveCenter(
              maxWidth: 560,
              child: AbsorbPointer(
                absorbing: _salvando,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  children: [
                    // Paciente (travado)
                    TextFormField(
                      key: const Key('campo_paciente'),
                      enabled: false,
                      initialValue: widget.nomePaciente,
                      decoration: const InputDecoration(
                        labelText: 'Paciente',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        suffixIcon: Icon(Icons.lock_outline),
                        helperText: 'Campo não editável',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Data
                    InkWell(
                      key: const Key('campo_data'),
                      borderRadius: BorderRadius.circular(12),
                      onTap: _selecionarData,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Data do Atendimento *',
                          prefixIcon: const Icon(Icons.calendar_today_rounded),
                          errorText: _mensagemErroData,
                        ),
                        child: Text(
                          UtilitariosData.formatarDataBr(_dataSelecionada),
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hora Início
                    InkWell(
                      key: const Key('campo_hora_inicio'),
                      borderRadius: BorderRadius.circular(12),
                      onTap: _selecionarHoraInicio,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Horário de Início *',
                          prefixIcon: Icon(Icons.access_time_rounded),
                        ),
                        child: Text(
                          _formatarHora(_horaInicio),
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hora Fim
                    InkWell(
                      key: const Key('campo_hora_fim'),
                      borderRadius: BorderRadius.circular(12),
                      onTap: _selecionarHoraFim,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Horário de Término *',
                          prefixIcon: Icon(Icons.access_time_filled_rounded),
                        ),
                        child: Text(
                          _formatarHora(_horaFim),
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Valor
                    TextFormField(
                      key: const Key('campo_valor'),
                      controller: _valorController,
                      decoration: const InputDecoration(
                        labelText: 'Valor da Sessão (R\$) *',
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
                      key: const Key('campo_observacoes'),
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
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  key: const Key('btn_salvar_edicao'),
                  onPressed: _salvando ? null : _salvarAlteracoes,
                  icon: _salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _salvando ? 'Salvando...' : 'Salvar Alterações',
                  ),
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
      initialDate: _dataSelecionada,
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

  Future<void> _selecionarHoraInicio() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaInicio,
    );
    if (hora != null) {
      setState(() => _horaInicio = hora);
    }
  }

  Future<void> _selecionarHoraFim() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaFim,
    );
    if (hora != null) {
      setState(() => _horaFim = hora);
    }
  }

  Future<void> _salvarAlteracoes() async {
    // Validar valor obrigatório
    final valorTexto = _valorController.text.trim();
    if (valorTexto.isEmpty) {
      _mostrarDialogCamposFaltando(['Valor da Sessão']);
      return;
    }

    // Validação de horário retroativo
    final dataHoraSelecionada = DateTime(
      _dataSelecionada.year,
      _dataSelecionada.month,
      _dataSelecionada.day,
      _horaInicio.hour,
      _horaInicio.minute,
    );

    if (UtilitariosData.ehDataRetroativa(dataHoraSelecionada)) {
      setState(
        () => _mensagemErroData = 'Selecione uma data e horário futuros.',
      );
      return;
    }

    setState(() => _salvando = true);

    final original = widget.agendamento;
    final valor = double.tryParse(
          valorTexto.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;

    final atualizado = Agendamento(
      idAgendamento: original.idAgendamento,
      idPaciente: original.idPaciente,
      data: DateTime(
        _dataSelecionada.year,
        _dataSelecionada.month,
        _dataSelecionada.day,
      ),
      horaInicio: _formatarHora(_horaInicio),
      horaFim: _formatarHora(_horaFim),
      valorSessao: valor,
      observacoes: _observacoesController.text.trim().isEmpty
          ? null
          : _observacoesController.text.trim(),
      situacao: original.situacao,
      dataCriacao: original.dataCriacao,
    );

    try {
      await atualizarAgendamentoReal(ref, atualizado);
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sessão atualizada com sucesso!'),
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

  void _mostrarDialogCamposFaltando(List<String> campos) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Campos obrigatórios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verifique os seguintes campos:'),
            const SizedBox(height: 12),
            ...campos.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(c),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
