# Análise de Segurança e Arquitetura - Fisio Home Care

## 🔴 CRÍTICO - Problemas de Segurança

### 1. **Credencial Exposta no Código** (MÁXIMA PRIORIDADE)
**Arquivo:** `lib/servicos/servico_autenticacao_google.dart` (linhas 8-12)

```dart
const googleOAuthClientIdWeb = String.fromEnvironment(
  'GOOGLE_OAUTH_CLIENT_ID_WEB',
  defaultValue: '1034972209864-22ivlkbu9eu206fv6tvot90mup62stic.apps.googleusercontent.com',
);
```

**Problema:** O Client ID do OAuth está exposto no código-fonte. Isso permite:
- Alguém usar esse ID para fazer requisições maliciosas
- Interceptação de autenticação
- Vazamento de dados dos usuários

**Solução:**
```dart
const googleOAuthClientIdWeb = String.fromEnvironment(
  'GOOGLE_OAUTH_CLIENT_ID_WEB',
  defaultValue: '', // Deixar vazio força uso da variável de ambiente
);
```

**Adicionar ao `.env` e `.gitignore`:**
```bash
GOOGLE_OAUTH_CLIENT_ID_WEB=1034972209864-22ivlkbu9eu206fv6tvot90mup62stic.apps.googleusercontent.com
```

---

### 2. **Falta de Validação de Dados de Entrada**
**Arquivos afetados:** `lib/modelos/paciente.dart`, `lib/telas/tela_cadastro_paciente.dart`

**Problema:** CPF, telefone e email não são validados antes de salvar nas planilhas.

**Risco:** Dados inválidos corrompem o banco de dados e pueden enganar relatórios.

**Solução - Criar utilitários de validação:**

```dart
// lib/utilitarios/validadores.dart
class Validadores {
  static bool validarCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');
    if (cpf.length != 11) return false;
    if (cpf == '00000000000' || cpf == '11111111111') return false;
    
    // Cálculo de dígitos verificadores
    int primerDigito = _calcularDigito(cpf.substring(0, 9));
    int segundoDigito = _calcularDigito(cpf.substring(0, 9) + primerDigito.toString());
    
    return cpf[9] == primerDigito.toString() && cpf[10] == segundoDigito.toString();
  }
  
  static bool validarTelefone(String telefone) {
    String apenas = telefone.replaceAll(RegExp(r'\D'), '');
    return apenas.length >= 10 && apenas.length <= 11;
  }
  
  static bool validarEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
  
  static int _calcularDigito(String sequencia) {
    int soma = 0;
    int multiplicador = sequencia.length + 1;
    
    for (int i = 0; i < sequencia.length; i++) {
      soma += int.parse(sequencia[i]) * multiplicador;
      multiplicador--;
    }
    
    int resto = soma % 11;
    return resto < 2 ? 0 : 11 - resto;
  }
}
```

**Usar em `Paciente.deLinhaPlanilha()`:**
```dart
factory Paciente.deLinhaPlanilha(List<String> linha) {
  // ... código existente ...
  
  // Validar CPF
  final cpfLimpo = linha[4].replaceAll(RegExp(r'\D'), '');
  if (!Validadores.validarCPF(linha[4])) {
    throw FormatException('CPF inválido: ${linha[4]}');
  }
  
  return Paciente(
    cpf: cpfLimpo,
    // ... resto dos dados ...
  );
}
```

---

### 3. **Acesso Não Controlado aos Dados**
**Problema:** Qualquer usuário autenticado acessa todos os dados de todos os pacientes.

**Risco:** Um fisioterapeuta pode ver dados de pacientes de outro.

**Solução:** Adicionar controle de acesso em nível de aplicação:

```dart
// lib/servicos/servico_controle_acesso.dart
class ServicoControleAcesso {
  final String emailUsuarioLogado;
  
  ServicoControleAcesso({required this.emailUsuarioLogado});
  
  /// Verifica se o usuário tem permissão para acessar um paciente
  bool podeAcessarPaciente(Paciente paciente) {
    // Por enquanto, o próprio usuário é dono de todos seus pacientes
    // Futuramente: verificar em uma aba 'Permissoes' da planilha
    return true;
  }
  
  /// Filtra apenas pacientes que o usuário pode acessar
  List<Paciente> filtrarPacientesPermitidos(List<Paciente> pacientes) {
    return pacientes.where((p) => podeAcessarPaciente(p)).toList();
  }
}
```

---

### 4. **Sem Proteção contra Dados Sensíveis em Logs**
**Arquivo:** `lib/provedores/provedores_dados.dart` (linhas 313-321)

**Problema:** Logs registram operações mas poderiam expor informações de pacientes.

**Solução:**
```dart
void registrarLog(WidgetRef ref, String operacao, String detalhes) {
  // Nunca registrar dados sensíveis (CPF, telefone, etc)
  final detalhesSeguro = detalhes
    .replaceAll(RegExp(r'\d{3}\.\d{3}\.\d{3}-\d{2}'), '[CPF]') // Mascarar CPF
    .replaceAll(RegExp(r'\(\d{2}\)\s?\d{4,5}-\d{4}'), '[TELEFONE]'); // Mascarar telefone
  
  final agora = DateTime.now();
  final data =
      '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year} '
      '${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}';

  ref
      .read(provedorLogsAuditoria.notifier)
      .adicionar('$data - $operacao - $detalhesSeguro');
}
```

---

## 🟠 IMPORTANTE - Problemas de Arquitetura

### 5. **Acoplamento Forte com Estrutura das Planilhas**
**Arquivo:** `lib/modelos/paciente.dart` (linhas 85-123)

**Problema:** O índice de cada coluna é hardcoded. Se mudar a ordem, quebra.

```dart
factory Paciente.deLinhaPlanilha(List<String> linha) {
    // ... Isso quebra se reordenar as colunas ...
    return Paciente(
      idPaciente: linha[0],      // Posição 0 = ID
      nome: linha[1],             // Posição 1 = Nome
      telefone: linha[2],         // Posição 2 = Telefone
      // ...
    );
}
```

**Solução - Usar Map ao invés de índices:**

```dart
class Paciente {
  // Mapa de colunas para índices (atualizar quando mudar na Sheets)
  static const _indicesColuna = {
    'ID_Paciente': 0,
    'Nome': 1,
    'Telefone': 2,
    'Data_Nascimento': 3,
    'CPF': 4,
    'Endereco': 5,
    'Queixa_Principal': 6,
    // ... resto ...
  };

  factory Paciente.deLinhaPlanilha(List<String> linha) {
    final obter = (String chave) {
      final idx = _indicesColuna[chave];
      if (idx == null || idx >= linha.length) return null;
      return linha[idx].isEmpty ? null : linha[idx];
    };

    return Paciente(
      idPaciente: obter('ID_Paciente') ?? '',
      nome: obter('Nome') ?? '',
      telefone: obter('Telefone') ?? '',
      // ... resto usando obter() ...
    );
  }
}
```

---

### 6. **Tratamento de Erro Silencioso**
**Arquivo:** `lib/servicos/preferencias.dart` (linhas 6-19)

**Problema:** Erros são silenciosamente ignorados, dificultando debug.

```dart
static Future<String?> lerPlanilhaId() async {
  try {
    // ...
  } catch (_) {  // ❌ Ignorando o erro completamente
    return null;
  }
}
```

**Solução:**

```dart
import 'dart:developer' as developer;

class Preferencias {
  static Future<String?> lerPlanilhaId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_chavePlanilhaId);
    } catch (e, stackTrace) {
      developer.log(
        'Erro ao ler planilhaId',
        error: e,
        stackTrace: stackTrace,
        name: 'Preferencias',
      );
      return null;
    }
  }
}
```

---

### 7. **Sem Versionamento de Dados**
**Problema:** Se a estrutura das planilhas mudar, versões antigas do app quebram.

**Solução - Adicionar versão:**

```dart
// lib/servicos/servico_google_sheets.dart
class ServicoGoogleSheets {
  static const VERSAO_ESQUEMA = 2; // Incrementar quando mudar estrutura
  
  static const cabecalhos = <String, List<String>>{
    'Versao': ['versao'],  // Nova aba para versionamento
    'Pacientes': [ /* ... */ ],
    // ...
  };
  
  Future<void> garantirEstrutura(String planilhaId) async {
    // Verificar versão antes de fazer operações
    final versaoGoogleSheets = await lerVersaoEsquema(planilhaId);
    
    if (versaoGoogleSheets != VERSAO_ESQUEMA) {
      throw StateError(
        'Esquema da planilha é versão $versaoGoogleSheets, '
        'mas app espera versão $VERSAO_ESQUEMA. '
        'Atualize a planilha em https://...'
      );
    }
  }
}
```

---

### 8. **Configurações Hardcoded**
**Arquivo:** `lib/provedores/provedores_dados.dart` (linha 87)

```dart
class ValorSessaoPadraoNotifier extends Notifier<String> {
  @override
  String build() => '150,00';  // ❌ Hardcoded
}
```

**Solução:**

```dart
class ConfiguracaoAppNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => {
    'valor_sessao_padrao': '150,00',
    'max_pacientes_por_pagina': '20',
    'dias_retention_logs': '90',
  };

  void atualizar(String chave, String valor) {
    state = {...state, chave: valor};
  }
}

final provedorConfiguracao = 
    NotifierProvider<ConfiguracaoAppNotifier, Map<String, String>>(
      ConfiguracaoAppNotifier.new,
    );
```

---

### 9. **Ausência de Invalidação de Cache**
**Problema:** O cache é limpo manualmente, mas não há estratégia clara.

**Solução - Adicionar TTL (Time To Live):**

```dart
class RepositorioDadosGoogle {
  String? _planilhaId;
  DateTime? _ultimaAtualizacao;
  
  static const _cacheTTL = Duration(minutes: 15);
  
  bool _cacheExpirou() {
    if (_ultimaAtualizacao == null) return true;
    return DateTime.now().difference(_ultimaAtualizacao!) > _cacheTTL;
  }
  
  Future<String> obterPlanilhaId() async {
    if (_planilhaId != null && !_cacheExpirou()) {
      return _planilhaId!;
    }
    
    // Carregar do servidor ...
    _ultimaAtualizacao = DateTime.now();
    return _planilhaId!;
  }
}
```

---

### 10. **Sem Migração de Dados entre Versões**
**Problema:** Se a estrutura muda, dados antigos ficam para trás.

**Solução - Sistema de migrations:**

```dart
// lib/servicos/migrations.dart
abstract class Migracao {
  int get versaoOrigem;
  int get versaoDestino;
  Future<void> executar(ServicoGoogleSheets sheets, String planilhaId);
}

class MigracaoV1ParaV2 implements Migracao {
  @override
  int get versaoOrigem => 1;
  @override
  int get versaoDestino => 2;

  @override
  Future<void> executar(ServicoGoogleSheets sheets, String planilhaId) async {
    // Exemplo: Adicionar coluna "Email" à aba Pacientes
    // 1. Ler dados atuais
    // 2. Adicionar nova coluna
    // 3. Salvar dados atualizados
  }
}
```

---

## 🟡 RECOMENDAÇÕES - Melhorias de Qualidade

### 11. **Evitar `print()` em Produção**
Habilitar a lint `avoid_print` em `analysis_options.yaml`:

```yaml
linter:
  rules:
    avoid_print: true
```

Usar `dart:developer` ao invés:

```dart
import 'dart:developer' as developer;

// Ao invés de:
// print('ERRO_LOGIN_GOOGLE: $e');

developer.log('Erro no login Google', error: e, name: 'Auth');
```

---

### 12. **Reduzir Duplicação de Código**
Muitas funções seguem o padrão "ler, modificar linha, salvar". Criar helper:

```dart
// lib/servicos/servico_repositorio_dados.dart
Future<void> _atualizarRegistro(
  String aba,
  String idRegistro,
  int indiceColuna,
  String novoValor,
  String operacao,
  String detalhes,
) async {
  final id = await obterPlanilhaId();
  final linhas = await _sheets.lerAba(id, aba);
  final indice = linhas.indexWhere(
    (linha) => linha.isNotEmpty && linha.first == idRegistro,
  );
  
  if (indice == -1) return;

  final linha = _preencher(linhas[indice], /* tamanho */);
  linha[indiceColuna] = novoValor;
  
  await _sheets.atualizarLinha(id, '$aba!A${indice + 2}:...', linha);
  await registrarAuditoria(operacao, detalhes);
}
```

---

### 13. **Adicionar Testes de Integração**
```dart
// test/servicos/servico_repositorio_dados_test.dart
void main() {
  group('RepositorioDadosGoogle', () {
    test('salvarPaciente deve inserir linha válida', () async {
      final paciente = Paciente(
        idPaciente: 'ID123',
        nome: 'João Silva',
        telefone: '11999999999',
        // ...
      );
      
      // await repositorio.salvarPaciente(paciente);
      // expect(linhas.contains(...), true);
    });
  });
}
```

---

### 14. **Documentar APIs Públicas**
```dart
/// Autentica o usuário com a conta Google.
/// 
/// Lança [StateError] se o login é cancelado.
/// Lança [PlatformException] se há erro na plataforma.
Future<SessaoGoogle> entrar() async {
  // ...
}
```

---

### 15. **Melhorar Tratamento de Estado de Carregamento**
Adicionar estado de sucesso/erro mais granulares:

```dart
enum StatusCarregamentoDados { 
  inicial, 
  carregando, 
  carregado, 
  erro,
  aguardandoRetentativa,  // ← novo
  vencimentoCache,         // ← novo
}
```

---

## 📋 Priorização de Implementação

1. **HOJE:** Mover credencial do OAuth para `.env`
2. **HOJE:** Implementar validadores (CPF, telefone, email)
3. **AMANHÃ:** Adicionar versionamento de esquema
4. **AMANHÃ:** Melhorar tratamento de erros
5. **PRÓXIMA SEMANA:** Implementar migrations
6. **PRÓXIMA SEMANA:** Adicionar testes de integração
7. **PRÓXIMA SEMANA:** Documentar APIs públicas

---

## 📚 Recursos Úteis

- OWASP Top 10: https://owasp.org/www-project-top-ten/
- Dart Security: https://dart.dev/security
- LGPD para Desenvolvimento: https://www.gov.br/cidadania/pt-br/acesso-a-informacao/lgpd
