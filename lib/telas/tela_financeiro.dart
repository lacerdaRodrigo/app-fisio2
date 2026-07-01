import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../componentes/design_system.dart';
import '../modelos/agendamento.dart';
import '../provedores/provedores_dados.dart';
import '../utilitarios/utilitarios_data.dart';

enum VisualizacaoFinanceiro { lista, porPaciente }

class TelaFinanceiro extends ConsumerStatefulWidget {
  const TelaFinanceiro({super.key});

  @override
  ConsumerState<TelaFinanceiro> createState() => _TelaFinanceiroState();
}

class _TelaFinanceiroState extends ConsumerState<TelaFinanceiro> {
  late DateTime _mesSelecionado;
  VisualizacaoFinanceiro _visualizacao = VisualizacaoFinanceiro.lista;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _mesSelecionado = DateTime(agora.year, agora.month);
  }

  void _mudarMes(int delta) {
    setState(() {
      _mesSelecionado =
          DateTime(_mesSelecionado.year, _mesSelecionado.month + delta);
    });
  }

  double _faturadoDoMes(List<Agendamento> ags, DateTime mes) => ags
      .where((a) => a.foiRealizado && UtilitariosData.mesmoMesAno(a.data, mes))
      .fold(0.0, (s, a) => s + a.valorSessao);

  List<DateTime> _ultimosSeisMeses() => List.generate(
        6,
        (i) => DateTime(_mesSelecionado.year, _mesSelecionado.month - (5 - i)),
      );

  @override
  Widget build(BuildContext context) {
    final agendamentos = ref.watch(provedorListaAgendamentos);
    final pacientes = ref.watch(provedorListaPacientes);

    final sessoesDoMes = agendamentos
        .where((a) =>
            UtilitariosData.mesmoMesAno(a.data, _mesSelecionado) &&
            (a.foiRealizado || a.estaAgendado))
        .toList()
      ..sort((a, b) => b.data.compareTo(a.data));

    final faturado = _faturadoDoMes(agendamentos, _mesSelecionado);
    final previsto = agendamentos
        .where((a) =>
            a.estaAgendado &&
            UtilitariosData.mesmoMesAno(a.data, _mesSelecionado))
        .fold(0.0, (s, a) => s + a.valorSessao);
    final realizadasLista = agendamentos
        .where((a) =>
            a.foiRealizado &&
            UtilitariosData.mesmoMesAno(a.data, _mesSelecionado))
        .toList();
    final realizadas = realizadasLista.length;
    final agendadas = agendamentos
        .where((a) =>
            a.estaAgendado &&
            UtilitariosData.mesmoMesAno(a.data, _mesSelecionado))
        .length;
    final ticketMedio = realizadas > 0 ? faturado / realizadas : 0.0;

    final mesesGrafico = _ultimosSeisMeses();
    final faturadoPorMes = {
      for (final m in mesesGrafico) m: _faturadoDoMes(agendamentos, m),
    };

    final mesAnterior =
        DateTime(_mesSelecionado.year, _mesSelecionado.month - 1);
    final faturadoAnterior = _faturadoDoMes(agendamentos, mesAnterior);
    final mapaPacientes = {for (final p in pacientes) p.idPaciente: p.nome};

    return Material(
      color: FisioCores.surface,
      child: FisioResponsiveCenter(
        maxWidth: 620,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(faturado, faturadoAnterior),
              Transform.translate(
                offset: const Offset(0, -52),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _tiles(previsto, agendadas, realizadas, ticketMedio),
                      const SizedBox(height: 12),
                      _cardGrafico(mesesGrafico, faturadoPorMes),
                      const SizedBox(height: 16),
                      _seletorVisualizacao(),
                      const SizedBox(height: 14),
                      if (sessoesDoMes.isEmpty)
                        const _EstadoVazio()
                      else if (_visualizacao == VisualizacaoFinanceiro.lista)
                        ...sessoesDoMes.map((s) =>
                            _cardSessao(s, mapaPacientes[s.idPaciente] ?? 'Paciente'))
                      else
                        ..._gruposPorPaciente(sessoesDoMes, mapaPacientes),
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

  Widget _header(double faturado, double faturadoAnterior) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 58, 22, 78),
      decoration: const BoxDecoration(
        gradient: FisioGradients.header,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Color(0xFFEAF1F0), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VISÃO GERAL',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.4,
                            color: Colors.white.withValues(alpha: 0.66))),
                    const Text('Financeiro',
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4)),
                  ],
                ),
              ),
              _navMes(Icons.chevron_left_rounded, () => _mudarMes(-1)),
              const SizedBox(width: 6),
              Container(
                constraints: const BoxConstraints(minWidth: 86),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                ),
                child: Text(
                  UtilitariosData.formatarMesAno(_mesSelecionado),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
              const SizedBox(width: 6),
              _navMes(Icons.chevron_right_rounded, () => _mudarMes(1)),
            ],
          ),
          const SizedBox(height: 26),
          _hero(faturado, faturadoAnterior),
        ],
      ),
    );
  }

  Widget _navMes(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _hero(double faturado, double faturadoAnterior) {
    Widget delta;
    if (faturadoAnterior > 0) {
      final pct = ((faturado - faturadoAnterior) / faturadoAnterior) * 100;
      final up = pct >= 0;
      delta = Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: (up ? FisioCores.secondary : FisioCores.danger)
              .withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '${up ? '↑' : '↓'} ${pct.abs().toStringAsFixed(0)}% vs mês anterior',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: up ? const Color(0xFFC8EBDD) : const Color(0xFFF4CDD0)),
        ),
      );
    } else {
      delta = Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text('novo período',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEAF1F0))),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Faturado no mês',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.72))),
            const SizedBox(width: 10),
            Flexible(child: delta),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('R\$ ',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.82))),
            Text(
              _formatarNumero(faturado),
              style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.2,
                  height: 1,
                  fontFeatures: [FontFeature.tabularFigures()]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tiles(double previsto, int agendadas, int realizadas, double ticket) {
    return Row(
      children: [
        Expanded(
          child: _tile(
            icone: Icons.schedule_rounded,
            cor: FisioCores.info,
            titulo: 'Previsto',
            valor: _formatarValor(previsto),
            sub: '$agendadas sessões agendadas',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _tile(
            icone: Icons.check_rounded,
            cor: FisioCores.success,
            titulo: 'Realizadas',
            valor: '$realizadas',
            sub: 'ticket médio ${_formatarValor(ticket)}',
          ),
        ),
      ],
    );
  }

  Widget _tile({
    required IconData icone,
    required Color cor,
    required String titulo,
    required String valor,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FisioCores.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EEF2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(icone, color: cor, size: 17),
              ),
              const SizedBox(width: 8),
              Text(titulo,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: FisioCores.textSecondary)),
            ],
          ),
          const SizedBox(height: 11),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(valor,
                style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: FisioCores.textPrimary,
                    letterSpacing: -0.5,
                    fontFeatures: [FontFeature.tabularFigures()])),
          ),
          const SizedBox(height: 2),
          Text(sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: FisioCores.textMuted)),
        ],
      ),
    );
  }

  Widget _cardGrafico(
      List<DateTime> meses, Map<DateTime, double> faturadoPorMes) {
    final valores = meses.map((m) => faturadoPorMes[m] ?? 0).toList();
    final maxV = valores.fold<double>(0, (a, b) => b > a ? b : a);
    final media = valores.isEmpty
        ? 0.0
        : valores.fold<double>(0, (a, b) => a + b) / valores.length;
    const alturaArea = 150.0;
    const alturaMaxBarra = 96.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: FisioCores.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EEF2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 28,
              offset: const Offset(0, 14)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Faturamento por mês',
                      style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: FisioCores.textPrimary)),
                  SizedBox(height: 1),
                  Text('Últimos 6 meses',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: FisioCores.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: FisioCores.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: FisioCores.secondary, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text('média ${_formatarValor(media)}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: FisioCores.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: alturaArea,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < meses.length; i++)
                  Expanded(
                    child: _barra(
                      mes: meses[i],
                      valor: faturadoPorMes[meses[i]] ?? 0,
                      altura: maxV > 0
                          ? (((faturadoPorMes[meses[i]] ?? 0) / maxV) *
                                  alturaMaxBarra)
                              .clamp(8.0, alturaMaxBarra)
                          : 8.0,
                      selecionado:
                          UtilitariosData.mesmoMesAno(meses[i], _mesSelecionado),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _barra({
    required DateTime mes,
    required double valor,
    required double altura,
    required bool selecionado,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _mesSelecionado = DateTime(mes.year, mes.month)),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            _formatarCurto(valor),
            style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: selecionado ? FisioCores.primary : const Color(0xFFB6C2CC),
                fontFeatures: const [FontFeature.tabularFigures()]),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            width: 24,
            height: altura,
            decoration: BoxDecoration(
              gradient: selecionado
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [FisioCores.secondary, Color(0xFF5E9D8B)],
                    )
                  : null,
              color: selecionado ? null : const Color(0xFFDDE6EC),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(9), bottom: Radius.circular(5)),
              boxShadow: selecionado
                  ? [
                      BoxShadow(
                          color: FisioCores.secondary.withValues(alpha: 0.5),
                          blurRadius: 14,
                          offset: const Offset(0, 8))
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            UtilitariosData.formatarMesAno(mes).split(' ').first,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selecionado ? FisioCores.primary : FisioCores.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _seletorVisualizacao() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: const Color(0xFFE8EEF2), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(child: _botaoSeletor('Lista', VisualizacaoFinanceiro.lista)),
          Expanded(
              child: _botaoSeletor('Por paciente', VisualizacaoFinanceiro.porPaciente)),
        ],
      ),
    );
  }

  Widget _botaoSeletor(String label, VisualizacaoFinanceiro v) {
    final sel = _visualizacao == v;
    return GestureDetector(
      onTap: () => setState(() => _visualizacao = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: sel ? FisioCores.card : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: sel
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: sel ? FisioCores.primary : FisioCores.textSecondary)),
      ),
    );
  }

  Widget _cardSessao(Agendamento sessao, String nome) {
    final cor = sessao.foiRealizado ? FisioCores.success : FisioCores.info;
    final status = sessao.foiRealizado ? 'Realizado' : 'Agendado';
    final corAvatar = fisioAvatarColor(nome);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: FisioCores.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEBF0F3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: corAvatar.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: Text(fisioIniciais(nome),
                  style: TextStyle(
                      color: corAvatar, fontWeight: FontWeight.w800, fontSize: 14)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: FisioCores.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    '${UtilitariosData.formatarDataBr(sessao.data)} · ${sessao.horaInicio}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: FisioCores.textMuted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatarValor(sessao.valorSessao),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: FisioCores.textPrimary,
                        fontFeatures: [FontFeature.tabularFigures()])),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                      color: cor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text(status,
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700, color: cor)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _gruposPorPaciente(
      List<Agendamento> sessoes, Map<String, String> mapaPacientes) {
    final grupos = <String, List<Agendamento>>{};
    for (final s in sessoes) {
      grupos.putIfAbsent(s.idPaciente, () => []).add(s);
    }
    final ids = grupos.keys.toList()
      ..sort((a, b) => (mapaPacientes[a] ?? a).compareTo(mapaPacientes[b] ?? b));

    return ids.map((id) {
      final arr = grupos[id]!;
      final nome = mapaPacientes[id] ?? 'Paciente';
      final cor = fisioAvatarColor(nome);
      final realizadas = arr.where((s) => s.foiRealizado).length;
      final agendadas = arr.where((s) => s.estaAgendado).length;
      final total = arr.fold(0.0, (s, a) => s + a.valorSessao);
      final pct = arr.isEmpty ? 0 : ((realizadas / arr.length) * 100).round();

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
          decoration: BoxDecoration(
            color: FisioCores.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEBF0F3)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                        color: cor.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(15)),
                    alignment: Alignment.center,
                    child: Text(fisioIniciais(nome),
                        style: TextStyle(
                            color: cor, fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: FisioCores.textPrimary)),
                        const SizedBox(height: 2),
                        Text('$realizadas realizadas · $agendadas agendadas',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: FisioCores.textMuted)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_formatarValor(total),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: FisioCores.primary,
                              fontFeatures: [FontFeature.tabularFigures()])),
                      const Text('total',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: FisioCores.textMuted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 13),
              const Divider(height: 1, color: Color(0xFFEEF2F5)),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        minHeight: 7,
                        backgroundColor: const Color(0xFFEEF2F5),
                        valueColor:
                            const AlwaysStoppedAnimation(FisioCores.success),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$pct% concluído',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: FisioCores.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _formatarValor(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  String _formatarNumero(double valor) =>
      valor.toStringAsFixed(2).replaceAll('.', ',');

  String _formatarCurto(double valor) {
    if (valor >= 1000) {
      return '${(valor / 1000).toStringAsFixed(1).replaceAll('.', ',')}k';
    }
    return valor.toStringAsFixed(0);
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Text('Nenhuma sessão neste mês.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: FisioCores.textSecondary)),
        ],
      ),
    );
  }
}
