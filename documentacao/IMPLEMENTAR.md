# Plano de Implementação — Fisio Home Care

Status atual do projeto: **MVP funcional completo**
Base: Flutter + Riverpod + Google Sheets API + Google Sign-In

---

## ✅ Já implementado

- Login Google com Drive/Sheets + restauração silenciosa de sessão
- Dashboard com cards de resumo + agenda do dia
- Cadastro de pacientes (formulário completo + CPF + anamnese)
- Lista de pacientes com busca por nome/CPF
- Modal de detalhes do paciente (rotas no mapa, arquivar, evoluções)
- Agendamento de sessões (com validação de data retroativa)
- Registro de evolução clínica (com speech-to-text)
- Histórico de evoluções (timeline visual)
- Configurações (valor padrão, link planilha, logs de auditoria)
- Persistência completa no Google Sheets (5 abas)
- Deploy Firebase Hosting (web)

---

## 🔴 Alta prioridade

### 1. Editar paciente
- **Arquivo:** `lib/telas/tela_cadastro_paciente.dart`
- **O que falta:** A tela atual só cria. Precisa aceitar um `Paciente?` opcional. Se receber, pré-preenche os campos e salva como atualização.
- **Serviço:** `lib/servicos/servico_repositorio_dados.dart` — adicionar `atualizarPaciente()`
- **Validação:** CPF único (ignorando o próprio paciente ao editar)

### 2. Editar / cancelar agendamento
- **Arquivo:** `lib/telas/tela_nova_sessao.dart` — adaptar para aceitar `Agendamento?` opcional
- **Serviço:** adicionar `atualizarAgendamento()` e `cancelarAgendamento()` no repositório
- **Lista:** adicionar ação de editar/cancelar na agenda do dashboard

### 3. Tela de agenda completa
- **Arquivo novo:** `lib/telas/tela_agenda.dart`
- **Funcionalidades:**
  - Lista completa de agendamentos (não só hoje)
  - Filtros: por data (hoje/semana/mês), por paciente, por status
  - Ações: editar, cancelar, marcar como realizado
- **Navegação:** adicionar 4ª aba no bottom nav (Agenda) ou botão no Dashboard

### 4. Ver / restaurar pacientes arquivados
- **Arquivo:** `lib/telas/tela_pacientes.dart`
- Adicionar toggle "Mostrar arquivados"
- No modal de paciente arquivado, exibir botão "Restaurar"

---

## 🟡 Média prioridade

### 5. Cache local offline
- Escolher e adicionar dependências de armazenamento local apenas quando a funcionalidade for implementada
- Salvar `SessaoGoogle` (tokens) localmente para login offline
- Cache de dados da planilha para leitura sem internet
- Indicador visual de conectividade

### 6. Relatório financeiro
- Modelo de dados: sessões "Realizado" com `Valor_Sessao`
- Resumo no Dashboard: total a receber, recebido, pendente por paciente
- Filtro por período (mês)

### 7. Exportar dados (PDF / CSV)
- Gerar relatório do paciente (perfil + histórico) em PDF
- Exportar agenda em CSV
- Exportar financeiro

### 8. Testes
- Testes de widget para as telas principais
- Testes de integração para o fluxo Sheets API
- Testes para `servico_autenticacao_google.dart`

### 9. Tratamento de erro e retry
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
  - Android: configurar release signing
  - dependências não usadas devem ser removidas em limpezas periódicas
  - `print()` em `provedor_autenticacao.dart:91` — substituir por logger
