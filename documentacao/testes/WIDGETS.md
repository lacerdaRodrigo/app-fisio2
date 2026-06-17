# 🎨 Testes de Widget (40 testes)

Testes de componentes visuais: telas, interação do usuário, estados UI.

---

## test/widgets/telas/ (40 testes | 6 arquivos)

Cada arquivo de teste representa uma tela da aplicação.

---

### tela_cadastro_paciente_test.dart (6 testes)

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

---

### tela_pacientes_test.dart (5 testes)

**Tela:** Lista de pacientes com filtros e busca.

```dart
✓ Exibir apenas pacientes ativos por padrão
  • Pacientes com situacao = 'Ativo' visíveis
  • Pacientes com situacao = 'Arquivado' ocultos

✓ Toggle "Arquivados" exibe inativos
  • Clica no toggle
  • Visualiza apenas pacientes arquivados

✓ Badge "Arquivado" exibido no card
  • Card mostra indicador visual

✓ Contagem correta de pacientes ativos
  • Counter/badge atualiza

✓ Busca por nome/CPF funciona
  • TextField de busca filtra resultados
```

---

### tela_registro_evolucao_test.dart (6 testes)

**Tela:** Registro de evolução clínica — criar novo ou editar existente.

```dart
✓ Modo "Registrar Evolução" (novo)
  • Título exibe "Registrar Evolução"
  • Botão "Salvar Evolução"

✓ Modo "Editar Evolução" (existente)
  • Título exibe "Editar Evolução"
  • Botão "Atualizar Evolução"

✓ Pré-preenchimento ao editar
  • Texto clínico carregado
  • Protocolo selecionado
  • Datas preenchidas

✓ Banner de bloqueio (editar após 24h)
  • Evolução com > 24h mostra banner
  • Botão editar desabilitado

✓ Botão editar/atualizar contexto-sensível
  • Se < 24h: botão ativo
  • Se > 24h: botão desabilitado

✓ Reavaliação vs avaliação
  • Dropdown com protocolos corretos
```

---

### tela_sessoes_test.dart (5 testes)

**Tela:** Histórico de sessões agendadas, realizadas, canceladas, faltas.

```dart
✓ Filtro "Canceladas" funciona
  • Exibe apenas sessões com Situacao = 'Cancelado*'

✓ Filtro "Faltas" funciona
  • Exibe apenas sessões com 'Faltou com/sem aviso'

✓ Busca por nome do paciente
  • TextField filtra por nome

✓ Agrupamento por paciente
  • Sessões de mesmo paciente agrupadas

✓ Visualização de histórico
  • Lista com status, data, hora, paciente visível
```

---

### tela_configuracoes_test.dart (4 testes)

**Tela:** Configurações, perfil do usuário, logout.

```dart
✓ Exibir card "Conta" com botão "Sair"
  • Card visível
  • Botão "Sair da conta" presente
  • Descrição: "Desconecta o Google e volta ao login"

✓ Botão "Sair" abre diálogo de confirmação
  • Clica em "Sair da conta"
  • Dialog aparece: "Tem certeza?"
  • Opções: "Cancelar" e "Sair"

✓ Cancelar mantém na tela
  • Clica em "Cancelar"
  • Dialog fecha
  • Continua em TelaConfiguracoes

✓ Título "Configurações" exibido
  • Header com título correto
```

---

### tela_historico_geral_evolucoes_test.dart (2 testes)

**Tela:** Timeline de todas as evoluções clínicas, agrupadas por paciente.

```dart
✓ Buscar por texto clínico
  • TextField filtra por conteúdo
  • Resultados atualizados em tempo real

✓ Agrupar por paciente
  • Evoluções do mesmo paciente agrupadas
  • Expansão/colapso de grupos
```

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
| Cadastro Paciente | ✅ | 6 | Validação, endereço, anamnese |
| Lista Pacientes | ✅ | 5 | Filtros, busca, status |
| Registro Evolução | ✅ | 6 | Criar/editar, bloqueios, protocolo |
| Sessões/Agenda | ✅ | 5 | Filtros, busca, agrupamento |
| Configurações | ✅ | 4 | Logout, diálogos |
| Histórico Evoluções | ✅ | 2 | Busca, agrupamento |
| **Total** | **✅** | **40** | Telas principais cobertas |

---

## Telas SEM Testes

As telas abaixo não têm testes de widget porque:
- **TelaDashboard:** Complexa (múltiplos cards, navegação). Cobertura via integração com telas secundárias.
- **TelaNovaSessao:** Depende de TelaPacientes. Testar agendamento via tela_sessoes.dart.

Podem ser adicionadas em futuras iterações se necessário.
