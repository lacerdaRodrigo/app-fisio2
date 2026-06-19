# Changelog — Fisio Home Care

## [Não lançado] — 2026-06-18

### Funcionalidades
- **Editar paciente:** nova tela `tela_editar_paciente.dart` acessível pelo botão "Editar Paciente" no modal de detalhes. Permite atualizar telefone, endereço e toda a anamnese clínica. **Nome, CPF, Data de Nascimento e Gênero ficam travados** (somente leitura) por serem dados de identidade.
  - Novo `RepositorioDadosGoogle.atualizarPaciente()` (reescreve a linha existente na aba `Pacientes`, range `A:S`) e wrapper `atualizarPacienteReal()` no provedor; auditoria/log `EDITAR_PACIENTE`.
- **Aviso de campos definitivos no cadastro:** ao salvar um novo paciente, popup de confirmação avisa que Nome, CPF, Data de Nascimento e Gênero não poderão ser editados depois (opções "Revisar" / "Confirmar e salvar").
- Modal de detalhes: altura máxima ajustada (0.6 → 0.72) para acomodar a nova ação.
- Novos testes: `tela_editar_paciente_test.dart` (6) + 1 no cadastro (popup) + 1 no modal (botão Editar) — total **248 testes**.

## [Não lançado] — 2026-06-17

### CI/CD
- Adicionada pipeline GitHub Actions (`.github/workflows/`):
  - `ci.yml`: lint + testes (`--coverage`) + build web em toda PR para `develop`/`master` e pushes de branches auxiliares
  - `deploy-preview.yml`: deploy em preview channel do Firebase a cada push em `develop` (ambiente de testes)
  - `deploy-prod.yml`: push em `master` incrementa versão (patch), build, deploy live no Firebase e commita o bump (`[skip ci]`)
- Auth do Firebase via Service Account (secret `FIREBASE_SERVICE_ACCOUNT`); Flutter pinado em 3.44.1
- Logs dos workflows em PT-BR com checagem de credencial; ambiente de testes (`develop`) validado e publicando
- Novos atalhos no `Makefile`: `ci-local`, `release-dev`, `release-prod`
- Novo guia `documentacao/CI_CD.md` (fluxo, secrets, uso e troubleshooting)
- Simplificado para fluxo de duas branches: removido `ci.yml` (rodava em toda branch e duplicava execuções); verificação de qualidade agora embutida nos deploys de `develop` e `master`

### UI
- Versão do app agora aparece **fixa em todas as telas** (canto inferior direito), via `VersaoOverlay` no `builder` do `MaterialApp` — antes `appVersao` existia mas não era exibido em lugar nenhum
- Novos testes: `rodape_versao_test.dart` (3) — total 240 testes

### Qualidade
- `flutter analyze` 100% limpo (eram 42 issues): aplicado `dart fix`, removido campo morto `_contaAtual` e constantes renomeadas para `lowerCamelCase` (`versaoAtual`, `historico`, `versaoEsquema`)
- Cobertura global de testes subiu de ~80% para ~85% (237 testes, eram 207)

### Correções de Bugs
- **Índices literais:** `_pacienteDeLinha` e `_agendamentoDeLinha` em `servico_repositorio_dados.dart` agora usam `Paciente.indicesColunas` / `Agendamento.indicesColunas` em vez de `linha[0..18]` — cumpre a regra crítica do projeto
- **Race condition de IDs:** geração de IDs por `length + 1` substituída por `GeradorId.proximo` (baseado no maior número existente) em nova sessão, registro de evolução e auditoria — evita IDs duplicados

### Código
- Novo utilitário `lib/utilitarios/gerador_id.dart` (geração de IDs sequenciais, 100% coberto)

### Testes
- Novos: `gerador_id_test.dart` (8), `preferencias_test.dart` (5), `modal_detalhes_paciente_test.dart` (11), `acoes_agendamento_test.dart` (6)
- Teste da tela de configurações documentado (11 testes, 100% de cobertura)

## [Não lançado] — 2026-06-14

### Segurança
- Removidos `documentacao/chaves.md` e `android/app/google-services.json` do rastreamento do git
- Adicionados ao `.gitignore`: credenciais Firebase, arquivos de debug do Mobilewright
- Removido Client ID hardcoded do `Makefile`

### Correções de Bugs
- **CRÍTICO:** Corrigido null dereference em `obterPlanilhaId` após `limparCache()` — app não crasha mais com planilha incompatível
- **CRÍTICO:** Corrigido `Paciente.copiarCom` que não preservava `dataCadastro` — arquivar/restaurar não corrompe mais a data de cadastro original
- Adicionado `try/catch` em `salvarAgendamento` e `salvarEvolucao` com logging estruturado
- Adicionado `.catchError` em `tentarRestaurarSessao` — falhas de rede não ficam silenciosas
- Índices hardcoded (`linha[10]`, `linha[7]`) em arquivar/restaurar substituídos por referência ao mapa `indicesColunas`

### Código
- Removido código morto (`is int` nunca verdadeiro) em `Paciente.deLinhaPlanilha`
- `Validadores.validarCPF` agora delega para `ValidadorCpf.validar` — algoritmo em um único lugar
- `Paciente.calcularIdade` agora delega para `UtilitariosData.calcularIdade` — lógica em um único lugar
- `Agendamento` agora expõe `indicesColunas` público (mesmo padrão de `Paciente`)
- Mensagem de erro do código 12500 não expõe mais o nome interno do projeto Firebase
- URL `fisio-home-care.local` substituída por mensagem genérica em `VersaoEsquema`

### Testes
- Removido `MockListaPacientesNotifier` que sobrescrevia métodos inexistentes
- Criado `test/helpers/fakes.dart` com `ServicoAutenticacaoGoogleFake` compartilhado
- Corrigidos CPFs inválidos nos testes de modelo (`222.222.222-22` → `529.982.247-25`)
- Corrigido ID duplicado `CT11` no E2E (renomeado segundo para `CT12`)

### Documentação
- Removidos 7 arquivos `.md` redundantes da raiz (ANALISE_MELHORIAS, ROTEIRO_IMPLEMENTACAO, RESUMO_EXECUTIVO, PROXIMOS_PASSOS, FASE1/2/3_IMPLEMENTADO)
- Movido `test/e2e/paciente/sugestoes_cadastro_paciente.md` para `documentacao/`
- Removido `documentacao/REATIVAR_TELAS.md` (nota temporária)
- Removido `test/e2e/login/tela_login_test.md` (duplicado)
- Criado `CHANGELOG.md` unificado (este arquivo)
- Criado `CLAUDE.md` com contexto do projeto para sessões futuras

### Qualidade
- `analysis_options.yaml`: adicionadas regras `cancel_subscriptions`, `close_sinks`, `prefer_const_constructors`, `prefer_final_fields`, `unawaited_futures`; adicionado bloco `analyzer` com erros obrigatórios e excludes para arquivos gerados
- `pubspec.yaml`: atualizada `description`; `google_sign_in` agora usa `^6.2.1`
- `Makefile`: adicionados targets `make test` e `make lint`
- Removidos arquivos de debug desnecessários: `example.test.ts`, `screenshot.png`, `window_dump.xml`, `1.html`, `fisio-web.html`

---

## [1.0.5] — 2026-06-14 (Fases 1–3)

### Fase 3: Testes e Documentação
- 46 testes unitários para `Validadores`
- 23 testes unitários para `VersaoEsquema`
- Dartdoc completo (100%) em `validadores.dart` e `versao_esquema.dart`

### Fase 2: Arquitetura
- Criado `VersaoEsquema` para gerenciar versões do esquema das planilhas
- `Paciente.deLinhaPlanilha` desacoplado de índices hardcoded via `indicesColunas`
- Validação automática de versão em `obterPlanilhaId`
- Logging estruturado com `developer.log` em operações críticas

### Fase 1: Segurança
- Client ID OAuth movido para variável de ambiente `GOOGLE_OAUTH_CLIENT_ID_WEB`
- Criados validadores: CPF, telefone, data de nascimento, endereço, nome
- Validação integrada em `Paciente.deLinhaPlanilha`
- Substituído `print()` por `developer.log()` em todo o projeto
- Habilitado lint `avoid_print`
