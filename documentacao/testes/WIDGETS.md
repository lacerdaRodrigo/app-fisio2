# 🎨 Testes de Widget (135 testes)

Testes de componentes visuais: telas, componentes reutilizáveis e utilitários
de UI, interação do usuário e estados visuais.

---

## test/widgets/telas/ (118 testes | 9 arquivos)

Cada arquivo de teste representa uma tela da aplicação.

---

### tela_dashboard_test.dart (16 testes — 100% de cobertura)

**Tela:** Início (home após login) — cabeçalho, cards de resumo, agenda do dia,
pendências, navegação inferior e FABs.

```dart
// Estados de carregamento
✓ Estado carregando exibe indicador de progresso
✓ Estado erro exibe mensagem e botão "Tentar novamente" (reexecuta carga)

// Cabeçalho e cards
✓ Cabeçalho mostra nome e inicial do usuário
✓ Tocar no avatar abre as Configurações
✓ Cards de resumo exibem títulos e contagens (cadastrados, ativos)
✓ Agenda vazia exibe estado "Tudo limpo!"

// Interação com cards
✓ Card "Pacientes Cadastrados" abre a aba Pacientes
✓ Card "Pacientes Ativos" abre a aba Pacientes
✓ Card "Total de Evoluções" navega para o histórico
✓ Card "Agenda do Dia" rola a lista sem erros

// Navegação inferior e FAB
✓ Barra inferior alterna abas (Início/Sessões/Pacientes) e mostra os FABs corretos
✓ FAB "Novo Paciente" abre o cadastro de paciente
✓ FAB "Nova Sessão" abre a tela de nova sessão

// Agenda e pendências
✓ Lista sessões de hoje com status Agendado e Atrasado
✓ Pendências de dias anteriores aparecem (com paciente ausente → "Paciente não encontrado")
✓ Menu de ações da sessão abre opções e diálogo de confirmação
```

> Usa notifiers de teste (`CarregamentoComEstado`, `PacientesComDados`,
> `AgendamentosComDados`) para injetar o estado "carregado" e evitar a chamada
> real ao Google Sheets disparada no `initState`.

---

### tela_nova_sessao_test.dart (9 testes — 100% de cobertura)

**Tela:** Agendamento de nova sessão — seleção de paciente, data, horário,
valor e observações.

```dart
// Renderização
✓ Exibe título, campos e valor padrão preenchido (150,00)
✓ Sem pacientes ativos exibe aviso de cadastro

// Validação
✓ Agendar sem selecionar paciente mostra erro de validação
✓ Paciente selecionado sem data/hora não agenda (retorno silencioso)

// Seletores e agendamento
✓ Selecionar data preenche o campo de data
✓ Data/horário retroativo exibe mensagem de erro
✓ Agendamento válido salva e volta para a tela anterior
✓ Falha ao salvar exibe snackbar de erro

// Navegação
✓ Botão fechar (X) aciona o retorno
```

> Usa `FakeRepositorioDadosGoogle` / `RepositorioQueFalha` para os caminhos de
> sucesso e erro. O seletor de horário é acionado em modo de digitação, com o
> finder escopado ao `Dialog` (evita capturar os campos da tela por trás);
> `MediaQuery.alwaysUse24HourFormat` força o formato 24h.

---

### tela_login_test.dart (6 testes)

**Tela:** Login com Google — checkbox LGPD, links legais, botão de entrada.

```dart
✓ Exibir título, subtítulo e botão "Entrar com Google"
✓ Exibir checkbox de termos e os links legais (Termos de Uso, Política LGPD)
✓ Checkbox começa desmarcado e sem mensagem de erro
✓ Tocar no checkbox marca os termos como aceitos
✓ Entrar sem aceitar os termos exibe erro e não chama o serviço
✓ Aceitar termos e entrar chama o serviço e exibe indicador de carregamento
```

> Usa `ServicoAutenticacaoGoogleControlavel` (fake com `Completer`) para
> inspecionar o estado de carregamento sem disparar a navegação ao dashboard.

---

### tela_cadastro_paciente_test.dart (22 testes — 100% de cobertura)

**Tela:** Cadastro de novo paciente — formulário com validação de campos obrigatórios.

#### Seção Endereço (6 testes)
```dart
✓ Exibir "Toque para preencher endereço" quando vazio
✓ Tocar no endereço abre modal com 4 campos
  • Rua/Avenida *
  • Número
  • Bairro *
  • Cidade *
✓ Preencher campos e confirmar atualiza endereço exibido
✓ Campos obrigatórios impedem confirmar sem preenchimento
✓ Endereço com apenas rua e cidade é composto corretamente
✓ Cancelar não altera o endereço
```

#### Seção Anamnese Clínica (3 testes)
```dart
✓ Exibir seção de Anamnese com todos os campos
✓ Permitir salvar paciente sem preencher anamnese
✓ Bloquear digitação de valor > 10 na escala de dor
```

#### Validação de Campos Obrigatórios — CT-F (6 testes)
```dart
✓ CT-F1: 5 campos vazios → dialog com 5 itens
  (Nome, CPF, Telefone, Data de Nascimento, Endereço)
✓ CT-F2: Só Nome preenchido → dialog com 4 itens
✓ CT-F3: Só CPF preenchido → dialog com 4 itens
✓ CT-F4: Nome+CPF+Telefone → dialog com 2 itens
  (Faltam Data e Endereço)
✓ CT-F5: Todos preenchidos → salva sem dialog
✓ CT-F6: Dialog fecha ao clicar OK
```

#### Cobertura adicional (7 testes)
```dart
✓ Botão fechar (X) aciona o retorno
✓ Selecionar gênero no dropdown atualiza a seleção
✓ Validação do formulário aceita o gênero selecionado
✓ Telefone com menos de 10 dígitos é sinalizado
✓ CPF já cadastrado exibe snackbar de erro
✓ Salvar com todos os campos gera próximo ID (P005 → P006) e persiste a anamnese
✓ Falha ao salvar exibe snackbar de erro
```

> Usa `FakeRepositorioDadosGoogle` / `RepositorioQueFalha` e `PacientesComDados`
> para os caminhos de sucesso, erro e CPF duplicado. Os testes que preenchem
> todos os campos montam a tela numa superfície alta (1000×4000) para evitar
> scroll e usam as `Key`s dos campos.

---

### tela_pacientes_test.dart (12 testes — 100% de cobertura)

**Tela:** Lista de pacientes com filtros (Todos/Ativos/Arquivados), busca e
modal de detalhes.

```dart
// Filtro de arquivados (originais)
✓ Exibir apenas pacientes ativos por padrão
✓ Toggle "Arquivados" exibe inativos
✓ Desativar o toggle volta a ocultar arquivados

// Badge e contagem
✓ Badge "Arquivado" exibido no card
✓ Contagem correta de pacientes ativos ("2 ativos")
✓ Filtro "Todos" exibe contagem total ("2 total")

// Busca
✓ Busca filtra por nome
✓ Busca filtra por CPF
✓ Botão limpar restaura a lista completa
✓ Lista vazia exibe estado vazio ("Nenhum paciente encontrado.")

// Interação
✓ Tocar no card abre o modal de detalhes (seções Telefone/Endereço)
✓ Mudar filtroInicial atualiza o filtro (didUpdateWidget)
```

> Usa `PacientesNotifierComDados` para injetar a lista. A busca por CPF usa um
> paciente com CPF numérico (o filtro de CPF é case-sensitive).

---

### tela_registro_evolucao_test.dart (23 testes — 100% de cobertura)

**Tela:** Registro de evolução clínica — criar novo, editar existente, transcrição
por voz. *(O arquivo também cobre a timeline `TelaHistoricoEvolucoes`.)*

```dart
// Modos (originais)
✓ Modo novo: título "Registrar Evolução" + botão "Salvar Evolução"
✓ Modo edição (<24h): título "Editar Evolução" + botão "Atualizar Evolução"
✓ Pré-preenche campos a partir da evolução existente
✓ Sem banner de bloqueio quando <24h
✓ Modo readonly (>24h): exibe banner de bloqueio e oculta o botão salvar
✓ Timeline: botão "Editar" só aparece para evoluções <24h

// Inicialização com agendamento
✓ Usa horários do agendamento e exibe o horário no cabeçalho

// Interação de campos
✓ Status "Ausente" exibe "Condição: Faltou"
✓ Altera local de atendimento
✓ Altera condição clínica
✓ Seleciona horários reais pelo time picker (início e fim)

// Validação e salvamento
✓ Salvar sem evolução técnica mostra erro de validação
✓ Salvar nova evolução com sucesso volta à tela anterior
✓ Editar evolução existente atualiza com sucesso
✓ Falha ao salvar exibe snackbar de erro
✓ Salvar como Ausente grava condição "Faltou"

// Navegação e microfone
✓ Botão voltar aciona o retorno
✓ Microfone indisponível exibe aviso
✓ Microfone disponível transcreve (resultado final) e encerra
```

> Microfone testado com um fake de `SpeechToTextPlatform` (dev-dependency
> `speech_to_text_platform_interface`); o timer interno de "final timeout" (2s)
> é drenado descartando a tela e avançando o relógio. Time picker em modo de
> digitação com finder escopado ao `Dialog`.

---

### tela_sessoes_test.dart (12 testes — 100% de cobertura)

**Tela:** Histórico de sessões com filtros por período/status, busca e duas
visualizações (lista e por paciente).

```dart
// Filtros e busca (originais)
✓ Filtro "Canceladas" exibe apenas sessões canceladas
✓ Filtro "Faltas" exibe apenas faltas (com/sem aviso)
✓ Busca por nome do paciente filtra a lista
✓ Agrupamento por paciente (visualização "Por paciente")
✓ Visualização de histórico (lista com status, data, hora, paciente)

// Busca e estado vazio
✓ Botão limpar apaga o termo de busca
✓ Estado vazio mostra o rótulo de cada filtro (todas, hoje, futuras,
  pendentes, canceladas, faltas, realizadas)

// Filtros por período e status
✓ Filtro "Futuras" mostra apenas sessões futuras
✓ Filtro "Pendentes" mostra sessões atrasadas/de dias anteriores
✓ Filtro "Realizadas" mostra apenas sessões realizadas
✓ Filtro "Hoje" mostra sessões do dia

// Ações da sessão
✓ Menu de ações na lista abre o diálogo de confirmação
✓ Visão por paciente ordena vários pacientes e aciona o menu de ações
```

> Usa notifiers de teste (`PacientesNotifierComDados`,
> `AgendamentosNotifierComDados`) para injetar pacientes e agendamentos.
> Chips fora da tela são revelados com `tester.ensureVisible` antes do toque.

---

### tela_configuracoes_test.dart (11 testes — 100% de cobertura)

**Tela:** Configurações — valor padrão da sessão, dados/privacidade
(planilha e termos), conta (logout) e logs de auditoria.

```dart
// Conta e logout (originais)
✓ Exibe o cartão "Conta" com o botão "Sair da conta" e descrição
✓ Botão "Sair da conta" abre diálogo de confirmação ("Tem certeza?")
✓ Cancelar o diálogo mantém na TelaConfiguracoes
✓ Exibe o título "Configurações"
✓ Confirmar logout navega para a TelaLogin

// Valor padrão da sessão
✓ Salvar valor vazio mostra aviso ("Informe um valor padrão.")
✓ Salvar valor com sucesso mostra confirmação ("Valor padrão salvo.")
✓ Falha ao salvar exibe snackbar de erro

// Dados e privacidade
✓ Logs de auditoria são exibidos quando existem
✓ Visualizar termos abre e fecha o diálogo (LGPD)
✓ Abrir planilha com falha exibe snackbar de erro
```

> Usa `FakeRepoConfig` / `RepoConfigQueFalha` para os caminhos de sucesso e
> erro ao salvar o valor padrão, `LogsComDados` para injetar os logs de
> auditoria e `_PlanilhaIdFixo` para o ID da planilha. A abertura da planilha
> é testada via mock do canal `plugins.flutter.io/url_launcher` retornando
> `false` (falha de abertura).

---

### tela_historico_geral_evolucoes_test.dart (7 testes — 100% de cobertura)

**Tela:** Histórico geral de todas as evoluções clínicas, com busca e duas
visualizações (lista e por paciente).

```dart
✓ Buscar evolução por texto clínico
✓ Agrupar evoluções por paciente (visualização "Por paciente")
✓ Estado vazio quando não há evoluções ("Nenhuma evolução registrada ainda.")
✓ Botão limpar restaura a lista completa
✓ Cores de condição (Piora e Faltou) são exibidas
✓ Visão por paciente ordena vários pacientes (comparador de nomes)
✓ Botão voltar aciona o retorno
```

---

## test/widgets/componentes/ (11 testes | 1 arquivo)

### modal_detalhes_paciente_test.dart (11 testes)

**Componente:** Bottom sheet de detalhes do paciente — dados cadastrais,
anamnese, última evolução, rotas (Maps/Waze) e ações de arquivar/restaurar.

```dart
✓ Exibe nome, telefone, endereço e seções clínicas preenchidas
✓ Paciente ativo mostra a ação "Arquivar Paciente"
✓ Paciente arquivado mostra a ação "Restaurar Paciente"
✓ Última evolução é exibida para paciente ativo
✓ Abrir opções de rota mostra Google Maps e Waze
✓ Abrir rota com falha exibe snackbar
✓ Cancelar o diálogo de arquivar mantém o modal
✓ Arquivar com sucesso fecha o modal e mostra confirmação
✓ Arquivar com erro exibe snackbar de erro
✓ Restaurar com sucesso fecha o modal e mostra confirmação
✓ Restaurar com erro exibe snackbar de erro
```

> Usa `FakeRepoModal` / `RepoModalQueFalha` para os caminhos de sucesso e erro
> de arquivar/restaurar, `EvolucoesComDados` para a última evolução e mock do
> canal `url_launcher` para a falha de rota. O botão de rota é revelado com
> `tester.ensureVisible` antes do toque.

---

## test/widgets/utilitarios/ (6 testes | 1 arquivo)

### acoes_agendamento_test.dart (6 testes — 96% de cobertura)

**Utilitário:** `executarAcaoAgendamento` — registrar evolução ou aplicar
desfecho (falta/cancelamento) a um agendamento.

```dart
✓ registrarEvolucao sem paciente não navega
✓ registrarEvolucao com paciente navega para a tela
✓ Ação de falta abre diálogo de confirmação
✓ Cancelar o diálogo não atualiza a sessão
✓ Confirmar atualiza a situação e exibe snackbar
✓ Falha ao atualizar exibe snackbar de erro
```

> Usa `FakeRepoAcoes` / `RepoAcoesQueFalha` e `AgendamentosComDados`. A ação é
> disparada a partir de um host `Consumer` que fornece o `WidgetRef`.

---

## Padrão: testWidgets + Arrange-Act-Assert

```dart
testWidgets('deve exibir apenas pacientes ativos por padrão', (tester) async {
  // Arrange: criar widget tree com dados
  await tester.pumpWidget(_criarApp([
    _pacienteAtivo('P001', 'João Ativo'),
    _pacienteArquivado('P002', 'Maria Arquivada'),
  ]));
  await tester.pumpAndSettle();

  // Act: verificar estado inicial
  // (não há ação aqui, é estado padrão)

  // Assert: validar resultado visual
  expect(find.text('João Ativo'), findsOneWidget);
  expect(find.text('Maria Arquivada'), findsNothing);
});
```

---

## Mocks Reutilizados

**Arquivo:** `test/unitarios/auxiliares/fakes.dart`

```dart
✓ ServicoAutenticacaoGoogleFake
  • Mock do login Google sem chamadas reais

✓ RepositorioDadosGoogleFake
  • Mock do repositório Sheets API
```

---

## Como Rodar Apenas Widgets

```bash
flutter test test/widgets/

# Um arquivo específico
flutter test test/widgets/telas/tela_pacientes_test.dart
```

---

## Cobertura de UI

| Tela | Status | Testes | Cobertura |
|---|---|---|---|
| Login | ✅ | 6 | Termos LGPD, login Google |
| Dashboard | ✅ | 16 | 100% |
| Cadastro Paciente | ✅ | 22 | 100% |
| Lista Pacientes | ✅ | 12 | 100% |
| Nova Sessão | ✅ | 9 | 100% |
| Registro Evolução | ✅ | 23 | 100% |
| Sessões/Agenda | ✅ | 12 | 100% |
| Configurações | ✅ | 11 | 100% |
| Histórico Evoluções | ✅ | 7 | 100% |
| Modal Detalhes Paciente | ✅ | 11 | 93,9% |
| Ações de Agendamento | ✅ | 6 | 96,2% |
| **Total** | **✅** | **135** | Telas principais + componentes/utilitários |
