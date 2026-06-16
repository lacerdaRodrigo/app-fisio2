# Como rodar os testes E2E

## Pré-requisitos

### 1. Flutter e Patrol
```bash
flutter pub get
dart pub global activate patrol_cli
```

### 2. Android device ou emulador
```bash
# Verificar devices conectados
adb devices

# Ou usar emulador
emulator -avd <device_name>
```

### 3. MCP (opcional, para testes automatizados avançados)
```bash
# Já registrado:
claude mcp list
# phone-controll: ... ✔ Connected
```

---

## Rodar testes localmente

### Opção 1: Via `flutter test` (emulador/device)
```bash
# Um arquivo de teste
flutter test test/e2e/login_test.dart

# Todos os testes E2E
flutter test test/e2e/

# Com verbose
flutter test test/e2e/ -v

# Com coverage
flutter test test/e2e/ --coverage
```

### Opção 2: Via Patrol CLI
```bash
# No device Android conectado
patrol test -d android

# No emulador
patrol test -d android --emulator
```

### Opção 3: Via Makefile
```bash
make test-e2e
```

---

## Rodar um teste específico

```bash
# Apenas CT-LG01
flutter test test/e2e/login_test.dart -n "CT-LG01"

# Todos os testes com "login" no nome
flutter test test/e2e/login_test.dart -k login
```

---

## Primeiro teste (validação básica)

**Objetivo:** Rodar CT-LG01 para validar que Patrol está funcionando

```bash
flutter test test/e2e/login_test.dart -n "CT-LG01"
```

**O que esperar:**
```
✓ CT-LG01: exibe erro ao clicar em Entrar com Google sem aceitar termos
All tests passed!
```

Se receber erro:
1. Verifique se device/emulador está conectado: `adb devices`
2. Reinstale app: `flutter clean && flutter pub get && flutter run`
3. Rodar novamente

---

## Rodar com screenshots automáticos (quando falha)

```bash
flutter test test/e2e/login_test.dart --verbose
```

Screenshots vão em: `build/screenshots/`

---

## Debug de teste falhando

```bash
# Rodar com logs detalhados
flutter test test/e2e/login_test.dart -v

# Pausar e inspecionar state
# Adicione no código do teste:
await $.pumpAndSettle();
// Breakpoint aqui — inspect widgets
```

---

## Via MCP (Claude Code)

```
Roda o teste "test/e2e/login_test.dart" no device Android.
Mostra screenshots antes e depois de cada step.
Se falhar, audita por que falhou.
```

Claude vai chamar as ferramentas MCP do flutter-dev-agents.

---

## Checklist antes de rodar

- [ ] `flutter pub get` rodou sem erro
- [ ] Device/emulador conectado (`adb devices`)
- [ ] App compile sem erro (`flutter run`)
- [ ] Config.dart importa corretamente
- [ ] Helpers.dart importa corretamente

Se tudo ok, rodar:
```bash
flutter test test/e2e/login_test.dart
```
