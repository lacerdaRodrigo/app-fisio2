import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos/agendamento.dart';
import '../modelos/paciente.dart';
import '../telas/tela_registro_evolucao.dart';
import '../provedores/provedores_dados.dart';
import '../componentes/design_system.dart';

enum AcaoAgendamento {
  registrarEvolucao,
  faltouComAviso,
  faltouSemAviso,
  canceladoPaciente,
  canceladoProfissional,
}

Future<void> executarAcaoAgendamento(
  BuildContext context,
  WidgetRef ref,
  AcaoAgendamento acao,
  Agendamento agendamento,
  Paciente? paciente,
) async {
  if (acao == AcaoAgendamento.registrarEvolucao) {
    if (paciente == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaRegistroEvolucao(
          paciente: paciente,
          agendamento: agendamento,
        ),
      ),
    );
    return;
  }

  final situacao = switch (acao) {
    AcaoAgendamento.faltouComAviso => Agendamento.situacaoFaltouComAviso,
    AcaoAgendamento.faltouSemAviso => Agendamento.situacaoFaltouSemAviso,
    AcaoAgendamento.canceladoPaciente =>
      Agendamento.situacaoCanceladoPaciente,
    AcaoAgendamento.canceladoProfissional =>
      Agendamento.situacaoCanceladoProfissional,
    AcaoAgendamento.registrarEvolucao => Agendamento.situacaoAgendado,
  };

  final confirmou = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Atualizar sessão?'),
      content: Text('Marcar esta sessão como "$situacao"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );

  if (confirmou != true || !context.mounted) return;

  try {
    await atualizarSituacaoAgendamentoReal(
      ref,
      agendamento.idAgendamento,
      situacao,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sessão atualizada para $situacao.')),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ocorreu um erro inesperado. Tente novamente.'),
        backgroundColor: FisioCores.danger,
      ),
    );
  }
}
