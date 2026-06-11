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
| `Queixa_Principal` | Motivo que levou o paciente a buscar tratamento (QP). | `Dor lombar crônica há 6 meses` |
| `Hist_Doenca_Atual` | Histórico atual da dor (EVA, fatores de piora/melhora). | `Dor irradia para perna direita (EVA 7)` |
| `Hist_Pregresso` | *Legado* - Doenças prévias, cirurgias, remédios. | `Hipertenso, uso de Losartana` |
| `Ocupacao` | *Legado* - Profissão ou rotina do paciente. | `Escriturário (tempo sentado)` |
| `Situacao` | Status de visibilidade no aplicativo. | `Ativo` ou `Arquivado` |
| `Data_Cadastro` | Data e hora em que o registro foi criado. | `04/06/2026 10:15:30` |
| `Genero` | Gênero do paciente. | `Masculino`, `Feminino`, `Outro` |
| `Dor` | Escala de dor numérica (0-10). | `7` |
| `Comorbidades` | Doenças prévias e comorbidades associadas. | `Hipertensão, Diabetes tipo 2` |
| `Medicamentos` | Medicamentos em uso atual. | `Losartana 50mg, Metformina 850mg` |
| `Alergias` | Alergias conhecidas (medicamentos, látex, etc.). | `Dipirona, Látex` |
| `Cirurgias` | Cirurgias e traumas prévios (fraturas, implantes). | `Artroscopia joelho dir. 2020` |
| `Habitos_Vida` | Hábitos de vida, atividade física, sedentarismo. | `Sedentário, caminhada 2x/semana` |

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
| `Situacao` | Estado atual do agendamento. Usado para controlar agenda do dia, pendências e desfechos sem excluir histórico. | `Agendado`, `Realizado`, `Cancelado`, `Cancelado pelo paciente`, `Cancelado pelo profissional`, `Faltou com aviso`, `Faltou sem aviso` |
| `Data_Criacao` | Data em que o agendamento foi marcado no app. | `04/06/2026 11:30:00` |

### Regras operacionais da agenda

- Agendamentos com `Situacao = "Agendado"` e `Data` igual ao dia atual aparecem em **Agenda de Hoje**.
- Agendamentos com `Situacao = "Agendado"` e `Data` anterior ao dia atual aparecem em **Pendências** até receberem um desfecho.
- Agendamentos cujo horário já passou no mesmo dia são exibidos como **Atrasado**, mas continuam com `Situacao = "Agendado"` até o usuário registrar evolução, falta ou cancelamento.
- O app não exclui agendamentos automaticamente. O histórico é preservado e o campo `Situacao` registra o desfecho operacional.
- Registrar uma evolução vinculada ao agendamento atualiza `Agenda.Situacao` para `"Realizado"`.

---

## 3. Aba: `Evolucoes`
Contém o prontuário clínico diário do paciente. Cada linha representa o parecer técnico e a evolução do paciente após uma sessão concluída, com dados estruturados obrigatórios e opcionais.

| #  | Coluna                  | Obrigatório | Descrição                                      | Exemplo                                      |
|----|-------------------------|-------------|------------------------------------------------|----------------------------------------------|
| 1  | `ID_Evolucao`           | ✅          | Chave única da evolução.                       | `E001`                                       |
| 2  | `ID_Paciente`           | ✅          | Relaciona a evolução ao paciente (`Pacientes`).| `P001`                                       |
| 3  | `ID_Agendamento`        | ✅          | Vincula à sessão correspondente (`Agenda`).    | `A001`                                       |
| 4  | `Data_Atendimento`      | ✅          | Data da sessão (`dd/MM/yyyy`).                 | `09/06/2026`                                 |
| 5  | `Evolucao_Texto`        | ✅          | Anotações clínicas e exercícios realizados.    | `Realizado TENS em região lombar por 20min.` |
| 6  | `Data_Registro`         | ✅          | Timestamp do registro no sistema.              | `09/06/2026 15:10:22`                        |
| 7  | `Local_Atendimento`     | ✅          | Local da sessão (Domicílio/Clínica/Tele).      | `Domicílio`                                  |
| 8  | `Status_Presenca`       | ✅          | Presença/ausência do paciente.                 | `Presente` ou `Ausente sem aviso`            |
| 9  | `Dor_Sessao`            | ✅          | Escala de dor avaliada na sessão (0-10).       | `5`                                          |
| 10 | `Horario_Inicio_Real`   | ✅          | Horário real de início (`HH:mm`).              | `14:05`                                      |
| 11 | `Horario_Fim_Real`      | ✅          | Horário real de término (`HH:mm`).             | `15:00`                                      |
| 12 | `Condicao_Paciente`     | ✅          | Condição clínica pós-sessão.                   | `Melhora` / `Estável` / `Piora` / `Faltou`  |
| 13 | `Pressao_Arterial`      | ❌          | Pressão arterial (mmHg) - opcional.            | `120/80`                                     |
| 14 | `Frequencia_Cardiaca`   | ❌          | Frequência cardíaca (bpm) - opcional.          | `72`                                         |

> **⚠️ Retrocompatibilidade**: Colunas 7-14 foram adicionadas ao final. Registros antigos (6 colunas) continuam funcionando com valores padrão. Colunas novas vazias são preenchidas com valores default no modelo.

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