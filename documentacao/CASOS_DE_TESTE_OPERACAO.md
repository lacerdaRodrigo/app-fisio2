# Casos de Teste: Operação, Cadastro, Rotas e Transcrição de Voz

Este documento apresenta a suíte de casos de teste para os fluxos operacionais do aplicativo de Fisioterapia Domiciliar, incluindo cadastro de pacientes, rotas integradas de navegação e transcrição de voz nas evoluções.

---

### CT01 - Cadastro de Novo Paciente com CPF Único e Validação

#### Objetivo
Validar que o formulário de cadastro de paciente exige todos os campos obrigatórios, impede a gravação com CPF duplicado e persiste com sucesso os dados no Google Sheets quando as informações estão válidas.

#### Pré-Condições
- O usuário está autenticado e na tela de Pacientes.
- O CPF `"123.456.789-00"` já está cadastrado na planilha para um paciente existente.
- O CPF `"987.654.321-00"` não existe na base de dados.

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Clicar no botão flutuante "+". | O aplicativo abre a tela de cadastro `CadastroPacienteScreen`. |
| 2  | Tentar clicar em "Salvar Paciente" com campos vazios. | O botão de salvar permanece inativo ou exibe alertas de obrigatoriedade nos campos: Nome, CPF, Telefone e Endereço. |
| 3  | Preencher Nome, Telefone, Endereço e inserir o CPF duplicado `"123.456.789-00"`. Clicar em "Salvar Paciente". | O sistema bloqueia a submissão e exibe o alerta de validação: `"Este CPF já está cadastrado."` |
| 4  | Alterar o CPF para o valor único `"987.654.321-00"` e preencher a anamnese clínica (QP, HDA). Clicar em "Salvar Paciente". | O aplicativo exibe tela de carregamento, persiste a nova linha na aba `Pacientes` do Google Sheets com status `"Ativo"` e retorna à lista de pacientes. |
| 5  | Digitar o nome do paciente cadastrado na barra de busca. | O novo paciente cadastrado é localizado e exibido na lista filtrada em tempo real. |

#### Resultados Esperados
- O sistema impede a duplicidade de CPFs e a inserção de dados incompletos.
- O cadastro de pacientes válidos atualiza a planilha do Google Sheets e a lista local.

#### Critérios de Aceitação
- Exibir a mensagem `"Este CPF já está cadastrado."` no campo de CPF ou em alerta popup caso haja duplicidade.
- O registro no Google Sheets deve conter automaticamente o status `"Ativo"` e a `Data_Cadastro` preenchida com a data do dia corrente.

---

### CT02 - Integração de Rotas para Atendimento (Google Maps / Waze)

#### Objetivo
Validar que o aplicativo oferece links corretos e gratuitos para aplicativos de GPS externos (Google Maps e Waze) baseando-se no endereço cadastrado do paciente.

#### Pré-Condições
- O usuário está logado e na tela inicial (Dashboard).
- Há pelo menos um atendimento agendado na lista de hoje com o endereço `"Av. Paulista, 1000 - São Paulo"`.

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Visualizar o card de atendimento do paciente na agenda. | O card exibe as informações da consulta e o botão `"Como Chegar"`. |
| 2  | Clicar no botão `"Como Chegar"`. | Uma caixa de diálogo/menu inferior (Bottom Sheet) é exibida com as opções `"Google Maps"` e `"Waze"`. |
| 3  | Selecionar a opção `"Google Maps"`. | O aplicativo dispara o deep link correspondente (`https://www.google.com/maps/search/?api=1&query=Av.+Paulista,+1000+-+S%C3%A3o+Paulo`) e abre o aplicativo externo do Google Maps no celular com a rota pronta. |
| 4  | Retornar ao app, clicar novamente em `"Como Chegar"` e selecionar `"Waze"`. | O aplicativo dispara o deep link correspondente (`https://waze.com/ul?q=Av.+Paulista,+1000+-+S%C3%A3o+Paulo`) e abre o app externo do Waze no celular. |

#### Resultados Esperados
- A ação redireciona o usuário para fora do app de forma transparente e aciona os navegadores externos com o endereço pré-formatado na URL.

#### Critérios de Aceitação
- O endereço do paciente no banco de dados deve ser devidamente codificado para URL (URLEncode) para evitar quebras por espaços ou acentos.
- O aplicativo não deve gerar loops ou travar ao invocar aplicativos externos.

---

### CT03 - Transcrição de Voz para Evolução (Speech-to-Text) com Permissão Concedida

#### Objetivo
Validar a facilidade de uso do microfone para ditar a evolução clínica de forma gratuita e nativa com o Speech-to-Text.

#### Pré-Condições
- O usuário está na tela de `RegistroEvolucaoScreen` para preencher os dados de uma sessão.
- O dispositivo possui suporte a reconhecimento de voz e permissão de microfone previamente concedida.

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Clicar no botão de microfone (Speech-to-Text) ao lado do campo de evolução. | O aplicativo exibe uma animação de gravação (ícone de microfone vermelho ou ondas sonoras) indicando que está ouvindo. |
| 2  | Falar pausadamente a frase: `"Paciente realizou exercícios de fortalecimento de quadríceps com carga."` | O texto ditado é transcrito e exibido em tempo real, preenchendo o campo de texto de evolução. |
| 3  | Clicar novamente no botão de microfone. | O aplicativo finaliza o modo de gravação, removendo a animação visual e mantendo o texto transcrito no campo. |
| 4  | Clicar em "Salvar Evolução". | Os dados são gravados com sucesso no Google Sheets e a sessão é atualizada para `"Realizado"`. |

#### Resultados Esperados
- O texto falado é convertido em texto escrito no campo correspondente sem erros de formatação.
- O status do atendimento muda na planilha após a confirmação.

#### Critérios de Aceitação
- A animação visual deve indicar claramente ao usuário se o microfone está capturando áudio ou não.
- A transcrição gerada pelo reconhecimento nativo do celular deve ser inserida sem apagar o texto já existente no campo (concatenação).

---

### CT04 - Transcrição de Voz para Evolução com Permissão Negada

#### Objetivo
Validar o tratamento amigável de erro caso o usuário recuse ou desative o acesso do aplicativo ao microfone do dispositivo.

#### Pré-Condições
- O usuário está na tela de `RegistroEvolucaoScreen`.
- A permissão de microfone não foi concedida anteriormente (ou foi revogada).

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Clicar no botão de microfone. | O aplicativo solicita permissão nativa de gravação de áudio do sistema operacional. |
| 2  | Clicar em `"Negar"` ou `"Recusar"` na pop-up de permissão. | O sistema operacional nega o acesso. O aplicativo exibe uma mensagem amigável de erro na tela: `"Permissão de microfone necessária para transcrição por voz."` |
| 3  | Verificar o campo de texto de evolução. | O campo de texto permanece limpo e apto para digitação manual convencional. |

#### Resultados Esperados
- O aplicativo não trava (*crash*) ao ter a permissão de hardware negada.
- O usuário é orientado adequadamente a conceder a permissão caso queira utilizar a funcionalidade.

#### Critérios de Aceitação
- Exibição de banner, toast ou mensagem na tela contendo exatamente: `"Permissão de microfone necessária para transcrição por voz."`
- O aplicativo deve permitir a digitação manual mesmo após a recusa de permissão do microfone.
