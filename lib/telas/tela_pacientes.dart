import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modelos/paciente.dart';
import '../provedores/provedores_dados.dart';
import 'tela_cadastro_paciente.dart';
import '../componentes/modal_detalhes_paciente.dart';

class TelaPacientes extends ConsumerWidget {
  const TelaPacientes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pacientes = ref.watch(provedorListaPacientes);
    final termoBusca = ref.watch(provedorBusca);
    final theme = Theme.of(context);

    final pacientesFiltrados = pacientes.where((p) {
      if (!p.estaAtivo) return false;
      if (termoBusca.isEmpty) return true;
      final termo = termoBusca.toLowerCase();
      return p.nome.toLowerCase().contains(termo) || p.cpf.contains(termo);
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Text(
                    'Meus Pacientes',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${pacientesFiltrados.length} ativos',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Buscador
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (valor) =>
                    ref.read(provedorBusca.notifier).definir(valor),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou CPF...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: termoBusca.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () =>
                              ref.read(provedorBusca.notifier).definir(''),
                        )
                      : null,
                ),
              ),
            ),

            // Lista de Pacientes
            Expanded(
              child: pacientesFiltrados.isEmpty
                  ? _construirEstadoVazio(theme)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: pacientesFiltrados.length,
                      itemBuilder: (context, index) {
                        final paciente = pacientesFiltrados[index];
                        return _construirCardPaciente(context, paciente);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TelaCadastroPaciente()),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
    );
  }

  Widget _construirEstadoVazio(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum paciente encontrado.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em "+" para cadastrar.',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _construirCardPaciente(BuildContext context, Paciente paciente) {
    final idade = paciente.calcularIdade();
    final iniciais = paciente.nome
        .split(' ')
        .map((n) => n.isNotEmpty ? n[0] : '')
        .take(2)
        .join();
    final cores = [
      const Color(0xFF00796B),
      const Color(0xFF5C6BC0),
      const Color(0xFFFF8F00),
      const Color(0xFFE91E63),
    ];
    final cor = cores[paciente.nome.length % cores.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => mostrarModalDetalhesPaciente(context, paciente),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: cor.withValues(alpha: 0.15),
                  child: Text(
                    iniciais.toUpperCase(),
                    style: TextStyle(
                      color: cor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paciente.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$idade anos  •  ${paciente.cpf}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
