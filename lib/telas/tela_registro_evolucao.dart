import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../modelos/agendamento.dart';
import '../modelos/evolucao.dart';
import '../modelos/paciente.dart';
import '../provedores/provedores_dados.dart';
import '../utilitarios/utilitarios_data.dart';

class TelaRegistroEvolucao extends ConsumerStatefulWidget {
  final Paciente paciente;
  final Agendamento? agendamento;

  const TelaRegistroEvolucao({
    super.key,
    required this.paciente,
    this.agendamento,
  });

  @override
  ConsumerState<TelaRegistroEvolucao> createState() =>
      _TelaRegistroEvolucaoState();
}

class _TelaRegistroEvolucaoState extends ConsumerState<TelaRegistroEvolucao> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _evolucaoController = TextEditingController();
  final _speech = stt.SpeechToText();
  bool _ouvindo = false;
  bool _salvando = false;

  @override
  void dispose() {
    _evolucaoController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataAtendimento = widget.agendamento?.data ?? DateTime.now();
    final horario = widget.agendamento?.horaInicio;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Evolução')),
      body: Form(
        key: _chaveFormulario,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.paciente.nome,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${UtilitariosData.formatarDataBr(dataAtendimento)}${horario != null ? ' às $horario' : ''}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _evolucaoController,
              decoration: InputDecoration(
                labelText: 'Evolução técnica *',
                hintText:
                    'Descreva exercícios, resposta do paciente e orientações...',
                alignLabelWithHint: true,
                suffixIcon: IconButton(
                  onPressed: _alternarMicrofone,
                  tooltip: _ouvindo
                      ? 'Parar transcrição'
                      : 'Transcrever por voz',
                  icon: Icon(
                    _ouvindo ? Icons.mic_rounded : Icons.mic_none_rounded,
                  ),
                  color: _ouvindo ? Colors.red : theme.colorScheme.primary,
                ),
              ),
              minLines: 8,
              maxLines: 14,
              textCapitalization: TextCapitalization.sentences,
              validator: (valor) => valor == null || valor.trim().isEmpty
                  ? 'Informe a evolução clínica.'
                  : null,
            ),
            if (_ouvindo) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.red.shade400,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ouvindo...',
                    style: TextStyle(color: Colors.red.shade400),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _salvando ? null : _salvarEvolucao,
                icon: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(_salvando ? 'Salvando...' : 'Salvar Evolução'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _alternarMicrofone() async {
    if (_ouvindo) {
      await _speech.stop();
      if (mounted) {
        setState(() => _ouvindo = false);
      }
      return;
    }

    final disponivel = await _speech.initialize();
    if (!mounted) {
      return;
    }

    if (!disponivel) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Permissão de microfone necessária para transcrição por voz.',
          ),
        ),
      );
      return;
    }

    setState(() => _ouvindo = true);
    await _speech.listen(
      listenOptions: stt.SpeechListenOptions(localeId: 'pt_BR'),
      onResult: (resultado) {
        if (!resultado.finalResult ||
            resultado.recognizedWords.trim().isEmpty) {
          return;
        }

        final atual = _evolucaoController.text.trim();
        final texto = resultado.recognizedWords.trim();
        _evolucaoController.text = [
          atual,
          texto,
        ].where((parte) => parte.isNotEmpty).join(' ');
        _evolucaoController.selection = TextSelection.collapsed(
          offset: _evolucaoController.text.length,
        );
      },
    );
  }

  Future<void> _salvarEvolucao() async {
    if (!_chaveFormulario.currentState!.validate()) return;

    setState(() => _salvando = true);

    final evolucoes = ref.read(provedorListaEvolucoes);
    final novaEvolucao = Evolucao(
      idEvolucao: 'E${(evolucoes.length + 1).toString().padLeft(3, '0')}',
      idPaciente: widget.paciente.idPaciente,
      idAgendamento:
          widget.agendamento?.idAgendamento ??
          'AVULSA-${DateTime.now().millisecondsSinceEpoch}',
      dataAtendimento: widget.agendamento?.data ?? DateTime.now(),
      evolucaoTexto: _evolucaoController.text.trim(),
    );

    try {
      await salvarEvolucaoReal(ref, novaEvolucao);
      if (widget.agendamento != null) {
        await marcarAgendamentoRealizadoReal(
          ref,
          widget.agendamento!.idAgendamento,
        );
      }

      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evolução salva com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao salvar evolução: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
