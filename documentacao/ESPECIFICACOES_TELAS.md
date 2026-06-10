# Especificações de Telas: Painel, Nova Sessão, Paciente e Evolução

Este documento detalha os requisitos funcionais, técnicos e fluxos de navegação das principais telas do aplicativo de Fisioterapia Domiciliar.

---

# Especificação da Tela: Início (Dashboard)

Esta tela é o painel central de controle do fisioterapeuta, apresentando um resumo dinâmico da operação e o gerenciamento de agenda.

## 1. Requisitos Funcionais
* **Saudação Dinâmica:** O sistema deve exibir uma saudação personalizada ("Bom dia", "Boa tarde" ou "Boa noite") baseada no horário do sistema, seguida do nome do fisioterapeuta autenticado.
* **Data Atual:** Exibição da data completa (dia, mês e ano) no cabeçalho.
* **Resumo Operacional (Cards):** Quatro indicadores (cards) no topo da tela:
    1. **Pacientes Cadastrados:** Contagem total de pacientes registrados na aba `Pacientes`.
    2. **Pacientes Ativos:** Contagem de pacientes com situação "Ativo".
    3. **Agendamentos do Dia:** Contagem de atendimentos marcados para a data atual, extraídos da aba `Agenda`.
    4. **Total de Evoluções:** Contagem acumulada de evoluções clínicas registradas na aba `Evolucoes`.
* **Agenda Semanal:**
    * Exibição do calendário com mês e ano correntes.
    * Visualização da grade semanal (Domingo a Sábado).
    * Indicadores visuais para identificar dias com agendamentos.
    * Funcionalidade para criar novo agendamento a partir de um dia selecionado.
* **Card de Atendimento da Agenda:**
    * Apresenta o nome do paciente, horário e o endereço.
    * **Integração de Rotas (Google Maps / Waze):** Exibe um botão "Como Chegar". Ao ser clicado, exibe uma janela/bottom-sheet permitindo selecionar entre Google Maps e Waze, e abre a rota via deep linking com o endereço do paciente de forma gratuita.

## 2. Implementação Técnica
* **Gerenciamento de Estado:** Utilizar `Riverpod` para gerenciar os dados dos cards.
* **Lógica Dinâmica:** O widget de saudação deve ser um componente que utiliza `DateTime.now()` para determinar o período do dia (Manhã: 05h-12h; Tarde: 12h-18h; Noite: 18h-05h).
* **Integração de Dados:**
    * Os dados para os cards devem ser filtrados a partir da aba `Pacientes`, `Agenda` e `Evolucoes`.
    * O calendário deve permitir a navegação e filtragem dinâmica dos agendamentos conforme o dia selecionado.
* **Deep Link de Rotas:** Usar a biblioteca `url_launcher` para abrir:
  * Google Maps: `https://www.google.com/maps/search/?api=1&query=ENDERECO`
  * Waze: `https://waze.com/ul?q=ENDERECO`

---

# Especificação da Tela: Nova Sessão

Esta tela permite ao profissional agendar um novo atendimento domiciliar, garantindo que o horário selecionado seja válido.

## 1. Requisitos Funcionais
* **Seleção de Paciente:** O sistema deve buscar e listar todos os pacientes cadastrados na aba `Pacientes` do Google Sheets para que o usuário possa selecionar o paciente desejado.
* **Validação de Horário:**
    * O sistema deve impedir a seleção de horários retroativos (passados).
    * A regra de validação deve ser baseada no `DateTime.now()`. O usuário só pode selecionar horários a partir do minuto corrente.
* **Campos de Cadastro:**
    * **Paciente:** Seleção via lista.
    * **Data/Hora:** Seletor de data e hora (respeitando a validação de tempo).
    * **Valor do Atendimento:** Campo numérico para registro do valor financeiro.
    * **Observações Clínicas:** Campo de texto (opcional) para anotações rápidas ou lembretes antes da sessão.
* **Ação de Agendar:** Botão "Agendar Sessão" que envia os dados para a aba `Agenda`.

## 2. Implementação Técnica
* **Gerenciamento de Estado:** Utilizar `Riverpod` para gerenciar a lista de pacientes (buscada via `FutureProvider`) e o estado do formulário de agendamento.
* **Validação de Data/Hora:**
    * Implementar lógica comparativa: `if (dataHoraSelecionada.isBefore(DateTime.now())) { exibirMensagemErro(); }`.
* **Integração de Dados:**
    * Ao confirmar o agendamento, o app deve disparar uma requisição POST para a Google Sheets API para criar uma nova linha na aba `Agenda`.

## 3. Fluxo de Navegação
1. Tela de Início -> Clicar em "Novo Agendamento".
2. Abrir `TelaNovaSessao`.
3. Selecionar paciente, definir data/hora, inserir valor e observação.
4. Validar preenchimento e regra de horário retroativo.
5. Confirmar agendamento -> Persistir no Google Sheets -> Retornar à Tela de Início.

---

# Especificação da Tela: Cadastro de Paciente (Anamnese)

Esta tela permite realizar o cadastro completo do paciente no aplicativo e preencher sua ficha de anamnese clínica inicial, alinhada aos padrões dos conselhos de fisioterapia.

## 1. Requisitos Funcionais
* **Formulário de Cadastro:**
    * **Campos Pessoais:** Nome Completo, CPF (com máscara de validação), Telefone, Data de Nascimento e Endereço Residencial.
    * **Campos Clínicos (Anamnese) - Organizados em Subseções:**
        * **Sintomas e Queixas:**
            * Queixa Principal (QP)
            * Histórico da Doença Atual (HDA) - EVA, fatores de piora/melhora
            * Gênero (Masculino, Feminino, Outro)
            * **Escala de Dor (0-10)** - Campo numérico com validação em tempo real (bloqueia letras e valores fora de 0-10)
        * **Histórico Clínico:**
            * Comorbidades/Doenças Prévias (Ex: Hipertensão, Diabetes)
            * Medicamentos em Uso
            * Alergias (crucial para eletroterapia, agulhamento, pomadas)
            * Cirurgias/Traumas Prévios (fraturas, implantes metálicos)
        * **Estilo de Vida:**
            * Hábitos de Vida / Atividade Física (sedentarismo, frequência exercícios, profissão)
* **Validação de CPF Único:**
    * O sistema deve validar se o CPF é estruturalmente válido.
    * O sistema deve consultar a lista de pacientes cadastrados e bloquear a criação se o CPF inserido já estiver registrado, exibindo a mensagem `"Este CPF já está cadastrado."`
* **Campos Obrigatórios:** Nome Completo, CPF, Telefone, Endereço e Escala de Dor são obrigatórios para habilitar o botão de cadastro.
* **Situação Inicial:** Todo paciente cadastrado é criado com a situação `"Ativo"` por padrão na planilha.

## 2. Implementação Técnica
* **Gerenciamento de Estado:** Utilizar `Riverpod` (`StateNotifierProvider` ou `AsyncNotifierProvider`) para gerenciar as validações do formulário e o estado de submissão.
* **Integração com API:** Dispara uma requisição de escrita (POST) adicionando uma nova linha à aba `Pacientes` do Google Sheets, gerando automaticamente um ID único (Ex: P001, P002...).

## 3. Fluxo de Navegação
1. Tela de Pacientes -> Clicar no botão "+" (Novo Paciente).
2. Abrir `TelaCadastroPaciente`.
3. Preencher campos obrigatórios e anamnese clínica.
4. Clicar em "Salvar Paciente" -> Gravar no Google Sheets -> Retornar para a lista de Pacientes atualizada.

---

# Especificação da Tela: Registro de Evolução

Esta tela permite que o fisioterapeuta registre a evolução clínica do paciente após realizar um atendimento domiciliar, com dados estruturados obrigatórios para garantir um prontuário completo e auditável.

## 1. Requisitos Funcionais
* **Identificação do Atendimento:** Exibe no cabeçalho o nome do paciente, idade, data e horário da sessão agendada.
* **Seção: Informações Básicas (Obrigatórias):**
    * **Status de Presença:** Dropdown com `"Presente"`, `"Ausente com aviso"`, `"Ausente sem aviso"`.
    * **Horários Reais:** Dois seletores de horário (Início e Fim) com validação de coerência.
    * **Local de Atendimento:** Dropdown com `"Domicílio"`, `"Clínica"`, `"Teleatendimento"`.
    * **Escala de Dor (0-10):** Campo numérico com validação de intervalo em tempo real.
* **Seção: Sinais Vitais (Opcional):**
    * **Pressão Arterial:** Campo de texto livre (ex: `"120/80"`).
    * **Frequência Cardíaca:** Campo numérico (bpm).
* **Seção: Evolução Clínica:**
    * **Campo de Evolução Técnica:** Campo de texto multilinhas para detalhamento dos exercícios, resposta do paciente e orientações dadas.
    * **Transcrição de Voz (Speech-to-Text) Gratuita:**
        * Exibe um botão de microfone ao lado do campo de texto da evolução.
        * Ao clicar no botão, o app aciona o microfone do celular usando o reconhecimento de voz nativo do sistema operacional.
        * O botão exibe um indicador visual ativo (ícone piscando ou ondas sonoras).
        * À medida que o profissional fala, o texto transcrito é concatenado automaticamente no campo de texto da evolução.
        * Clicar novamente no botão de microfone finaliza a captura de áudio.
* **Condição Clínica:** 
    * Se `Status_Presenca == "Presente"`: dropdown com `"Melhora"`, `"Estável"`, `"Piora"`.
    * Se `Status_Presenca != "Presente"`: automático para `"Faltou"` (exibido como badge laranja).
* **Ação de Finalizar Sessão:** Botão "Salvar Evolução" que:
    * Valida todos os campos obrigatórios.
    * Cria registro na aba `Evolucoes` (14 colunas).
    * Atualiza o agendamento na aba `Agenda` para `Situacao = "Realizado"`.

## 2. Implementação Técnica
* **Modelo de Dados:** `Evolucao` agora possui 12 campos (6 originais + 6 novos obrigatórios + 2 opcionais). Serialização via `paraMapaPlanilha()` e `deLinhaPlanilha()`.
* **Biblioteca Speech-to-Text:** Utilizar o pacote oficial `speech_to_text` do Flutter.
* **Fluxo de Permissão:** O app deve solicitar permissão de uso do microfone na primeira tentativa de uso. Em caso de recusa, exibe a mensagem `"Permissão de microfone necessária para transcrição por voz."`
* **Persistência de Dados:** Realiza uma requisição POST na aba `Evolucoes` (14 colunas) e PATCH na aba `Agenda` para alterar `Situacao` do agendamento para `"Realizado"`.
* **Retrocompatibilidade:** A aba `Evolucoes` agora possui 14 colunas. Novas colunas foram adicionadas ao final. Registros antigos (6 colunas) são carregados com valores padrão.
* **Badge no Modal:** O modal de detalhes do paciente (`ModalDetalhesPaciente`) exibe a condição da última evolução com cor indicativa (🟢 Melhora / 🟡 Estável / 🔴 Piora / ⚫ Faltou).

---

# Especificação da Tela: Histórico de Evoluções (Linha do Tempo)

Esta tela exibe o prontuário clínico consolidado do paciente em ordem cronológica reversa, permitindo que o profissional analise a evolução do tratamento.

## 1. Requisitos Funcionais
* **Cabeçalho Clínico:** Exibição do nome e idade do paciente selecionado para contexto imediato.
* **Visualização em Linha do Tempo (Timeline):** Apresentação das evoluções em formato visual de linha do tempo:
    * **Ordenação:** As evoluções mais recentes devem aparecer no topo (ordem cronológica decrescente).
    * **Conteúdo do Card:** Cada nó da linha do tempo deve exibir a data da sessão (`Data_Atendimento`) e o texto completo da evolução técnica (`Evolucao_Texto`).
* **Estado Vazio:** Caso o paciente seja recém-cadastrado e não possua evoluções gravadas, o sistema deve exibir uma ilustração ou mensagem amigável: `"Nenhum registro clínico cadastrado para este paciente."`

## 2. Implementação Técnica
* **Filtro de Dados:** O aplicativo deve realizar a consulta na aba `Evolucoes` do Google Sheets aplicando o filtro `ID_Paciente == PacienteSelecionado.ID_Paciente`.
* **Ordenação no App:** A ordenação decrescente deve ser realizada via código (`list.sort()`) comparando as datas do campo `Data_Atendimento`.

---

# Especificação da Tela: Configurações

Esta tela centraliza o controle operacional e as ferramentas de privacidade e conformidade com a LGPD para o fisioterapeuta.

## 1. Requisitos Funcionais
* **Ajuste de Valor Padrão:** Campo de texto monetário para definir o valor padrão cobrado por sessão.
    * **Regra de Negócio:** Ao definir um valor (Ex: R$ 150,00), o sistema salva esta preferência. Ao abrir a `TelaNovaSessao` para agendar qualquer atendimento, o campo de valor é preenchido automaticamente com esta configuração.
* **Acesso Soberano ao Banco:** Botão "Visualizar Planilha de Dados". Ao ser clicado, abre o link oficial da planilha `__saas_fisio_db__` do Google Sheets no navegador do dispositivo, garantindo transparência total.
* **Privacidade (LGPD):** 
    * Botão "Visualizar Termos de Uso" para reexibir o documento legal aceito no login.
    * **Logs de Auditoria:** Seção que exibe a listagem dos logs da aba `Auditoria` (últimas ações de criação, alteração ou arquivamento realizadas no app) em formato somente leitura, garantindo conformidade com a rastreabilidade exigida pela LGPD.

## 2. Implementação Técnica
* **Persistência de Preferências:** Ao alterar o valor padrão, o aplicativo grava os dados na aba `Configuracoes` associando a chave `valor_sessao_padrao` ao valor inserido. No carregamento do app, esse valor é mantido em cache local.
* **Rastreabilidade (Logs):** Qualquer ação crítica no app (Ex: login, agendamento de sessão, arquivamento de paciente) dispara uma chamada assíncrona de escrita em background na aba `Auditoria` descrevendo a ação. A tela de configurações apenas lê e renderiza estas linhas.
