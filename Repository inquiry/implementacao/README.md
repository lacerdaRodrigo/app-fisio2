# Fisio Home Care — Redesign (arquivos Dart)

Visual novo: **violeta `#6C4CE0`** (primary) + **verde-sálvia `#7CB9A8`** (secondary).
Todos os arquivos espelham a estrutura `lib/`. Copie por cima dos seus.

## Ordem de aplicação

1. **`lib/componentes/design_system_fisio.dart`** — a fundação (paleta + todos os
   componentes compartilhados). É a base de tudo; aplique primeiro.
2. **`lib/utilitarios/utilitarios_data_adicoes.dart`** — métodos de data que as
   telas usam. **Cole o corpo deles dentro da sua classe `UtilitariosData`**
   (não mantenha a classe `UtilitariosDataAdicoes` separada).
3. As telas em **`lib/telas/`**.

## Telas incluídas

- `tela_dashboard.dart` — Início
- `tela_sessoes.dart` — Sessões (busca, mês, filtros, lista por dia)
- `tela_pacientes.dart` — Pacientes (busca, agrupado por letra)
- `tela_nova_sessao.dart` — Nova/Editar Sessão
- `tela_cadastro_paciente.dart` — Cadastro/Anamnese/Editar Paciente
- `tela_registro_evolucao.dart` — Evolução (com ditado por voz)
- `tela_historico_paciente.dart` — Histórico + timeline
- `tela_login.dart` — Login Google + LGPD
- `tela_configuracoes.dart` — Configurações
- `tela_financeiro.dart` — Financeiro (já atualizado pro violeta)

## ⚠️ Campos de modelo esperados pelas telas

As telas foram escritas com as mesmas suposições do `tela_financeiro.dart` que
você já aceitou. Confirme/ajuste estes nomes nos seus modelos e providers:

**`Agendamento`**: `data` (DateTime), `horaInicio` (String "09:00"),
`valorSessao` (double/num), `foiRealizado` (bool), `estaAgendado` (bool),
`idPaciente` (String). *Opcional usado no Dashboard:* `enderecoResumido` (String?).

**`Paciente`**: `idPaciente` (String), `nome` (String), `ativo` (bool),
`valorSessao` (num), `cpf` (String?). *Opcional usado na lista:* `resumoStatus`
(String?).

> Os campos marcados como *opcionais* (`enderecoResumido`, `resumoStatus`) são
> usados com `?? fallback`. Se eles **não existirem** no seu modelo, remova a
> referência ou adicione o getter — senão o Dart não compila.

**Providers Riverpod**: `provedorListaAgendamentos`, `provedorListaPacientes`
(retornando `List<Agendamento>` / `List<Paciente>`).

## Fonte

O tema usa `PlusJakartaSans`. Adicione a fonte no `pubspec.yaml` (ou troque o
`fontFamily` em `fisioTheme()` por outra). Sem isso, o app usa a fonte padrão.

## Navegação

As telas não trazem `Scaffold`/bottom-nav próprios (exceto Login) — elas são o
**corpo** de cada aba. Use `FisioBottomNav` no seu shell de navegação:

```dart
Scaffold(
  body: IndexedStack(index: _aba, children: [
    TelaDashboard(nomeUsuario: nome, onNavegar: (i) => setState(() => _aba = i)),
    TelaSessoes(onAbrir: _abrirSessao),
    TelaPacientes(onAbrir: _abrirPaciente),
    TelaFinanceiro(),
  ]),
  bottomNavigationBar: FisioBottomNav(
    index: _aba,
    onChanged: (i) => setState(() => _aba = i),
    onFab: _novaSessao,
  ),
);
```
