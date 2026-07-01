// =============================================================================
// Helpers de data usados pelas telas redesenhadas.
// COLE estes métodos dentro da sua classe UtilitariosData existente
// (lib/utilitarios/utilitarios_data.dart). Não crie uma segunda classe.
// =============================================================================

class UtilitariosDataAdicoes {
  static const List<String> _meses = [
    'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'
  ];
  static const List<String> _mesesLongos = [
    'janeiro','fevereiro','março','abril','maio','junho',
    'julho','agosto','setembro','outubro','novembro','dezembro'
  ];

  /// "Jun 2026"
  static String formatarMesAno(DateTime d) => '${_meses[d.month - 1]} ${d.year}';

  /// "30 de junho"
  static String formatarDataExtensa(DateTime d) =>
      '${d.day} de ${_mesesLongos[d.month - 1]}';

  /// "01/07/2026"
  static String formatarDataBr(DateTime d) =>
      '${_2(d.day)}/${_2(d.month)}/${d.year}';

  static bool mesmoMesAno(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static bool mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// "Hoje · 30 jun", "Amanhã · 1 jul" ou "Seg, 23 jun"
  static String rotuloDiaRelativo(DateTime d) {
    final hoje = DateTime.now();
    final dia = DateTime(d.year, d.month, d.day);
    final base = DateTime(hoje.year, hoje.month, hoje.day);
    final diff = dia.difference(base).inDays;
    final curto = '${d.day} ${_meses[d.month - 1].toLowerCase()}';
    if (diff == 0) return 'Hoje · $curto';
    if (diff == 1) return 'Amanhã · $curto';
    if (diff == -1) return 'Ontem · $curto';
    return curto;
  }

  static String _2(int n) => n.toString().padLeft(2, '0');
}
