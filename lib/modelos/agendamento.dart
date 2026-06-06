/// Modelo de dados representando um agendamento de sessão.
/// Espelha a aba `Agenda` da planilha `__saas_fisio_db__`.
class Agendamento {
  final String idAgendamento;
  final String idPaciente;
  final DateTime data;
  final String horaInicio;
  final String horaFim;
  final double valorSessao;
  final String? observacoes;
  final String situacao; // 'Agendado', 'Realizado' ou 'Cancelado'
  final DateTime dataCriacao;

  Agendamento({
    required this.idAgendamento,
    required this.idPaciente,
    required this.data,
    required this.horaInicio,
    required this.horaFim,
    required this.valorSessao,
    this.observacoes,
    this.situacao = 'Agendado',
    DateTime? dataCriacao,
  }) : dataCriacao = dataCriacao ?? DateTime.now();

  bool get estaAgendado => situacao == 'Agendado';
  bool get foiRealizado => situacao == 'Realizado';
  bool get foiCancelado => situacao == 'Cancelado';

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
