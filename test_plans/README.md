# Test Plans — Patrol + MCP

Testes end-to-end declarativos em YAML que rodam com **flutter-dev-agents MCP**.

## Como usar

### 1. Rodar um test plan via Claude Code

No chat do Claude Code:

```
Run the test plan "test_plans/login_success.yaml" on the Android device.
Show me the screenshot after each step.
```

Claude vai chamar as ferramentas MCP para:
- Iniciar o app
- Executar cada passo
- Capturar screenshots
- Validar assertions
- Gerar relatório

### 2. Rodar via CLI (se flutter-dev-agents HTTP está rodando)

```bash
# Inicia HTTP server (opcional)
cd ~/Estudos/flutter-dev-agents/packages/phone-controll
source .venv/bin/activate
uvicorn mcp_phone_controll:create_app --port 8000 &

# Roda test plan
curl -X POST http://localhost:8000/tools/run_test_plan \
  -H "Content-Type: application/json" \
  -d '{"test_plan_path": "test_plans/login_success.yaml"}'
```

### 3. Auditoria automática de qualidade

```
audit_test_quality({
  test_plan_path: "test_plans/login_success.yaml",
  ruleset: "senior-tester"
})
```

Volta com checklist:
- ✅ Assertions claras
- ✅ Waits apropriados
- ⚠️ Hardcoded selectors (frágeis)
- ❌ Falta rollback/cleanup

## Estrutura de um Test Plan

```yaml
name: Descrição do teste
description: Contexto e objetivo
tier: smoke|core|edge  # Prioridade

setup:
  - action: launch_app
    clear_cache: true

steps:
  - action: wait_for_element
    selector: text:ElementText
    timeout: 5s

  - action: tap_text
    text: Botão
    
  - action: enter_text
    selector: placeholder:Campo
    text: Valor

  - action: verify
    selector: text:Resultado
    timeout: 3s

assertions:
  - element: text:Esperado
    visible: true

tags:
  - critical
  - login
```

## Seletores disponíveis

```yaml
# Por texto (exato ou substring)
selector: text:FisioCare
selector: text:Boa noite  # substring match

# Por tipo de widget
selector: type:ElevatedButton
selector: type:Checkbox
selector: type:TextFormField
selector: type:CircleAvatar

# Por ícone
selector: icon:add
selector: icon:logout

# Por placeholder (campos de input)
selector: placeholder:Nome Completo
selector: placeholder:CPF

# Por testID (se configurado no código)
selector: id:login_button
selector: id:paciente_list
```

## Ações disponíveis

```yaml
# Básicas
- action: launch_app
- action: take_screenshot
  path: screenshots/step1.png

# Navegação e interação
- action: tap_text
  text: Texto a clicar

- action: tap
  selector: type:Button

- action: enter_text
  selector: placeholder:Campo
  text: Valor digitado

- action: swipe
  direction: up|down|left|right
  distance: 300

- action: scroll
  selector: type:ListView
  direction: down
  distance: 200

# Esperas e verificações
- action: wait_for_element
  selector: text:Elemento
  timeout: 5s
  fail_if_not_found: true

- action: verify
  selector: text:Esperado
  
- action: tap_and_verify
  action: tap_text
    text: Botão
  expectation: text:Resultado

# Limpeza
- action: press_back
- action: tap_text
  text: OK  # Fecha AlertDialog
```

## Templates prontos

- **login_success.yaml** — Login + Dashboard
- **login_validation_error.yaml** — Validação de campos obrigatórios
- **add_paciente.yaml** — Cadastro de paciente completo

## Criando novo test plan

1. Copie um template como base
2. Adapte o nome e description
3. Escreva os steps
4. Adicione assertions
5. Cole o nome dos selectors do código ou UI

No Claude Code:

```
Cria um test plan YAML para:
1. Login
2. Navegar para Sessões
3. Criar nova sessão para "João Silva" em "10/06/2026 14:00"
4. Validar que aparece na agenda

Use os seletores que fazem sentido para o app.
```

Claude vai:
1. Escrever o YAML
2. Salvar em `test_plans/`
3. Rodar e validar qualidade

## Integração com CI/CD

No `.github/workflows/e2e-tests.yml`:

```yaml
- name: Run Patrol Tests
  run: |
    cd packages/phone-controll
    source .venv/bin/activate
    python -m mcp_phone_controll &
    
    # Roda todos os test plans
    for plan in ../../test_plans/*.yaml; do
      echo "Running $plan..."
      curl -X POST http://localhost:8000/tools/run_test_plan \
        -d "{\"test_plan_path\": \"$plan\"}"
    done
```

## Troubleshooting

### "Elemento não encontrado"
Verifique o seletor:
```yaml
# ❌ Errado
selector: text:Boa noite,  # Vírgula extra

# ✅ Certo
selector: text:Boa noite
```

### "Timeout esperando elemento"
Aumente o timeout:
```yaml
timeout: 10s  # era 5s
```

### "Test plan falha em device novo"
Garanta setup correto:
```yaml
setup:
  - action: launch_app
    clear_cache: true
    timeout: 10s
```

## Referência

- 📖 [flutter-dev-agents docs](https://github.com/michal-giza/flutter-dev-agents/tree/main/docs)
- 🔧 [All 137 tools](https://github.com/michal-giza/flutter-dev-agents/blob/main/docs/tools-by-category.md)
- 📋 [Test plan schema](https://github.com/michal-giza/flutter-dev-agents/blob/main/packages/phone-controll/src/mcp_phone_controll/data/test_plan_schema.json)
