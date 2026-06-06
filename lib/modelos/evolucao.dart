/// Modelo de dados representando uma evolução clínica diária.
/// Espelha a aba `Evolucoes` da planilha `__saas_fisio_db__`.
class Evolucao {
  final String idEvolucao;
  final String idPaciente;
  final String idAgendamento;
  final DateTime dataAtendimento;
  final String evolucaoTexto;
  final DateTime dataRegistro;

  Evolucao({
    required this.idEvolucao,
    required this.idPaciente,
    required this.idAgendamento,
    required this.dataAtendimento,
    required this.evolucaoTexto,
    DateTime? dataRegistro,
  }) : dataRegistro = dataRegistro ?? DateTime.now();

  /// Converte para mapa de valores para envio à planilha.
  Map<String, dynamic> paraMapaPlanilha() {
    return {
      'ID_Evolucao': idEvolucao,
      'ID_Paciente': idPaciente,
      'ID_Agendamento': idAgendamento,
      'Data_Atendimento':
          '${dataAtendimento.day.toString().padLeft(2, '0')}/${dataAtendimento.month.toString().padLeft(2, '0')}/${dataAtendimento.year}',
      'Evolucao_Texto': evolucaoTexto,
      'Data_Registro': dataRegistro.toIso8601String(),
    };
  }
}
