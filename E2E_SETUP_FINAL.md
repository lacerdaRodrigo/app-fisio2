# Setup Final — Testes E2E com Patrol + MCP

## Status da Migração

✅ **Completo!** Removido Mobilewright, instalado Patrol + MCP flutter-dev-agents.

### O que foi feito

1. **Removido Mobilewright**
   - ❌ `mobilewright.config.ts`, `scripts/mobilewright-env.sh`
   - ❌ Pasta antiga `test/e2e/`
   - ❌ Dependências do package.json

2. **Instalado Patrol**
   - ✅ `patrol: ^4.6.1` em pubspec.yaml
   - ✅ Patrol CLI global (`dart pub global activate patrol_cli`)
   - ✅ Estrutura em `patrol_test/` (padrão do Patrol)

3. **Instalado MCP flutter-dev-agents**
   - ✅ Clonado em `/home/rodrigo/Estudos/flutter-dev-agents`
   - ✅ Instalado com `uv` em venv
   - ✅ Registrado com Claude Code: `claude mcp list` → `phone-controll ✔ Connected`
   - ✅ 137 ferramentas disponíveis para automação

4. **Estrutura de testes**
   ```
   patrol_test/
   ├── config.dart           ← Configurações centralizadas
   ├── helpers.dart          ← Funções reutilizáveis
   ├── smoke_test.dart       ← Teste básico de validação
   ├── login_test.dart       ← Testes de autenticação (CT-LG01..06)
   └── paciente_cadastro_test.dart  ← Testes de cadastro
   
   integration_test/         ← Espelho para referência
   ├── (mesmos arquivos)
   ├── README.md
   └── RUN_TESTS.md
   
   test_plans/               ← YAML plans para MCP
   ├── login_success.yaml
   ├── login_validation_error.yaml
   ├── add_paciente.yaml
   └── README.md
   
   test/                     ← Testes unitários (não E2E)
   ├── helpers/
   ├── modelos/
   └── (165 testes passando)
   ```

5. **Makefile atualizado**
   - ✅ `make test-e2e` → `patrol test -d android`

## Como rodar testes

### Pré-requisito: Setup PATH
```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### Opção 1: Teste único (smoke)
```bash
patrol test -d android --test patrol_test/smoke_test.dart
```

### Opção 2: Todos os testes E2E
```bash
patrol test -d android
```

### Opção 3: Via Makefile
```bash
make test-e2e
```

### Opção 4: Via Claude Code (MCP)
```
Run the test plan "test_plans/login_success.yaml" on the Android device.
Show screenshots before and after each step.
```

## Próximos passos

### 1. Validar estrutura
```bash
# Verificar que devices estão visíveis
patrol devices

# Verificar MCP está conectado
claude mcp list
```

### 2. Rodar primeiro teste
```bash
patrol test -d android --test patrol_test/smoke_test.dart
```

Esperar sucesso:
```
✓ SMOKE: App inicia e tela de login aparece
✓ SMOKE: Checkbox pode ser marcado
✓ SMOKE: Botão login pode ser tocado
All tests passed!
```

### 3. Converter Mobilewright → Patrol
Qualquer teste que estava em Mobilewright:
- Remova coordenadas hardcoded (`tap(x, y)`)
- Use seletores robustos (`find.text()`, `find.byType()`)
- Organize em `patrol_test/`
- Rodar com `patrol test`

## Diferenças Mobilewright → Patrol

| Aspecto | Mobilewright | Patrol |
|---|---|---|
| Coordenadas | ❌ `tap(540, 1685)` | ✅ `find.text("Login")` |
| Linguagem | TypeScript | Dart |
| Localização | `test/e2e/` | `patrol_test/` ou `integration_test/` |
| Execução | `npm run mobilewright:test` | `patrol test -d android` |
| Manutenção | ⚠️ Parou | ✅ Ativo (May 2026) |
| Ferramentas disponíveis | ~5 | **137** (com MCP) |

## Troubleshooting

### "patrol: command not found"
```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### "Device not attached"
```bash
adb devices  # Verificar que device está lá
patrol devices  # Patrol enxerga?
```

### "Compilation failed"
```bash
flutter clean
flutter pub get
patrol test -d android  # Rodar novamente
```

### Teste falha no device real
- Verifique que o app inicia: `flutter run -d RQ8R70GZTLA`
- Teste pode estar frágil — revisar seletores
- Use `--verbose` para mais informações: `patrol test -d android -v`

## Documentação

- 📖 [Patrol docs](https://patrol.dev)
- 📖 [flutter-dev-agents MCP](https://github.com/michal-giza/flutter-dev-agents)
- 📋 [RUN_TESTS.md](integration_test/RUN_TESTS.md)
- 📋 [MCP_PATROL_SETUP.md](MCP_PATROL_SETUP.md)

## Próximas sessões

1. **Rodar todos os testes Patrol**
2. **Converter testes Mobilewright restantes**
3. **Integrar com CI/CD**
4. **Usar MCP para automação avançada**

---

**Commit principal:** `bfef4c1` — "Migrar de Mobilewright para Patrol + flutter-dev-agents MCP"

Tudo pronto para começar! 🚀
