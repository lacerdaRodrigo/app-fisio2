import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../componentes/design_system_fisio.dart';
import '../modelos/agendamento.dart';
import '../provedores/provedores_dados.dart';
import '../utilitarios/utilitarios_data.dart';

/// Tela Início / Dashboard.
/// Substitui lib/telas/tela_dashboard.dart (mantém o nome da classe que sua
/// navegação usa; ajuste se for diferente).
class TelaDashboard extends ConsumerWidget {
  final String nomeUsuario;
  final ValueChanged<int>? onNavegar; // troca de aba no shell
  final VoidCallback? onNovaSessao;

  const TelaDashboard({
    super.key,
    this.nomeUsuario = 'Fisioterapeuta',
    this.onNavegar,
    this.onNovaSessao,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendamentos = ref.watch(provedorListaAgendamentos);
    final pacientes = ref.watch(provedorListaPacientes);
    final hoje = DateTime.now();

    final doDia = agendamentos
        .where((a) => UtilitariosData.mesmoDia(a.data, hoje))
        .toList()
      ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

    final ativos = pacientes.where((p) => p.ativo).length;
    final pendencias = agendamentos
        .where((a) => a.estaAgendado && a.data.isBefore(hoje))
        .length;

    final saudacao = _saudacao(hoje.hour);
    final mapaPacientes = {for (final p in pacientes) p.idPaciente: p.nome};

    return ColoredBox(
      color: FisioCores.surface,
      child: FisioResponsiveCenter(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FisioGradientHeader(
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 30),
                eyebrow: saudacao,
                titulo: nomeUsuario,
                trailing: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Text(fisioIniciais(nomeUsuario),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                ),
                bottom: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Você tem hoje, ${UtilitariosData.formatarDataExtensa(hoje)}',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.78))),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('${doDia.length}',
                            style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1,
                                letterSpacing: -1)),
                        const SizedBox(width: 9),
                        Text(doDia.length == 1 ? 'sessão' : 'sessões',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.9))),
                      ],
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -38),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: FisioStatTile(
                              icone: Icons.people_alt_rounded,
                              cor: FisioCores.primary,
                              titulo: 'Pacientes ativos',
                              valor: '$ativos',
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: FisioStatTile(
                              icone: Icons.warning_amber_rounded,
                              cor: FisioCores.warning,
                              titulo: 'Pendências',
                              valor: '$pendencias',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Agenda de hoje',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: FisioCores.textPrimary)),
                          GestureDetector(
                            onTap: () => onNavegar?.call(1),
                            child: const Text('Ver tudo',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: FisioCores.primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (doDia.isEmpty)
                        const FisioEmptyState(
                          icone: Icons.event_available_rounded,
                          titulo: 'Nenhuma sessão hoje',
                          subtitulo: 'Aproveite para revisar evoluções.',
                        )
                      else
                        ...doDia.map((s) => _linhaAgenda(
                            s, mapaPacientes[s.idPaciente] ?? 'Paciente')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linhaAgenda(Agendamento s, String nome) {
    final cor = s.foiRealizado ? FisioCores.success : FisioCores.info;
    final status = s.foiRealizado ? 'Realizado' : 'Agendado';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FisioCard(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        child: Row(
          children: [
            SizedBox(
              width: 46,
              child: Column(
                children: [
                  Text(s.horaInicio,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: FisioCores.textPrimary,
                          fontFeatures: [FontFeature.tabularFigures()])),
                ],
              ),
            ),
            Container(
              width: 3,
              height: 34,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: cor, borderRadius: BorderRadius.circular(99)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: FisioCores.textPrimary)),
                  const SizedBox(height: 1),
                  Text(s.enderecoResumido ?? 'Atendimento domiciliar',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: FisioCores.textMuted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FisioStatusPill(label: status, cor: cor),
          ],
        ),
      ),
    );
  }

  String _saudacao(int hora) {
    if (hora < 12) return 'Bom dia,';
    if (hora < 18) return 'Boa tarde,';
    return 'Boa noite,';
  }
}
