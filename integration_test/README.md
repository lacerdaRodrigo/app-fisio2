# Testes E2E com Patrol

Esta pasta contém testes end-to-end automatizados para o app Fisio Home Care usando **Patrol**.

## O que é Patrol?

Patrol é um framework de testes para Flutter que:
- Usa **seletores robustos** (não coordenadas hardcoded)
- Interage com widgets reais e com o sistema Android/iOS
- Funciona com `flutter test` localmente e em devices físicos
- Melhor integração nativa com Flutter que Mobilewright

## Estrutura

```
integration_test/
  ├── helpers.dart              # Funções auxiliares reutilizáveis
  ├── login_test.dart           # Testes de autenticação (CT-LG01..06)
  ├── paciente_cadastro_test.dart # Testes de cadastro (CT-PC01..04)
  └── README.md                 # Este arquivo
```

## Como rodar os testes

### Localmente (simulador/emulador)
```bash
flutter test integration_test/login_test.dart
flutter test integration_test/paciente_cadastro_test.dart
```

### Em device Android conectado
```bash
patrol test -d android
```

### Ou via Makefile
```bash
make test-e2e
```

## Padrão de nomenclatura

Cada teste segue o padrão do QA:
- `CT-LG01`, `CT-LG02`, etc. (Login)
- `CT-PC01`, `CT-PC02`, etc. (Paciente)
- `CT-SES01`, etc. (Sessão)
- `CT-EV01`, etc. (Evolução)

## Como escrever novos testes

### Template básico

```dart
import 'package:patrol/patrol.dart';
import 'helpers.dart';

void main() {
  patrolTest('CT-XX01: descrição do teste', ($) async {
    // 1. Setup
    final estaLogado = await TestHelpers.fazerLogin($);
    expect(estaLogado, true);

    // 2. Navegar/Executar ações
    await $.tap(find.text('Pacientes'));
    await $.pumpAndSettle();

    // 3. Validar
    expect(find.text('Pacientes'), findsWidgets);
  });
}
```

### Usando helpers comuns

```dart
// Login
await TestHelpers.fazerLogin($);

// Logout
await TestHelpers.fazerLogout($);

// Aguardar Dashboard
await TestHelpers.esperarDashboard($);

// Scroll até elemento
await TestHelpers.scrollParaElemento($, find.text('Sair da conta'));

// Aguardar elemento com timeout
await TestHelpers.aguardarElemento($, find.byIcon(Icons.add));
```

### Seletores úteis

```dart
// Por texto
find.text('Pacientes')

// Por ícone
find.byIcon(Icons.add)

// Por tipo de widget
find.byType(TextFormField)
find.byType(ElevatedButton)
find.byType(Checkbox)
find.byType(CircleAvatar)

// Múltiplos: primeiro, segundo, etc
find.byType(TextFormField).first
find.byType(TextFormField).at(0)

// Combinado
find.text('OK')
```

### Ações comuns

```dart
// Tap
await $.tap(find.text('Botão'));

// Enter text em campo
await $.enterText('João Silva');

// Scroll
await $.scrollUntilVisible(find.text('Elemento'), dyScroll: -300);

// Press back/home
await $.native.pressButton(NativeButton.back);
await $.native.pressButton(NativeButton.home);

// Pump (aguardar render)
await $.pumpAndSettle();
await $.pumpAndSettle(Duration(seconds: 2));
await $.pump(Duration(milliseconds: 100));
```

## Diferenças do Mobilewright

| Mobilewright | Patrol |
|---|---|
| Coordenadas hardcoded (`tap(x, y)`) | Seletores robustos (`find.text()`) |
| ADB crua (`adb shell input tap`) | Dart puro |
| TypeScript | Dart |
| Frágil com mudanças de UI | Robusto |

## Troubleshooting

### "App não inicia"
Certifique-se que:
- Device/emulador está conectado: `adb devices`
- App foi compilado: `flutter clean && flutter pub get`
- Permissões Android estão ok

### "Timeout esperando elemento"
Aumentar timeout com `Duration(seconds: 10)` em vez de padrão:
```dart
await TestHelpers.aguardarElemento($, find.text('X'), timeout: Duration(seconds: 10));
```

### "Google Sign-In modal não aparece"
Isso é esperado em emulador/simulador. O fluxo real só funciona em device físico com Google Play Services ativo.

## Referência Patrol

- [Documentação oficial](https://patrol.dev)
- [API PatrolTester](https://pub.dev/documentation/patrol/latest/patrol/PatrolTester-class.html)
- [Finders e Gestures](https://patrol.dev/docs/guides/finders)
