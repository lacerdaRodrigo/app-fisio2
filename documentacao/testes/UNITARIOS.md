# 📁 Testes Unitários (89 testes)

Lógica pura: validação de entrada, transformação de dados, cálculos.

---

## test/unitarios/utilitarios/ (67 testes)

### validadores_test.dart (46 testes)

Valida entrada de usuário em toda a aplicação.

#### CPF (15 testes)
```dart
✓ Aceita CPF válido com formatação (111.444.777-35)
✓ Aceita CPF válido sem formatação (11144477735)
✓ Rejeita CPF com dígitos repetidos (111.111.111-11)
✓ Rejeita CPF com comprimento errado
✓ Rejeita CPF com dígito verificador inválido
✓ Rejeita CPF vazio
✓ Rejeita CPF com apenas pontos e hífens
✓ Retorna mensagem de erro para CPF inválido
✓ Retorna null para CPF válido
✓ Retorna mensagem específica para CPF vazio
```

#### Telefone (8 testes)
```dart
✓ Aceita telefone com 10 dígitos (11) 3333-4444
✓ Aceita telefone com 11 dígitos (11) 99999-9999
✓ Aceita telefone sem formatação com 10 dígitos
✓ Aceita telefone sem formatação com 11 dígitos
✓ Rejeita telefone com menos de 10 dígitos
✓ Rejeita telefone com mais de 11 dígitos
✓ Rejeita telefone começando com 0
✓ Rejeita DDD inválido (menor que 11)
```

#### Nome (6 testes)
```dart
✓ Aceita nome válido
✓ Rejeita nome vazio
✓ Rejeita nome com números
✓ Rejeita nome com caracteres especiais inválidos
✓ Valida comprimento mínimo
✓ Valida comprimento máximo
```

#### Data (8 testes)
```dart
✓ Rejeita data retroativa
✓ Aceita data futura
✓ Rejeita data vazia
✓ Valida data em formato correto
✓ Calcula dias até agendamento
✓ Evita agendamento no fim de semana (se aplicável)
```

#### Email (3 testes)
```dart
✓ Aceita email válido
✓ Rejeita email sem @
✓ Rejeita email incompleto
```

### validador_cpf_test.dart (9 testes)

Testes isolados da classe ValidadorCpf com casos extremos.

```dart
✓ Calcula dígito verificador correto
✓ Rejeita CPF com caracteres não-numéricos
✓ Trata underflow (strings muito curtas)
✓ Trata overflow (strings muito longas)
✓ Valida sequências de repetição
✓ Dígitos verificadores aplicados corretamente
```

### utilitarios_data_test.dart (12 testes)

Manipulação de datas e horários.

```dart
✓ Calcula idade corretamente (nascimento → idade)
✓ Calcula idade com data de referência
✓ Retorna idade correta no aniversário
✓ Retorna idade - 1 antes do aniversário
✓ Formata DateTime em DD/MM/YYYY
✓ Converte string DD/MM/YYYY → DateTime
✓ Calcula próximos 7 dias
✓ Identifica mesma semana
✓ Identifica mesmo mês
✓ Trata datas inválidas
```

---

## test/unitarios/modelos/ (22 testes)

Serialização, transformação e comportamento dos modelos de dados.

### paciente_test.dart (9 testes)

Modelo Paciente: dados cadastrais, anamnese, status.

```dart
✓ calcularIdade() retorna idade correta
✓ estaAtivo é true quando situacao = 'Ativo'
✓ estaAtivo é false quando situacao = 'Arquivado'
✓ copiarCom() mantém imutabilidade
✓ copiarCom() altera campos especificados
✓ paraMapaPlanilha() serializa corretamente
✓ Mapa contém todas as 19 colunas esperadas
✓ deLinhaPlanilha() desserializa linha corretamente
✓ Preserva anamnese na cópia
```

### agendamento_test.dart (7 testes)

Modelo Agendamento: sessões, desfechos, horários.

```dart
✓ Gera ID automaticamente
✓ Valida data/hora não retroativa
✓ Desfechos válidos: Realizado, Cancelado, Faltou
✓ paraMapaPlanilha() serializa com 9 colunas
✓ deLinhaPlanilha() desserializa linha
✓ Calcula duração corretamente
✓ Status em aberto vs finalizado
```

### evolucao_test.dart (6 testes)

Modelo Evolução: registros clínicos, protocolos.

```dart
✓ Gera timestamp automático
✓ Protocolo: avaliação vs reavaliação
✓ Campos obrigatórios validados
✓ paraMapaPlanilha() com 14 colunas
✓ deLinhaPlanilha() desserializa corretamente
✓ Preserva texto clínico após cópia
```

---

## Cobertura de Lógica

| Componente | Cobertura | Detalhes |
|---|---|---|
| Validadores | ✅ 100% | CPF, telefone, nome, data, email |
| Cálculos | ✅ 100% | Idade, duração, datas |
| Serialização | ✅ 100% | paraMapaPlanilha, deLinhaPlanilha |
| Transformação | ✅ 100% | copiarCom, status changes |

---

## Como Rodar Apenas Unitários

```bash
flutter test test/unitarios/
```

---

## Padrão: Arrange → Act → Assert

```dart
test('Paciente.calcularIdade deve retornar 40 para nascido 04/06/1986', () {
  // Arrange
  final paciente = Paciente(
    dataNascimento: DateTime(1986, 6, 4),
    ...
  );
  
  // Act
  final idade = paciente.calcularIdade(
    dataReferencia: DateTime(2026, 6, 4)
  );
  
  // Assert
  expect(idade, equals(40));
});
```
