# Sugestões de Correção — Cadastro de Paciente

Problemas encontrados durante a análise do código-fonte do módulo de cadastro de paciente. Organizados por gravidade.

---

## 🔴 Críticos

### S1 — `deLinhaPlanilha` quebra se data da planilha estiver mal formatada

**Arquivo:** `lib/modelos/paciente.dart:86-95`
**Problema:** O método `deLinhaPlanilha` faz `linha[3].split('/')` e acessa `partesData[2]` sem verificar se a data é válida. Se uma célula da planilha estiver vazia, com formato incorreto ou apenas parcial, o método lança `RangeError` e **todo o carregamento de dados falha**, impedindo o app de funcionar.
**Sugestão:**
```dart
factory Paciente.deLinhaPlanilha(List<String> linha) {
  final partesData = linha.length > 3 ? linha[3].split('/') : [];
  DateTime? dataNasc;
  if (partesData.length == 3) {
    dataNasc = DateTime.tryParse(
      '${partesData[2]}-${partesData[1].padLeft(2, '0')}-${partesData[0].padLeft(2, '0')}',
    );
  }
  dataNasc ??= DateTime.now(); // fallback ou lançar erro tratado
  // ... resto do factory
}
```

### S2 — `DropdownButtonFormField` usa parâmetro `initialValue` (inexistente)

**Arquivo:** `lib/telas/tela_cadastro_paciente.dart:249`
**Problema:** O código usa `initialValue: _genero` no `DropdownButtonFormField`. Este widget **não possui** o parâmetro `initialValue` — o parâmetro correto é `value`. Dependendo da versão do Flutter, isso pode causar erro de compilação ou ser ignorado silenciosamente.
**Sugestão:**
```dart
DropdownButtonFormField<String>(
  value: _genero, // ← trocar initialValue por value
  // ...
)
```

---

## 🟠 Médios

### S3 — ID do paciente derivado de `length + 1` — risco de duplicata

**Arquivo:** `lib/telas/tela_cadastro_paciente.dart:470`
**Problema:** `idPaciente: 'P${(pacientes.length + 1).toString().padLeft(3, '0')}'`. Se dois pacientes forem cadastrados antes de um reload da lista (ou em paralelo), ambos receberão o mesmo ID. Além disso, se pacientes forem arquivados, o ID incrementa sem reuso, causando lacunas.
**Sugestão:** Usar timestamp + random, ou consultar o maior ID existente na lista para determinar o próximo:
```dart
final maxId = pacientes
    .map((p) => int.tryParse(p.idPaciente.replaceAll('P', '')) ?? 0)
    .reduce((a, b) => a > b ? a : b);
final novoId = 'P${(maxId + 1).toString().padLeft(3, '0')}';
```

### S4 — Comparação de CPF duplicado usa valor mascarado vs. raw

**Arquivo:** `lib/telas/tela_cadastro_paciente.dart:456`
**Problema:** `paciente.cpf == cpf` compara o CPF mascarado do formulário (`529.982.247-25`) com o CPF armazenado. Se um paciente foi importado ou cadastrado sem máscara (`52998224725`), a comparação falha e permite duplicata.
**Sugestão:**
```dart
final cpfLimpo = cpf.replaceAll(RegExp(r'[^\d]'), '');
final cpfJaCadastrado = pacientes.any(
  (p) => p.cpf.replaceAll(RegExp(r'[^\d]'), '') == cpfLimpo,
);
```

### S5 — Telefone sem validação de tamanho mínimo

**Arquivo:** `lib/telas/tela_cadastro_paciente.dart:141-146`
**Problema:** O validador do telefone só verifica se está vazio. Um telefone com 2 dígitos (`(11) 9`) passa na validação e é salvo como dado inconsistente.
**Sugestão:**
```dart
validator: (v) {
  if (v == null || v.isEmpty) return 'Telefone é obrigatório.';
  final digitos = v.replaceAll(RegExp(r'[^\d]'), '');
  if (digitos.length < 10) return 'Telefone deve ter pelo menos 10 dígitos.';
  return null;
},
```

### S6 — `histPregresso` e `ocupacao` existem no modelo mas não têm campo na UI

**Arquivos:** `lib/modelos/paciente.dart:11-12` e `lib/telas/tela_cadastro_paciente.dart`
**Problema:** O modelo `Paciente` possui os campos `histPregresso` (História Pregressa) e `ocupacao` (Ocupação/Profissão), mas o formulário de cadastro não oferece campos para preenchê-los. Dados vindos da planilha com esses campos preenchidos são carregados, mas novos cadastros sempre os terão como `null` — **inconsistência de dados**.
**Sugestão:** Adicionar campos no formulário:
- Após "HDA", adicionar "História Pregressa (HP)" (TextFormField, maxLines: 3)
- Após "Hábitos de Vida", adicionar "Ocupação/Profissão" (TextFormField)

### S7 — Campos editáveis durante o salvamento

**Arquivo:** `lib/telas/tela_cadastro_paciente.dart:400-410`
**Problema:** Durante o `_salvarPaciente`, apenas o botão "Salvar Paciente" é desabilitado. O usuário pode continuar editando os campos de texto e alterando o dropdown, causando inconsistências se os dados mudarem após a validação mas antes da persistência remota.
**Sugestão:** Envolver todo o formulário em um `AbsorbPointer` durante o salvamento:
```dart
AbsorbPointer(
  absorbing: _salvando,
  child: Form(...),
)
```

---

## 🟡 Leves

### S8 — Modelo retorna `""` vazio da planilha, mas formulário envia `null`

**Arquivos:** `lib/modelos/paciente.dart:98-113` vs `lib/telas/tela_cadastro_paciente.dart:476-500`
**Problema:** `deLinhaPlanilha` faz `queixaPrincipal: linha[6]` (retorna `""` se vazio). O formulário faz `queixaPrincipal: ... isEmpty ? null : ...` (retorna `null` se vazio). Código que compara contra `null` pode falhar com dados da planilha.
**Sugestão:** Unificar a abordagem. Sugiro normalizar no modelo:
```dart
// No factory deLinhaPlanilha:
queixaPrincipal: linha.length > 6 && linha[6].isNotEmpty ? linha[6] : null,
```

### S9 — Validação de data de nascimento e endereço fora do Form — UX desconexa

**Arquivo:** `lib/telas/tela_cadastro_paciente.dart:439-451`
**Problema:** Data de nascimento e endereço são validados manualmente com SnackBars APÓS o `Form.validate()`. Isso significa que o usuário corrige um erro de cada vez: primeiro vê os erros de validação inline, submete, vê snackbar da data, corrige, submete, vê snackbar do endereço.
**Sugestão:** Integrar a validação destes campos ao `Form`:
```dart
// Para data: usar um TextFormField não editável com onTap que abre DatePicker
TextFormField(
  controller: _dataController, // controlador que armazena a data formatada
  readOnly: true,
  validator: (_) => _dataNascimento == null ? 'Selecione a data de nascimento.' : null,
  onTap: () => showDatePicker(...).then((d) { ... }),
)

// Para endereço: usar um TextFormField não editável
TextFormField(
  controller: _enderecoController, // controlador que armazena o endereço
  readOnly: true,
  validator: (_) => _enderecoCompleto.isEmpty ? 'Preencha o endereço.' : null,
  onTap: () => _mostrarModalEndereco(),
)
```

### S10 — Badge de contagem mostra "Ativos" mesmo no filtro "Arquivados"

**Arquivo:** `lib/telas/tela_pacientes.dart:105-115`
**Problema:** Quando o filtro "Arquivados" está ativo, o badge exibe `${qtdeAtivos} ativos` em vez de `${pacientesFiltrados.length} arquivados`.
**Sugestão:**
```dart
String textoContagem;
switch (_filtro) {
  case FiltroPacientes.todos:
    textoContagem = '${pacientes.length} total';
  case FiltroPacientes.ativos:
    textoContagem = '$qtdeAtivos ativos';
  case FiltroPacientes.arquivados:
    textoContagem = '$qtdeArquivados arquivados';
}
```

### S11 — Chip "Arquivados" alterna para "Ativos" ao tocar novamente — UX confusa

**Arquivo:** `lib/telas/tela_pacientes.dart:191-198`
**Problema:** Tocar no chip "Arquivados" quando já está selecionado muda para "Ativos" em vez de apenas manter ou desselecionar. Usuário pode estranhar o comportamento.
**Sugestão:** Tornar o toggle previsível: tocar no chip já selecionado não faz nada (no-op), ou alterna entre todos os filtros de forma consistente.

### S12 — Lista de pacientes sem estado de carregamento

**Arquivo:** `lib/telas/tela_pacientes.dart`
**Problema:** Quando a lista está vazia porque ainda está carregando (spinner do Google Sheets), a UI mostra "Nenhum paciente encontrado." — o mesmo texto de quando realmente não há pacientes. O usuário não sabe diferenciar "carregando" de "vazio".
**Sugestão:** Observar `provedorCarregamentoDados` e exibir um `CircularProgressIndicator` enquanto o estado for `carregando`:
```dart
final estadoCarregamento = ref.watch(provedorCarregamentoDados);
// ...
if (estadoCarregamento is Carregando) {
  return const Center(child: CircularProgressIndicator());
}
```
