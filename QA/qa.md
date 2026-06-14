Você é um Analista de Qualidade Sênior experiente em testes funcionais de software.

Sua tarefa é criar um documento completo de Casos de Testes para o sistema descrito abaixo, seguindo rigorosamente as instruções e o modelo fornecidos.

---

## Informações do Sistema

**Nome do sistema:** Fisio Home Care — Gestão de Fisioterapia Domiciliar

**Descrição:** Aplicativo mobile e web desenvolvido em Flutter para fisioterapeutas que atendem em domicílio. Permite autenticação via Google Sign-In, gestão de pacientes, agendamento de sessões, registro de evoluções clínicas e consulta operacional da agenda. Os dados são armazenados na planilha `__saas_fisio_db__` do Google Drive do próprio profissional (modelo BYODB — Bring Your Own Database), sem servidor central de prontuários, em conformidade com a LGPD.

**Plataformas:** Android (dispositivo físico ou emulador) e Web (`https://app-fisio-care-2.web.app/app/`).

**Módulos/Funcionalidades a cobrir:** Login e Consentimento LGPD, Dashboard (Início), Pacientes, Cadastro de Paciente, Nova Sessão, Sessões (histórico da agenda), Registro de Evolução, Histórico de Evoluções, Configurações.

**Perfis de usuário:** Fisioterapeuta (Usuário Profissional).

**Regras de negócio relevantes:**
- **Login:** O botão "Entrar com Google" permanece desabilitado até o aceite explícito do termo LGPD (checkbox obrigatório).
- **Autenticação:** Integração obrigatória com Google Sign-In; na Web, a autorização de acesso ao Drive/Sheets ocorre em ação explícita separada do login.
- **Armazenamento:** Dados clínicos persistidos exclusivamente na planilha `__saas_fisio_db__` da conta Google do profissional; escopo OAuth restrito (`drive.file`).
- **Isolamento:** Cada fisioterapeuta possui sua própria planilha; não há acesso cruzado entre contas.
- **Agenda do dia:** Exibe somente sessões com `Situacao = "Agendado"` na data atual; sessões antigas sem desfecho aparecem em **Pendências**.
- **Desfechos de sessão:** `Realizado`, `Cancelado`, `Cancelado pelo paciente`, `Cancelado pelo profissional`, `Faltou com aviso`, `Faltou sem aviso`.
- **Nova sessão:** Não permite agendar horários retroativos (anteriores ao momento atual).
- **Pacientes:** Cadastro com validação de campos obrigatórios (nome, CPF, telefone, endereço, dados clínicos iniciais); filtros `Todos` e `Ativos`.
- **Evolução clínica:** Registro estruturado obrigatório após atendimento realizado.
- **Rotas:** Integração com Google Maps e Waze a partir do endereço do paciente.
- **LGPD:** O profissional atua como Controlador dos dados; o app exige consentimento na entrada e oferece ferramentas de privacidade em Configurações.

---

## Escopo dos Testes

Cobrir obrigatoriamente:
- Testes funcionais (blackbox)
- Cenários positivos (fluxo feliz)
- Cenários negativos (erros, dados inválidos, permissões negadas)
- Validação de campos obrigatórios
- Validação de regras de negócio
- Fluxos principais e alternativos
- Permissões e níveis de acesso por perfil de usuário

Não incluir:
- Testes de performance
- Testes de carga ou estresse
- Testes automatizados
- Testes de segurança avançados

---

## Modelo de Caso de Teste

Cada caso de teste deve seguir exatamente este formato:

---

### CT[NN] - [Nome descritivo do caso de teste]

#### Objetivo
[Descrição clara e objetiva do que está sendo validado.]

#### Pré-Condições
- [Condição 1]
- [Condição 2]
- [...]

#### Passos

| Id | Ação | Resultado Esperado |
|----|------|--------------------|
| 1  | [Ação do usuário] | [Comportamento esperado do sistema] |
| 2  | [...] | [...] |

#### Resultados Esperados
- [Descreva o estado final esperado do sistema após todos os passos.]

#### Critérios de Aceitação
- [Critério objetivo 1]
- [Critério objetivo 2]
- [...]

---

## Instruções de Geração

1. Numere os casos de teste sequencialmente: CT01, CT02, CT03...
2. Cubra no mínimo os seguintes fluxos base para cada módulo informado:
   - Operação bem-sucedida (fluxo feliz)
   - Operação com dados inválidos ou incompletos
   - Operação sem permissão adequada (quando aplicável)
3. Inclua casos de teste para validação de campos obrigatórios.
4. Inclua casos de teste para cada perfil de usuário listado, sempre que houver comportamentos distintos.
5. Seja detalhado nos passos — cada ação deve ser clara o suficiente para que qualquer pessoa execute o teste sem dúvidas.
6. Gere o resultado em formato Markdown, pronto para ser salvo em um arquivo `.md` dentro da pasta `documentacao/` do projeto (ex.: `CASOS_DE_TESTE_[MODULO].md`), seguindo o padrão dos casos de teste já existentes.