/// Modelo de dados representando um agendamento de sessão.
/// Espelha a aba `Agenda` da planilha `__saas_fisio_db__`.
class Agendamento {
  /// Mapa de nomes de coluna para índices (0-based) na aba Agenda.
  static const indicesColunas = {
    'idAgendamento': 0,
    'idPaciente': 1,
    'data': 2,
    'horaInicio': 3,
    'horaFim': 4,
    'valorSessao': 5,
    'observacoes': 6,
    'situacao': 7,
    'dataCriacao': 8,
  };

  static const situacaoAgendado = 'Agendado';
  static const situacaoRealizado = 'Realizado';
  static const situacaoCancelado = 'Cancelado';
  static const situacaoCanceladoPaciente = 'Cancelado pelo paciente';
  static const situacaoCanceladoProfissional = 'Cancelado pelo profissional';
  static const situacaoFaltouComAviso = 'Faltou com aviso';
  static const situacaoFaltouSemAviso = 'Faltou sem aviso';

  final String idAgendamento;
  final String idPaciente;
  final DateTime data;
  final String horaInicio;
  final String horaFim;
  final double valorSessao;
  final String? observacoes;
  final String situacao;
  final DateTime dataCriacao;

  Agendamento({
    required this.idAgendamento,
    required this.idPaciente,
    required this.data,
    required this.horaInicio,
    required this.horaFim,
    required this.valorSessao,
    this.observacoes,
    this.situacao = situacaoAgendado,
    DateTime? dataCriacao,
  }) : dataCriacao = dataCriacao ?? DateTime.now();

  bool get estaAgendado => situacao == situacaoAgendado;
  bool get foiRealizado => situacao == situacaoRealizado;
  bool get foiCancelado =>
      situacao == situacaoCancelado ||
      situacao == situacaoCanceladoPaciente ||
      situacao == situacaoCanceladoProfissional;
  bool get foiFalta =>
      situacao == situacaoFaltouComAviso || situacao == situacaoFaltouSemAviso;
  bool get possuiDesfecho => foiRealizado || foiCancelado || foiFalta;

  DateTime get inicioPrevisto {
    final partes = horaInicio.split(':');
    return DateTime(
      data.year,
      data.month,
      data.day,
      int.tryParse(partes.first) ?? 0,
      partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0,
    );
  }

  bool ehDeHoje(DateTime referencia) {
    return data.year == referencia.year &&
        data.month == referencia.month &&
        data.day == referencia.day;
  }

  bool estaAtrasado(DateTime referencia) {
    return estaAgendado && inicioPrevisto.isBefore(referencia);
  }

  bool pendenteDeDiaAnterior(DateTime referencia) {
    final hoje = DateTime(referencia.year, referencia.month, referencia.day);
    final diaAgendamento = DateTime(data.year, data.month, data.day);
    return estaAgendado && diaAgendamento.isBefore(hoje);
  }

  /// Converte para mapa de valores para envio à planilha.
  Map<String, dynamic> paraMapaPlanilha() {
    return {
      'ID_Agendamento': idAgendamento,
      'ID_Paciente': idPaciente,
      'Data':
          '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}',
      'Hora_Inicio': horaInicio,
      'Hora_Fim': horaFim,
      'Valor_Sessao': valorSessao.toStringAsFixed(2),
      'Observacoes': observacoes ?? '',
      'Situacao': situacao,
      'Data_Criacao': dataCriacao.toIso8601String(),
    };
  }

  Agendamento copiarCom({String? situacao}) {
    return Agendamento(
      idAgendamento: idAgendamento,
      idPaciente: idPaciente,
      data: data,
      horaInicio: horaInicio,
      horaFim: horaFim,
      valorSessao: valorSessao,
      observacoes: observacoes,
      situacao: situacao ?? this.situacao,
      dataCriacao: dataCriacao,
    );
  }
}
