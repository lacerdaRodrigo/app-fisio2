# Casos de Teste: Fluxo de Login, LGPD e Persistência

Este documento apresenta a suíte de casos de teste para o fluxo de autenticação, termos de consentimento da LGPD e persistência de sessão do aplicativo de Fisioterapia Domiciliar. Cenários offline estão documentados como planejamento futuro.

---

### CT01 - Tentativa de Login sem Consentimento da LGPD

#### Objetivo
Validar que o sistema impede o login se o usuário não aceitar os termos de consentimento da LGPD, exibindo uma mensagem de erro adequada.

#### Pré-Condições
- O aplicativo está instalado e aberto na tela de login.
- O checkbox de consentimento da LGPD está desmarcado.

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Clicar no botão "Entrar com Google" sem marcar o checkbox de consentimento. | O sistema impede o login e exibe a mensagem de erro: `"Por favor, aceite os termos de consentimento da LGPD para continuar."` |

#### Resultados Esperados
- O fluxo de autenticação com o Google Sign-In não é iniciado.
- A mensagem de erro é exibida de forma visível na tela.
- O usuário permanece na tela de login.

#### Critérios de Aceitação
- Deve exibir a mensagem de erro sugerida: `"Por favor, aceite os termos de consentimento da LGPD para continuar."` (ou bloquear a ação caso o botão esteja desabilitado, apresentando feedback de que o aceite é obrigatório).
- O estado de carregamento do banco de dados ou a janela de login do Google não devem ser exibidos.

---

### CT02 - Leitura e Validação dos Termos de Consentimento da LGPD

#### Objetivo
Validar que o termo de consentimento da LGPD é exibido ao marcar o checkbox e que cada seção individual (Objetivo, Natureza dos Dados, Armazenamento e Segurança, Direitos do Titular, Responsabilidades, Consentimento) exibe o texto correto para validação do usuário.

#### Pré-Condições
- O aplicativo está instalado e aberto na tela de login.
- O checkbox de consentimento da LGPD está desmarcado.

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Marcar o checkbox de consentimento da LGPD. | O checkbox é marcado e o link/botão para visualizar os Termos de Consentimento é habilitado ou exibido. |
| 2  | Clicar no link/botão para visualizar os Termos de Consentimento. | A interface de visualização dos Termos de Consentimento é aberta. |
| 3  | Clicar em cada seção do termo para expandir/ler os textos. | Cada seção (Objetivo, Natureza dos Dados, Armazenamento, Direitos, Responsabilidades e Consentimento) exibe seu respectivo texto conforme a especificação. |
| 4  | Fechar a visualização do termo de consentimento. | O termo é fechado e o usuário retorna à tela de login, mantendo o checkbox no estado marcado. |

#### Resultados Esperados
- Todos os termos e seções são acessados e lidos com sucesso.
- O estado marcado do checkbox é preservado após fechar a visualização dos termos.

#### Critérios de Aceitação
- A visualização dos termos deve disponibilizar todas as seções descritas no documento de especificação (`LOGIN_SCREEN_SPEC.md`).
- A navegação entre as seções ou a rolagem de texto deve ocorrer de forma fluida.

---

### CT03 - Fluxo Completo de Login com Criação de Banco de Dados

#### Objetivo
Validar o fluxo completo de login após a aceitação dos termos da LGPD, certificando-se de que os estados de loading para criação/validação do banco de dados no Google Sheets ocorrem corretamente e que a sessão é estabelecida com sucesso exibindo o nome do usuário logado.

#### Pré-Condições
- O aplicativo está instalado e aberto na tela de login.
- O usuário possui uma conta Google válida para autenticação.
- O checkbox de consentimento da LGPD está desmarcado.

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Marcar o checkbox de consentimento da LGPD. | O botão de login "Entrar com Google" torna-se ativo e habilitado para clique. |
| 2  | Clicar no botão "Entrar com Google". | No Web, o botão oficial do Google inicia o fluxo de autenticação OAuth para seleção de conta. |
| 3  | Concluir a autenticação na janela do Google. | O aplicativo reconhece a conta conectada e exibe a ação explícita "Autorizar Drive e Sheets". |
| 4  | Clicar em "Autorizar Drive e Sheets". | O navegador abre a autorização de escopos de dados a partir de uma ação direta do usuário. |
| 5  | Aguardar a finalização do processamento. | O sistema cria/valida a planilha e redireciona para a tela de Início (Dashboard). |
| 6  | Verificar o cabeçalho/saudação no Dashboard. | O Dashboard é carregado com sucesso exibindo a saudação dinâmica personalizada com o nome correto do usuário logado. |

#### Resultados Esperados
- O login é concluído com sucesso.
- A infraestrutura de dados no Google Sheets é criada/validada após autorização explícita de Drive/Sheets.
- O Dashboard do profissional é exibido exibindo o nome associado à conta Google autenticada.

#### Critérios de Aceitação
- O botão "Entrar com Google" deve mudar seu estado visual para ativo imediatamente após a marcação do checkbox.
- O carregamento da criação/validação do banco de dados deve ocorrer após a autorização dos escopos de dados.
- O nome exibido na saudação do Dashboard deve coincidir exatamente com o nome da conta Google utilizada para fazer login.

---

### CT04 - Login Automático (Persistência de Sessão)

#### Objetivo
Validar que um usuário já autenticado anteriormente seja redirecionado diretamente para o Dashboard ao abrir o aplicativo, sem passar pela tela de login, respeitando a persistência da sessão local.

#### Pré-Condições
- O usuário já realizou o primeiro login com sucesso utilizando uma conta Google.
- A sessão ativa é válida no dispositivo (persistência definida de longa duração, ex: 24 horas).

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Fechar completamente o aplicativo (remover da memória/background). | O aplicativo é encerrado. |
| 2  | Abrir o aplicativo novamente. | O aplicativo verifica a existência e validade do token de sessão localmente. |
| 3  | Aguardar o carregamento inicial (Splash Screen). | O sistema pula a tela de login e redireciona o usuário de forma automática e transparente diretamente para o Dashboard. |

#### Resultados Esperados
- O usuário acessa o Dashboard sem a necessidade de interações com botões de login ou aceite de termos repetidos.

#### Critérios de Aceitação
- O redirecionamento deve ocorrer de forma fluida sem exibir flashes rápidos ("piscadas") da tela de login.
- A sessão deve persistir ativa mesmo após reinicializações completas do dispositivo.

---

### CT05 - Cancelamento da Autenticação pelo Usuário

#### Objetivo
Validar o comportamento do aplicativo caso o usuário clique em "Entrar com Google", mas decida cancelar ou fechar a pop-up de seleção de conta do Google.

#### Pré-Condições
- O aplicativo está aberto na tela de login.
- O checkbox de consentimento da LGPD está marcado.

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Clicar no botão "Entrar com Google". | O sistema exibe a interface nativa/pop-up do Google Sign-In para seleção de conta. |
| 2  | Cancelar o fluxo de autenticação (clicar em voltar, fechar a pop-up ou tocar fora da janela). | A janela do Google é encerrada. O aplicativo remove o indicador de carregamento e retorna ao estado inicial de login. |

#### Resultados Esperados
- O aplicativo cancela a operação de login com segurança.
- O usuário permanece na tela de login com o checkbox marcado e o botão pronto para uma nova tentativa.
- Nenhum travamento ou encerramento inesperado (crash) do app ocorre.

#### Critérios de Aceitação
- O estado de `isLoading` deve ser desativado imediatamente após o cancelamento detectado pela API do Google.
- Nenhuma mensagem de erro técnica e incompreensível deve ser exposta ao usuário final.

---

### CT06 - Inicialização Offline e Sincronização de Dados Posterior (Planejado)

#### Objetivo
Validar, em uma versão futura, que um usuário com login ativo consiga inicializar o app sem conectividade à internet, operando sobre um banco de dados local e sincronizando com o Google Sheets quando a internet voltar.

> Status atual: ainda não implementado. A versão atual depende de conectividade para carregar e persistir dados no Google Sheets.

#### Pré-Condições
- O usuário possui uma sessão ativa válida.
- O dispositivo está totalmente sem acesso à internet (Modo Avião ativado).

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Abrir o aplicativo em modo offline. | Na versão atual, o app deve exibir erro amigável de conectividade ao tentar carregar dados reais. |
| 2  | Realizar uma ação de escrita sem internet. | Na versão atual, a gravação deve falhar com feedback ao usuário, sem prometer sincronização posterior. |
| 3  | Reestabelecer a conexão com a internet. | O usuário pode tentar novamente a operação manualmente. |

#### Resultados Esperados
- O comportamento atual não deve perder dados já persistidos no Google Sheets.
- A ausência de offline persistente deve ser clara para o usuário.

#### Critérios de Aceitação
- O aplicativo não deve prometer sincronização automática enquanto a fila offline não existir.
- Uma futura implementação de modo offline deve incluir indicador de pendência e reconciliação sem duplicidade.

---

### CT07 - Revogação de Sessão (Logout)

#### Objetivo
Validar que ao realizar o logout (sair) no aplicativo, a sessão local seja completamente destruída, limpando dados sensíveis e redirecionando o usuário de volta à tela de login.

#### Pré-Condições
- O usuário está autenticado e visualizando a tela do Dashboard.

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | Acessar o menu/perfil do usuário e clicar no botão "Sair" (Logout). | O sistema desconecta a conta do Google Sign-In e apaga o token de sessão local. |
| 2  | Confirmar o encerramento da sessão. | O aplicativo redireciona o usuário para a tela de login. |
| 3  | Verificar o estado da tela de login. | O checkbox de consentimento da LGPD está desmarcado e o botão de login está desabilitado. |
| 4  | Fechar e reabrir o aplicativo. | O aplicativo inicia diretamente na tela de login, exigindo novo fluxo completo de autenticação. |

#### Resultados Esperados
- A sessão é encerrada de forma definitiva e segura.
- Nenhum resíduo de credenciais permite o bypass da tela de login sem uma nova autenticação voluntária.

#### Critérios de Aceitação
- Os dados do cache local de atendimentos e pacientes devem ser protegidos/inacessíveis após o logout.
- O token local deve ser completamente destruído para evitar logins acidentais ou restauração não autorizada.
