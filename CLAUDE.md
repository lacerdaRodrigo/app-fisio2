# Fisio Home Care — Contexto para Claude

## O que é este projeto

App Flutter de Fisioterapia Domiciliar. O backend é serverless: usa **Google Sheets API** como banco de dados (modelo BYODB — o fisioterapeuta conecta a própria conta Google). Não há servidor próprio. Autenticação via OAuth 2.0 (Google Sign-In). Hospedagem web no Firebase Hosting.

## Stack

- **Flutter + Dart** (Material 3, null-safety)
- **Riverpod 3** para estado e injeção de dependência
- **Google Sheets API v4** como banco de dados
- **Google Drive API** para localizar a planilha por nome
- **Google Sign-In** para OAuth

## Estrutura de pastas

```
lib/
  main.dart
  telas/           # Telas UI
  componentes/     # Widgets reutilizáveis (design_system.dart é o central)
  provedores/      # Riverpod: autenticacao + dados
  modelos/         # Paciente, Agendamento, Evolucao
  servicos/        # Google Sheets, Drive, Auth, Preferencias
  utilitarios/     # Validadores, UtilitariosData, ValidadorCpf, MensagensErroGoogle

test/
  helpers/fakes.dart   # Fakes compartilhados (ServicoAutenticacaoGoogleFake)
  utilitarios/         # Testes de validadores e data
  modelos/             # Testes de Paciente, Agendamento, Evolucao
  provedores/          # Testes de AutenticacaoNotificador, ProvedoresDados
  telas/               # Testes de widgets (tela_cadastro_paciente, etc.)
  servicos/            # Testes de VersaoEsquema
```

## Banco de dados: Google Sheets

A planilha chama `__saas_fisio_db__` e tem 5 abas:

| Aba           | Descrição                     |
|---------------|-------------------------------|
| `Pacientes`   | 19 colunas — dados do paciente |
| `Agenda`      | 9 colunas — agendamentos       |
| `Evolucoes`   | 14 colunas — evoluções clínicas |
| `Configuracoes` | Chave/Valor (configurações do app) |
| `Auditoria`   | Log de operações               |

Os índices de coluna estão mapeados em:
- `Paciente.indicesColunas` (`lib/modelos/paciente.dart`)
- `Agendamento.indicesColunas` (`lib/modelos/agendamento.dart`)
- `VersaoEsquema.obterIndicesColunas(versao)` (`lib/servicos/versao_esquema.dart`)

**Nunca use índice numérico literal** (ex: `linha[10]`) para acessar colunas. Use sempre os mapas acima.

## Credenciais e segurança

- O Client ID OAuth deve estar na variável de ambiente `GOOGLE_OAUTH_CLIENT_ID_WEB`
- Nunca commitar `android/app/google-services.json` ou `documentacao/chaves.md` (já estão no `.gitignore`)
- Para rodar localmente: `./run-dev.sh` (carrega `.env`) ou `make dev-android`
- O `.env` real nunca é commitado; use `.env.example` como template

## Padrões de código

### Estado (Riverpod)
- Provedores em `lib/provedores/`
- `provedorAutenticacao` → `AutenticacaoNotificador` → gerencia login Google
- `provedorRepositorioDados` → `RepositorioDadosGoogle` (null se não autenticado)
- Carregar dados: `carregarDadosReais(ref)` em `provedores_dados.dart`
- Salvar: `salvarPacienteReal`, `salvarAgendamentoReal`, `salvarEvolucaoReal`, etc.

### Logging
- **Nunca usar `print()`** — regra de lint habilitada
- Usar sempre `developer.log('msg', error: e, stackTrace: st, name: 'NomeClasse')`

### Erros na UI
- SnackBars de erro devem mostrar **mensagem genérica** ao usuário, nunca `$e` direto
- Logar o detalhe do erro com `developer.log`

### Validação
- Usar `Validadores` de `lib/utilitarios/validadores.dart`
- `Validadores.validarCPF` delega para `ValidadorCpf.validar`
- `Paciente.calcularIdade` delega para `UtilitariosData.calcularIdade`
- Nunca duplicar algoritmos — há uma única fonte de verdade para cada

## Bugs conhecidos / trade-offs

- `Evolucao.deLinhaPlanilha` ainda usa índices literais (`linha[0..13]`) — a ser refatorado
- Geração de IDs de agendamento/evolução por `length + 1` tem potencial race condition em uso concorrente
- `FisioCores.secondary` definida mas não usada (código morto, a remover)
- `BackdropFilter` reimplementado inline em algumas telas em vez de usar `FisioGlass`
- Lógica de popup de ação de agendamento duplicada em `tela_dashboard.dart` e `tela_sessoes.dart`

## Testes

```bash
flutter test                    # Todos os testes unitários
flutter test test/utilitarios/  # Só validadores e data
make lint                       # flutter analyze
make test                       # flutter test
```

## Publicar

```bash
make prod-web      # Web → Firebase Hosting (incrementa versão automaticamente)
make prod-android  # APK release
```

## Documentação do projeto

| Arquivo | Conteúdo |
|---|---|
| `README.md` | Como rodar, publicar, estrutura |
| `CHANGELOG.md` | Histórico de mudanças |
| `documentacao/MODELO_DADOS.md` | Estrutura das abas do Google Sheets |
| `documentacao/DIAGRAMA_FLUXOS.md` | Diagrama de navegação do app |
| `documentacao/SEGURANCA_E_DADOS.md` | Modelo BYODB, LGPD, OAuth |
| `documentacao/IMPLEMENTAR.md` | Backlog priorizado de features |
| `documentacao/ESPECIFICACOES_TELAS.md` | Requisitos funcionais das telas |
| `QA/qa.md` | Instruções de QA |
