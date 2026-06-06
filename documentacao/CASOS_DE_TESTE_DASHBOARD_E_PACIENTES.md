# Casos de Teste: Dashboard, Agendamentos e Gestão de Pacientes

Este documento apresenta a suíte de casos de teste para o Dashboard (Início), o Agendamento de Nova Sessão e a Gestão de Pacientes (incluindo busca, cálculo de idade, histórico e arquivamento).

---

### CT01 - Saudação Dinâmica e Atualização dos Cards do Dashboard

#### Objetivo
Validar que o cabeçalho ajusta a saudação dinamicamente com base no horário do dispositivo e que os cards de resumo estatístico exibem contagens fiéis ao Google Sheets.

#### Pré-Condições
- O usuário está autenticado e na tela de Início (Dashboard).
- A base de dados do Google Sheets contém:
  - 5 Pacientes cadastrados (4 Ativos, 1 Arquivado).
  - 3 Agendamentos marcados para o dia de hoje.
  - 12 Evoluções clínicas registradas no total.

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Alterar o horário do sistema operacional para 08:00 e abrir o Dashboard. | O cabeçalho exibe a saudação: `"Bom dia, [Nome do Fisioterapeuta]"`. |
| 2  | Alterar o horário do sistema operacional para 14:00 e abrir o Dashboard. | O cabeçalho exibe a saudação: `"Boa tarde, [Nome do Fisioterapeuta]"`. |
| 3  | Alterar o horário do sistema operacional para 20:00 e abrir o Dashboard. | O cabeçalho exibe a saudação: `"Boa noite, [Nome do Fisioterapeuta]"`. |
| 4  | Verificar os valores nos 4 Cards de Resumo. | Os cards exibem exatamente:<br>- Pacientes Cadastrados: `5`<br>- Pacientes Ativos: `4`<br>- Agendamentos do Dia: `3`<br>- Total de Evoluções: `12`. |

#### Resultados Esperados
- A saudação acompanha o horário do dia de forma precisa.
- Os cards do Dashboard consolidam os dados da planilha corretamente.

#### Critérios de Aceitação
- A lógica de saudação deve seguir as faixas: Manhã (05h-12h), Tarde (12h-18h) e Noite (18h-05h).
- O total de "Pacientes Ativos" não deve incluir o paciente com status "Arquivado".

---

### CT02 - Agendamento de Nova Sessão com Validação de Horário Retroativo

#### Objetivo
Validar que o formulário de agendamento bloqueia tentativas de marcação de sessões em datas ou horários que já passaram.

#### Pré-Condições
- O usuário está autenticado e na tela de `NovaSessaoScreen`.
- A data atual do sistema é 04/06/2026, às 14:30.

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Selecionar um paciente na lista. | O paciente é selecionado corretamente. |
| 2  | No seletor de Data/Hora, selecionar o dia anterior (03/06/2026) às 14:30. | O seletor bloqueia a seleção (fica cinza/inativo) ou, ao tentar confirmar, o sistema exibe mensagem de erro: `"Selecione uma data e horário futuros."` |
| 3  | No seletor de Data/Hora, selecionar o dia atual (04/06/2026) às 14:00 (30 minutos no passado). | O sistema impede a seleção ou exibe o alerta: `"Selecione uma data e horário futuros."` |
| 4  | Selecionar uma data futura (05/06/2026) às 09:00, preencher valor da sessão e observações. Clicar em "Agendar Sessão". | O agendamento é processado com sucesso, o registro é salvo na aba `Agendamentos_Evolucoes` com status `"Agendado"` e o app retorna ao Dashboard. |

#### Resultados Esperados
- O sistema impossibilita o agendamento de consultas retroativas.
- Consultas futuras são agendadas com sucesso e refletidas na planilha.

#### Critérios de Aceitação
- A validação de data deve considerar o horário em minutos (`DateTime.now()`).
- O botão de confirmação não deve enviar dados para a API se houver erros de validação de horário na tela.

---

### CT03 - Busca Dinâmica e Cálculo de Idade do Paciente

#### Objetivo
Validar que o campo de pesquisa filtra a lista de pacientes ativos por Nome ou CPF instantaneamente e que o cálculo de idade com base na data de nascimento está correto.

#### Pré-Condições
- O usuário está na tela de Pacientes.
- Existem dois pacientes ativos cadastrados na base:
  - `"Carlos Eduardo"`, CPF `"111.111.111-11"`, Data de Nascimento `"04/06/1986"` (idade calculada: 40 anos, considerando o ano corrente de 2026).
  - `"Ana Paula"`, CPF `"222.222.222-22"`, Data de Nascimento `"04/06/1996"` (idade calculada: 30 anos).

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Visualizar a lista padrão de pacientes ativos. | Ambos os pacientes são listados, exibindo seus nomes e suas idades calculadas (`40 anos` para Carlos e `30 anos` para Ana). |
| 2  | Digitar `"Carlos"` no buscador. | A lista atualiza em tempo real mostrando apenas o card de `"Carlos Eduardo"`. |
| 3  | Limpar a busca e digitar o CPF `"222.222.222-22"`. | A lista atualiza em tempo real exibindo apenas o card de `"Ana Paula"`. |
| 4  | Digitar um termo inexistente (ex: `"Xyz"`). | A lista fica vazia e apresenta a mensagem: `"Nenhum paciente encontrado."` |

#### Resultados Esperados
- A busca filtra os resultados de forma dinâmica a cada letra ou número digitado.
- A idade é exibida de forma correta baseada no ano atual em relação ao ano de nascimento.

#### Critérios de Aceitação
- A busca deve ser case-insensitive (não diferenciar maiúsculas/minúsculas).
- O buscador deve suportar a busca tanto por CPF formatado (com pontos/traço) quanto por CPF apenas com números.

---

### CT04 - Arquivamento e Filtro de Pacientes Arquivados (LGPD)

#### Objetivo
Validar que o arquivamento de um paciente altera seu status no Google Sheets sem excluir os dados fisicamente, removendo-o da busca padrão e permitindo sua posterior recuperação através do filtro de arquivados.

#### Pré-Condições
- O usuário está na tela de Pacientes.
- O paciente `"Carlos Eduardo"` está cadastrado com status `"Ativo"`.

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Clicar no paciente `"Carlos Eduardo"` para abrir o modal de detalhes. | O modal de detalhes é exibido. |
| 2  | Clicar no botão `"Arquivar Paciente"` e confirmar na pop-up de segurança. | O status do paciente na planilha (aba `Pacientes`) é atualizado para `"Arquivado"`. O modal fecha e `"Carlos Eduardo"` desaparece da lista de pacientes ativos. |
| 3  | Digitar `"Carlos"` no buscador de pacientes ativos. | O app exibe `"Nenhum paciente encontrado."` (confirmando que ele não aparece mais na busca principal). |
| 4  | Clicar no seletor de visualização e mudar de `"Ativos"` para `"Arquivados"`. | A tela passa a listar os pacientes arquivados. O paciente `"Carlos Eduardo"` é exibido nesta lista. |

#### Resultados Esperados
- O paciente é ocultado da lista principal de trabalho, mas seus dados históricos continuam preservados na base de dados e acessíveis no filtro correspondente.

#### Critérios de Aceitação
- A ação de arquivar deve atualizar apenas a coluna `Status` correspondente ao ID do paciente no Google Sheets, mantendo intactos todos os demais dados clínicos.
- A lista de "Arquivados" deve possuir interface diferenciada (ou indicação visual) indicando que são dados inativos.

---

### CT05 - Linha do Tempo de Prontuário Clínico (Histórico de Evoluções)

#### Objetivo
Validar que o histórico clínico (evoluções) de um paciente é recuperado de forma completa e ordenado cronologicamente na visualização de linha do tempo.

#### Pré-Condições
- O usuário está na tela de Pacientes.
- O paciente `"Ana Paula"` possui 3 evoluções registradas na aba `Agendamentos_Evolucoes`:
  - Sessão 1: 01/06/2026 - `"Evolução: Treino de marcha."`
  - Sessão 2: 02/06/2026 - `"Evolução: Fortalecimento de membros inferiores."`
  - Sessão 3: 03/06/2026 - `"Evolução: Alongamento ativo global."`

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Clicar no paciente `"Ana Paula"` para abrir o modal de detalhes. | O modal de detalhes abre. |
| 2  | Clicar no botão `"Ver Histórico"`. | O aplicativo carrega e abre a tela de prontuário com a linha do tempo. |
| 3  | Validar a ordem e conteúdo das evoluções exibidas. | As 3 evoluções são exibidas em ordem cronológica (da mais recente à mais antiga) contendo a data correspondente e o texto da evolução perfeitamente legíveis. |

#### Resultados Esperados
- As evoluções passadas do paciente são exibidas de forma clara e estruturada, permitindo ao fisioterapeuta a leitura rápida do histórico de tratamento.

#### Critérios de Aceitação
- O cabeçalho da tela do histórico deve identificar claramente o paciente.
- Se o paciente não possuir nenhuma evolução prévia cadastrada, deve exibir uma mensagem indicativa amigável: `"Nenhum registro de evolução para este paciente."`
