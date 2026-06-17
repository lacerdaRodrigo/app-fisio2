# 📋 Testes Automatizados — Visão Geral

**Status:** ✅ 129 testes passando | 1.800 linhas de código de teste

---

## Resumo Executivo

O projeto utiliza **apenas testes unitários e de widget** (sem E2E automatizados). A estrutura é simples, clara e sem redundâncias:

| Categoria | Quantidade | % | Focos |
|---|---|---|---|
| **Unit — Utilitários** | 67 | 52% | Validadores, formatadores, utilitários |
| **Unit — Modelos** | 22 | 17% | Serialização, transformação, cópia |
| **Widget — Telas** | 40 | 31% | UI, interação, estados visuais |
| **TOTAL** | **129** | **100%** | — |

---

## Estrutura de Diretórios

```
test/
├── unitarios/              (89 testes — lógica pura)
│   ├── auxiliares/         
│   │   └── fakes.dart                    — Mocks reutilizados
│   ├── modelos/
│   │   ├── agendamento_test.dart        (7 testes)
│   │   ├── evolucao_test.dart           (6 testes)
│   │   └── paciente_test.dart           (9 testes)
│   └── utilitarios/
│       ├── utilitarios_data_test.dart   (12 testes)
│       ├── validador_cpf_test.dart      (9 testes)
│       └── validadores_test.dart        (46 testes)
└── widgets/                (40 testes — UI + componentes)
    └── telas/
        ├── tela_cadastro_paciente_test.dart
        ├── tela_configuracoes_test.dart
        ├── tela_historico_geral_evolucoes_test.dart
        ├── tela_pacientes_test.dart
        ├── tela_registro_evolucao_test.dart
        └── tela_sessoes_test.dart
```

---

## Como Rodar

```bash
# Todos os 129 testes
flutter test

# Apenas unitários
flutter test test/unitarios/

# Apenas widgets
flutter test test/widgets/

# Um arquivo específico
flutter test test/unitarios/utilitarios/validadores_test.dart

# Modo watch (rerun ao salvar)
flutter test --watch

# Com relatório de coverage
flutter test --coverage
```

---

## Padrão de Teste: AAA

Todos os testes seguem **Arrange → Act → Assert**:

```dart
test('descrição do comportamento', () {
  // Arrange: preparar dados
  final entrada = Paciente(...);
  
  // Act: executar função
  final resultado = entrada.calcularIdade();
  
  // Assert: validar resultado
  expect(resultado, equals(40));
});
```

---

## O que NÃO é Testado

❌ Google Sheets API real (seria lento, usaria quota)  
❌ Google Sign-In real (exigiria navegador/device)  
❌ Testes E2E (removidos — era redundante)  
❌ Performance/carga  

---

## Ver Também

- [`UNITARIOS.md`](./UNITARIOS.md) — Detalhes de cada teste unitário
- [`WIDGETS.md`](./WIDGETS.md) — Detalhes de cada teste de widget
- [`../../QA/qa.md`](../../QA/qa.md) — Script de QA manual
