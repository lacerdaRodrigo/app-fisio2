# MCP Patrol + Flutter Dev Agents — Setup

## O que foi instalado

**flutter-dev-agents** é um MCP server oficial com **137 ferramentas** para testes E2E em Flutter:
- ✅ Integração Patrol de primeira classe
- ✅ Testes em devices Android/iOS reais
- ✅ Audit suite de 7 dimensões (segurança, acessibilidade, i18n, etc)
- ✅ YAML test plans declarativos
- ✅ Cross-session device locking (múltiplas sessões Claude sem colisão)

## Status

```bash
$ claude mcp list
phone-controll: ... ✔ Connected
```

O MCP está registrado em `/home/rodrigo/.claude.json` e pronto para usar em Claude Code.

## Como usar

### 1. Testes interativos via Claude Code

No Chat do Claude Code, você pode chamar ferramentas como:

```
Vou criar um teste E2E para login.
Cria um test plan YAML que:
1. Inicia o app
2. Encontra "FisioCare" na tela
3. Marca checkbox de aceito termos
4. Clica "Entrar com Google"
5. Valida Dashboard aparece

Use as ferramentas do MCP para escrever e executar o plano.
```

Claude automaticamente tem acesso a ferramentas como:
- `run_test_plan(test_plan_yaml)`
- `take_screenshot()`
- `tap_text(text)`, `tap_element(selector)`
- `tap_and_verify(action, expectation)`
- `audit_test_quality(test_plan_path)`
- `run_patrol_test(test_file_path)`
- E mais 130+ ferramentas

### 2. Test Plans YAML declarativos

Ao invés de Dart/TypeScript, você escreve plans em YAML que Claude e Patrol executam:

```yaml
name: Login - Fluxo Feliz
steps:
  - action: launch_app
  - action: wait_for_element
    selector: text:FisioCare
    timeout: 5s
  - action: tap
    selector: text:Checkbox
  - action: tap_text
    text: Entrar com Google
    wait_after: 3s
  - action: tap_text
    text: João Silva  # Selecionar conta na tela Google
  - action: verify
    selector: text:Boa noite
    timeout: 10s
```

Depois rodar com Claude: `run_test_plan("test_plans/login.yaml")`

### 3. Verificação automática de qualidade

Claude pode auditar seus testes:

```
audit_test_quality({
  test_plan_path: "test_plans/login.yaml",
  ruleset: "senior-tester"
})
```

Volta com:
- ❌ Hardcoded waits sem necessidade
- ⚠️ Assertions fracas
- ✅ Boas práticas de E2E

## Próximos passos

1. **Converter testes Patrol existentes** (`integration_test/login_test.dart`) para YAML plans
2. **Rodar em device real** com `patrol test -d android` ou via MCP
3. **Auditar qualidade** dos planos

## Referência

- 📖 [Documentação flutter-dev-agents](https://github.com/michal-giza/flutter-dev-agents/tree/main/docs)
- 🔧 [Tools by category](https://github.com/michal-giza/flutter-dev-agents/blob/main/docs/tools-by-category.md)
- 📋 [Configuration](https://github.com/michal-giza/flutter-dev-agents/blob/main/docs/CONFIGURATION.md)
- 🎬 [Getting Started](https://github.com/michal-giza/flutter-dev-agents/blob/main/docs/GETTING-STARTED.md)

## Device setup

Para rodar testes em device real:

```bash
# Android
adb devices  # verificar que device está conectado

# iOS (se necessário)
brew install pymobiledevice3
pymobiledevice3 remote tunneld &
```

Então Claude pode chamar:
```
select_device("R3CYA05CHXB")  # Galaxy S25
run_patrol_test("integration_test/login_test.dart")
```

## Exemplo: Criar teste via Claude

No Chat do Claude Code:

```
Preciso de um teste E2E para o fluxo:
1. Login com Google
2. Navegar para Pacientes
3. Adicionar novo paciente "João Silva"
4. Validar que aparece na lista

Cria um YAML test plan que eu possa rodar com patrol.
Depois valida a qualidade do teste.
```

Claude vai:
1. Escrever o YAML plan
2. Salvar em `test_plans/add_paciente.yaml`
3. Chamar `run_test_plan(...)` para executar
4. Chamar `audit_test_quality(...)` para validar

Resultado: teste automatizado, auditado, pronto para CI/CD.

## Comparação: Mobilewright → flutter-dev-agents

| Aspecto | Mobilewright | flutter-dev-agents |
|---|---|---|
| Coordenadas hardcoded | ❌ `tap(540, 1685)` | ✅ `tap_text("Login")` |
| Test definition | TypeScript | ✅ YAML declarativo |
| Tools disponíveis | Básico | ✅ **137 ferramentas** |
| Audit de qualidade | ❌ Manual | ✅ Automático |
| Device locking | ❌ Sem | ✅ Sim (4+ sessions) |
| Maestro composition | ❌ Não | ✅ Sim |
| Mantido | ❌ Parou | ✅ Ativo (May 2026) |
