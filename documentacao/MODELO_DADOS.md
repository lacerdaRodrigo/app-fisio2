# Modelo de Dados - Google Sheets Backend

Este documento detalha a estrutura das 5 abas criadas na planilha `__saas_fisio_db__` do Google Sheets para suportar o sistema de fisioterapia domiciliar. Esta estrutura modular garante clareza absoluta para o fisioterapeuta caso ele decida abrir e ler a planilha diretamente no Google Drive.

---

## 1. Aba: `Pacientes`
Armazena os dados cadastrais e a ficha de anamnese inicial dos pacientes.

| Coluna | Descrição | Exemplo |
| :--- | :--- | :--- |
| `ID_Paciente` | Chave única identificadora do paciente. | `P001` |
| `Nome` | Nome completo do paciente. | `Carlos Eduardo` |
| `Telefone` | Contato telefônico principal. | `(11) 99999-9999` |
| `Data_Nascimento` | Data para fins de cálculo de idade e prontuário. | `04/06/1986` |
| `CPF` | Documento de identificação (único no sistema). | `111.111.111-11` |
| `Endereco` | Endereço residencial completo para visitas. | `Rua das Flores, 123, São Paulo - SP` |
| `Queixa_Principal` | Motivo que levou o paciente a buscar tratamento. | `Dor lombar crônica há 6 meses` |
| `Hist_Doenca_Atual` | Histórico atual da dor (EVA de dor, fatores de piora). | `Dor irradia para perna direita (EVA 7)` |
| `Hist_Pregresso` | Doenças prévias, cirurgias, remédios em uso. | `Hipertenso, faz uso de Losartana` |
| `Ocupacao` | Profissão ou rotina do paciente. | `Escriturário (fica muito tempo sentado)` |
| `Situacao` | Status de visibilidade no aplicativo. | `Ativo` ou `Arquivado` |
| `Data_Cadastro` | Data e hora em que o registro foi criado. | `04/06/2026 10:15:30` |

---

## 2. Aba: `Agenda`
Armazena a grade de atendimentos e compromissos agendados. É uma aba puramente operacional e de calendário.

| Coluna | Descrição | Exemplo |
| :--- | :--- | :--- |
| `ID_Agendamento` | Chave única do agendamento. | `A001` |
| `ID_Paciente` | Relaciona o agendamento ao paciente (`Pacientes`). | `P001` |
| `Data` | Dia agendado para o atendimento. | `05/06/2026` |
| `Hora_Inicio` | Horário de início marcado. | `14:00` |
| `Hora_Fim` | Horário estimado de término. | `15:00` |
| `Valor_Sessao` | Preço cobrado pela sessão domiciliar. | `150,00` |
| `Observacoes` | Notas prévias para a sessão (Ex: levar aparelhos). | `Levar eletroestimulador TENS` |
| `Situacao` | Estado atual do agendamento. | `Agendado`, `Realizado` ou `Cancelado` |
| `Data_Criacao` | Data em que o agendamento foi marcado no app. | `04/06/2026 11:30:00` |

---

## 3. Aba: `Evolucoes`
Contém o prontuário clínico diário do paciente. Cada linha representa o parecer técnico e a evolução do paciente após uma sessão concluída.

| Coluna | Descrição | Exemplo |
| :--- | :--- | :--- |
| `ID_Evolucao` | Chave única da evolução. | `E001` |
| `ID_Paciente` | Relaciona a evolução ao paciente (`Pacientes`). | `P001` |
| `ID_Agendamento` | Vincula a evolução à sessão correspondente (`Agenda`). | `A001` |
| `Data_Atendimento` | Data em que a sessão foi de fato realizada. | `05/06/2026` |
| `Evolucao_Texto` | Anotações clínicas e exercícios realizados. | `Paciente relatou melhora na dor (EVA 4). Realizado alongamento de cadeia posterior e fortalecimento de core.` |
| `Data_Registro` | Data/hora exata em que a evolução foi gravada. | `05/06/2026 15:10:22` |

---

## 4. Aba: `Configuracoes`
Armazena preferências e dados operacionais internos do aplicativo para o usuário logado.

| Coluna | Descrição | Exemplo |
| :--- | :--- | :--- |
| `Chave` | Nome identificador do parâmetro. | `valor_sessao_padrao` |
| `Valor` | Configuração correspondente salva. | `150,00` |

---

## 5. Aba: `Auditoria`
Registra logs básicos de alteração para fins de segurança e conformidade de histórico LGPD.

| Coluna | Descrição | Exemplo |
| :--- | :--- | :--- |
| `ID_Log` | Chave sequencial do log. | `L001` |
| `Data_Hora` | Momento da ação realizada. | `04/06/2026 12:00:00` |
| `Operacao` | Ação executada pelo usuário no app. | `ARQUIVAMENTO_PACIENTE` |
| `Detalhes` | Informações de apoio da operação. | `Paciente P001 arquivado por solicitação clínica.` |