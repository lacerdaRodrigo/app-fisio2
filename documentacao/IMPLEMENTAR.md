# Plano de Implementação — Fisio Home Care

Status atual do projeto: **MVP funcional completo + Revisão de Qualidade Implementada** (commit 3ea292c, 2026-06-14)  
Base: Flutter + Riverpod + Google Sheets API + Google Sign-In

---

## 📊 Avaliação de Qualidade (2026-06-14)

**Nota Geral: 7.8/10** ⭐⭐⭐⭐

| Dimensão | Nota | Status |
|---|---|---|
| **Segurança** | 8.5/10 | ✅ Credenciais fora do git, validação de entrada, logging estruturado. Falta: validação de API endpoints Sheets; BYODB depende da conta Google |
| **Documentação** | 8/10 | ✅ `CLAUDE.md`, `CHANGELOG.md` unificado, `README.md` claro. Falta: LGPD/Privacidade formal, fluxos de erro |
| **Funcionalidades** | 7.5/10 | ✅ Pacientes, agendamentos, evoluções, login funcionando. Falta: edição de paciente/sessão, relatórios, backup automático |
| **Arquitetura** | 8/10 | ✅ Riverpod bem estruturado, schema versioning, separação clara. Falta: algumas duplicações residuais em seletores |
| **Qualidade de Código** | 8.5/10 | ✅ Lint rigoroso, 0 erros, 165 testes, sem código morto. Falta: documentação de métodos complexos |
| **Testes** | 7.5/10 | ✅ 165 unitários (validadores, modelos, provedores, widgets). Falta: integração Sheets, performance/carga |
| **DevOps/Deploy** | 6/10 | ✅ Makefile com targets (`test`, `lint`, `prod-web`, `prod-android`). Falta: CI/CD |

### O que foi corrigido nesta sessão (2026-06-14)

**Commit 307d40a — Revisão Completa:**
- Removidas credenciais do git (`google-services.json`, `chaves.md`)
- Bugs críticos: null dereference em `obterPlanilhaId`, corrupção de `dataCadastro`
- Documentação: removidos 7 arquivos redundantes, criado `CLAUDE.md` e `CHANGELOG.md` unificado
- Testes: removidos mocks inúteis, CPFs inválidos corrigidos

**Commit 3ea292c — 4 Pendências Finais:**
- SnackBars: 8 locais com `$e` bruto → mensagem genérica + logging
- `Evolucao.deLinhaPlanilha`: refatorada para usar `indicesColunas` + proteção RangeError
- `FisioCores.secondary`: removida (nunca usada)
- Duplicação de popup: centralizado em `lib/utilitarios/acoes_agendamento.dart`

### Para atingir 9/10
- [ ] Documentação formal de LGPD/Privacidade
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Validação end-to-end Sheets API com fallbacks
- [ ] Backup automático para Google Drive

---

## ✅ Já implementado

- Login Google com Drive/Sheets + restauração silenciosa de sessão
- Dashboard com cards de resumo + agenda do dia
- Cards do Dashboard clicáveis (pacientes, agenda e histórico geral de evoluções)
- Redesign visual mobile-first com tema global, cards arredondados, headers padronizados, bottom sheets e responsividade
- Cadastro de pacientes (formulário completo + CPF + anamnese)
- Lista de pacientes com busca por nome/CPF e filtros `Todos`, `Ativos`, `Arquivados`
- Modal de detalhes do paciente (rotas no mapa em bottom sheet dedicado, arquivar/restaurar, evoluções)
- Agendamento de sessões (com validação de data retroativa)
- Pendências de agenda: sessões antigas sem desfecho saem da agenda de hoje e aparecem em `Pendências`
- Desfechos de sessão via Dashboard: falta com/sem aviso e cancelamento pelo paciente/profissional
- Aba `Sessões` no rodapé para consultar futuras, pendentes, realizadas, canceladas e faltas, com busca e visualização agrupada por paciente
- Registro de evolução clínica (com speech-to-text)
- Histórico de evoluções (timeline visual)
- Histórico geral de evoluções acessível pelo Dashboard, com busca e visualização agrupada por paciente
- Configurações (valor padrão, link planilha, logs de auditoria)
- Persistência completa no Google Sheets (5 abas)
- Deploy Firebase Hosting (web)

---

## 🔴 Alta prioridade

### Ordem sugerida de evolução do produto
1. **Editar paciente** — essencial para corrigir dados cadastrais, endereço, telefone, anamnese e informações clínicas sem recriar o paciente.
2. **Editar / reagendar sessão** — evita poluir o histórico com cancelamentos desnecessários quando o paciente apenas muda data, horário, valor ou local.
3. **Financeiro simples** — transforma a agenda em controle operacional e financeiro básico para uso real no dia a dia.

### 1. Editar paciente ✅ (implementado em 2026-06-18)
- **Arquivo:** `lib/telas/tela_editar_paciente.dart` (tela dedicada que recebe `Paciente`).
- **Acesso:** botão "Editar Paciente" no modal de detalhes (`modal_detalhes_paciente.dart`).
- **Campos travados:** Nome, CPF, Data de Nascimento e Gênero (somente leitura). Editáveis: telefone, endereço e toda a anamnese.
- **Serviço:** `RepositorioDadosGoogle.atualizarPaciente()` + `atualizarPacienteReal()` no provedor (auditoria `EDITAR_PACIENTE`).
- **Melhoria relacionada:** popup de confirmação no cadastro avisando que os campos de identidade não poderão ser alterados depois.

### 2. Editar / reagendar agendamento
- **Arquivo:** `lib/telas/tela_nova_sessao.dart` — adaptar para aceitar `Agendamento?` opcional
- **Serviço:** adicionar `atualizarAgendamento()` no repositório para editar data/hora/valor/observações.
- **Já implementado:** desfechos operacionais (`Cancelado pelo paciente`, `Cancelado pelo profissional`, `Faltou com aviso`, `Faltou sem aviso`) usando `Agenda.Situacao`.

### 3. Tela de agenda completa
- **Arquivo novo:** `lib/telas/tela_agenda.dart`
- **Funcionalidades:**
  - Lista completa de agendamentos (não só hoje)
  - Filtros: por data (hoje/semana/mês), por paciente, por status
  - Ações: editar, cancelar, marcar como realizado
- **Navegação:** adicionar 4ª aba no bottom nav (Agenda) ou botão no Dashboard

### 4. Financeiro por desfecho
- **Arquivo:** criar fluxo de relatório financeiro.
- **Contexto:** `Agenda.Situacao` já diferencia realizado, cancelamentos e faltas.
- **Próximo passo:** definir regra de cobrança para cancelamento em cima da hora e faltas sem aviso.
- **Escopo inicial sugerido:** total previsto, total recebido, pendente por paciente e filtro por mês.

---

## 🟡 Média prioridade

### 5. Cache local offline
- Escolher e adicionar dependências de armazenamento local apenas quando a funcionalidade for implementada
- Salvar `SessaoGoogle` (tokens) localmente para login offline
- Cache de dados da planilha para leitura sem internet
- Indicador visual de conectividade

### 6. WhatsApp para confirmação e contato rápido
- **Onde:** modal de detalhes do paciente e cards de sessão.
- **Funcionalidade:** abrir conversa no WhatsApp com mensagem pronta de confirmação, remarcação ou lembrete.
- **Exemplo:** `Olá, confirmando sua sessão de fisioterapia no dia X às Y.`
- **Valor de produto:** reduz faltas, agiliza confirmação e combina bem com atendimento domiciliar.

### 7. Relatório do paciente
- Gerar PDF com perfil do paciente, dados clínicos principais, histórico de evoluções, dor, condição clínica e sessões realizadas
- Útil para encaminhamentos, prestação de contas, auditoria e apresentação profissional do atendimento

### 8. Exportar dados (PDF / CSV)
- Exportar agenda em CSV
- Exportar financeiro

### 9. Testes
- Testes de widget para as telas principais
- Testes de integração para o fluxo Sheets API
- Testes para `servico_autenticacao_google.dart`

### 10. Tratamento de erro e retry
- Retry automático em falhas da API Google
- Feedback visual consistente em todas as telas
- Timeout handling

---

## 🟢 Baixa prioridade

### Funcionalidades avançadas

| Feature | Descrição |
|---|---|
| **Pacotes de sessão** | Pacotes pré-pagos (ex: 10 sessões) com controle de saldo |
| **Escalas de avaliação** | EVA dor, SF-36, Roland-Morris, etc. |
| **Prescrição de exercícios** | Biblioteca de exercícios com imagens/descrição |
| **Lembretes WhatsApp** | Enviar link de rota ou lembrete via WhatsApp |
| **Modo escuro** | Tema dark nas configurações |
| **Perfil do profissional** | CREFITO, telefone, endereço da clínica |
| **Backup manual** | Botão para exportar/importar backup completo |
| **Notificações push** | Lembretes de consulta via Firebase Cloud Messaging |
| **Multi-clínica** | Suporte a múltiplos profissionais/empresas |
| **Gráficos** | Visualização de tendências por período |
| **Deep links** | Compartilhar link direto para paciente/agenda |

---

## Observações técnicas

- **Banco:** Google Sheets (5 abas: Pacientes, Agenda, Evolucoes, Configuracoes, Auditoria)
- **Autenticação:** `google_sign_in` 6.2.1 com escopo OAuth `drive.file`
- **Pendências infra:**
  - iOS: falta `GoogleService-Info.plist`, `CFBundleURLTypes`, permissões de microfone
  - Android: registrar SHA-1 debug no Firebase e baixar `google-services.json` atualizado; configurar release signing para Play Store
  - Android: permissão `RECORD_AUDIO` e OAuth nativo já configurados no código
  - dependências não usadas devem ser removidas em limpezas periódicas
  - `print()` em `provedor_autenticacao.dart:91` — substituir por logger
