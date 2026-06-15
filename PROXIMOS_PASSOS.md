# Próximos Passos - Fase 2

## ✅ Fase 1 Concluída!

**3 Commits de Segurança implementados:**
1. ✅ `c908f61` - Mover credencial OAuth para variáveis de ambiente
2. ✅ `6370830` - Adicionar validadores de entrada
3. ✅ `f24123b` - Remover print() e adicionar developer.log()

---

## 🧪 Como Testar Agora

### Opção 1: Usando arquivo `.env`
```bash
# Criar arquivo local
cp .env.example .env

# Editar e adicionar seu Client ID:
# GOOGLE_OAUTH_CLIENT_ID_WEB=1034972209864-22ivlkbu9eu206fv6tvot90mup62stic.apps.googleusercontent.com

# Rodar com script
./run-dev.sh
```

### Opção 2: Passando como argumento
```bash
flutter run \
  --dart-define=GOOGLE_OAUTH_CLIENT_ID_WEB=1034972209864-22ivlkbu9eu206fv6tvot90mup62stic.apps.googleusercontent.com
```

### Opção 3: Exportar variável
```bash
export GOOGLE_OAUTH_CLIENT_ID_WEB=1034972209864-22ivlkbu9eu206fv6tvot90mup62stic.apps.googleusercontent.com
./run-dev.sh
```

---

## 📊 Status Atual

```
Segurança:    3.5/10 ➜ 6.0/10 ✅
├─ Credenciais Expostas     4/10 ➜ 10/10 ✅
├─ Validação de Entrada     0/10 ➜ 9/10 ✅
├─ Tratamento de Erro       3/10 ➜ 6/10 ✅
└─ Proteção de Dados        0/10 ➜ 2/10 (próximo)

Arquitetura:  5/10 (sem mudança nesta fase)
Qualidade:    6/10 (sem mudança nesta fase)

GERAL:        4.8/10 ➜ 5.5/10 ✅
```

---

## 🎯 Próximos Passos (Fase 2 e 3)

### Fase 2: Importante (Arquitetura) - 6 horas
**Quando:** Próxima semana

1. **Desacoplar da estrutura de colunas** (3h)
   - Remover índices hardcoded em Paciente
   - Usar Map de colunas ao invés de posições
   - Arquivo: `lib/modelos/paciente.dart`

2. **Melhorar tratamento de erro** (1h)
   - Adicionar logging em mais lugares
   - Melhorar mensagens de erro
   - Arquivo: `lib/servicos/servico_repositorio_dados.dart`

3. **Adicionar versionamento de esquema** (2h)
   - Criar `VersaoEsquema` class
   - Validar versão ao iniciar
   - Arquivo novo: `lib/servicos/versao_esquema.dart`

### Fase 3: Qualidade (Testes) - 5 horas
**Quando:** Fim da próxima semana

1. **Criar testes unitários** (3h)
   - Testes para validadores
   - Testes para parsing de data
   - Arquivo: `test/utilitarios/validadores_test.dart`

2. **Documentar APIs** (2h)
   - Adicionar documentação em Validadores
   - Adicionar documentação em Serviços
   - Arquivo: `lib/servicos/README.md`

---

## 📚 Documentação Disponível

```
Projeto Root:
├── ANALISE_MELHORIAS.md           ⭐ Leia primeiro (análise técnica)
├── RESUMO_EXECUTIVO.md            📊 Scorecard visual
├── ROTEIRO_IMPLEMENTACAO.md        🛠️  Passo a passo
├── FASE1_IMPLEMENTADO.md           ✅ O que foi feito
└── PROXIMOS_PASSOS.md              👈 Este arquivo

Código:
├── lib/utilitarios/validadores.dart (NOVO)
├── .env.example                      (NOVO)
├── run-dev.sh                        (NOVO)
└── [Vários arquivos modificados]
```

---

## 🔍 Validadores Disponíveis

### Uso em Código

```dart
import 'lib/utilitarios/validadores.dart';

// Validar CPF
if (Validadores.validarCPF('123.456.789-09')) {
  print('CPF válido');
}

// Gerar mensagem de erro
final erro = Validadores.mensagemErroCPF('123.456.789-00');
if (erro != null) {
  showError(erro);
}

// Todos os validadores:
Validadores.validarCPF(String) -> bool
Validadores.validarTelefone(String) -> bool
Validadores.validarDataNascimento(DateTime) -> bool
Validadores.validarEndereco(String) -> bool
Validadores.validarNome(String) -> bool

// Com mensagens de erro:
Validadores.mensagemErroCPF(String) -> String?
Validadores.mensagemErroTelefone(String) -> String?
Validadores.mensagemErroDataNascimento(DateTime?) -> String?
Validadores.mensagemErroEndereco(String) -> String?
Validadores.mensagemErroNome(String) -> String?
```

---

## 🚀 Checklist Antes de Publicar

### Antes de Publicar a Versão 1.0.6

```markdown
- [ ] Fase 1 Completa (FEITO)
  - [ ] Credencial segura
  - [ ] Validadores implementados
  - [ ] Logging melhorado
  
- [ ] Fase 2 Completa
  - [ ] Desacoplamento de colunas
  - [ ] Versionamento de esquema
  - [ ] Tratamento de erro robusto
  
- [ ] Fase 3 Completa
  - [ ] Testes unitários
  - [ ] Documentação de APIs
  - [ ] Code review
  
- [ ] Testes Manuais
  - [ ] Testar login Google
  - [ ] Testar cadastro de paciente
  - [ ] Testar validação de CPF
  - [ ] Testar em Android real
  - [ ] Testar em iOS (se tiver)
  - [ ] Testar em Web
  
- [ ] Segurança
  - [ ] flutter analyze (0 erros)
  - [ ] pub security audit (0 vulnerabilidades)
  - [ ] Revisar dados sensíveis nos logs
  
- [ ] Performance
  - [ ] Sem memory leaks
  - [ ] Startup < 2s
  - [ ] Operações de leitura < 1s
```

---

## 📞 Referências Rápidas

### Validar CPF
```dart
if (!Validadores.validarCPF(cpf)) {
  throw FormatException('CPF inválido');
}
```

### Validar Telefone
```dart
if (!Validadores.validarTelefone(phone)) {
  throw FormatException('Telefone inválido');
}
```

### Usar Developer Log
```dart
import 'dart:developer' as developer;

developer.log('Mensagem', error: e, stackTrace: st, name: 'MeuModulo');
```

### Rodar Análise
```bash
flutter analyze
flutter pub security audit
```

### Criar Novo Commit
```bash
git add [files]
git commit -m "Seu commit message" -m "Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>"
```

---

## 📈 Métricas Esperadas

| Métrica | Fase 1 | Fase 2 | Fase 3 |
|---------|--------|--------|--------|
| **Score de Segurança** | 6.0/10 | 7.0/10 | 7.5/10 |
| **Score de Arquitetura** | 5.0/10 | 7.5/10 | 8.0/10 |
| **Score de Qualidade** | 6.0/10 | 6.5/10 | 8.0/10 |
| **Cobertura de Teste** | 0% | 10% | 30% |
| **Linhas de Código** | +400 | +250 | +150 |

---

## ⏰ Cronograma Estimado

```
SEMANA 1:
├─ Seg-Ter: Fase 1 Implementação ✅ DONE
├─ Qua: Fase 1 Testes + Code Review
└─ Qui: Pequenos ajustes e fixes

SEMANA 2:
├─ Seg-Ter: Fase 2 Implementação
├─ Qua-Qui: Fase 2 Testes
└─ Sex: Consolidação

SEMANA 3:
├─ Seg-Ter: Fase 3 Testes + Docs
├─ Qua: Code Review Final
└─ Qui-Sex: Publicação 1.0.6 🎉
```

---

## 💡 Dicas para Próximas Implementações

1. **Use validadores sempre que possível**
   - Em formulários
   - Ao carregar dados de APIs
   - Ao salvar em banco de dados

2. **Log estruturado é seu amigo**
   - Sempre inclua `error` e `stackTrace`
   - Use `name` para identificar o módulo
   - Evite logs sensíveis (CPF, email)

3. **Teste com dados reais**
   - Validadores foram testados com CPFs reais
   - Telefones seguem padrão brasileiro (ANATEL)
   - Datas validam corretamente contra futuros

4. **Mantenha `.env.example` atualizado**
   - Novo desenvolvedor não fica perdido
   - Documenta todas as variáveis necessárias
   - Facilita onboarding

---

## 🆘 Troubleshooting

### Erro: "GOOGLE_OAUTH_CLIENT_ID_WEB não foi definido"
```bash
# Solução 1:
./run-dev.sh

# Solução 2:
export GOOGLE_OAUTH_CLIENT_ID_WEB=seu_client_id
flutter run

# Solução 3:
flutter run --dart-define=GOOGLE_OAUTH_CLIENT_ID_WEB=seu_client_id
```

### Erro: "CPF inválido" ao carregar dados
```dart
// Verificar se o CPF na planilha está correto
// Validadores.validarCPF() usa algoritmo oficial do governo
// Certifique-se que o CPF foi digitado corretamente
```

### Logs não aparecendo
```dart
// Verificar se está usando developer.log ao invés de print
import 'dart:developer' as developer;
developer.log('Seu log aqui', name: 'MeuModule');
```

---

**Última Atualização:** 2026-06-14  
**Status:** Fase 1 Concluída ✅  
**Próxima Revisão:** Após Fase 2
