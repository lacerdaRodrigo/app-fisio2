# Roteiro de Implementação - Correções Imediatas

## Fase 1: Crítico de Segurança (Fazer HOJE)

### 1.1 Remover Credencial Exposta

**Status:** 🔴 CRÍTICO

**Arquivo:** `lib/servicos/servico_autenticacao_google.dart`

**Passos:**

1. Criar arquivo `.env.example`:
```
GOOGLE_OAUTH_CLIENT_ID_WEB=SEU_CLIENT_ID_AQUI
```

2. Adicionar ao `.gitignore`:
```
.env
.env.local
.env.*.local
```

3. Modificar `servico_autenticacao_google.dart`:
```dart
const googleOAuthClientIdWeb = String.fromEnvironment(
  'GOOGLE_OAUTH_CLIENT_ID_WEB',
  defaultValue: '', // Forçar uso da variável de ambiente
);

// Adicionar validação no _criarGoogleSignIn():
GoogleSignIn _criarGoogleSignIn() {
  if (googleOAuthClientIdWeb.isEmpty) {
    throw StateError(
      'GOOGLE_OAUTH_CLIENT_ID_WEB não foi definido. '
      'Configure a variável de ambiente ou execute:\n'
      'flutter run --dart-define=GOOGLE_OAUTH_CLIENT_ID_WEB=SEU_CLIENT_ID'
    );
  }
  // ...
}
```

4. Para rodar localmente:
```bash
flutter run --dart-define=GOOGLE_OAUTH_CLIENT_ID_WEB=1034972209864-22ivlkbu9eu206fv6tvot90mup62stic.apps.googleusercontent.com
```

5. Para CI/CD (GitHub Actions):
```yaml
# .github/workflows/build.yml
- name: Build
  run: |
    flutter build web \
      --dart-define=GOOGLE_OAUTH_CLIENT_ID_WEB=${{ secrets.GOOGLE_OAUTH_CLIENT_ID_WEB }}
```

---

### 1.2 Implementar Validadores de Entrada

**Status:** 🔴 CRÍTICO

**Arquivo novo:** `lib/utilitarios/validadores.dart`

```dart
class Validadores {
  /// Valida um CPF. Remove formatação e verifica dígitos.
  static bool validarCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');
    
    // CPF deve ter 11 dígitos
    if (cpf.length != 11) return false;
    
    // Números repetidos são inválidos
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;
    
    // Validar primeiro dígito
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int resto = soma % 11;
    int digito1 = resto < 2 ? 0 : 11 - resto;
    
    if (int.parse(cpf[9]) != digito1) return false;
    
    // Validar segundo dígito
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    resto = soma % 11;
    int digito2 = resto < 2 ? 0 : 11 - resto;
    
    return int.parse(cpf[10]) == digito2;
  }
  
  /// Valida telefone brasileiro. Aceita (XX) XXXXX-XXXX ou variações.
  static bool validarTelefone(String telefone) {
    final apenas = telefone.replaceAll(RegExp(r'\D'), '');
    
    // Telefone deve ter 10 ou 11 dígitos (com ou sem 9)
    if (apenas.length < 10 || apenas.length > 11) return false;
    
    // Primeiros dígitos não podem ser zero
    if (apenas.startsWith('0')) return false;
    
    return true;
  }
  
  /// Valida data de nascimento. Não pode ser futura.
  static bool validarDataNascimento(DateTime data) {
    final hoje = DateTime.now();
    
    // Data não pode ser no futuro
    if (data.isAfter(hoje)) return false;
    
    // Pessoa deve ter pelo menos 18 anos
    int idade = hoje.year - data.year;
    if (hoje.month < data.month ||
        (hoje.month == data.month && hoje.day < data.day)) {
      idade--;
    }
    
    return idade >= 0; // Aqui pode ajustar para >= 18 se necessário
  }
  
  /// Valida endereco. Não pode estar vazio.
  static bool validarEndereco(String endereco) {
    return endereco.trim().isNotEmpty && endereco.length >= 5;
  }
  
  /// Valida nome. Deve ter pelo menos 2 nomes.
  static bool validarNome(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+'));
    return partes.length >= 2 && partes.every((p) => p.length >= 2);
  }
}
```

**Usar em `Paciente.deLinhaPlanilha()`:**

```dart
factory Paciente.deLinhaPlanilha(List<String> linha) {
  // Validar dados antes de criar
  final nome = linha.length > 1 ? linha[1] : '';
  if (!Validadores.validarNome(nome)) {
    throw FormatException('Nome inválido: "$nome"');
  }
  
  final cpf = linha.length > 4 ? linha[4] : '';
  if (!Validadores.validarCPF(cpf)) {
    throw FormatException('CPF inválido: "$cpf"');
  }
  
  final telefone = linha.length > 2 ? linha[2] : '';
  if (!Validadores.validarTelefone(telefone)) {
    throw FormatException('Telefone inválido: "$telefone"');
  }
  
  // Resto do código existente ...
}
```

---

### 1.3 Remover Prints de Debug

**Arquivo:** `lib/provedores/provedor_autenticacao.dart` (linhas 128-130)

**Mudar de:**
```dart
if (kDebugMode) {
  // ignore: avoid_print
  print('ERRO_LOGIN_GOOGLE: $e');
}
```

**Para:**
```dart
if (kDebugMode) {
  developer.log('Erro no login Google', error: e, name: 'Autenticacao');
}
```

**Adicionar import:**
```dart
import 'dart:developer' as developer;
```

**Habilitar lint em `analysis_options.yaml`:**
```yaml
linter:
  rules:
    avoid_print: true
```

---

## Fase 2: Erros Importantes (AMANHÃ)

### 2.1 Melhorar Tratamento de Erro

**Arquivo:** `lib/servicos/preferencias.dart`

```dart
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

class Preferencias {
  static const _chavePlanilhaId = 'planilha_id';

  static Future<String?> lerPlanilhaId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_chavePlanilhaId);
    } catch (e, stackTrace) {
      developer.log(
        'Erro ao ler planilha_id do SharedPreferences',
        error: e,
        stackTrace: stackTrace,
        name: 'Preferencias',
      );
      return null;
    }
  }

  static Future<void> salvarPlanilhaId(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chavePlanilhaId, id);
    } catch (e, stackTrace) {
      developer.log(
        'Erro ao salvar planilha_id no SharedPreferences',
        error: e,
        stackTrace: stackTrace,
        name: 'Preferencias',
      );
      // Relançar erro para que a UI saiba
      rethrow;
    }
  }

  static Future<void> limparPlanilhaId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chavePlanilhaId);
    } catch (e, stackTrace) {
      developer.log(
        'Erro ao limpar planilha_id do SharedPreferences',
        error: e,
        stackTrace: stackTrace,
        name: 'Preferencias',
      );
      // Não relançar aqui porque é uma limpeza
    }
  }
}
```

---

### 2.2 Desacoplar da Estrutura das Planilhas

**Arquivo:** `lib/modelos/paciente.dart`

```dart
class Paciente {
  // Mapa que documenta a estrutura esperada da planilha
  // IMPORTANTE: Atualizar isso quando reordenar colunas na planilha
  static const Map<String, int> _indicesColuna = {
    'idPaciente': 0,
    'nome': 1,
    'telefone': 2,
    'dataNascimento': 3,
    'cpf': 4,
    'endereco': 5,
    'queixaPrincipal': 6,
    'histDoencaAtual': 7,
    'histPregresso': 8,
    'ocupacao': 9,
    'situacao': 10,
    'dataCadastro': 11,
    'genero': 12,
    'dor': 13,
    'comorbidades': 14,
    'medicamentos': 15,
    'alergias': 16,
    'cirurgias': 17,
    'habitosVida': 18,
  };

  // ... resto da classe ...

  factory Paciente.deLinhaPlanilha(List<String> linha) {
    /// Helper para obter valor seguro de um índice
    String? obterValor(String chave, {String padrao = ''}) {
      final idx = _indicesColuna[chave];
      if (idx == null || idx >= linha.length) return padrao;
      final valor = linha[idx].trim();
      return valor.isEmpty ? padrao : valor;
    }

    /// Helper para datas
    DateTime? obterData(String chave) {
      final valor = obterValor(chave);
      if (valor.isEmpty) return null;
      
      final partes = valor.split('/');
      if (partes.length == 3) {
        try {
          return DateTime.tryParse(
            '${partes[2]}-${partes[1].padLeft(2, '0')}-${partes[0].padLeft(2, '0')}',
          );
        } catch (_) {
          return null;
        }
      }
      
      return DateTime.tryParse(valor);
    }

    final dataNasc = obterData('dataNascimento') ?? DateTime.now();

    return Paciente(
      idPaciente: obterValor('idPaciente'),
      nome: obterValor('nome'),
      telefone: obterValor('telefone'),
      dataNascimento: dataNasc,
      cpf: obterValor('cpf'),
      endereco: obterValor('endereco'),
      queixaPrincipal: obterValor('queixaPrincipal', padrao: '')
          .isEmpty
          ? null
          : obterValor('queixaPrincipal'),
      // ... resto dos campos ...
      situacao: obterValor('situacao', padrao: 'Ativo'),
      dataCadastro: obterData('dataCadastro') ?? DateTime.now(),
    );
  }
}
```

---

### 2.3 Adicionar Versionamento de Esquema

**Novo arquivo:** `lib/servicos/versao_esquema.dart`

```dart
class VersaoEsquema {
  static const int VERSAO_ATUAL = 1;
  
  /// Descrição de mudanças por versão
  static const Map<int, String> HISTORICO = {
    1: 'Versão inicial com abas: Pacientes, Agenda, Evolucoes, Configuracoes, Auditoria',
  };
  
  /// Índices das colunas por versão
  /// Usar essa função ao migrar dados entre versões
  static Map<String, int> obterIndicesColuna(int versao) {
    switch (versao) {
      case 1:
        return {
          'idPaciente': 0,
          'nome': 1,
          'telefone': 2,
          // ... resto das colunas ...
        };
      default:
        throw UnsupportedError('Versão de esquema $versao não suportada');
    }
  }
}
```

**Adicionar em `servico_google_sheets.dart`:**

```dart
class ServicoGoogleSheets {
  static const nomeBanco = '__saas_fisio_db__';
  static const int VERSAO_ESQUEMA = 1;
  
  // ... resto do código ...
  
  /// Cria a planilha com a versão do esquema
  Future<String> criarPlanilhaBanco() async {
    final planilha = await _api.spreadsheets.create(
      sheets.Spreadsheet(
        properties: sheets.SpreadsheetProperties(
          title: nomeBanco,
        ),
        sheets: [
          // Adicionar aba de versão como primeira
          sheets.Sheet(
            properties: sheets.SheetProperties(
              title: 'Versao',
              index: 0,
            ),
          ),
          for (final aba in cabecalhos.keys)
            sheets.Sheet(
              properties: sheets.SheetProperties(title: aba),
            ),
        ],
      ),
      $fields: 'spreadsheetId',
    );

    final id = planilha.spreadsheetId;
    if (id == null || id.isEmpty) {
      throw StateError('Não foi possível criar a planilha de dados.');
    }

    // Salvar versão
    await atualizarLinha(id, 'Versao!A1:B1', ['versao', VERSAO_ESQUEMA.toString()]);
    await garantirCabecalhos(id);
    
    return id;
  }
  
  /// Lê a versão do esquema da planilha
  Future<int> lerVersaoEsquema(String planilhaId) async {
    try {
      final resposta = await _api.spreadsheets.values.get(
        planilhaId,
        'Versao!B1',
      );
      
      final valores = resposta.values;
      if (valores == null || valores.isEmpty) {
        return 1; // Versão padrão se não existir
      }
      
      return int.tryParse(valores[0][0].toString()) ?? 1;
    } catch (_) {
      return 1;
    }
  }
  
  /// Garante que a versão é compatível
  Future<void> validarVersao(String planilhaId) async {
    final versaoSheets = await lerVersaoEsquema(planilhaId);
    
    if (versaoSheets > VERSAO_ESQUEMA) {
      throw StateError(
        'A planilha usa versão $versaoSheets, '
        'mas este app suporta apenas até versão $VERSAO_ESQUEMA. '
        'Atualize o app.'
      );
    }
    
    if (versaoSheets < VERSAO_ESQUEMA) {
      throw StateError(
        'A planilha usa versão $versaoSheets, '
        'mas este app requer versão $VERSAO_ESQUEMA. '
        'Execute a migração em: https://...'
      );
    }
  }
}
```

---

## Fase 3: Arquitetura (PRÓXIMA SEMANA)

### 3.1 Criar Sistema de Migrations

**Novo arquivo:** `lib/servicos/migrations/migracao.dart`

```dart
abstract class Migracao {
  int get versaoOrigem;
  int get versaoDestino;
  String get descricao;
  
  /// Execute a migração
  Future<void> executar(
    ServicoGoogleSheets sheets,
    String planilhaId,
  );
}
```

### 3.2 Melhorar Gestão de Configurações

**Novo arquivo:** `lib/servicos/servico_configuracao.dart`

```dart
class ServicoConfiguracao {
  static const String _chaveValorSessao = 'valor_sessao_padrao';
  static const String _valoPadraoSessao = '150,00';
  
  final ServicoGoogleSheets _sheets;
  final String planilhaId;
  
  ServicoConfiguracao({
    required this.planilhaId,
    required ServicoGoogleSheets sheets,
  }) : _sheets = sheets;
  
  Future<String> obterValorSessaoPadrao() async {
    final config = await _sheets.lerAba(planilhaId, 'Configuracoes');
    for (final linha in config) {
      if (linha.isNotEmpty && linha[0] == _chaveValorSessao) {
        return linha.length > 1 ? linha[1] : _valoPadraoSessao;
      }
    }
    return _valoPadraoSessao;
  }
  
  Future<void> salvarValorSessaoPadrao(String valor) async {
    await _sheets.inserirOuAtualizar(
      planilhaId,
      'Configuracoes',
      _chaveValorSessao,
      valor,
    );
  }
}
```

---

## Checklist de Implementação

```markdown
### Fase 1: Crítico (Fazer HOJE)
- [ ] Mover credencial OAuth para .env
- [ ] Criar arquivo .env.example
- [ ] Criar validadores.dart
- [ ] Adicionar validação em Paciente.deLinhaPlanilha()
- [ ] Remover print() de debug
- [ ] Habilitar lint avoid_print

### Fase 2: Importante (AMANHÃ)
- [ ] Melhorar tratamento de erro em Preferencias
- [ ] Desacoplar Paciente da estrutura de colunas
- [ ] Adicionar versionamento de esquema
- [ ] Testar mudanças localmente

### Fase 3: Arquitetura (PRÓXIMA SEMANA)
- [ ] Criar sistema de migrations
- [ ] Melhorar ServicoConfiguracao
- [ ] Adicionar testes unitários
- [ ] Documentar APIs públicas
```

---

## Comandos Para Testar

```bash
# Verificar análise estática
flutter analyze

# Rodar com credencial definida
flutter run --dart-define=GOOGLE_OAUTH_CLIENT_ID_WEB=1034972209864-22ivlkbu9eu206fv6tvot90mup62stic.apps.googleusercontent.com

# Limpar cache e rebuildar
flutter clean && flutter pub get && flutter run
```

---

## Próximos Passos

1. **Implemente a Fase 1 completa**
2. **Faça commit com mensagem:** "Correções críticas de segurança"
3. **Teste em dispositivo real**
4. **Depois inicie Fase 2**
