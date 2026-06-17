# 📚 Documentação de Testes

Guia completo dos 129 testes automatizados do Fisio Home Care.

---

## 📖 Documentos

1. **[VISAO_GERAL.md](./VISAO_GERAL.md)** — Overview, estrutura, como rodar
2. **[UNITARIOS.md](./UNITARIOS.md)** — 89 testes unitários (validadores, modelos)
3. **[WIDGETS.md](./WIDGETS.md)** — 40 testes de widget (telas, UI)

---

## 🎯 Quick Start

```bash
# Rodar todos os testes
flutter test

# Apenas unitários
flutter test test/unitarios/

# Apenas widgets
flutter test test/widgets/

# Um arquivo específico
flutter test test/unitarios/utilitarios/validadores_test.dart
```

---

## 📊 Estatísticas

| Tipo | Quantidade | % |
|---|---|---|
| Unit — Utilitários | 67 | 52% |
| Unit — Modelos | 22 | 17% |
| Widget — Telas | 40 | 31% |
| **TOTAL** | **129** | **100%** |

---

## ✅ Cobertura

✅ **Validação de entrada** — CPF, telefone, nome, data, email  
✅ **Modelos de dados** — Serialização, transformação, cópia  
✅ **Utilitários** — Cálculo de idade, formatação de datas  
✅ **UI e interação** — 6 telas principais com 40 cenários  

❌ **Não coberto:** Google Sheets API real, Google Sign-In real, E2E, performance

---

## 📂 Estrutura

```
test/
├── unitarios/
│   ├── auxiliares/
│   ├── modelos/
│   └── utilitarios/
└── widgets/
    └── telas/
```

---

## 🔗 Relacionado

- **[../../QA/qa.md](../../QA/qa.md)** — Script de QA manual
- **[../IMPLEMENTAR.md](../IMPLEMENTAR.md)** — Roadmap do projeto
