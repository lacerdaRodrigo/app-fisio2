# Plano de Melhorias: Tela de Registro de Evolução
**App**: Fisio Home Care
**Data**: 2026-06-09

---

## 🎯 Objetivo
Expansão da **Tela de Registro de Evolução** (`TelaRegistroEvolucao`) para incluir **dados clínicos essenciais** em cada registro: status de presença, horários reais, local, escala de dor, condição clínica, e sinais vitais opcionais.

---

## ✅ O que foi implementado

### 1. Modelo `Evolucao` expandido
| Campo | Tipo | Obrigatório | Padrão |
|-------|------|-------------|--------|
| `localAtendimento` | String | ✅ | `"Domicílio"` |
| `statusPresenca` | String | ✅ | `"Presente"` |
| `dorSessao` | int | ✅ | `0` |
| `horarioInicioReal` | DateTime | ✅ | - |
| `horarioFimReal` | DateTime | ✅ | - |
| `condicaoPaciente` | String | ✅ | `"Melhora"` |
| `pressaoArterial` | String? | ❌ | `null` |
| `frequenciaCardiaca` | int? | ❌ | `null` |

### 2. Google Sheets - Aba `Evolucoes` (14 colunas)
- Colunas 1-6: originais (retrocompatíveis)
- Colunas 7-14: novas (ao final, sem quebra)
- `ServicoGoogleSheets.cabecalhos['Evolucoes']` atualizado

### 3. UI da `TelaRegistroEvolucao`
- **Cabeçalho**: Nome, Idade, Data/Hora agendada
- **Informações Básicas**: Presença, Horários Reais, Local, Dor (0-10)
- **Sinais Vitais** (opcional): PA e FC
- **Evolução Clínica**: Texto + Speech-to-Text
- **Condição Clínica**: Dropdown ou automático ("Faltou")
- **Salvar**: Valida todos os campos obrigatórios

### 4. `TelaHistoricoEvolucoes` enriquecida
- Bolinha colorida por condição (🟢 Melhora / 🟡 Estável / 🔴 Piora / ⚫ Faltou)
- Badge de condição no card
- Info: Dor X/10 e Local de Atendimento

### 5. Modal de Detalhes do Paciente
- Badge "Última Evolução" com condição e dor

### 6. Testes
- `test/modelos/evolucao_test.dart`: 5 testes (serialização, retrocompatibilidade, valores padrão)
- `test/provedores/provedores_dados_test.dart`: adaptado para novos parâmetros obrigatórios

### 7. Documentação
- `MODELO_DADOS.md`: tabela da aba `Evolucoes` atualizada com 14 colunas
- `ESPECIFICACOES_TELAS.md`: seção `Registro de Evolução` atualizada

---

## 📊 Resultado dos Testes
```
flutter test → 63 tests passed
flutter analyze → 0 errors
```

---

## 🔄 Pendências Futuras (não implementadas neste ciclo)
- [ ] Widget Test para `TelaRegistroEvolucao` (validações de campos obrigatórios)
- [ ] Teste de integração de agendamento → evolução
- [ ] Campo `observacoes` administrativas opcionais
- [ ] Exportar PDF do prontuário completo
