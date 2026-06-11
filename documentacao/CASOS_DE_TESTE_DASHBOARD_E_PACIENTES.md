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
  - 3 Agendamentos marcados para o dia de hoje, sendo 2 com `Situacao = "Agendado"` e 1 com `Situacao = "Realizado"`.
  - 12 Evoluções clínicas registradas no total.

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Alterar o horário do sistema operacional para 08:00 e abrir o Dashboard. | O cabeçalho exibe a saudação: `"Bom dia, [Nome do Fisioterapeuta]"`. |
| 2  | Alterar o horário do sistema operacional para 14:00 e abrir o Dashboard. | O cabeçalho exibe a saudação: `"Boa tarde, [Nome do Fisioterapeuta]"`. |
| 3  | Alterar o horário do sistema operacional para 20:00 e abrir o Dashboard. | O cabeçalho exibe a saudação: `"Boa noite, [Nome do Fisioterapeuta]"`. |
| 4  | Verificar os valores nos 4 Cards de Resumo. | Os cards exibem exatamente:<br>- Pacientes Cadastrados: `5`<br>- Pacientes Ativos: `4`<br>- Agenda do Dia: `2` (somente sessões ainda `Agendado` hoje)<br>- Total de Evoluções: `12`. |
| 5  | Clicar em `Pacientes Cadastrados`. | O app abre a aba Pacientes no filtro `Todos`. |
| 6  | Clicar em `Pacientes Ativos`. | O app abre a aba Pacientes no filtro `Ativos`. |
| 7  | Clicar em `Agenda do Dia`. | O Dashboard rola até a seção `Agenda de Hoje`. |
| 8  | Clicar em `Total de Evoluções`. | O app abre a tela de histórico geral de evoluções. |

#### Resultados Esperados
- A saudação acompanha o horário do dia de forma precisa.
- Os cards do Dashboard consolidam os dados da planilha corretamente.

#### Critérios de Aceitação
- A lógica de saudação deve seguir as faixas: Manhã (05h-12h), Tarde (12h-18h) e Noite (18h-05h).
- O total de "Pacientes Ativos" não deve incluir o paciente com status "Arquivado".
- O total de "Agenda do Dia" deve contar somente sessões de hoje ainda sem desfecho (`Situacao = "Agendado"`).
- Cards clicáveis devem entregar uma navegação/ação clara.

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
| 4  | Selecionar uma data futura (05/06/2026) às 09:00, preencher valor da sessão e observações. Clicar em "Agendar Sessão". | O agendamento é processado com sucesso, o registro é salvo na aba `Agenda` com `Situacao = "Agendado"` e o app retorna ao Dashboard. |

#### Resultados Esperados
- O sistema impossibilita o agendamento de consultas retroativas.
- Consultas futuras são agendadas com sucesso e refletidas na planilha.

#### Critérios de Aceitação
- A validação de data deve considerar o horário em minutos (`DateTime.now()`).
- O botão de confirmação não deve enviar dados para a API se houver erros de validação de horário na tela.

---

### CT03 - Agenda de Hoje, Virada de Dia e Pendências

#### Objetivo
Validar que o Dashboard mostra apenas sessões do dia atual na seção `Agenda de Hoje` e move sessões antigas sem desfecho para `Pendências`.

#### Pré-Condições
- A data atual do sistema é 10/06/2026.
- A aba `Agenda` contém:
  - `A001`: Data `10/06/2026`, `Situacao = "Agendado"`.
  - `A002`: Data `09/06/2026`, `Situacao = "Agendado"`.
  - `A003`: Data `09/06/2026`, `Situacao = "Realizado"`.

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Abrir o Dashboard. | `A001` aparece em `Agenda de Hoje`. |
| 2  | Verificar a seção `Pendências`. | `A002` aparece como pendente, com data do agendamento e ação de desfecho. |
| 3  | Verificar agendamento realizado do dia anterior. | `A003` não aparece em `Agenda de Hoje` nem em `Pendências`, pois já possui desfecho. |

#### Critérios de Aceitação
- Ao virar o dia, sessões antigas com `Situacao = "Agendado"` não devem continuar na agenda de hoje.
- Nenhum agendamento deve ser excluído automaticamente.
- Pendências devem permanecer visíveis até receberem desfecho.

---

### CT04 - Desfecho de Sessão pela Agenda

#### Objetivo
Validar que o usuário consegue resolver uma sessão pendente ou atrasada diretamente pelo card da agenda.

#### Pré-Condições
- O usuário está no Dashboard.
- Existe uma sessão `A010` com `Situacao = "Agendado"` exibida em `Agenda de Hoje` ou `Pendências`.

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Abrir o menu de ações da sessão. | O menu exibe `Registrar evolução`, `Faltou com aviso`, `Faltou sem aviso`, `Cancelar pelo paciente` e `Cancelar pelo profissional`. |
| 2  | Selecionar `Faltou sem aviso`. | O app pede confirmação antes de atualizar. |
| 3  | Confirmar a ação. | A coluna `Situacao` da aba `Agenda` é atualizada para `Faltou sem aviso`, o card deixa de aparecer como pendência/agendado e um log de auditoria é registrado. |
| 4  | Repetir o fluxo selecionando `Registrar evolução`. | O app abre `TelaRegistroEvolucao`; ao salvar a evolução, `Situacao` é atualizada para `Realizado`. |

#### Critérios de Aceitação
- Cancelamentos e faltas não removem linhas da planilha.
- O desfecho deve ser salvo em `Agenda.Situacao`.
- O usuário deve confirmar antes de aplicar um desfecho irreversível no fluxo operacional.

---

### CT05 - Consulta de Sessões Canceladas, Faltas e Realizadas

#### Objetivo
Validar que sessões resolvidas saem da agenda operacional, mas continuam consultáveis na aba `Sessões`.

#### Pré-Condições
- O usuário está autenticado.
- A aba `Agenda` contém:
  - Uma sessão com `Situacao = "Cancelado pelo profissional"`.
  - Uma sessão com `Situacao = "Faltou sem aviso"`.
  - Uma sessão com `Situacao = "Realizado"`.

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Abrir o rodapé e tocar em `Sessões`. | A tela `Sessões` é exibida com filtros horizontais. |
| 2  | Clicar no filtro `Canceladas`. | A sessão `Cancelado pelo profissional` é exibida; faltas e realizadas ficam ocultas. |
| 3  | Clicar no filtro `Faltas`. | A sessão `Faltou sem aviso` é exibida. |
| 4  | Clicar no filtro `Realizadas`. | A sessão `Realizado` é exibida. |
| 5  | Digitar o nome do paciente no campo de busca. | A lista exibe somente sessões compatíveis com o paciente pesquisado. |
| 6  | Alternar para `Por paciente`. | As sessões são agrupadas por paciente, exibindo quantidade de sessões e último status do grupo. |

#### Critérios de Aceitação
- Canceladas e faltas nunca devem ser apagadas da base.
- A aba `Sessões` deve ser o local oficial para consultar sessões fora da agenda de hoje.
- A busca deve filtrar por paciente, data ou situação sem alterar o filtro ativo.

---

### CT06 - Busca Dinâmica e Cálculo de Idade do Paciente

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

### CT07 - Arquivamento e Filtro de Pacientes Arquivados (LGPD)

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
| 4  | Clicar no filtro `"Arquivados"`. | A tela passa a listar os pacientes arquivados. O paciente `"Carlos Eduardo"` é exibido nesta lista. |
| 5  | Clicar no filtro `"Todos"`. | A tela lista pacientes ativos e arquivados, mantendo indicação visual dos arquivados. |

#### Resultados Esperados
- O paciente é ocultado da lista principal de trabalho, mas seus dados históricos continuam preservados na base de dados e acessíveis no filtro correspondente.

#### Critérios de Aceitação
- A ação de arquivar deve atualizar apenas a coluna `Status` correspondente ao ID do paciente no Google Sheets, mantendo intactos todos os demais dados clínicos.
- A lista de "Arquivados" deve possuir interface diferenciada (ou indicação visual) indicando que são dados inativos.

---

### CT08 - Linha do Tempo de Prontuário Clínico (Histórico de Evoluções)

#### Objetivo
Validar que o histórico clínico (evoluções) de um paciente é recuperado de forma completa e ordenado cronologicamente na visualização de linha do tempo.

#### Pré-Condições
- O usuário está na tela de Pacientes.
- O paciente `"Ana Paula"` possui 3 evoluções registradas na aba `Evolucoes`:
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

---

### CT09 - Busca e Agrupamento no Histórico Geral de Evoluções

#### Objetivo
Validar que o histórico geral de evoluções permite localizar registros clínicos rapidamente e agrupar os resultados por paciente.

#### Pré-Condições
- O usuário está autenticado e no Dashboard.
- Existem evoluções de pelo menos um paciente registradas na aba `Evolucoes`.

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Clicar no card `Total de Evoluções`. | O app abre a tela de histórico geral de evoluções. |
| 2  | Digitar um termo clínico no campo de busca, como `"marcha"`. | A lista exibe somente evoluções cujo paciente, data, texto, condição, local ou presença correspondem ao termo. |
| 3  | Limpar a busca e alternar para `Por paciente`. | As evoluções são agrupadas por paciente, mostrando quantidade de evoluções e última condição clínica. |

#### Critérios de Aceitação
- A busca deve ser case-insensitive.
- A tela não deve gravar dados nem alterar evoluções existentes.
- O agrupamento deve manter os registros mais recentes no topo de cada paciente.
