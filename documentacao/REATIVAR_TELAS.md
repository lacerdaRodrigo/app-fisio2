# Reativação de Telas Desativadas

## Histórico

Em 08/06/2026, a tela de **Ajustes** foi desativada da navegação principal para permitir o desenvolvimento focado das telas essenciais: Login, Início (Dashboard), Pacientes e Nova Sessão.

## O que foi desativado

- **Aba Ajustes** na navegação inferior (bottom navigation)
- A tela `TelaConfiguracoes` (`lib/telas/tela_configuracoes.dart`) **não foi excluída** — apenas não é mais navegável via bottom nav

## Telas que permanecem ativas

| Tela | Arquivo | Acesso |
|---|---|---|
| Login | `tela_login.dart` | Inicial |
| Início (Dashboard) | `tela_dashboard.dart` | Aba 1 |
| Pacientes | `tela_pacientes.dart` | Aba 2 |
| Nova Sessão | `tela_nova_sessao.dart` | FAB no Início |
| Registro de Evolução | `tela_registro_evolucao.dart` | Botão na agenda + modal do paciente |
| Histórico de Evoluções | `tela_historico_evolucoes.dart` | Modal do paciente |

## Como reativar a tela de Ajustes

No arquivo `lib/telas/tela_dashboard.dart`:

1. **Adicionar o import** (entre as linhas de import):
   ```dart
   import 'tela_configuracoes.dart';
   ```

2. **Adicionar na lista `telas`** (após `const TelaPacientes()`):
   ```dart
   final telas = [
     _construirConteudoDashboard(context),
     const TelaPacientes(),
     const TelaConfiguracoes(),  // <-- reativar
   ];
   ```

3. **Adicionar o destino na `NavigationBar`** (após o destino de Pacientes):
   ```dart
   NavigationDestination(
     icon: Icon(Icons.settings_rounded),
     label: 'Ajustes',
   ),
   ```

4. Ajustar o índice se necessário — `_indiceSelecionado` deve suportar range 0-2.
