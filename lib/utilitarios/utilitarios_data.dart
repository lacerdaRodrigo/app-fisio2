/// Utilitários para cálculos e validações de data e hora.
class UtilitariosData {
  /// Calcula a idade em anos a partir de uma data de nascimento.
  static int calcularIdade(
    DateTime dataNascimento, {
    DateTime? dataReferencia,
  }) {
    final hoje = dataReferencia ?? DateTime.now();
    int idade = hoje.year - dataNascimento.year;
    if (hoje.month < dataNascimento.month ||
        (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) {
      idade--;
    }
    return idade;
  }

  /// Verifica se uma data/hora selecionada está no passado (é retroativa).
  static bool ehDataRetroativa(
    DateTime dataHoraSelecionada, {
    DateTime? agora,
  }) {
    final referencia = agora ?? DateTime.now();
    return dataHoraSelecionada.isBefore(referencia);
  }

  /// Retorna a saudação dinâmica baseada no horário do sistema.
  /// Manhã: 05h-12h | Tarde: 12h-18h | Noite: 18h-05h
  static String obterSaudacao({DateTime? agora}) {
    final hora = (agora ?? DateTime.now()).hour;
    if (hora >= 5 && hora < 12) return 'Bom dia';
    if (hora >= 12 && hora < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  /// Formata uma data para o padrão brasileiro (DD/MM/AAAA).
  static String formatarDataBr(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  static const _nomesMes = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  /// Formata mês e ano abreviados (ex: "Jun 2026").
  static String formatarMesAno(DateTime data) {
    return '${_nomesMes[data.month - 1]} ${data.year}';
  }

  /// Verifica se duas datas pertencem ao mesmo mês e ano.
  static bool mesmoMesAno(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  /// Verifica se duas datas são o mesmo dia (ignora hora).
  static bool mesmoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static const _mesesLongos = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];

  /// "30 de junho"
  static String formatarDataExtensa(DateTime d) =>
      '${d.day} de ${_mesesLongos[d.month - 1]}';

  /// "Hoje · 30 jun", "Amanhã · 1 jul", "Ontem · …" ou "30 jun"
  static String rotuloDiaRelativo(DateTime d) {
    final hoje = DateTime.now();
    final dia = DateTime(d.year, d.month, d.day);
    final base = DateTime(hoje.year, hoje.month, hoje.day);
    final diff = dia.difference(base).inDays;
    final curto = '${d.day} ${_nomesMes[d.month - 1].toLowerCase()}';
    if (diff == 0) return 'Hoje · $curto';
    if (diff == 1) return 'Amanhã · $curto';
    if (diff == -1) return 'Ontem · $curto';
    return curto;
  }
}
